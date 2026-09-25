import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../widgets/copy_chip.dart';
import '../widgets/dynamic_notice.dart';
import '../widgets/glass_panel.dart';
import 'digital_card_screen.dart';

class AccountScreen extends StatefulWidget {
  final UserSession user;

  const AccountScreen({super.key, required this.user});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _biometricsEnabled = false;
  bool _isLoadingBiometrics = true;

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
        _isLoadingBiometrics = false;
      });
    }
  }

  Future<void> _handleToggleBiometrics(bool val) async {
    HapticFeedback.selectionClick();
    if (val) {
      // Prompt biometric authentication to verify identity before enabling
      final authenticated = await BiometricService.instance.authenticate(
        reason: 'Verifique su identidad para habilitar Face ID',
      );

      if (authenticated) {
        await BiometricService.instance.setEnabled(true);
        if (mounted) {
          setState(() => _biometricsEnabled = true);
          DynamicNotice.show(
            context,
            message: 'Face ID activado',
            subtitle: 'Tu sesión está protegida con biometría',
            icon: CupertinoIcons.viewfinder,
          );
        }
      } else {
        if (mounted) {
          setState(() => _biometricsEnabled = false);
        }
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

  void _handleLogout() {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Cerrar Sesión', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text('¿Deseas cerrar tu sesión en este dispositivo?'),
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
    return CupertinoPageScaffold(
      backgroundColor: LuxevaTheme.obsidianBg,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: LuxevaTheme.glassBg,
        middle: Text('PERFIL', style: TextStyle(letterSpacing: 1.5, fontSize: 13, fontWeight: FontWeight.w700)),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Avatar and Name
            Center(
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [LuxevaTheme.goldLight, LuxevaTheme.goldAccent, LuxevaTheme.goldDark],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: LuxevaTheme.goldAccent.withOpacity(0.25),
                          blurRadius: 20,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.user.initials,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
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
                  Text(
                    'SOCIO LUXEVA',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: LuxevaTheme.goldAccent.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Account Details Panel
            const Text(
              'DATOS DE LA CUENTA',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: LuxevaTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            GlassPanel(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileRow('Correo Electrónico', widget.user.email),
                  Container(
                    height: 0.5,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    color: const Color(0x18FFFFFF),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Número de Cuenta',
                            style: TextStyle(fontSize: 11, color: LuxevaTheme.textSecondary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.user.accountNumber,
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Courier',
                              fontWeight: FontWeight.w700,
                              color: LuxevaTheme.goldLight,
                            ),
                          ),
                        ],
                      ),
                      CopyChip(textToCopy: widget.user.accountNumber),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Card Shortcut
            const Text(
              'SERVICIOS Y CREDENCIALES',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: LuxevaTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).push(
                  CupertinoPageRoute(builder: (_) => DigitalCardScreen(user: widget.user)),
                );
              },
              child: GlassPanel(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: LuxevaTheme.goldAccent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(CupertinoIcons.creditcard_fill, size: 18, color: LuxevaTheme.goldAccent),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tarjeta Luxeva Digital',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LuxevaTheme.textPrimary),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Acceso a ATMs Luxeva y comercios afiliados',
                            style: TextStyle(fontSize: 11, color: LuxevaTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(CupertinoIcons.chevron_forward, size: 16, color: LuxevaTheme.textMuted),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Security & Biometrics
            const Text(
              'SEGURIDAD',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: LuxevaTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            GlassPanel(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(CupertinoIcons.viewfinder, size: 20, color: LuxevaTheme.goldAccent),
                          SizedBox(width: 12),
                          Text(
                            'Face ID / Biometría',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LuxevaTheme.textPrimary),
                          ),
                        ],
                      ),
                      if (_isLoadingBiometrics)
                        const CupertinoActivityIndicator()
                      else
                        CupertinoSwitch(
                          value: _biometricsEnabled,
                          activeColor: LuxevaTheme.goldAccent,
                          onChanged: _handleToggleBiometrics,
                        ),
                    ],
                  ),
                  Container(
                    height: 0.5,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    color: const Color(0x18FFFFFF),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(CupertinoIcons.lock_shield, size: 20, color: LuxevaTheme.goldAccent),
                          SizedBox(width: 12),
                          Text(
                            'Cifrado Secure Enclave',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LuxevaTheme.textPrimary),
                          ),
                        ],
                      ),
                      Text(
                        'ACTIVO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: LuxevaTheme.greenPositive,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 34),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: CupertinoButton(
                color: const Color(0x18FF453A),
                borderRadius: BorderRadius.circular(12),
                padding: EdgeInsets.zero,
                onPressed: _handleLogout,
                child: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    color: LuxevaTheme.redNegative,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: LuxevaTheme.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: LuxevaTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
