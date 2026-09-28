import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/developer_service.dart';
import '../widgets/cash_withdrawal_modal.dart';
import '../widgets/developer_console_modal.dart';
import '../widgets/dynamic_notice.dart';
import '../widgets/notifications_sheet.dart';
import 'account_screen.dart';
import 'spei_deposit_screen.dart';
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
  int _secretDevTapCount = 0;
  DateTime? _lastDevTapTime;

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
          _recentTransactions = txs.take(6).toList();
          _isLoadingTxs = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingTxs = false);
    }
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    await Future.wait([
      AuthService.instance.refreshBalance(),
      _fetchRecentTransactions(),
    ]);
  }

  void _handleSecretDevTap() {
    final now = DateTime.now();
    if (_lastDevTapTime == null || now.difference(_lastDevTapTime!).inSeconds > 2) {
      _secretDevTapCount = 1;
    } else {
      _secretDevTapCount++;
    }
    _lastDevTapTime = now;

    if (_secretDevTapCount < 5) {
      HapticFeedback.selectionClick();
    } else {
      _secretDevTapCount = 0;
      HapticFeedback.heavyImpact();
      final current = DeveloperService.instance.isDeveloperMode.value;
      final target = !current;
      DeveloperService.instance.setDeveloperMode(target);

      DynamicNotice.show(
        context,
        message: target ? 'Modo Developer Habilitado' : 'Modo Developer Desactivado',
        subtitle: target ? 'Toca la etiqueta SANDBOX para abrir la consola' : 'Retornaste al modo de socio real',
        icon: target ? CupertinoIcons.wrench_fill : CupertinoIcons.lock_fill,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserSession?>(
      valueListenable: AuthService.instance.currentSession,
      builder: (context, liveUser, _) {
        final currentUser = liveUser ?? widget.user;

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
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [LuxevaTheme.goldLight, LuxevaTheme.goldAccent],
                      ),
                      border: Border.all(color: LuxevaTheme.borderGold, width: 0.5),
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
                middle: GestureDetector(
                  onTap: _handleSecretDevTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'LUXEVA',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3.5,
                          color: LuxevaTheme.textPrimary,
                        ),
                      ),
                      if (isDev) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => DeveloperConsoleModal.show(context, currentUser),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0x30FF9F0A),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0x70FF9F0A), width: 0.5),
                            ),
                            child: const Text(
                              'SANDBOX',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: LuxevaTheme.amberSandbox,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isDev)
                      CupertinoButton(
                        padding: const EdgeInsets.only(right: 8),
                        child: const Icon(CupertinoIcons.wrench, size: 18, color: LuxevaTheme.amberSandbox),
                        onPressed: () => DeveloperConsoleModal.show(context, currentUser),
                      ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Icon(CupertinoIcons.bell, size: 20, color: LuxevaTheme.textPrimary),
                      onPressed: () => NotificationsSheet.show(context),
                    ),
                  ],
                ),
              ),
              child: SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    CupertinoSliverRefreshControl(
                      onRefresh: _handleRefresh,
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 1. Available Balance (Optical Typography with Tabular Figures)
                            const Text(
                              'SALDO DISPONIBLE EN BÓVEDA',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.0,
                                color: LuxevaTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              currentUser.formattedBalance,
                              style: LuxevaTheme.tabularFigures(
                                fontFamily: 'Georgia',
                                fontSize: 38,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                                color: LuxevaTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // 2. Primary Operations Capsule Row (Apple Wallet Style)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildOperationCapsule(
                                    icon: CupertinoIcons.arrow_up_right,
                                    label: 'Transferir',
                                    onTap: () {
                                      Navigator.of(context).push(
                                        CupertinoPageRoute(builder: (_) => TransferScreen(user: currentUser)),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildOperationCapsule(
                                    icon: CupertinoIcons.plus,
                                    label: 'Depositar',
                                    onTap: () {
                                      Navigator.of(context).push(
                                        CupertinoPageRoute(builder: (_) => SpeiDepositScreen(user: currentUser)),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildOperationCapsule(
                                    icon: CupertinoIcons.money_dollar_circle,
                                    label: 'Efectivo',
                                    onTap: () {
                                      CashWithdrawalModal.show(context, currentUser);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 36),

                            // 3. Recent Activity Section Header
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'ACTIVIDAD RECIENTE',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.6,
                                  color: LuxevaTheme.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 4. Activity List (Apple Wallet Grouped Inset)
                            if (_isLoadingTxs)
                              const Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Center(child: CupertinoActivityIndicator(color: LuxevaTheme.goldAccent)),
                              )
                            else if (_recentTransactions.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 36),
                                decoration: BoxDecoration(
                                  color: LuxevaTheme.surfaceLayer,
                                  borderRadius: BorderRadius.circular(LuxevaTheme.radiusStandard),
                                  border: Border.all(color: LuxevaTheme.borderSubtle, width: LuxevaTheme.hairline),
                                ),
                                child: const Center(
                                  child: Column(
                                    children: [
                                      Icon(CupertinoIcons.tray, size: 28, color: LuxevaTheme.textSecondary),
                                      SizedBox(height: 10),
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
                              Container(
                                decoration: BoxDecoration(
                                  color: LuxevaTheme.surfaceLayer,
                                  borderRadius: BorderRadius.circular(LuxevaTheme.radiusStandard),
                                  border: Border.all(color: LuxevaTheme.borderSubtle, width: LuxevaTheme.hairline),
                                ),
                                child: Column(
                                  children: _recentTransactions.asMap().entries.map((entry) {
                                    final idx = entry.key;
                                    final tx = entry.value;
                                    final isLast = idx == _recentTransactions.length - 1;

                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: isLast ? CupertinoColors.transparent : LuxevaTheme.dividerColor,
                                            width: LuxevaTheme.hairline,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: tx.isPositive
                                                  ? LuxevaTheme.greenPositive.withOpacity(0.12)
                                                  : const Color(0x18FFFFFF),
                                            ),
                                            child: Icon(
                                              tx.isPositive
                                                  ? CupertinoIcons.arrow_down_left
                                                  : CupertinoIcons.arrow_up_right,
                                              size: 15,
                                              color: tx.isPositive
                                                  ? LuxevaTheme.greenPositive
                                                  : LuxevaTheme.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
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
                                            style: LuxevaTheme.tabularFigures(
                                              fontFamily: 'Georgia',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: tx.isPositive
                                                  ? LuxevaTheme.greenPositive
                                                  : LuxevaTheme.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOperationCapsule({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: LuxevaTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(LuxevaTheme.radiusStandard),
          border: Border.all(color: LuxevaTheme.borderSubtle, width: LuxevaTheme.hairline),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: LuxevaTheme.goldAccent),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: LuxevaTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
