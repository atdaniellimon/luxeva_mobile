import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../models/spei_details.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/copy_chip.dart';
import '../widgets/dynamic_notice.dart';
import '../widgets/glass_panel.dart';

class SpeiDepositScreen extends StatefulWidget {
  final UserSession user;

  const SpeiDepositScreen({super.key, required this.user});

  @override
  State<SpeiDepositScreen> createState() => _SpeiDepositScreenState();
}

class _SpeiDepositScreenState extends State<SpeiDepositScreen> {
  final TextEditingController _amountController = TextEditingController();
  SpeiInstructions? _instructions;
  bool _isLoadingInstructions = true;
  bool _isDepositing = false;

  @override
  void initState() {
    super.initState();
    _loadInstructions();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadInstructions() async {
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

  Future<void> _handleConfirmDeposit() async {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      _showAlert('Monto requerido', 'Ingresa una cantidad válida para depositar.');
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _isDepositing = true);

    try {
      final concept = _instructions?.concept ?? widget.user.accountNumber;

      await ApiService.instance.notifyAndApproveDeposit(
        accountNumber: widget.user.accountNumber,
        amount: amount,
        concept: concept,
      );

      await AuthService.instance.refreshBalance();
      HapticFeedback.heavyImpact();

      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Depósito acreditado', style: TextStyle(fontWeight: FontWeight.w700)),
            content: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Se abonaron \$${amount.toStringAsFixed(2)} MXN a tu cuenta con éxito.'),
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('Listo', style: TextStyle(color: LuxevaTheme.goldAccent, fontWeight: FontWeight.w600)),
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
      _showAlert('Error', e.toString().replaceAll('Exception: ', ''));
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
        middle: const Text(
          'Depositar fondos',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Transfer Instruction Card
                  GlassPanel(
                    hasGoldBorder: true,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: LuxevaTheme.goldAccent.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(CupertinoIcons.arrow_down_to_line, size: 20, color: LuxevaTheme.goldAccent),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Datos de Transferencia',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: LuxevaTheme.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Transfiere a estos datos desde cualquier banco',
                                    style: TextStyle(fontSize: 11, color: LuxevaTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // CLABE
                        _buildDataRow(
                          label: 'CLABE interbancaria',
                          value: instructions.formattedClabe,
                          copyValue: instructions.clabe.replaceAll(' ', ''),
                          isLarge: true,
                        ),
                        Container(
                          height: 0.5,
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          color: const Color(0x18FFFFFF),
                        ),

                        // Bank
                        _buildDataRow(
                          label: 'Banco receptor',
                          value: instructions.bankName,
                          copyValue: instructions.bankName,
                        ),
                        Container(
                          height: 0.5,
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          color: const Color(0x18FFFFFF),
                        ),

                        // Beneficiary
                        _buildDataRow(
                          label: 'Beneficiario',
                          value: instructions.beneficiary,
                          copyValue: instructions.beneficiary,
                        ),
                        Container(
                          height: 0.5,
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          color: const Color(0x18FFFFFF),
                        ),

                        // Concept
                        _buildDataRow(
                          label: 'Concepto (Tu cuenta)',
                          value: instructions.concept,
                          copyValue: instructions.concept,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick test deposit simulator
                  GlassPanel(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Acreditar Saldo',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: LuxevaTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Ingresa el monto que transferiste para registrar el abono',
                          style: TextStyle(fontSize: 12, color: LuxevaTheme.textSecondary),
                        ),
                        const SizedBox(height: 16),

                        // Amount Input
                        Container(
                          decoration: BoxDecoration(
                            color: LuxevaTheme.cardElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: LuxevaTheme.borderGold.withOpacity(0.35), width: 0.8),
                          ),
                          child: CupertinoTextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            placeholder: '0.00',
                            placeholderStyle: const TextStyle(color: LuxevaTheme.textMuted, fontSize: 24, fontWeight: FontWeight.w600),
                            prefix: const Padding(
                              padding: EdgeInsets.only(left: 14.0),
                              child: Text(
                                '\$',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: LuxevaTheme.goldAccent,
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                            decoration: null,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: LuxevaTheme.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Confirm Button
                        GestureDetector(
                          onTap: _isDepositing ? null : _handleConfirmDeposit,
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [LuxevaTheme.goldLight, LuxevaTheme.goldAccent, LuxevaTheme.goldDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: _isDepositing
                                  ? const CupertinoActivityIndicator(color: LuxevaTheme.obsidianBg)
                                  : const Text(
                                      'Acreditar Saldo',
                                      style: TextStyle(
                                        color: LuxevaTheme.obsidianBg,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDataRow({
    required String label,
    required String value,
    required String copyValue,
    bool isLarge = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: LuxevaTheme.textSecondary),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  fontSize: isLarge ? 16 : 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: isLarge ? 'Courier' : null,
                  color: isLarge ? LuxevaTheme.goldLight : LuxevaTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        CopyChip(textToCopy: copyValue),
      ],
    );
  }
}
