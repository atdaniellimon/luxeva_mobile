import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/dynamic_notice.dart';
import '../widgets/glass_panel.dart';

class TransferScreen extends StatefulWidget {
  final UserSession user;

  const TransferScreen({super.key, required this.user});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _conceptController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _toController.dispose();
    _amountController.dispose();
    _conceptController.dispose();
    super.dispose();
  }

  void _showAlert(String title, String message, {bool popOnSuccess = false}) {
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
            onPressed: () {
              Navigator.of(ctx).pop();
              if (popOnSuccess) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleSendTransfer() async {
    final to = _toController.text.trim();
    final amountText = _amountController.text.trim();
    final concept = _conceptController.text.trim();
    final amount = double.tryParse(amountText);

    if (to.isEmpty) {
      _showAlert('Datos incompletos', 'Ingresa la CLABE o número de cuenta de destino.');
      return;
    }

    if (amount == null || amount <= 0) {
      _showAlert('Monto inválido', 'Ingresa una cantidad válida para transferir.');
      return;
    }

    if (amount > widget.user.balance) {
      _showAlert('Saldo insuficiente', 'El monto supera tu saldo disponible en cuenta.');
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _isSending = true);

    try {
      await ApiService.instance.sendTransfer(
        accountNumber: widget.user.accountNumber,
        to: to,
        amount: amount,
        concept: concept.isNotEmpty ? concept : 'Transferencia',
      );

      await AuthService.instance.refreshBalance();
      HapticFeedback.heavyImpact();

      if (mounted) {
        DynamicNotice.show(
          context,
          message: 'Transferencia enviada',
          subtitle: '-\$${amount.toStringAsFixed(2)} MXN a $to',
          icon: CupertinoIcons.arrow_up_right,
        );

        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Transferencia Enviada', style: TextStyle(fontWeight: FontWeight.w700)),
            content: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Se enviaron \$${amount.toStringAsFixed(2)} MXN a $to.'),
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
      _showAlert('Error al transferir', e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: LuxevaTheme.obsidianBg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: LuxevaTheme.glassBg,
        middle: const Text('Transferir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.chevron_left, color: LuxevaTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Available Balance Card
            GlassPanel(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Saldo disponible',
                    style: TextStyle(fontSize: 13, color: LuxevaTheme.textSecondary),
                  ),
                  Text(
                    widget.user.formattedBalance,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: LuxevaTheme.goldLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            GlassPanel(
              hasGoldBorder: true,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DESTINATARIO (CLABE O CUENTA)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: LuxevaTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: LuxevaTheme.cardElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: LuxevaTheme.borderGold.withOpacity(0.35), width: 0.8),
                    ),
                    child: CupertinoTextField(
                      controller: _toController,
                      placeholder: 'CLABE interbancaria (18 dígitos)',
                      placeholderStyle: const TextStyle(color: LuxevaTheme.textMuted, fontSize: 14),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 14),
                        child: Icon(CupertinoIcons.creditcard, size: 18, color: LuxevaTheme.goldAccent),
                      ),
                      decoration: null,
                      style: const TextStyle(color: LuxevaTheme.textPrimary, fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    'MONTO A TRANSFERIR (MXN)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: LuxevaTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: LuxevaTheme.cardElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: LuxevaTheme.borderGold.withOpacity(0.35), width: 0.8),
                    ),
                    child: CupertinoTextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 14.0),
                        child: Text(
                          '\$',
                          style: TextStyle(fontSize: 20, color: LuxevaTheme.goldAccent, fontWeight: FontWeight.w700),
                        ),
                      ),
                      placeholder: '0.00',
                      placeholderStyle: const TextStyle(color: LuxevaTheme.textMuted, fontSize: 18),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                      decoration: null,
                      style: const TextStyle(color: LuxevaTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    'CONCEPTO (OPCIONAL)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: LuxevaTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: LuxevaTheme.cardElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: LuxevaTheme.borderGold.withOpacity(0.35), width: 0.8),
                    ),
                    child: CupertinoTextField(
                      controller: _conceptController,
                      placeholder: 'Ej. Renta, comida, servicio...',
                      placeholderStyle: const TextStyle(color: LuxevaTheme.textMuted, fontSize: 14),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 14),
                        child: Icon(CupertinoIcons.text_quote, size: 18, color: LuxevaTheme.goldAccent),
                      ),
                      decoration: null,
                      style: const TextStyle(color: LuxevaTheme.textPrimary, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 26),

                  GestureDetector(
                    onTap: _isSending ? null : _handleSendTransfer,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [LuxevaTheme.goldLight, LuxevaTheme.goldAccent, LuxevaTheme.goldDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: _isSending
                            ? const CupertinoActivityIndicator(color: LuxevaTheme.obsidianBg)
                            : const Text(
                                'Enviar Transferencia',
                                style: TextStyle(
                                  color: LuxevaTheme.obsidianBg,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
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
}
