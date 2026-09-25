import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../theme/luxeva_theme.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _toController = TextEditingController();
  final _amountController = TextEditingController();
  final _conceptController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _handleTransfer() async {
    final to = _toController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final concept = _conceptController.text.trim().isEmpty ? 'Transferencia' : _conceptController.text.trim();

    if (to.isEmpty) {
      _showToast('Ingresa el beneficiario o CLABE receptora');
      return;
    }
    if (amount <= 0) {
      _showToast('Ingresa un importe válido a transferir');
      return;
    }

    final session = ApiService.instance.currentSession;
    if (session == null) return;

    if (amount > session.balance) {
      _showToast('Fondos insuficientes para esta operación');
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);

    try {
      await ApiService.instance.sendTransfer(
        accountNumber: session.accountNumber,
        recipient: to,
        amount: amount,
        concept: concept,
      );

      HapticFeedback.lightImpact();
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Transferencia SPEI Enviada'),
            content: Text('Se han transferido \$${amount.toStringAsFixed(2)} MXN exitosamente a $to.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Aceptar', style: TextStyle(color: LuxevaTheme.accentGold)),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transferencia de Capital',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: LuxevaTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'DISPERSIÓN INTERBANCARIA SPEI BANXICO',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                  color: LuxevaTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(22),
                decoration: LuxevaTheme.glassCardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BENEFICIARIO O CLABE (18 DÍGITOS)',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                        color: LuxevaTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _toController,
                      placeholder: 'CLABE, Tarjeta o Cuenta',
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0x1AFFFFFF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: LuxevaTheme.borderSubtle),
                      ),
                      style: const TextStyle(color: LuxevaTheme.textPrimary),
                      placeholderStyle: const TextStyle(color: LuxevaTheme.textMuted),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'IMPORTE A TRANSFERIR (MXN)',
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
                    const SizedBox(height: 20),

                    const Text(
                      'CONCEPTO DE OPERACIÓN',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                        color: LuxevaTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _conceptController,
                      placeholder: 'Honorarios, Liquidación, etc.',
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
                        onPressed: _isSubmitting ? null : _handleTransfer,
                        child: _isSubmitting
                            ? const CupertinoActivityIndicator(color: LuxevaTheme.background)
                            : const Text(
                                'Ejecutar Instrucción SPEI',
                                style: TextStyle(
                                  color: LuxevaTheme.background,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  letterSpacing: 0.5,
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
      ),
    );
  }
}
