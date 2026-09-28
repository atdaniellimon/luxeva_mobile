import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../models/user.dart';
import '../services/luxeva_card_generator.dart';
import '../services/notification_service.dart';
import 'dynamic_notice.dart';

class CashWithdrawalModal extends StatefulWidget {
  final UserSession user;

  const CashWithdrawalModal({super.key, required this.user});

  static Future<void> show(BuildContext context, UserSession user) {
    HapticFeedback.lightImpact();
    return showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CashWithdrawalModal(user: user),
    );
  }

  @override
  State<CashWithdrawalModal> createState() => _CashWithdrawalModalState();
}

class _CashWithdrawalModalState extends State<CashWithdrawalModal> {
  final TextEditingController _customAmountController = TextEditingController();
  double _selectedAmount = 2000.0;
  bool _isCustom = false;

  AtmWithdrawalToken? _activeToken;
  Timer? _countdownTimer;

  final List<double> _quickAmounts = [1000.0, 2000.0, 3000.0, 5000.0];

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _customAmountController.dispose();
    super.dispose();
  }

  void _handleGenerateToken() {
    double amount = _selectedAmount;
    if (_isCustom) {
      final parsed = double.tryParse(_customAmountController.text.trim());
      if (parsed == null || parsed <= 0) {
        DynamicNotice.show(
          context,
          message: 'Monto inválido',
          subtitle: 'Ingresa una cantidad válida para disponer',
          icon: CupertinoIcons.exclamationmark_circle,
        );
        return;
      }
      amount = parsed;
    }

    if (amount > widget.user.balance) {
      DynamicNotice.show(
        context,
        message: 'Fondos insuficientes',
        subtitle: 'El monto supera el saldo disponible en bóveda',
        icon: CupertinoIcons.xmark_circle,
      );
      return;
    }

    HapticFeedback.heavyImpact();
    final token = LuxevaCardGenerator.generateAtmToken(widget.user.accountNumber, amount: amount);

    setState(() {
      _activeToken = token;
    });

    NotificationService.instance.addNotification(
      title: 'Disposición de Efectivo',
      message: 'Clave generada por \$${amount.toStringAsFixed(2)} MXN (Válida 15 min).',
      type: 'cash',
    );

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_activeToken == null || _activeToken!.isExpired) {
        timer.cancel();
        if (mounted) {
          setState(() => _activeToken = null);
          DynamicNotice.show(
            context,
            message: 'La clave de efectivo ha expirado',
            icon: CupertinoIcons.clock,
          );
        }
      } else {
        if (mounted) setState(() {});
      }
    });
  }

  void _handleCancelToken() {
    HapticFeedback.lightImpact();
    _countdownTimer?.cancel();
    setState(() => _activeToken = null);
    DynamicNotice.show(
      context,
      message: 'Orden de efectivo cancelada',
      icon: CupertinoIcons.xmark_circle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
        color: LuxevaTheme.surfaceLayer,
        borderRadius: BorderRadius.vertical(top: Radius.circular(LuxevaTheme.continuousRadius)),
        border: Border(
          top: BorderSide(color: LuxevaTheme.borderGold, width: LuxevaTheme.hairline),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Grabber
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0x30FFFFFF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'DISPOSICIÓN DE EFECTIVO',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: LuxevaTheme.textPrimary,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(CupertinoIcons.xmark_circle_fill, size: 22, color: LuxevaTheme.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            Container(
              height: LuxevaTheme.hairline,
              color: LuxevaTheme.borderSubtle,
            ),

            Expanded(
              child: _activeToken == null ? _buildSelectionView() : _buildActiveTokenView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionView() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        Center(
          child: Column(
            children: [
              const Text(
                'SALDO DISPONIBLE EN BÓVEDA',
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
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: LuxevaTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'SELECCIONA O ESCRIBE EL MONTO A RETIRAR',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: LuxevaTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 12),

        // Quick amount chips
        Row(
          children: _quickAmounts.map((amt) {
            final isSelected = !_isCustom && _selectedAmount == amt;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _isCustom = false;
                    _selectedAmount = amt;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? LuxevaTheme.goldAccent.withOpacity(0.18) : LuxevaTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(LuxevaTheme.radiusCompact),
                    border: Border.all(
                      color: isSelected ? LuxevaTheme.goldAccent : LuxevaTheme.borderSubtle,
                      width: isSelected ? 1.0 : LuxevaTheme.hairline,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '\$${amt.toInt()}',
                      style: LuxevaTheme.tabularFigures(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? LuxevaTheme.goldLight : LuxevaTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Custom amount button / field
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _isCustom = true);
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: LuxevaTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(LuxevaTheme.radiusStandard),
              border: Border.all(
                color: _isCustom ? LuxevaTheme.goldAccent : LuxevaTheme.borderSubtle,
                width: _isCustom ? 1.0 : LuxevaTheme.hairline,
              ),
            ),
            child: Row(
              children: [
                const Icon(CupertinoIcons.pencil, size: 16, color: LuxevaTheme.goldAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: _isCustom
                      ? CupertinoTextField(
                          controller: _customAmountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          autofocus: true,
                          placeholder: 'Escribe el monto en MXN',
                          placeholderStyle: const TextStyle(color: LuxevaTheme.textMuted, fontSize: 14),
                          style: LuxevaTheme.tabularFigures(fontSize: 16, color: LuxevaTheme.textPrimary),
                          decoration: null,
                        )
                      : const Text(
                          'Otro monto personalizado',
                          style: TextStyle(fontSize: 14, color: LuxevaTheme.textSecondary),
                        ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Generate button
        CupertinoButton(
          color: LuxevaTheme.goldAccent,
          borderRadius: BorderRadius.circular(LuxevaTheme.radiusStandard),
          padding: const EdgeInsets.symmetric(vertical: 14),
          onPressed: _handleGenerateToken,
          child: const Text(
            'Generar Clave de Retiro',
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
            'Válido en cajeros automáticos y terminales de la red privada Luxeva.',
            style: TextStyle(fontSize: 11, color: LuxevaTheme.textMuted),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveTokenView() {
    final token = _activeToken!;
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: LuxevaTheme.greenPositive.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: LuxevaTheme.greenPositive.withOpacity(0.4), width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(CupertinoIcons.checkmark_shield_fill, size: 14, color: LuxevaTheme.greenPositive),
                const SizedBox(width: 6),
                Text(
                  'CLAVE ACTIVA: \$${token.authorizedAmount.toStringAsFixed(2)} MXN',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: LuxevaTheme.greenPositive),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // OTP Display
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: LuxevaTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(LuxevaTheme.continuousRadius),
            border: Border.all(color: LuxevaTheme.borderGold, width: LuxevaTheme.hairline),
          ),
          child: Column(
            children: [
              const Text(
                'CÓDIGO DE RETIRO DE UN SOLO USO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: LuxevaTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${token.code.substring(0, 3)}  ${token.code.substring(3, 6)}',
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 6,
                  color: LuxevaTheme.goldLight,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.clock, size: 14, color: LuxevaTheme.amberSandbox),
                  const SizedBox(width: 6),
                  Text(
                    'Expira en: ${token.formattedTimeRemaining}',
                    style: LuxevaTheme.tabularFigures(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: LuxevaTheme.amberSandbox,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Cancel order button
        CupertinoButton(
          padding: const EdgeInsets.symmetric(vertical: 13),
          color: const Color(0x18FF453A),
          borderRadius: BorderRadius.circular(LuxevaTheme.radiusStandard),
          onPressed: _handleCancelToken,
          child: const Text(
            'Cancelar Orden de Efectivo',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LuxevaTheme.redNegative),
          ),
        ),
      ],
    );
  }
}
