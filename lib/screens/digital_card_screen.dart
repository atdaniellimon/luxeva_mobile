import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../models/user.dart';
import '../services/biometric_service.dart';
import '../services/luxeva_card_generator.dart';
import '../services/notification_service.dart';
import '../widgets/dynamic_notice.dart';
import '../widgets/luxury_card.dart';

class DigitalCardScreen extends StatefulWidget {
  final UserSession user;

  const DigitalCardScreen({
    super.key,
    required this.user,
  });

  @override
  State<DigitalCardScreen> createState() => _DigitalCardScreenState();
}

class _DigitalCardScreenState extends State<DigitalCardScreen> {
  late Future<LuxevaCardDetails> _cardFuture;
  bool _showSensitive = false;
  bool _isFrozen = false;
  String _currentPin = '4829';

  @override
  void initState() {
    super.initState();
    _loadCard();
  }

  void _loadCard() {
    _cardFuture = LuxevaCardGenerator.getCardForUser(widget.user).then((card) {
      if (mounted) {
        setState(() {
          _isFrozen = card.isFrozen;
          _currentPin = card.pin;
        });
      }
      return card;
    });
  }

  Future<void> _handleToggleReveal() async {
    HapticFeedback.lightImpact();
    if (!_showSensitive) {
      // Authenticate with Face ID / PIN
      final authenticated = await BiometricService.instance.authenticate(
        reason: 'Verifica tu identidad para revelar los datos de tu tarjeta',
      );
      if (authenticated) {
        if (mounted) setState(() => _showSensitive = true);
        HapticFeedback.mediumImpact();
      }
    } else {
      setState(() => _showSensitive = false);
    }
  }

  Future<void> _toggleFreeze(bool val) async {
    HapticFeedback.selectionClick();
    setState(() => _isFrozen = val);
    await LuxevaCardGenerator.setCardFrozen(widget.user.accountNumber, val);
    
    NotificationService.instance.addNotification(
      title: val ? 'Tarjeta Pausada' : 'Tarjeta Reactivada',
      message: val ? 'Se bloquearon transacciones en terminales y compras.' : 'Tarjeta lista para operar con normalidad.',
      type: 'card',
    );

    if (mounted) {
      DynamicNotice.show(
        context,
        message: val ? 'Tarjeta pausada' : 'Tarjeta activa',
        subtitle: val ? 'Operaciones bloqueadas preventivamente' : 'Lista para compras y cargos',
        icon: val ? CupertinoIcons.lock_fill : CupertinoIcons.lock_open_fill,
      );
    }
  }

  void _promptChangePin() {
    final controller = TextEditingController();
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('PIN de Tarjeta Física', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Column(
            children: [
              const Text('Ingresa el nuevo PIN de 4 dígitos para tu tarjeta física Luxeva:'),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: controller,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.bold),
                placeholder: '••••',
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancelar', style: TextStyle(color: LuxevaTheme.textSecondary)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          CupertinoDialogAction(
            child: const Text('Guardar', style: TextStyle(color: LuxevaTheme.goldAccent, fontWeight: FontWeight.w600)),
            onPressed: () async {
              final newPin = controller.text.trim();
              if (newPin.length == 4) {
                Navigator.of(ctx).pop();
                setState(() => _currentPin = newPin);
                await LuxevaCardGenerator.setCardPin(widget.user.accountNumber, newPin);
                NotificationService.instance.addNotification(
                  title: 'PIN de Tarjeta Modificado',
                  message: 'Se actualizó la clave de 4 dígitos de tu tarjeta física.',
                  type: 'security',
                );
                if (mounted) {
                  DynamicNotice.show(
                    context,
                    message: 'PIN actualizado con éxito',
                    icon: CupertinoIcons.checkmark_shield_fill,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  String _assignedLimitString() {
    final t = widget.user.tier.toLowerCase();
    if (t == 'zenith') return 'Sin límite preestablecido / Dinámico';
    if (t == 'tungsten') return '\$50,000.00 MXN / día';
    return '\$15,000.00 MXN / día';
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: LuxevaTheme.obsidianBg,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: LuxevaTheme.glassBg,
        border: Border(
          bottom: BorderSide(
            color: LuxevaTheme.borderSubtle,
            width: LuxevaTheme.hairline,
          ),
        ),
        middle: Text(
          'TARJETA',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: LuxevaTheme.textPrimary,
          ),
        ),
      ),
      child: SafeArea(
        child: FutureBuilder<LuxevaCardDetails>(
          future: _cardFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CupertinoActivityIndicator(color: LuxevaTheme.goldAccent));
            }

            final card = snapshot.data!;

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // 1. Titanium Physical & Digital Card
                LuxuryCardWidget(
                  user: widget.user,
                  customCardNumber: card.cardNumber,
                  cvv: card.cvv,
                  showSensitive: _showSensitive,
                  isFrozen: _isFrozen,
                ),
                const SizedBox(height: 16),

                // 2. Sensitive Data Reveal Pill
                Center(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    color: LuxevaTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    onPressed: _handleToggleReveal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _showSensitive ? CupertinoIcons.eye_slash_fill : CupertinoIcons.eye_fill,
                          size: 15,
                          color: LuxevaTheme.goldAccent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _showSensitive ? 'Ocultar Datos Sensibles' : 'Ver Número y CVV',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                            color: LuxevaTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // 3. Card Security & Governance (Apple Wallet Grouped Inset)
                const Text(
                  'GESTIÓN DEL INSTRUMENTO',
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
                      // Pausar Tarjeta
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Pausar Tarjeta',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LuxevaTheme.textPrimary),
                            ),
                            CupertinoSwitch(
                              value: _isFrozen,
                              activeColor: LuxevaTheme.redNegative,
                              onChanged: _toggleFreeze,
                            ),
                          ],
                        ),
                      ),
                      Container(height: LuxevaTheme.hairline, color: LuxevaTheme.dividerColor),

                      // PIN
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'PIN de Tarjeta',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LuxevaTheme.textPrimary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _showSensitive ? 'PIN: $_currentPin' : 'PIN: ••••',
                                  style: LuxevaTheme.tabularFigures(
                                    fontSize: 12,
                                    fontFamily: 'Courier',
                                    color: LuxevaTheme.goldAccent,
                                  ),
                                ),
                              ],
                            ),
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              color: const Color(0x18CBBD93),
                              borderRadius: BorderRadius.circular(8),
                              onPressed: _promptChangePin,
                              child: const Text(
                                'Modificar',
                                style: TextStyle(fontSize: 12, color: LuxevaTheme.goldLight, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(height: LuxevaTheme.hairline, color: LuxevaTheme.dividerColor),

                      // Límite Diario
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Límite Diario',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LuxevaTheme.textPrimary),
                            ),
                            Text(
                              _assignedLimitString(),
                              style: LuxevaTheme.tabularFigures(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: LuxevaTheme.goldLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }
}
