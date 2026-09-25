import 'package:flutter/cupertino.dart';
import '../config/theme.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../widgets/glass_panel.dart';

class TransactionsScreen extends StatefulWidget {
  final UserSession user;

  const TransactionsScreen({super.key, required this.user});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<TransactionItem> _transactions = [];
  bool _isLoading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
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

  void _showDetailSheet(TransactionItem tx) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(
          tx.formattedAmount,
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: tx.isPositive ? LuxevaTheme.greenPositive : LuxevaTheme.redNegative,
          ),
        ),
        message: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Text(
                tx.description,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: LuxevaTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Fecha: ${tx.createdAt}',
                style: const TextStyle(fontSize: 13, color: LuxevaTheme.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                'Folio de Auditoría: ${tx.id.isNotEmpty ? tx.id : "LX-7721"}',
                style: const TextStyle(fontSize: 12, fontFamily: 'Courier', color: LuxevaTheme.goldAccent),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0x1834C759),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'COMPLETADO · CÁMARA DE COMPENSACIÓN',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: LuxevaTheme.greenPositive),
                ),
              ),
            ],
          ),
        ),
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cerrar', style: TextStyle(color: LuxevaTheme.goldAccent)),
          onPressed: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _transactions.where((tx) {
      if (_filter == 'income') return tx.isPositive;
      if (_filter == 'expense') return !tx.isPositive;
      return true;
    }).toList();

    return CupertinoPageScaffold(
      backgroundColor: LuxevaTheme.obsidianBg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: LuxevaTheme.glassBg,
        middle: const Text('BITÁCORA DE OPERACIONES', style: TextStyle(letterSpacing: 1.5, fontSize: 13)),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.chevron_left, color: LuxevaTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Filter Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: CupertinoSlidingSegmentedControl<String>(
                groupValue: _filter,
                backgroundColor: const Color(0x14FFFFFF),
                thumbColor: LuxevaTheme.cardElevated,
                children: const {
                  'all': Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Text('Todos', style: TextStyle(fontSize: 12, color: LuxevaTheme.textPrimary)),
                  ),
                  'income': Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Text('Acreditaciones', style: TextStyle(fontSize: 12, color: LuxevaTheme.textPrimary)),
                  ),
                  'expense': Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Text('Dispersiones', style: TextStyle(fontSize: 12, color: LuxevaTheme.textPrimary)),
                  ),
                },
                onValueChanged: (val) {
                  if (val != null) setState(() => _filter = val);
                },
              ),
            ),

            // Transaction List
            Expanded(
              child: _isLoading
                  ? const Center(child: CupertinoActivityIndicator(color: LuxevaTheme.goldAccent))
                  : filtered.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.tray, size: 36, color: LuxevaTheme.goldAccent),
                              SizedBox(height: 10),
                              Text(
                                'SIN MOVIMIENTOS REGISTRADOS',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                  color: LuxevaTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final tx = filtered[index];
                            return GestureDetector(
                              onTap: () => _showDetailSheet(tx),
                              child: GlassPanel(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                borderRadius: 16,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
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
                                        size: 18,
                                        color: tx.isPositive
                                            ? LuxevaTheme.greenPositive
                                            : LuxevaTheme.goldAccent,
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
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
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
                                        fontFamily: 'Georgia',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: tx.isPositive
                                            ? LuxevaTheme.greenPositive
                                            : LuxevaTheme.redNegative,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
