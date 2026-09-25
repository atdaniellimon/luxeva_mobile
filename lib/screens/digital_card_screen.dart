import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../models/user.dart';
import '../services/luxeva_card_generator.dart';
import '../widgets/copy_chip.dart';
import '../widgets/dynamic_notice.dart';
import '../widgets/glass_panel.dart';

class DigitalCardScreen extends StatefulWidget {
  final UserSession user;

  const DigitalCardScreen({super.key, required this.user});

  @override
  State<DigitalCardScreen> createState() => _DigitalCardScreenState();
}

class _DigitalCardScreenState extends State<DigitalCardScreen> {
  late Future<LuxevaCardDetails> _cardFuture;
  bool _showSensitive = false;
  bool _isFrozen = false;
  String _currentPin = '4829';
  double _dailyLimit = 15000.0;

  // ATM Token State
  AtmWithdrawalToken? _activeAtmToken;
  Timer? _countdownTimer;

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
          _dailyLimit = card.dailyLimit;
        });
      }
      return card;
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _generateAtmToken() {
    HapticFeedback.mediumImpact();
    final token = LuxevaCardGenerator.generateAtmToken(widget.user.accountNumber);
    setState(() {
      _activeAtmToken = token;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_activeAtmToken == null || _activeAtmToken!.isExpired) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _activeAtmToken = null;
          });
          DynamicNotice.show(
            context,
            message: 'El código de retiro ATM ha expirado',
            icon: CupertinoIcons.clock,
          );
        }
      } else {
        if (mounted) setState(() {});
      }
    });

    DynamicNotice.show(
      context,
      message: 'Código de retiro generado',
      subtitle: 'Válido durante 15 minutos en cajeros Luxeva',
      icon: CupertinoIcons.qrcode,
    );
  }

  void _cancelAtmToken() {
    HapticFeedback.lightImpact();
    _countdownTimer?.cancel();
    setState(() {
      _activeAtmToken = null;
    });
    DynamicNotice.show(
      context,
      message: 'Código de retiro cancelado',
      icon: CupertinoIcons.xmark_circle,
    );
  }

  Future<void> _toggleFreeze(bool val) async {
    HapticFeedback.selectionClick();
    setState(() => _isFrozen = val);
    await LuxevaCardGenerator.setCardFrozen(widget.user.accountNumber, val);
    if (mounted) {
      DynamicNotice.show(
        context,
        message: val ? 'Tarjeta pausada' : 'Tarjeta activa',
        subtitle: val ? 'Operaciones en cajeros bloqueadas' : 'Lista para retiros y consultas',
        icon: val ? CupertinoIcons.lock_fill : CupertinoIcons.lock_open_fill,
      );
    }
  }

  void _promptChangePin() {
    final controller = TextEditingController();
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('PIN de Cajero ATM', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Column(
            children: [
              const Text('Ingrese el nuevo PIN de 4 dígitos para operaciones en cajeros Luxeva:'),
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
            child: const Text('Guardar PIN', style: TextStyle(color: LuxevaTheme.goldAccent, fontWeight: FontWeight.w600)),
            onPressed: () async {
              final newPin = controller.text.trim();
              if (newPin.length == 4) {
                Navigator.of(ctx).pop();
                setState(() => _currentPin = newPin);
                await LuxevaCardGenerator.setCardPin(widget.user.accountNumber, newPin);
                if (mounted) {
                  DynamicNotice.show(
                    context,
                    message: 'PIN de cajero actualizado con éxito',
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

  void _promptChangeLimit() {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('Límite Diario de Retiro en ATM'),
        message: const Text('Seleccione el monto máximo autorizado para dispensar en cajeros por día:'),
        actions: [
          CupertinoActionSheetAction(
            child: const Text('\$5,000 MXN / día'),
            onPressed: () => _updateLimit(5000.0, ctx),
          ),
          CupertinoActionSheetAction(
            child: const Text('\$10,000 MXN / día'),
            onPressed: () => _updateLimit(10000.0, ctx),
          ),
          CupertinoActionSheetAction(
            child: const Text('\$15,000 MXN / día'),
            onPressed: () => _updateLimit(15000.0, ctx),
          ),
          CupertinoActionSheetAction(
            child: const Text('\$25,000 MXN / día'),
            onPressed: () => _updateLimit(25000.0, ctx),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          child: const Text('Cancelar'),
          onPressed: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  Future<void> _updateLimit(double limit, BuildContext ctx) async {
    Navigator.of(ctx).pop();
    setState(() => _dailyLimit = limit);
    await LuxevaCardGenerator.setDailyLimit(widget.user.accountNumber, limit);
    if (mounted) {
      DynamicNotice.show(
        context,
        message: 'Límite de retiro actualizado a \$${limit.toStringAsFixed(0)} MXN',
        icon: CupertinoIcons.slider_horizontal_3,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: LuxevaTheme.obsidianBg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: LuxevaTheme.glassBg,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back, color: LuxevaTheme.goldAccent),
          onPressed: () => Navigator.of(context).pop(),
        ),
        middle: const Text(
          'TARJETA LUXEVA',
          style: TextStyle(letterSpacing: 1.5, fontSize: 13, fontWeight: FontWeight.w700),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            _showSensitive ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
            color: LuxevaTheme.goldAccent,
            size: 20,
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            setState(() => _showSensitive = !_showSensitive);
          },
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // 1. Titanium Physical Card Representation
                _buildCardView(card),
                const SizedBox(height: 14),

                // 2. Network & Usage Note (Quiet Luxury)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0x10CBBD93),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: LuxevaTheme.borderGold.withOpacity(0.25), width: 0.8),
                  ),
                  child: const Row(
                    children: [
                      Icon(CupertinoIcons.building_2_fill, size: 16, color: LuxevaTheme.goldAccent),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Credencial exclusiva para la Red de Cajeros ATMs Luxeva y comercios afiliados al club.',
                          style: TextStyle(fontSize: 11, color: LuxevaTheme.textSecondary, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // 3. ATM Withdrawal Token Generator Section
                _buildAtmTokenSection(),
                const SizedBox(height: 28),

                // 4. Security Management Section
                const Text(
                  'GESTIÓN DE SEGURIDAD',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: LuxevaTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                GlassPanel(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Freeze Switch
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pausar Tarjeta',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LuxevaTheme.textPrimary),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Bloquea temporalmente el uso en cajeros',
                                style: TextStyle(fontSize: 11, color: LuxevaTheme.textSecondary),
                              ),
                            ],
                          ),
                          CupertinoSwitch(
                            value: _isFrozen,
                            activeColor: LuxevaTheme.redNegative,
                            onChanged: _toggleFreeze,
                          ),
                        ],
                      ),
                      Container(
                        height: 0.5,
                        margin: const EdgeInsets.symmetric(vertical: 14),
                        color: const Color(0x18FFFFFF),
                      ),

                      // ATM PIN
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PIN de Cajero ATM',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LuxevaTheme.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _showSensitive ? 'PIN: $_currentPin' : 'PIN: ••••',
                                style: const TextStyle(fontSize: 12, fontFamily: 'Courier', color: LuxevaTheme.goldAccent),
                              ),
                            ],
                          ),
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            color: const Color(0x18CBBD93),
                            borderRadius: BorderRadius.circular(8),
                            onPressed: _promptChangePin,
                            child: const Text(
                              'Cambiar',
                              style: TextStyle(fontSize: 12, color: LuxevaTheme.goldLight, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 0.5,
                        margin: const EdgeInsets.symmetric(vertical: 14),
                        color: const Color(0x18FFFFFF),
                      ),

                      // Daily Limit
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Límite Diario en Cajero',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LuxevaTheme.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '\$${_dailyLimit.toStringAsFixed(0)} MXN / día',
                                style: const TextStyle(fontSize: 12, color: LuxevaTheme.textSecondary),
                              ),
                            ],
                          ),
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            color: const Color(0x18CBBD93),
                            borderRadius: BorderRadius.circular(8),
                            onPressed: _promptChangeLimit,
                            child: const Text(
                              'Ajustar',
                              style: TextStyle(fontSize: 12, color: LuxevaTheme.goldLight, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardView(LuxevaCardDetails card) {
    return Container(
      width: double.infinity,
      height: 215,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isFrozen
              ? [const Color(0xFF1E1416), const Color(0xFF140D0F), const Color(0xFF0D080A)]
              : [const Color(0xFF262630), const Color(0xFF15151B), const Color(0xFF0B0B0E)],
        ),
        border: Border.all(
          color: _isFrozen ? LuxevaTheme.redNegative.withOpacity(0.5) : LuxevaTheme.borderGold,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Chip and Brand
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Gold Chip
              Container(
                width: 44,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8DEBF), Color(0xFFCBBD93), Color(0xFFA69668)],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 32,
                    height: 22,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0x33000000), width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isFrozen ? LuxevaTheme.redNegative : LuxevaTheme.greenPositive,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isFrozen ? 'PAUSADA' : 'LUXEVA',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3.0,
                      color: _isFrozen ? LuxevaTheme.redNegative : LuxevaTheme.goldLight,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Card Number
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _showSensitive ? card.formattedCardNumber : card.formattedMaskedNumber,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: LuxevaTheme.textPrimary,
                    ),
                  ),
                  if (_showSensitive) ...[
                    const SizedBox(width: 8),
                    CopyChip(textToCopy: card.cardNumber),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              const Text(
                'RED PRIVADA LXC-PAN',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: LuxevaTheme.textMuted,
                ),
              ),
            ],
          ),

          // Bottom Row: Holder, Expiry, CVV
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TITULAR',
                    style: TextStyle(fontSize: 8, letterSpacing: 1.2, color: LuxevaTheme.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    card.cardHolder,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: LuxevaTheme.textPrimary),
                  ),
                ],
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'VENCE',
                        style: TextStyle(fontSize: 8, letterSpacing: 1.2, color: LuxevaTheme.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        card.expiry,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: LuxevaTheme.goldAccent),
                      ),
                    ],
                  ),
                  const SizedBox(width: 18),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'CVV',
                        style: TextStyle(fontSize: 8, letterSpacing: 1.2, color: LuxevaTheme.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _showSensitive ? card.cvv : '•••',
                        style: const TextStyle(fontSize: 12, fontFamily: 'Courier', fontWeight: FontWeight.w700, color: LuxevaTheme.textPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAtmTokenSection() {
    if (_activeAtmToken == null) {
      return GlassPanel(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(CupertinoIcons.qrcode_viewfinder, size: 20, color: LuxevaTheme.goldAccent),
                SizedBox(width: 10),
                Text(
                  'Retiro en Cajero ATM',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: LuxevaTheme.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Genera una clave de un solo uso para retirar efectivo sin plástico físico.',
              style: TextStyle(fontSize: 12, color: LuxevaTheme.textSecondary, height: 1.3),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: CupertinoButton(
                color: const Color(0x18CBBD93),
                borderRadius: BorderRadius.circular(12),
                padding: EdgeInsets.zero,
                onPressed: _isFrozen ? null : _generateAtmToken,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.sparkles, size: 16, color: LuxevaTheme.goldAccent),
                    const SizedBox(width: 8),
                    Text(
                      _isFrozen ? 'Tarjeta Pausada' : 'Generar Código de Retiro ATM',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _isFrozen ? LuxevaTheme.textMuted : LuxevaTheme.goldLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final token = _activeAtmToken!;
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      borderColor: LuxevaTheme.goldAccent.withOpacity(0.6),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(CupertinoIcons.qrcode, size: 18, color: LuxevaTheme.goldAccent),
                  SizedBox(width: 8),
                  Text(
                    'CÓDIGO DE RETIRO ACTIVO',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: LuxevaTheme.goldAccent),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0x1ACBBD93),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  token.formattedTimeRemaining,
                  style: const TextStyle(fontSize: 12, fontFamily: 'Courier', fontWeight: FontWeight.w700, color: LuxevaTheme.goldLight),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 6-digit Code Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: LuxevaTheme.cardElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: LuxevaTheme.borderGold.withOpacity(0.4), width: 0.8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${token.code.substring(0, 3)}  ${token.code.substring(3, 6)}',
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 6.0,
                    color: LuxevaTheme.goldLight,
                  ),
                ),
                const SizedBox(width: 12),
                CopyChip(textToCopy: token.code),
              ],
            ),
          ),
          const SizedBox(height: 12),

          const Text(
            'Ingresa este código de 6 dígitos en el teclado del cajero automático Luxeva.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: LuxevaTheme.textSecondary, height: 1.3),
          ),
          const SizedBox(height: 16),

          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _cancelAtmToken,
            child: const Text(
              'Cancelar Código',
              style: TextStyle(fontSize: 12, color: LuxevaTheme.redNegative, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
