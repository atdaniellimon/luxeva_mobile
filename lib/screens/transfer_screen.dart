import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/developer_service.dart';
import '../services/notification_service.dart';
import '../widgets/dynamic_notice.dart';

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
      _showAlert('Destinatario requerido', 'Ingresa la CLABE (18 dígitos) o cuenta Luxeva.');
      return;
    }

    if (amount == null || amount <= 0) {
      _showAlert('Monto requerido', 'Ingresa una cantidad válida para transferir.');
      return;
    }

    if (amount > widget.user.balance) {
      _showAlert('Saldo insuficiente', 'El monto supera el saldo disponible en tu bóveda.');
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _isSending = true);

    try {
      await ApiService.instance.sendTransfer(
        accountNumber: widget.user.accountNumber,
        to: to,
        amount: amount,
        concept: concept.isNotEmpty ? concept : 'Transferencia Luxeva',
      );

      await AuthService.instance.refreshBalance();
      HapticFeedback.heavyImpact();

      // Register in offline notifications
      NotificationService.instance.addNotification(
        title: 'Transferencia Enviada',
        message: '-\$${amount.toStringAsFixed(2)} MXN enviado a $to.',
        type: 'transfer',
      );

      if (mounted) {
        DynamicNotice.show(
          context,
          message: 'Transferencia liquidada con éxito',
          subtitle: '-\$${amount.toStringAsFixed(2)} MXN a $to',
          icon: CupertinoIcons.arrow_up_right,
        );

        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Transferencia Liquidada', style: TextStyle(fontWeight: FontWeight.w700)),
            content: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Se transfirieron \$${amount.toStringAsFixed(2)} MXN a $to mediante liquidación STP inmediata.'),
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
      _showAlert('Error de Liquidación', e.toString().replaceAll('Exception: ', ''));
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: [
            // 1. Hero Amount Input (Apple Cash Style)
            Center(
              child: Column(
                children: [
                  const Text(
                    'SALDO DISPONIBLE',
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
                    style: LuxevaTheme.tabularFigures(
                      fontFamily: 'Georgia',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: LuxevaTheme.goldLight,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Large Minimal Amount Field
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text(
                        '\$',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: LuxevaTheme.goldAccent,
                        ),
                      ),
                      const SizedBox(width: 4),
                      IntrinsicWidth(
                        child: CupertinoTextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          autofocus: true,
                          textAlign: TextAlign.center,
                          placeholder: '0.00',
                          placeholderStyle: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 44,
                            fontWeight: FontWeight.w700,
                            color: LuxevaTheme.textMuted,
                          ),
                          style: LuxevaTheme.tabularFigures(
                            fontFamily: 'Georgia',
                            fontSize: 44,
                            fontWeight: FontWeight.w700,
                            color: LuxevaTheme.textPrimary,
                          ),
                          decoration: null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 2. Sandbox Contacts (Quiet Luxury Chips)
            if (isDev) ...[
              const Text(
                'DESTINATARIOS FRECUENTES (SANDBOX)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: LuxevaTheme.amberSandbox,
                ),
              ),
              const SizedBox(height: 10),
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
                                HapticFeedback.selectionClick();
                                _toController.text = member.accountNumber;
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: LuxevaTheme.surfaceElevated,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: LuxevaTheme.borderSubtle, width: LuxevaTheme.hairline),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: LuxevaTheme.amberSandbox.withOpacity(0.18),
                                      ),
                                      child: const Center(
                                        child: Icon(CupertinoIcons.person_fill, size: 10, color: LuxevaTheme.amberSandbox),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      member.fullName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: LuxevaTheme.textPrimary,
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
              const SizedBox(height: 24),
            ],

            // 3. Form Grouped Inset
            const Text(
              'DATOS DEL DESTINATARIO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: LuxevaTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: LuxevaTheme.surfaceLayer,
                borderRadius: BorderRadius.circular(LuxevaTheme.radiusStandard),
                border: Border.all(color: LuxevaTheme.borderSubtle, width: LuxevaTheme.hairline),
              ),
              child: Column(
                children: [
                  CupertinoTextField(
                    controller: _toController,
                    placeholder: 'CLABE (18 dígitos) o Cuenta Luxeva (LX-...)',
                    placeholderStyle: const TextStyle(color: LuxevaTheme.textMuted, fontSize: 13),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Icon(CupertinoIcons.person_crop_circle, size: 20, color: LuxevaTheme.goldAccent),
                    ),
                    style: const TextStyle(fontSize: 14, color: LuxevaTheme.textPrimary),
                    decoration: null,
                  ),
                  Container(height: LuxevaTheme.hairline, color: LuxevaTheme.dividerColor),
                  CupertinoTextField(
                    controller: _conceptController,
                    placeholder: 'Concepto de pago (Opcional)',
                    placeholderStyle: const TextStyle(color: LuxevaTheme.textMuted, fontSize: 13),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Icon(CupertinoIcons.text_quote, size: 20, color: LuxevaTheme.textSecondary),
                    ),
                    style: const TextStyle(fontSize: 14, color: LuxevaTheme.textPrimary),
                    decoration: null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // 4. Primary Send Button
            CupertinoButton(
              color: LuxevaTheme.goldAccent,
              borderRadius: BorderRadius.circular(LuxevaTheme.radiusStandard),
              padding: const EdgeInsets.symmetric(vertical: 14),
              onPressed: _isSending ? null : _handleSendTransfer,
              child: _isSending
                  ? const CupertinoActivityIndicator(color: LuxevaTheme.obsidianBg)
                  : const Text(
                      'Confirmar Transferencia',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: LuxevaTheme.obsidianBg,
                      ),
                    ),
            ),
            const SizedBox(height: 14),

            const Center(
              child: Text(
                'Liquidación inmediata vía Sistema de Pagos Electrónicos Interbancarios (SPEI).',
                style: TextStyle(fontSize: 11, color: LuxevaTheme.textMuted),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
