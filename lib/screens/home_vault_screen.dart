import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/glass_panel.dart';
import '../widgets/luxury_card.dart';
import 'account_screen.dart';
import 'digital_card_screen.dart';
import 'spei_deposit_screen.dart';
import 'transactions_screen.dart';
import 'transfer_screen.dart';

class HomeVaultScreen extends StatefulWidget {
  final UserSession user;

  const HomeVaultScreen({super.key, required this.user});

  @override
  State<HomeVaultScreen> createState() => _HomeVaultScreenState();
}

class _HomeVaultScreenState extends State<HomeVaultScreen> {
  List<TransactionItem> _recentTransactions = [];
  bool _isLoadingTxs = true;

  @override
  void initState() {
    super.initState();
    _fetchRecentTransactions();
  }

  Future<void> _fetchRecentTransactions() async {
    try {
      final txs = await ApiService.instance.getTransactions(widget.user.accountNumber);
      if (mounted) {
        setState(() {
          _recentTransactions = txs.take(4).toList();
          _isLoadingTxs = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingTxs = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserSession?>(
      valueListenable: AuthService.instance.currentSession,
      builder: (context, liveUser, _) {
        final currentUser = liveUser ?? widget.user;

        return CupertinoPageScaffold(
          backgroundColor: LuxevaTheme.obsidianBg,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: LuxevaTheme.glassBg,
            leading: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).push(
                  CupertinoPageRoute(builder: (_) => AccountScreen(user: currentUser)),
                );
              },
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [LuxevaTheme.goldLight, LuxevaTheme.goldAccent],
                  ),
                ),
                child: Center(
                  child: Text(
                    currentUser.initials,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: LuxevaTheme.obsidianBg,
                    ),
                  ),
                ),
              ),
            ),
            middle: const Text(
              'LUXEVA',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 3.0,
                color: LuxevaTheme.textPrimary,
              ),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.bell, size: 20, color: LuxevaTheme.textPrimary),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).push(
                  CupertinoPageRoute(builder: (_) => TransactionsScreen(user: currentUser)),
                );
              },
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              children: [
                // Available Balance Container
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'SALDO DISPONIBLE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                          color: LuxevaTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentUser.formattedBalance,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: LuxevaTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Physical Metal Card Widget
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (_) => DigitalCardScreen(user: currentUser)),
                    );
                  },
                  child: LuxuryCardWidget(user: currentUser),
                ),
                const SizedBox(height: 24),

                // Quick Actions Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(
                      icon: CupertinoIcons.arrow_up_right,
                      label: 'Transferir',
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(builder: (_) => TransferScreen(user: currentUser)),
                        );
                      },
                    ),
                    _buildActionButton(
                      icon: CupertinoIcons.plus,
                      label: 'Depositar',
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(builder: (_) => SpeiDepositScreen(user: currentUser)),
                        );
                      },
                    ),
                    _buildActionButton(
                      icon: CupertinoIcons.creditcard,
                      label: 'Tarjeta',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).push(
                          CupertinoPageRoute(builder: (_) => DigitalCardScreen(user: currentUser)),
                        );
                      },
                    ),
                    _buildActionButton(
                      icon: CupertinoIcons.list_bullet,
                      label: 'Historial',
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(builder: (_) => TransactionsScreen(user: currentUser)),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Recent Operations Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ÚLTIMOS MOVIMIENTOS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: LuxevaTheme.textSecondary,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text(
                        'Ver todos',
                        style: TextStyle(fontSize: 12, color: LuxevaTheme.goldAccent, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(builder: (_) => TransactionsScreen(user: currentUser)),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Recent Operations List
                if (_isLoadingTxs)
                  const Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Center(child: CupertinoActivityIndicator(color: LuxevaTheme.goldAccent)),
                  )
                else if (_recentTransactions.isEmpty)
                  GlassPanel(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(CupertinoIcons.tray, size: 30, color: LuxevaTheme.goldAccent),
                          SizedBox(height: 8),
                          Text(
                            'SIN MOVIMIENTOS RECIENTES',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: LuxevaTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._recentTransactions.map((tx) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: GlassPanel(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          borderRadius: 16,
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: tx.isPositive
                                      ? LuxevaTheme.greenPositive.withOpacity(0.12)
                                      : LuxevaTheme.goldAccent.withOpacity(0.12),
                                ),
                                child: Icon(
                                  tx.isPositive
                                      ? CupertinoIcons.arrow_down_left
                                      : CupertinoIcons.arrow_up_right,
                                  size: 16,
                                  color: tx.isPositive
                                      ? LuxevaTheme.greenPositive
                                      : LuxevaTheme.goldAccent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tx.description,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: LuxevaTheme.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      tx.createdAt,
                                      style: const TextStyle(fontSize: 11, color: LuxevaTheme.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                tx.formattedAmount,
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: tx.isPositive
                                      ? LuxevaTheme.greenPositive
                                      : LuxevaTheme.redNegative,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: LuxevaTheme.cardElevated,
              border: Border.all(color: LuxevaTheme.borderGold, width: 1.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x30000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, size: 20, color: LuxevaTheme.goldAccent),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: LuxevaTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
