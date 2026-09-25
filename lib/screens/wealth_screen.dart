import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../widgets/glass_panel.dart';

class WealthScreen extends StatelessWidget {
  final UserSession user;

  const WealthScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 2);
    final liquidBalance = user.balance;
    final fixedYield = 125000.00;
    final goldHoldings = 84500.00;
    final totalPatrimony = liquidBalance + fixedYield + goldHoldings;

    return CupertinoPageScaffold(
      backgroundColor: LuxevaTheme.obsidianBg,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: LuxevaTheme.glassBg,
        middle: Text(
          'PATRIMONIO PRIVADO',
          style: TextStyle(
            letterSpacing: 2.0,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: LuxevaTheme.textPrimary,
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            // Total Consolidated Header
            GlassPanel(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PATRIMONIO CONSOLIDADO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                          color: LuxevaTheme.goldAccent,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: LuxevaTheme.goldAccent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: LuxevaTheme.borderGold, width: 0.5),
                        ),
                        child: const Row(
                          children: [
                            Icon(CupertinoIcons.graph_circle, size: 13, color: LuxevaTheme.goldAccent),
                            SizedBox(width: 4),
                            Text(
                              '+11.45% TIIE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: LuxevaTheme.goldLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${currencyFormatter.format(totalPatrimony)} MXN',
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: LuxevaTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Valuación estimada en tiempo real con custodia institucional blindada',
                    style: TextStyle(
                      fontSize: 12,
                      color: LuxevaTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Distribution Breakdown
            const Text(
              'DESGLOSE DE ACTIVOS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
                color: LuxevaTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            _buildAssetRow(
              icon: CupertinoIcons.money_dollar_circle,
              title: 'Liquidez Inmediata en Bóveda',
              subtitle: 'Saldo disponible para dispersión SPEI 24/7',
              amount: '${currencyFormatter.format(liquidBalance)} MXN',
              percentage: '${((liquidBalance / totalPatrimony) * 100).toStringAsFixed(1)}%',
              badgeColor: LuxevaTheme.greenPositive,
            ),
            const SizedBox(height: 12),

            _buildAssetRow(
              icon: CupertinoIcons.shield_lefthalf_fill,
              title: 'Pagaré de Tesorería Luxeva',
              subtitle: 'Rendimiento pactado liquidable a 28 días',
              amount: '${currencyFormatter.format(fixedYield)} MXN',
              percentage: '${((fixedYield / totalPatrimony) * 100).toStringAsFixed(1)}%',
              badgeColor: LuxevaTheme.goldAccent,
            ),
            const SizedBox(height: 12),

            _buildAssetRow(
              icon: CupertinoIcons.sparkles,
              title: 'Metales Preciosos Asignados',
              subtitle: 'Custodia física lingote LBMA 99.99%',
              amount: '${currencyFormatter.format(goldHoldings)} MXN',
              percentage: '${((goldHoldings / totalPatrimony) * 100).toStringAsFixed(1)}%',
              badgeColor: LuxevaTheme.goldLight,
            ),

            const SizedBox(height: 32),

            // Private Banking Contact Card
            GlassPanel(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(CupertinoIcons.person_badge_plus, size: 20, color: LuxevaTheme.goldAccent),
                      SizedBox(width: 10),
                      Text(
                        'BANQUERO PRIVADO ASIGNADO',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: LuxevaTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Su cuenta cuenta con atención directa de la Mesa de Dinero y Tesorería Corporativa de Luxeva.',
                    style: TextStyle(fontSize: 13, color: LuxevaTheme.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: LuxevaTheme.cardElevated,
                    borderRadius: BorderRadius.circular(10),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      showCupertinoDialog(
                        context: context,
                        builder: (ctx) => CupertinoAlertDialog(
                          title: const Text('Mesa de Tesorería'),
                          content: const Text(
                            'Su oficial de cuenta institucional se comunicará a la brevedad vía canal encriptado.',
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text('Entendido', style: TextStyle(color: LuxevaTheme.goldAccent)),
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Center(
                      child: Text(
                        'Contactar Banquero Privado',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: LuxevaTheme.goldAccent,
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

  Widget _buildAssetRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required String percentage,
    required Color badgeColor,
  }) {
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: LuxevaTheme.cardElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: LuxevaTheme.borderSubtle, width: 0.5),
            ),
            child: Icon(icon, size: 22, color: LuxevaTheme.goldAccent),
          ),
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
                const SizedBox(height: 3),
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
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: LuxevaTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  percentage,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
