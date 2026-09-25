import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/glass_panel.dart';
import 'spei_deposit_screen.dart';
import 'transfer_screen.dart';

class WealthScreen extends StatefulWidget {
  final UserSession user;

  const WealthScreen({super.key, required this.user});

  @override
  State<WealthScreen> createState() => _WealthScreenState();
}

class _WealthScreenState extends State<WealthScreen> {
  List<TransactionItem> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRealData();
  }

  Future<void> _loadRealData() async {
    try {
      final txs = await ApiService.instance.getTransactions(widget.user.accountNumber);
      if (mounted) {
        setState(() {
          _transactions = txs;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 2);

    return ValueListenableBuilder<UserSession?>(
      valueListenable: AuthService.instance.currentSession,
      builder: (context, sessionUser, _) {
        final currentUser = sessionUser ?? widget.user;
        final realBalance = currentUser.balance;

        // Calculate real incoming and outgoing from actual transactions
        double totalIn = 0;
        double totalOut = 0;
        for (final tx in _transactions) {
          if (tx.isPositive) {
            totalIn += tx.amount;
          } else {
            totalOut += tx.amount.abs();
          }
        }

        return CupertinoPageScaffold(
          backgroundColor: LuxevaTheme.obsidianBg,
          navigationBar: const CupertinoNavigationBar(
            backgroundColor: LuxevaTheme.glassBg,
            middle: Text(
              'Balance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: LuxevaTheme.textPrimary,
              ),
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              children: [
                // Real Balance Card
                GlassPanel(
                  hasGoldBorder: true,
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SALDO TOTAL DISPONIBLE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: LuxevaTheme.goldAccent,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${currencyFormatter.format(realBalance)} MXN',
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: LuxevaTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Cuenta ${currentUser.accountNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: LuxevaTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Cashflow Summary: Entradas vs Salidas
                Row(
                  children: [
                    Expanded(
                      child: GlassPanel(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(CupertinoIcons.arrow_down_left, size: 16, color: LuxevaTheme.greenPositive),
                                SizedBox(width: 6),
                                Text(
                                  'Ingresos',
                                  style: TextStyle(fontSize: 12, color: LuxevaTheme.textSecondary, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currencyFormatter.format(totalIn),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: LuxevaTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassPanel(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(CupertinoIcons.arrow_up_right, size: 16, color: LuxevaTheme.redNegative),
                                SizedBox(width: 6),
                                Text(
                                  'Enviado',
                                  style: TextStyle(fontSize: 12, color: LuxevaTheme.textSecondary, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currencyFormatter.format(totalOut),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: LuxevaTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Quick Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        color: LuxevaTheme.cardElevated,
                        borderRadius: BorderRadius.circular(12),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).push(
                            CupertinoPageRoute(builder: (_) => SpeiDepositScreen(user: currentUser)),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.plus_circle, size: 18, color: LuxevaTheme.goldAccent),
                            SizedBox(width: 8),
                            Text(
                              'Depositar',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LuxevaTheme.goldAccent),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        color: LuxevaTheme.cardElevated,
                        borderRadius: BorderRadius.circular(12),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).push(
                            CupertinoPageRoute(builder: (_) => TransferScreen(user: currentUser)),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.arrow_up_right_circle, size: 18, color: LuxevaTheme.textPrimary),
                            SizedBox(width: 8),
                            Text(
                              'Transferir',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: LuxevaTheme.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Real Movement Count & Status
                const Text(
                  'RESUMEN DE CUENTA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: LuxevaTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                GlassPanel(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildSummaryRow('Movimientos registrados', '${_transactions.length}'),
                      Container(
                        height: 0.5,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        color: const Color(0x18FFFFFF),
                      ),
                      _buildSummaryRow('Estado de cuenta', 'Activa y verificada', valueColor: LuxevaTheme.greenPositive),
                      Container(
                        height: 0.5,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        color: const Color(0x18FFFFFF),
                      ),
                      _buildSummaryRow('Nivel de cuenta', currentUser.tier.toUpperCase(), valueColor: LuxevaTheme.goldLight),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: LuxevaTheme.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? LuxevaTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
