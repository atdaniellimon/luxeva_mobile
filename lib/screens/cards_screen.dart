import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/luxeva_theme.dart';
import '../widgets/luxury_card.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  bool _isCardLocked = false;
  bool _dynamicCvvEnabled = true;
  bool _internationalPurchases = true;

  @override
  Widget build(BuildContext context) {
    final session = ApiService.instance.currentSession ??
        UserSession(
          id: '',
          fullName: 'Daniel Limón',
          email: 'daniel@luxeva.com',
          accountNumber: 'LX-6365121453',
          balance: 800.0,
          tier: 'Titanium Private',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Instrumentos de Pago',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: LuxevaTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'EMISIÓN PRIVADA TUNGSTENO Y ORO',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                  color: LuxevaTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Digital Metal Card
              LuxuryCardWidget(session: session),

              const SizedBox(height: 32),

              const Text(
                'PROTOCOLOS DE SEGURIDAD',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                  color: LuxevaTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: LuxevaTheme.glassCardDecoration,
                child: Column(
                  children: [
                    _buildSwitchItem(
                      icon: CupertinoIcons.lock,
                      title: 'Bloqueo Preventivo',
                      subtitle: 'Inhabilita transacciones físicas y en línea',
                      value: _isCardLocked,
                      onChanged: (val) {
                        HapticFeedback.lightImpact();
                        setState(() => _isCardLocked = val);
                      },
                    ),
                    const Divider(height: 1, color: LuxevaTheme.borderSubtle),
                    _buildSwitchItem(
                      icon: CupertinoIcons.shield_lefthalf_fill,
                      title: 'CVV Dinámico de Protección',
                      subtitle: 'Regeneración periódica de token de seguridad',
                      value: _dynamicCvvEnabled,
                      onChanged: (val) {
                        HapticFeedback.lightImpact();
                        setState(() => _dynamicCvvEnabled = val);
                      },
                    ),
                    const Divider(height: 1, color: LuxevaTheme.borderSubtle),
                    _buildSwitchItem(
                      icon: CupertinoIcons.globe,
                      title: 'Operaciones Internacionales',
                      subtitle: 'Compras en divisas extranjeras sin fricción',
                      value: _internationalPurchases,
                      onChanged: (val) {
                        HapticFeedback.lightImpact();
                        setState(() => _internationalPurchases = val);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: CupertinoButton(
                  color: const Color(0x1ACBBD93),
                  borderRadius: BorderRadius.circular(14),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                  },
                  child: const Text(
                    'Emitir Nuevo Instrumento Privado',
                    style: TextStyle(
                      color: LuxevaTheme.accentGold,
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

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: LuxevaTheme.accentGold, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: LuxevaTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: LuxevaTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeColor: LuxevaTheme.accentGold,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
