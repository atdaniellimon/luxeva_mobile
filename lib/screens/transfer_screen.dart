import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/developer_service.dart';
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
              child: Text('Se enviaron \$${amount.toStringAsFixed(2)} MXN a $to exitosamente.'),
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
    final isDev = DeveloperService.instance.isDeveloperMode.value;

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
          'TRANSFERIR',
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
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          children: [
            // Available Balance Header (Apple HIG Optical typography)
            Center(
              child: Column(
                children: [
                  const Text(
                    'SALDO DISPONIBLE PARA TRANSFERIR',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                      color: LuxevaTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.user.formattedBalance,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: LuxevaTheme.goldLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sandbox Member Quick Chips
            if (isDev) ...[
              const Text(
                'DESTINATARIOS SANDBOX (CONEXIÓN DIRECTA)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: LuxevaTheme.amberSandbox,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: DeveloperService.sandboxMembers
                      .where((m) => m.accountNumber != widget.user.accountNumber)
                      .map((member) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _toController.text = member.accountNumber;
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0x18FF9F0A),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0x50FF9F0A), width: 0.5),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(CupertinoIcons.person_fill, size: 12, color: LuxevaTheme.amberSandbox),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${member.fullName} (${member.accountNumber})',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: LuxevaTheme.amberSandbox,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 18),
            ],

            // Transfer Form Group
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: LuxevaTheme.surfaceLayer,
                borderRadius: BorderRadius.circular(LuxevaTheme.continuousRadius),
                border: Border.all(color: LuxevaTheme.borderSubtle, width: LuxevaTheme.hairline),
              ),
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
                      color: LuxevaTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: LuxevaTheme.borderSubtle, width: LuxevaTheme.hairline),
                    ),
                    child: CupertinoTextField(
                      controller: _toController,
                      placeholder: 'CLABE (18 dígitos) o Cuenta Luxeva',
                      placeholderStyle: const TextStyle(color: LuxevaTheme.textMuted, fontSize: 13),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 14),
                        child: Icon(CupertinoIcons.creditcard, size: 18, color: LuxevaTheme.goldAccent),
                      ),
                      decoration: null,
                      style: const TextStyle(color: LuxevaTheme.textPrimary, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 20),

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
                      color: LuxevaTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: LuxevaTheme.borderSubtle, width: LuxevaTheme.hairline),
                    ),
                    child: CupertinoTextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Text(
                          '\$',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 22,
                            color: LuxevaTheme.goldAccent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      placeholder: '0.00',
                      placeholderStyle: const TextStyle(color: LuxevaTheme.textMuted, fontSize: 22),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                      decoration: null,
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        color: LuxevaTheme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

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
                      color: LuxevaTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: LuxevaTheme.borderSubtle, width: LuxevaTheme.hairline),
                    ),
                    child: CupertinoTextField(
                      controller: _conceptController,
                      placeholder: 'Ej. Gastos de representación, membresía...',
                      placeholderStyle: const TextStyle(color: LuxevaTheme.textMuted, fontSize: 13),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 14),
                        child: Icon(CupertinoIcons.text_quote, size: 18, color: LuxevaTheme.goldAccent),
                      ),
                      decoration: null,
                      style: const TextStyle(color: LuxevaTheme.textPrimary, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Send Transfer Button (Apple HIG Primary Control)
                  GestureDetector(
                    onTap: _isSending ? null : _handleSendTransfer,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [LuxevaTheme.goldLight, LuxevaTheme.goldAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isSending
                            ? const CupertinoActivityIndicator(color: LuxevaTheme.obsidianBg)
                            : const Text(
                                'Enviar Transferencia',
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
}
