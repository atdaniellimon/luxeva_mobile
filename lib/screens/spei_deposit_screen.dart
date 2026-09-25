import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../models/spei_details.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/copy_chip.dart';
import '../widgets/glass_panel.dart';

class SpeiDepositScreen extends StatefulWidget {
  final UserSession user;

  const SpeiDepositScreen({super.key, required this.user});

  @override
  State<SpeiDepositScreen> createState() => _SpeiDepositScreenState();
}

class _SpeiDepositScreenState extends State<SpeiDepositScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _trackingController = TextEditingController();
  SpeiInstructions? _instructions;
  bool _isLoadingInstructions = true;
  bool _isDepositing = false;

  @override
  void initState() {
    super.initState();
    _loadSpeiInstructions();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _trackingController.dispose();
    super.dispose();
  }

  Future<void> _loadSpeiInstructions() async {
    try {
      final data = await ApiService.instance.getSpeiInstructions(widget.user.accountNumber);
      if (mounted) {
        setState(() {
          _instructions = data;
          _isLoadingInstructions = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingInstructions = false);
    }
  }

  void _setQuickAmount(double amt) {
    HapticFeedback.selectionClick();
    _amountController.text = amt.toStringAsFixed(2);
  }

  Future<void> _handleConfirmDeposit() async {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      _showAlert('Importe Inválido', 'Ingrese un importe válido para la acreditación.');
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _isDepositing = true);

    try {
      final concept = _instructions?.concept ?? widget.user.accountNumber;
      final tracking = _trackingController.text.trim();

      await ApiService.instance.notifyAndApproveDeposit(
        accountNumber: widget.user.accountNumber,
        amount: amount,
        concept: concept,
        trackingKey: tracking.isNotEmpty ? tracking : null,
      );

      await AuthService.instance.refreshBalance();
      HapticFeedback.heavyImpact();

      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Acreditación Exitosa', style: TextStyle(fontWeight: FontWeight.w700)),
            content: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Se han acreditado \$${amount.toStringAsFixed(2)} MXN a su cuenta patrimonial.'),
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('Aceptar', style: TextStyle(color: LuxevaTheme.goldAccent)),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _showAlert('Error de Acreditación', e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isDepositing = false);
    }
  }

  void _showAlert(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(message),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Entendido', style: TextStyle(color: LuxevaTheme.goldAccent)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final instructions = _instructions ??
        SpeiInstructions(
          bankName: 'Spin by OXXO',
          clabe: '728969000044989306',
          beneficiary: 'Luxeva',
          concept: widget.user.accountNumber,
          accountNumber: widget.user.accountNumber,
        );

    return CupertinoPageScaffold(
      backgroundColor: LuxevaTheme.obsidianBg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: LuxevaTheme.glassBg,
        middle: const Text('ACREDITACIÓN DE CAPITAL', style: TextStyle(letterSpacing: 1.5, fontSize: 13)),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.chevron_left, color: LuxevaTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      child: SafeArea(
        child: _isLoadingInstructions
            ? const Center(child: CupertinoActivityIndicator(color: LuxevaTheme.goldAccent))
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Subtitle info
                  const Center(
                    child: Text(
                      'CÁMARA DE COMPENSACIÓN SPEI · BANCO DE MÉXICO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                        color: LuxevaTheme.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // SPEI Card Panel
                  GlassPanel(
                    hasGoldBorder: true,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'LUXEVA PRIVATE BANKING',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.0,
                                color: LuxevaTheme.goldAccent,
                              ),
                            ),
                            Text(
                              'LIQUIDACIÓN MXN',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                                color: LuxevaTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Bank Receptor
                        _buildDetailItem(
                          label: 'INSTITUCIÓN BANCARIA RECEPTORA',
                          value: instructions.bankName,
                        ),
                        const SizedBox(height: 12),

                        // CLABE
                        _buildDetailItem(
                          label: 'CLABE INTERBANCARIA INSTITUCIONAL',
                          value: instructions.formattedClabe,
                          copyText: instructions.clabe.replaceAll(' ', ''),
                          isHighlighted: true,
                        ),
                        const SizedBox(height: 12),

                        // Beneficiary
                        _buildDetailItem(
                          label: 'BENEFICIARIO ACREDITADO',
                          value: instructions.beneficiary,
                          copyText: instructions.beneficiary,
                        ),
                        const SizedBox(height: 12),

                        // Concept
                        _buildDetailItem(
                          label: 'CONCEPTO / FOLIO DE OPERACIÓN',
                          value: instructions.concept,
                          copyText: instructions.concept,
                          isHighlighted: true,
                          note: 'Folio exclusivo para acreditación inmediata en su cuenta patrimonial.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Free Amount Input & Quick Pills
                  const Text(
                    'IMPORTE A FONDEAR (MXN)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: LuxevaTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 14.0),
                      child: Text(
                        '\$',
                        style: TextStyle(fontSize: 20, color: LuxevaTheme.goldAccent, fontWeight: FontWeight.w600),
                      ),
                    ),
                    placeholder: '0.00',
                    placeholderStyle: const TextStyle(color: LuxevaTheme.textMuted, fontSize: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0x10FFFFFF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: LuxevaTheme.borderGold),
                    ),
                    style: const TextStyle(
                      color: LuxevaTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Quick Pills
                  Row(
                    children: [
                      _buildQuickPill(100),
                      const SizedBox(width: 8),
                      _buildQuickPill(250),
                      const SizedBox(width: 8),
                      _buildQuickPill(500),
                      const SizedBox(width: 8),
                      _buildQuickPill(1000),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Banxico Tracking Key
                  const Text(
                    'CLAVE DE RASTREO BANXICO (OPCIONAL)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: LuxevaTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _trackingController,
                    placeholder: 'Folio numérico o alfanumérico SPEI',
                    placeholderStyle: const TextStyle(color: LuxevaTheme.textMuted, fontSize: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: const Color(0x10FFFFFF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: LuxevaTheme.borderSubtle),
                    ),
                    style: const TextStyle(color: LuxevaTheme.textPrimary, fontSize: 14),
                  ),
                  const SizedBox(height: 30),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: CupertinoButton(
                      color: LuxevaTheme.goldAccent,
                      borderRadius: BorderRadius.circular(14),
                      onPressed: _isDepositing ? null : _handleConfirmDeposit,
                      child: _isDepositing
                          ? const CupertinoActivityIndicator(color: LuxevaTheme.obsidianBg)
                          : const Text(
                              'Instruir Acreditación Inmediata',
                              style: TextStyle(
                                color: LuxevaTheme.obsidianBg,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
      ),
    );
  }

  Widget _buildDetailItem({
    required String label,
    required String value,
    String? copyText,
    bool isHighlighted = false,
    String? note,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: LuxevaTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0x0CFFFFFF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0x10FFFFFF)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontFamily: isHighlighted ? 'Courier' : null,
                    fontSize: isHighlighted ? 14 : 13,
                    fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: isHighlighted ? 0.8 : 0.2,
                    color: isHighlighted ? LuxevaTheme.goldLight : LuxevaTheme.textPrimary,
                  ),
                ),
              ),
              if (copyText != null) CopyChip(textToCopy: copyText),
            ],
          ),
        ),
        if (note != null) ...[
          const SizedBox(height: 4),
          Text(
            note,
            style: const TextStyle(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: LuxevaTheme.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuickPill(double amount) {
    return Expanded(
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: const Color(0x12CBBD93),
        borderRadius: BorderRadius.circular(10),
        onPressed: () => _setQuickAmount(amount),
        child: Text(
          '\$${amount.toInt()}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: LuxevaTheme.goldAccent,
          ),
        ),
      ),
    );
  }
}
