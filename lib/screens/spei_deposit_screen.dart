import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../models/spei_details.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../widgets/dynamic_notice.dart';

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

  void _copyToClipboard(String text, String label) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: text));
    DynamicNotice.show(
      context,
      message: '$label copiado al portapapeles',
      icon: CupertinoIcons.doc_on_doc_fill,
    );
  }

  Future<void> _handleConfirmDeposit() async {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      DynamicNotice.show(
        context,
        message: 'Monto requerido',
        subtitle: 'Ingresa una cantidad válida para fondear tu cuenta',
        icon: CupertinoIcons.exclamationmark_circle,
      );
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

      // Register notification
      NotificationService.instance.addNotification(
        title: 'Depósito SPEI Acreditado',
        message: '+\$${amount.toStringAsFixed(2)} MXN acreditado vía Banxico / STP.',
        type: 'deposit',
      );

      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Depósito Acreditado', style: TextStyle(fontWeight: FontWeight.w700)),
            content: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Se abonaron \$${amount.toStringAsFixed(2)} MXN a tu bóveda con éxito.'),
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
      DynamicNotice.show(
        context,
        message: 'Error de Fondeo',
        subtitle: e.toString().replaceAll('Exception: ', ''),
        icon: CupertinoIcons.xmark_circle,
      );
    } finally {
      if (mounted) setState(() => _isDepositing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final instructions = _instructions ??
        SpeiInstructions(
          bankName: 'Spin by OXXO / STP',
          clabe: '728969000044989306',
          beneficiary: 'Luxeva',
          concept: widget.user.accountNumber,
          accountNumber: widget.user.accountNumber,
        );

    final clabeFormatted = instructions.clabe.length == 18
        ? '${instructions.clabe.substring(0, 4)}  ${instructions.clabe.substring(4, 8)}  ${instructions.clabe.substring(8, 14)}  ${instructions.clabe.substring(14, 18)}'
        : instructions.clabe;

    return CupertinoPageScaffold(
      backgroundColor: LuxevaTheme.obsidianBg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: LuxevaTheme.glassBg,
        border: const Border(
          bottom: BorderSide(
            color: LuxevaTheme.borderSubtle,
            width: LuxevaTheme.hairline,
          ),
        ),
        middle: const Text(
          'DEPOSITAR FONDOS',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: LuxevaTheme.textPrimary,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.chevron_left, color: LuxevaTheme.textPrimary, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      child: SafeArea(
        child: _isLoadingInstructions
            ? const Center(child: CupertinoActivityIndicator(color: LuxevaTheme.goldAccent))
            : ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                children: [
                  // 1. Institutional Bank Transfer Slip
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: LuxevaTheme.surfaceLayer,
                      borderRadius: BorderRadius.circular(LuxevaTheme.radiusStandard),
                      border: Border.all(color: LuxevaTheme.borderGold, width: LuxevaTheme.hairline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'FICHA BANCARIA SPEI',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: LuxevaTheme.textSecondary),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: LuxevaTheme.greenPositive.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'LIQUIDACIÓN 24/7',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: LuxevaTheme.greenPositive),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // CLABE hero with 1-tap copy
                        const Text(
                          'CLABE INTERBANCARIA',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: LuxevaTheme.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => _copyToClipboard(instructions.clabe, 'CLABE Interbancaria'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: LuxevaTheme.surfaceElevated,
                              borderRadius: BorderRadius.circular(LuxevaTheme.radiusCompact),
                              border: Border.all(color: LuxevaTheme.borderSubtle, width: LuxevaTheme.hairline),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  clabeFormatted,
                                  style: LuxevaTheme.tabularFigures(
                                    fontSize: 15,
                                    fontFamily: 'Courier',
                                    fontWeight: FontWeight.w700,
                                    color: LuxevaTheme.goldLight,
                                  ),
                                ),
                                const Icon(CupertinoIcons.doc_on_doc, size: 16, color: LuxevaTheme.goldAccent),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        _DetailRow(
                          label: 'Banco Receptor',
                          value: instructions.bankName,
                          onCopy: () => _copyToClipboard(instructions.bankName, 'Banco'),
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(
                          label: 'Beneficiario',
                          value: instructions.beneficiary,
                          onCopy: () => _copyToClipboard(instructions.beneficiary, 'Beneficiario'),
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(
                          label: 'Concepto / Referencia',
                          value: instructions.concept,
                          onCopy: () => _copyToClipboard(instructions.concept, 'Concepto'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 2. Direct Deposit Simulator / Verification
                  const Text(
                    'NOTIFICAR O ACREDITAR DEPÓSITO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: LuxevaTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: LuxevaTheme.surfaceLayer,
                      borderRadius: BorderRadius.circular(LuxevaTheme.radiusStandard),
                      border: Border.all(color: LuxevaTheme.borderSubtle, width: LuxevaTheme.hairline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Si ya realizaste la transferencia desde tu banca electrónica, ingresa el monto transferido para validación y acreditación inmediata:',
                          style: TextStyle(fontSize: 12, color: LuxevaTheme.textSecondary, height: 1.4),
                        ),
                        const SizedBox(height: 14),

                        CupertinoTextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          placeholder: 'Monto depositado en MXN (ej. 5000)',
                          placeholderStyle: const TextStyle(color: LuxevaTheme.textMuted, fontSize: 13),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          style: LuxevaTheme.tabularFigures(fontSize: 15, color: LuxevaTheme.textPrimary),
                          decoration: BoxDecoration(
                            color: LuxevaTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(LuxevaTheme.radiusCompact),
                            border: Border.all(color: LuxevaTheme.borderSubtle, width: LuxevaTheme.hairline),
                          ),
                        ),
                        const SizedBox(height: 16),

                        CupertinoButton(
                          color: LuxevaTheme.goldAccent,
                          borderRadius: BorderRadius.circular(LuxevaTheme.radiusStandard),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          onPressed: _isDepositing ? null : _handleConfirmDeposit,
                          child: Center(
                            child: _isDepositing
                                ? const CupertinoActivityIndicator(color: LuxevaTheme.obsidianBg)
                                : const Text(
                                    'Verificar y Abonar Fondos',
                                    style: TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: LuxevaTheme.obsidianBg,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onCopy;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: LuxevaTheme.textSecondary)),
        GestureDetector(
          onTap: onCopy,
          child: Row(
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: LuxevaTheme.textPrimary),
              ),
              const SizedBox(width: 6),
              const Icon(CupertinoIcons.doc_on_doc, size: 12, color: LuxevaTheme.textMuted),
            ],
          ),
        ),
      ],
    );
  }
}
