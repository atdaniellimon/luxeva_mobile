import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
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
      _showAlert('Datos Incompletos', 'Ingrese la CLABE interbancaria o titular de destino.');
      return;
    }

    if (amount == null || amount <= 0) {
      _showAlert('Importe Inválido', 'Ingrese un importe válido para la transferencia.');
      return;
    }

    if (amount > widget.user.balance) {
      _showAlert('Fondos Insuficientes', 'El importe excede su patrimonio líquido disponible.');
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _isSending = true);

    try {
      await ApiService.instance.sendTransfer(
        accountNumber: widget.user.accountNumber,
        to: to,
        amount: amount,
        concept: concept.isNotEmpty ? concept : 'Transferencia SPEI',
      );

      await AuthService.instance.refreshBalance();
      HapticFeedback.heavyImpact();

      if (mounted) {
        _showAlert(
          'Instrucción SPEI Ejecutada',
          'Se ha liquidado la transferencia de \$${amount.toStringAsFixed(2)} MXN a $to con éxito.',
          popOnSuccess: true,
        );
      }
    } catch (e) {
      _showAlert('Error de Liquidación', e.toString().replaceAll('Exception: ', ''));
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
        middle: const Text('DISPERSIÓN DE CAPITAL', style: TextStyle(letterSpacing: 1.5, fontSize: 13)),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.chevron_left, color: LuxevaTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Available Balance Reminder
            Center(
              child: Column(
                children: [
                  const Text(
                    'PATRIMONIO DISPONIBLE PARA DISPERSIÓN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: LuxevaTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.user.formattedBalance,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: LuxevaTheme.goldLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            GlassPanel(
              hasGoldBorder: true,
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BENEFICIARIO O CLABE (18 DÍGITOS)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: LuxevaTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _toController,
                    placeholder: '7289... / Nombre del Beneficiario',
                    placeholderStyle: const TextStyle(color: LuxevaTheme.textMuted, fontSize: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: const Color(0x10FFFFFF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: LuxevaTheme.borderSubtle),
                    ),
                    style: const TextStyle(color: LuxevaTheme.textPrimary, fontSize: 15),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'IMPORTE A TRANSFERIR (MXN)',
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
                        style: TextStyle(fontSize: 18, color: LuxevaTheme.goldAccent, fontWeight: FontWeight.w600),
                      ),
                    ),
                    placeholder: '0.00',
                    placeholderStyle: const TextStyle(color: LuxevaTheme.textMuted, fontSize: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
                    decoration: BoxDecoration(
                      color: const Color(0x10FFFFFF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: LuxevaTheme.borderSubtle),
                    ),
                    style: const TextStyle(color: LuxevaTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'CONCEPTO DE OPERACIÓN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: LuxevaTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _conceptController,
                    placeholder: 'Referencia de dispersión',
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

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: CupertinoButton(
                      color: LuxevaTheme.goldAccent,
                      borderRadius: BorderRadius.circular(14),
                      onPressed: _isSending ? null : _handleSendTransfer,
                      child: _isSending
                          ? const CupertinoActivityIndicator(color: LuxevaTheme.obsidianBg)
                          : const Text(
                              'Ejecutar Instrucción SPEI',
                              style: TextStyle(
                                color: LuxevaTheme.obsidianBg,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
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
