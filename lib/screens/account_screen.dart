import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/luxeva_theme.dart';

class AccountScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const AccountScreen({super.key, required this.onLogout});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _biometricsEnabled = true;

  void _handleLogout() {
    HapticFeedback.mediumImpact();
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Deseas finalizar la sesión segura en este dispositivo?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Cerrar Sesión'),
            onPressed: () async {
              Navigator.pop(ctx);
              await ApiService.instance.clearSession();
              widget.onLogout();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ApiService.instance.currentSession ??
        UserSession(
          id: '',
          fullName: 'Daniel Limón',
          email: 'daniel@luxeva.com',
          accountNumber: 'LX-6365121453',
          balance: 800.0,
          tier: 'Titanium Private Club',
          token: '',
        );

    return CupertinoPageScaffold(
      backgroundColor: LuxevaTheme.background,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: Color(0xE609090B),
        middle: Text(
          'LUXEVA',
          style: TextStyle(fontFamily: 'serif', letterSpacing: 2, color: LuxevaTheme.textPrimary),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Avatar
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [LuxevaTheme.accentGoldLight, LuxevaTheme.accentGold],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: Color(0x4DCBBD93), blurRadius: 20, offset: Offset(0, 6)),
                  ],
                ),
                child: Center(
                  child: Text(
                    session.initials,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: LuxevaTheme.background,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                session.fullName,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: LuxevaTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x1ACBBD93),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: LuxevaTheme.borderGold),
                ),
                child: Text(
                  session.tier.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: LuxevaTheme.accentGold,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Detail Tiles
              Container(
                decoration: LuxevaTheme.glassCardDecoration,
                child: Column(
                  children: [
                    _buildInfoTile('Identificador (Email)', session.email),
                    const Divider(height: 1, color: LuxevaTheme.borderSubtle),
                    _buildInfoTile('Cuenta Institucional', session.accountNumber),
                    const Divider(height: 1, color: LuxevaTheme.borderSubtle),
                    _buildInfoTile('Divisa de Liquidación', 'MXN (Peso Mexicano)'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Security & Biometrics
              Container(
                decoration: LuxevaTheme.glassCardDecoration,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.viewfinder, color: LuxevaTheme.accentGold, size: 22),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Autenticación Face ID',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: LuxevaTheme.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Desbloqueo biométrico instantáneo',
                                  style: TextStyle(fontSize: 11, color: LuxevaTheme.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          CupertinoSwitch(
                            value: _biometricsEnabled,
                            activeColor: LuxevaTheme.accentGold,
                            onChanged: (val) {
                              HapticFeedback.lightImpact();
                              setState(() => _biometricsEnabled = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: CupertinoButton(
                  color: const Color(0x1AFF453A),
                  borderRadius: BorderRadius.circular(14),
                  onPressed: _handleLogout,
                  child: const Text(
                    'Cerrar Sesión Institucional',
                    style: TextStyle(
                      color: LuxevaTheme.redNegative,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: LuxevaTheme.textSecondary),
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
      ),
    );
  }
}
