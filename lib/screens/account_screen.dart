import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../services/developer_service.dart';
import '../widgets/copy_chip.dart';
import '../widgets/developer_console_modal.dart';
import '../widgets/dynamic_notice.dart';

class AccountScreen extends StatefulWidget {
  final UserSession user;

  const AccountScreen({super.key, required this.user});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _biometricsEnabled = false;
  int _secretTapCount = 0;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    _loadBiometrics();
  }

  Future<void> _loadBiometrics() async {
    final enabled = await BiometricService.instance.isEnabled();
    if (mounted) {
      setState(() {
        _biometricsEnabled = enabled;
      });
    }
  }

  Future<void> _handleToggleBiometrics(bool val) async {
    HapticFeedback.selectionClick();
    if (val) {
      final authenticated = await BiometricService.instance.authenticate(
        reason: 'Verifica tu identidad para habilitar Face ID',
      );

      if (authenticated) {
        await BiometricService.instance.setEnabled(true);
        if (mounted) {
          setState(() => _biometricsEnabled = true);
          DynamicNotice.show(
            context,
            message: 'Face ID activado',
            subtitle: 'Tu sesión está protegida con biometría institucional',
            icon: CupertinoIcons.viewfinder,
          );
        }
      } else {
        if (mounted) setState(() => _biometricsEnabled = false);
      }
    } else {
      await BiometricService.instance.setEnabled(false);
      if (mounted) {
        setState(() => _biometricsEnabled = false);
        DynamicNotice.show(
          context,
          message: 'Face ID desactivado',
          icon: CupertinoIcons.lock_open,
        );
      }
    }
  }

  void _handleSecretTap() {
    final now = DateTime.now();
    if (_lastTapTime == null || now.difference(_lastTapTime!).inSeconds > 2) {
      _secretTapCount = 1;
    } else {
      _secretTapCount++;
    }
    _lastTapTime = now;

    if (_secretTapCount < 5) {
      HapticFeedback.selectionClick();
    } else {
      _secretTapCount = 0;
      HapticFeedback.heavyImpact();
      final current = DeveloperService.instance.isDeveloperMode.value;
      final target = !current;
      DeveloperService.instance.setDeveloperMode(target);

      DynamicNotice.show(
        context,
        message: target ? 'Modo Developer Habilitado' : 'Modo Developer Desactivado',
        subtitle: target ? 'Consola de pruebas y simulación disponible' : 'Regresaste al entorno real',
        icon: target ? CupertinoIcons.wrench_fill : CupertinoIcons.lock_fill,
      );
    }
  }

  void _handleLogout() {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Cerrar Sesión', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text('¿Deseas finalizar tu sesión segura en este dispositivo?'),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancelar', style: TextStyle(color: LuxevaTheme.textSecondary)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Cerrar Sesión'),
            onPressed: () {
              Navigator.of(ctx).pop();
              HapticFeedback.mediumImpact();
              AuthService.instance.logout();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: DeveloperService.instance.isDeveloperMode,
      builder: (context, isDev, _) {
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
              'PERFIL Y AJUSTES',
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
                // 1. User Monogram & Name
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [LuxevaTheme.goldLight, LuxevaTheme.goldAccent, LuxevaTheme.goldDark],
                          ),
                          border: Border.all(color: LuxevaTheme.borderGold, width: 0.5),
                        ),
                        child: Center(
                          child: Text(
                            widget.user.initials,
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: LuxevaTheme.obsidianBg,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        widget.user.fullName,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: LuxevaTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: LuxevaTheme.goldAccent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'SOCIO ${widget.user.tier.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: LuxevaTheme.goldLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // 2. Account Information Inset
                const Text(
                  'CUENTA Y AUTENTICACIÓN',
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
                      // Email
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Correo Electrónico', style: TextStyle(fontSize: 13, color: LuxevaTheme.textSecondary)),
                            Text(widget.user.email, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: LuxevaTheme.textPrimary)),
                          ],
                        ),
                      ),
                      Container(height: LuxevaTheme.hairline, color: LuxevaTheme.dividerColor),

                      // Account Number
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Número de Cuenta', style: TextStyle(fontSize: 13, color: LuxevaTheme.textSecondary)),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  widget.user.accountNumber,
                                  style: LuxevaTheme.tabularFigures(
                                    fontSize: 13,
                                    fontFamily: 'Courier',
                                    fontWeight: FontWeight.w700,
                                    color: LuxevaTheme.goldLight,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                CopyChip(textToCopy: widget.user.accountNumber),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(height: LuxevaTheme.hairline, color: LuxevaTheme.dividerColor),

                      // Face ID Toggle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Face ID / Biometría', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LuxevaTheme.textPrimary)),
                            CupertinoSwitch(
                              value: _biometricsEnabled,
                              activeColor: LuxevaTheme.goldAccent,
                              onChanged: _handleToggleBiometrics,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // 3. Development / Sandbox Inset
                const Text(
                  'ENTORNO Y DESARROLLO',
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Modo Developer (Sandbox)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LuxevaTheme.textPrimary)),
                                SizedBox(height: 2),
                                Text('Habilita faucet y conmutador de cuentas', style: TextStyle(fontSize: 11, color: LuxevaTheme.textSecondary)),
                              ],
                            ),
                            CupertinoSwitch(
                              value: isDev,
                              activeColor: LuxevaTheme.amberSandbox,
                              onChanged: (val) {
                                HapticFeedback.selectionClick();
                                DeveloperService.instance.setDeveloperMode(val);
                              },
                            ),
                          ],
                        ),
                      ),
                      if (isDev) ...[
                        Container(height: LuxevaTheme.hairline, color: LuxevaTheme.dividerColor),
                        GestureDetector(
                          onTap: () => DeveloperConsoleModal.show(context, widget.user),
                          child: Container(
                            color: CupertinoColors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(CupertinoIcons.wrench_fill, size: 16, color: LuxevaTheme.amberSandbox),
                                    SizedBox(width: 10),
                                    Text('Abrir Consola Sandbox', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: LuxevaTheme.amberSandbox)),
                                  ],
                                ),
                                Icon(CupertinoIcons.chevron_right, size: 14, color: LuxevaTheme.textMuted),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // 4. Session Controls
                Container(
                  decoration: BoxDecoration(
                    color: LuxevaTheme.surfaceLayer,
                    borderRadius: BorderRadius.circular(LuxevaTheme.radiusStandard),
                    border: Border.all(color: LuxevaTheme.borderSubtle, width: LuxevaTheme.hairline),
                  ),
                  child: GestureDetector(
                    onTap: _handleLogout,
                    child: Container(
                      color: CupertinoColors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.square_arrow_right, size: 16, color: LuxevaTheme.redNegative),
                          SizedBox(width: 8),
                          Text(
                            'Cerrar Sesión Segura',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LuxevaTheme.redNegative),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // 5. Version Footer with 5-tap dev trigger
                Center(
                  child: GestureDetector(
                    onTap: _handleSecretTap,
                    child: const Text(
                      'LUXEVA PRIVATE BANKING • BUILD 2026.09',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: LuxevaTheme.textMuted),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
