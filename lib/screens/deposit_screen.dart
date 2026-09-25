import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/luxeva_theme.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final _amountController = TextEditingController();
  final _trackingController = TextEditingController();
  SpeiDetails? _spei;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchSpei();
  }

  Future<void> _fetchSpei() async {
    final session = ApiService.instance.currentSession;
    if (session != null) {
      try {
        final data = await ApiService.instance.getSpeiInstructions(session.accountNumber);
        if (mounted) {
          setState(() {
            _spei = data;
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

  void _setAmount(double amount) {
    HapticFeedback.selectionClick();
    _amountController.text = amount.toStringAsFixed(2);
  }

  void _copy(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    _showToast('$label copiado al portapapeles');
  }

  Future<void> _handleConfirm() async {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      _showToast('Ingresa un importe válido a fondear');
      return;
    }

    final session = ApiService.instance.currentSession;
    if (session == null) return;

    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);

    try {
      await ApiService.instance.confirmSpeiDeposit(
        accountNumber: session.accountNumber,
        amount: amount,
        concept: _spei?.concept ?? session.accountNumber,
        trackingKey: _trackingController.text.trim().isEmpty ? null : _trackingController.text.trim(),
      );

      HapticFeedback.lightImpact();
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Acreditación Exitosa'),
            content: Text('Se han acreditado \$${amount.toStringAsFixed(2)} MXN a tu patrimonio líquido.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Continuar', style: TextStyle(color: LuxevaTheme.accentGold)),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      _showToast(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showToast(String msg) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Banca Privada Luxeva'),
        content: Text(msg),
        actions: [
          CupertinoDialogAction(
            child: const Text('Aceptar', style: TextStyle(color: LuxevaTheme.accentGold)),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spei = _spei;

    return CupertinoPageScaffold(
      backgroundColor: LuxevaTheme.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xE609090B),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.chevron_back, color: LuxevaTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        middle: const Text(
          'LUXEVA',
          style: TextStyle(fontFamily: 'serif', letterSpacing: 2, color: LuxevaTheme.textPrimary),
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator(color: LuxevaTheme.accentGold))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Acreditación de Capital',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: LuxevaTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'CÁMARA DE COMPENSACIÓN SPEI · BANCO DE MÉXICO',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                        color: LuxevaTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tarjeta Bancaria Institucional SPEI
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: LuxevaTheme.goldBorderCardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'LUXEVA PRIVATE BANKING',
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  color: LuxevaTheme.accentGold,
                                ),
                              ),
                              Text(
                                'LIQUIDACIÓN MXN',
                                style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w600,
                                  color: LuxevaTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          _buildDetailRow(
                            label: 'INSTITUCIÓN BANCARIA RECEPTORA',
                            value: spei?.bankName ?? 'Spin by OXXO',
                          ),
                          const SizedBox(height: 14),

                          _buildDetailRow(
                            label: 'CLABE INTERBANCARIA INSTITUCIONAL',
                            value: spei?.formattedClabe ?? '7289 6900 0044 9893 06',
                            isHighlight: true,
                            onCopy: () => _copy(spei?.clabe ?? '728969000044989306', 'CLABE'),
                          ),
                          const SizedBox(height: 14),

                          _buildDetailRow(
                            label: 'BENEFICIARIO ACREDITADO',
                            value: spei?.beneficiary ?? 'Luxeva',
                            onCopy: () => _copy(spei?.beneficiary ?? 'Luxeva', 'Beneficiario'),
                          ),
                          const SizedBox(height: 14),

                          _buildDetailRow(
                            label: 'CONCEPTO DE OPERACIÓN / FOLIO',
                            value: spei?.concept ?? 'LX-000000',
                            isHighlight: true,
                            onCopy: () => _copy(spei?.concept ?? 'LX-000000', 'Concepto'),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Folio exclusivo para acreditación inmediata en su cuenta patrimonial.',
                            style: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              color: LuxevaTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Monto y Píldoras Rápidas
                    const Text(
                      'IMPORTE A FONDEAR (MXN)',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                        color: LuxevaTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 14),
                        child: Text('\$', style: TextStyle(color: LuxevaTheme.accentGold, fontSize: 18)),
                      ),
                      placeholder: '0.00',
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0x1AFFFFFF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: LuxevaTheme.borderSubtle),
                      ),
                      style: const TextStyle(color: LuxevaTheme.textPrimary, fontSize: 18),
                      placeholderStyle: const TextStyle(color: LuxevaTheme.textMuted),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        _buildQuickAmount(100),
                        const SizedBox(width: 8),
                        _buildQuickAmount(250),
                        const SizedBox(width: 8),
                        _buildQuickAmount(500),
                        const SizedBox(width: 8),
                        _buildQuickAmount(1000),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'CLAVE DE RASTREO BANXICO (OPCIONAL)',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                        color: LuxevaTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _trackingController,
                      placeholder: 'Folio numérico o alfanumérico SPEI',
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0x1AFFFFFF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: LuxevaTheme.borderSubtle),
                      ),
                      style: const TextStyle(color: LuxevaTheme.textPrimary),
                      placeholderStyle: const TextStyle(color: LuxevaTheme.textMuted),
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: CupertinoButton(
                        color: LuxevaTheme.accentGold,
                        borderRadius: BorderRadius.circular(14),
                        onPressed: _isSubmitting ? null : _handleConfirm,
                        child: _isSubmitting
                            ? const CupertinoActivityIndicator(color: LuxevaTheme.background)
                            : const Text(
                                'Instruir Acreditación Inmediata',
                                style: TextStyle(
                                  color: LuxevaTheme.background,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    bool isHighlight = false,
    VoidCallback? onCopy,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
            color: LuxevaTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0x0DFFFFFF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0x1AFFFFFF)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
                  color: isHighlight ? LuxevaTheme.accentGold : LuxevaTheme.textPrimary,
                  fontFamily: isHighlight ? 'Courier' : null,
                ),
              ),
              if (onCopy != null)
                GestureDetector(
                  onTap: onCopy,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: LuxevaTheme.borderGold),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'COPIAR',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                        color: LuxevaTheme.accentGold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAmount(double amount) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _setAmount(amount),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0x1ACBBD93),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: LuxevaTheme.borderGold),
          ),
          child: Center(
            child: Text(
              '\$${amount.toInt()}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: LuxevaTheme.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
