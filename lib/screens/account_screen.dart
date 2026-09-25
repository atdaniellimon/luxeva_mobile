import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../widgets/copy_chip.dart';
import '../widgets/glass_panel.dart';

class AccountScreen extends StatefulWidget {
  final UserSession user;

  const AccountScreen({super.key, required this.user});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _biometricsEnabled = true;

  void _handleLogout() {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Finalizar Sesión', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text('¿Desea cerrar la sesión de su bóveda privada en este dispositivo?'),
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
        middle: Text('OFICIALÍA DE CUENTA', style: TextStyle(letterSpacing: 1.5, fontSize: 13)),
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
                          color: LuxevaTheme.goldAccent.withOpacity(0.3),
                          blurRadius: 24,
                          spreadRadius: 2,
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x18CBBD93),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: LuxevaTheme.borderGold),
                    ),
                    child: const Text(
                      'SOCIO PRIVADO INSTITUCIONAL',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: LuxevaTheme.goldAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Credentials Panel
            const Text(
              'PARÁMETROS DEL TITULAR',
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
                  const Divider(color: Color(0x10FFFFFF), height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cuenta Institucional',
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
            const SizedBox(height: 24),

            // Security & Biometrics
            const Text(
              'PROTOCOLOS DE SEGURIDAD',
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
                      CupertinoSwitch(
                        value: _biometricsEnabled,
                        activeColor: LuxevaTheme.goldAccent,
                        onChanged: (val) {
                          HapticFeedback.selectionClick();
                          setState(() => _biometricsEnabled = val);
                        },
                      ),
                    ],
                  ),
                  const Divider(color: Color(0x10FFFFFF), height: 24),
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
              height: 50,
              child: CupertinoButton(
                color: const Color(0x18FF453A),
                borderRadius: BorderRadius.circular(14),
                onPressed: _handleLogout,
                child: const Text(
                  'Finalizar Sesión Privada',
                  style: TextStyle(
                    color: LuxevaTheme.redNegative,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
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
