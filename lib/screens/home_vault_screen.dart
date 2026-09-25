import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/luxeva_theme.dart';
import 'deposit_screen.dart';
import 'transfer_screen.dart';

class HomeVaultScreen extends StatefulWidget {
  final Function(int) onTabChange;
  const HomeVaultScreen({super.key, required this.onTabChange});

  @override
  State<HomeVaultScreen> createState() => _HomeVaultScreenState();
}

class _HomeVaultScreenState extends State<HomeVaultScreen> {
  UserSession? _session;
  List<TransactionItem> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _session = ApiService.instance.currentSession ?? await ApiService.instance.loadSession();
    if (_session != null && _session!.accountNumber.isNotEmpty) {
      try {
        final bal = await ApiService.instance.refreshBalance(_session!.accountNumber);
        final txs = await ApiService.instance.getTransactions(_session!.accountNumber);
        if (mounted) {
          setState(() {
            _session = _session!.copyWith(balance: bal);
            _transactions = txs;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showConciergeSheet() {
    HapticFeedback.lightImpact();
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text(
          'Banca Privada Institucional',
          style: TextStyle(fontFamily: 'serif', letterSpacing: 1),
        ),
        message: const Text('Oficial de Cuenta Privado asignado: Lic. Rodrigo Valenzuela (Luxeva Prime Desk)'),
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Llamar a Mesa de Dinero', style: TextStyle(color: LuxevaTheme.accentGold)),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoActionSheetAction(
            child: const Text('Solicitar Línea de Crédito Privada', style: TextStyle(color: LuxevaTheme.accentGold)),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoActionSheetAction(
            child: const Text('Auditoría Fiscal y Patrimonial', style: TextStyle(color: LuxevaTheme.textPrimary)),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          child: const Text('Cerrar'),
          onPressed: () => Navigator.pop(ctx),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;

    return CupertinoPageScaffold(
      backgroundColor: LuxevaTheme.background,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: _loadData,
            ),
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => widget.onTabChange(3), // Navigate to account tab
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [LuxevaTheme.accentGoldLight, LuxevaTheme.accentGold],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(color: Color(0x33CBBD93), blurRadius: 10, offset: Offset(0, 3)),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            session?.initials ?? 'LX',
                            style: const TextStyle(
                              color: LuxevaTheme.background,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      'LUXEVA',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 18,
                        letterSpacing: 3,
                        fontWeight: FontWeight.bold,
                        color: LuxevaTheme.textPrimary,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Icon(CupertinoIcons.bell, color: LuxevaTheme.textPrimary, size: 22),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Hero Balance Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  children: [
                    const Text(
                      'PATRIMONIO LÍQUIDO DISPONIBLE',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.8,
                        fontWeight: FontWeight.w600,
                        color: LuxevaTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      session?.formattedBalance ?? '\$0.00 MXN',
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 40,
                        letterSpacing: -1,
                        fontWeight: FontWeight.w500,
                        color: LuxevaTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Quick Actions Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: CupertinoIcons.arrow_up_right,
                      label: 'Transferir',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (_) => const TransferScreen()),
                        ).then((_) => _loadData());
                      },
                    ),
                    _buildActionButton(
                      icon: CupertinoIcons.plus,
                      label: 'Fondear',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (_) => const DepositScreen()),
                        ).then((_) => _loadData());
                      },
                    ),
                    _buildActionButton(
                      icon: CupertinoIcons.creditcard,
                      label: 'Instrumentos',
                      onTap: () => widget.onTabChange(2),
                    ),
                    _buildActionButton(
                      icon: CupertinoIcons.ellipsis,
                      label: 'Banca Privada',
                      onTap: _showConciergeSheet,
                    ),
                  ],
                ),
              ),
            ),

            // Transactions Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 36, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bitácora de Operaciones',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: LuxevaTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${_transactions.length} registros',
                      style: const TextStyle(
                        fontSize: 12,
                        color: LuxevaTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Transactions List or Empty State
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CupertinoActivityIndicator(color: LuxevaTheme.accentGold)),
              )
            else if (_transactions.isEmpty)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: LuxevaTheme.glassCardDecoration,
                  child: const Column(
                    children: [
                      Icon(CupertinoIcons.tray, size: 36, color: LuxevaTheme.accentGold),
                      SizedBox(height: 12),
                      Text(
                        'SIN MOVIMIENTOS AÚN',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                          color: LuxevaTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final tx = _transactions[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: LuxevaTheme.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: LuxevaTheme.borderSubtle),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: tx.isPositive
                                    ? const Color(0x1A34C759)
                                    : const Color(0x1AFF453A),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                tx.isPositive
                                    ? CupertinoIcons.arrow_down_left
                                    : CupertinoIcons.arrow_up_right,
                                color: tx.isPositive
                                    ? LuxevaTheme.greenPositive
                                    : LuxevaTheme.redNegative,
                                size: 18,
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
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: LuxevaTheme.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    tx.createdAt,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: LuxevaTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              tx.formattedAmount,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: tx.isPositive
                                    ? LuxevaTheme.greenPositive
                                    : LuxevaTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: _transactions.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0x1ACBBD93),
              shape: BoxShape.circle,
              border: Border.all(color: LuxevaTheme.borderGold, width: 1.2),
            ),
            child: Icon(icon, color: LuxevaTheme.accentGold, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: LuxevaTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
