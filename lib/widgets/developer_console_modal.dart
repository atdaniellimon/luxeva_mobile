import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/developer_service.dart';
import 'dynamic_notice.dart';
import 'glass_panel.dart';

class DeveloperConsoleModal extends StatefulWidget {
  final UserSession user;

  const DeveloperConsoleModal({super.key, required this.user});

  static void show(BuildContext context, UserSession user) {
    HapticFeedback.mediumImpact();
    showCupertinoModalPopup(
      context: context,
      builder: (_) => DeveloperConsoleModal(user: user),
    );
  }

  @override
  State<DeveloperConsoleModal> createState() => _DeveloperConsoleModalState();
}

class _DeveloperConsoleModalState extends State<DeveloperConsoleModal> {
  final TextEditingController _customAmountController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  Future<void> _handleFaucet(double amount) async {
    setState(() => _isProcessing = true);
    await DeveloperService.instance.applyFaucet(
      context,
      accountNumber: widget.user.accountNumber,
      amount: amount,
    );
    if (mounted) setState(() => _isProcessing = false);
  }

  Future<void> _handleSimulatedPOS() async {
    HapticFeedback.lightImpact();
    setState(() => _isProcessing = true);
    try {
      await ApiService.instance.sendTransfer(
        accountNumber: widget.user.accountNumber,
        to: 'Terminal POS Hermès Masaryk',
        amount: 2850.00,
        concept: 'Compra con Tarjeta Luxeva',
      );
      await AuthService.instance.refreshBalance();
      if (mounted) {
        DynamicNotice.show(
          context,
          message: 'Compra POS Simulada',
          subtitle: '-\$2,850.00 MXN • Hermès Masaryk',
          icon: CupertinoIcons.creditcard_fill,
        );
      }
    } catch (e) {
      if (mounted) {
        DynamicNotice.show(
          context,
          message: 'Error en Simulación',
          subtitle: e.toString(),
          icon: CupertinoIcons.exclamationmark_circle,
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleSimulatedATM() async {
    HapticFeedback.lightImpact();
    setState(() => _isProcessing = true);
    try {
      await ApiService.instance.sendTransfer(
        accountNumber: widget.user.accountNumber,
        to: 'ATM Luxeva Polanco 01',
        amount: 3000.00,
        concept: 'Dispensación de Efectivo ATM',
      );
      await AuthService.instance.refreshBalance();
      if (mounted) {
        DynamicNotice.show(
          context,
          message: 'Retiro ATM Simulado',
          subtitle: '-\$3,000.00 MXN • ATM Luxeva Polanco',
          icon: CupertinoIcons.money_dollar_circle_fill,
        );
      }
    } catch (e) {
      if (mounted) {
        DynamicNotice.show(
          context,
          message: 'Error en Simulación',
          subtitle: e.toString(),
          icon: CupertinoIcons.exclamationmark_circle,
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleSimulatedInwardSPEI() async {
    HapticFeedback.lightImpact();
    setState(() => _isProcessing = true);
    try {
      await ApiService.instance.instantFund(
        accountNumber: widget.user.accountNumber,
        amount: 15000.00,
      );
      await AuthService.instance.refreshBalance();
      if (mounted) {
        DynamicNotice.show(
          context,
          message: 'Depósito SPEI Acreditado',
          subtitle: '+\$15,000.00 MXN • Folio Banxico STP-9481',
          icon: CupertinoIcons.arrow_down_circle_fill,
        );
      }
    } catch (e) {
      if (mounted) {
        DynamicNotice.show(
          context,
          message: 'Error en Simulación',
          subtitle: e.toString(),
          icon: CupertinoIcons.exclamationmark_circle,
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: GlassPanel(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        borderRadius: 28,
        backgroundColor: const Color(0xF00D0E13),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Grabber pill
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: LuxevaTheme.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0x28FF9F0A),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0x60FF9F0A), width: 0.5),
                        ),
                        child: const Text(
                          'SANDBOX',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: LuxevaTheme.amberSandbox,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Consola Developer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: LuxevaTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Icon(CupertinoIcons.xmark_circle_fill, size: 22, color: LuxevaTheme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 1. FAUCET / SALDO DEMO
              const Text(
                'BÓVEDA FAUCET (INYECCIÓN DE FONDOS)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: LuxevaTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildFaucetChip('+\$5,000', 5000.0)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildFaucetChip('+\$25,000', 25000.0)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildFaucetChip('+\$100,000', 100000.0)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: _customAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      placeholder: 'Monto personalizado MXN',
                      placeholderStyle: const TextStyle(fontSize: 13, color: LuxevaTheme.textMuted),
                      style: const TextStyle(fontSize: 13, color: LuxevaTheme.textPrimary),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0x18FFFFFF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: LuxevaTheme.borderSubtle, width: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    color: LuxevaTheme.goldAccent,
                    borderRadius: BorderRadius.circular(10),
                    onPressed: _isProcessing
                        ? null
                        : () {
                            final val = double.tryParse(_customAmountController.text.trim());
                            if (val != null && val > 0) {
                              _handleFaucet(val);
                              _customAmountController.clear();
                            }
                          },
                    child: const Text(
                      'Cargar',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: LuxevaTheme.obsidianBg),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. CONMUTADOR DE CUENTAS (MULTI-CUENTA)
              const Text(
                'CONMUTADOR DE CUENTAS SANDBOX',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: LuxevaTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0x12FFFFFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: LuxevaTheme.borderSubtle, width: 0.5),
                ),
                child: Column(
                  children: DeveloperService.sandboxMembers.map((member) {
                    final isCurrent = widget.user.accountNumber == member.accountNumber;
                    return GestureDetector(
                      onTap: () async {
                        if (!isCurrent) {
                          await DeveloperService.instance.switchToSandboxAccount(context, member);
                          if (context.mounted) Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: isCurrent ? const Color(0x18CBBD93) : CupertinoColors.transparent,
                          border: Border(
                            bottom: BorderSide(
                              color: member == DeveloperService.sandboxMembers.last
                                  ? CupertinoColors.transparent
                                  : LuxevaTheme.borderSubtle,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isCurrent ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.person_crop_circle,
                                  size: 18,
                                  color: isCurrent ? LuxevaTheme.goldAccent : LuxevaTheme.textSecondary,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member.fullName,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                                        color: isCurrent ? LuxevaTheme.goldLight : LuxevaTheme.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${member.accountNumber} • ${member.email}',
                                      style: const TextStyle(fontSize: 10, color: LuxevaTheme.textSecondary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0x12FFFFFF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                member.tier.toUpperCase(),
                                style: const TextStyle(fontSize: 9, letterSpacing: 0.8, color: LuxevaTheme.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // 3. SIMULADOR DE MOVIMIENTOS
              const Text(
                'SIMULADOR DE EVENTOS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: LuxevaTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildSimulateButton(
                      icon: CupertinoIcons.creditcard,
                      label: 'POS Masaryk',
                      subtitle: '-\$2,850 MXN',
                      onTap: _isProcessing ? null : _handleSimulatedPOS,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSimulateButton(
                      icon: CupertinoIcons.money_dollar,
                      label: 'ATM Luxeva',
                      subtitle: '-\$3,000 MXN',
                      onTap: _isProcessing ? null : _handleSimulatedATM,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSimulateButton(
                      icon: CupertinoIcons.arrow_down_left,
                      label: 'SPEI Inward',
                      subtitle: '+\$15,000 MXN',
                      onTap: _isProcessing ? null : _handleSimulatedInwardSPEI,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 4. SALIR DE MODO DESARROLLADOR
              CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: const Color(0x14FFFFFF),
                borderRadius: BorderRadius.circular(12),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  DeveloperService.instance.setDeveloperMode(false);
                  Navigator.of(context).pop();
                  DynamicNotice.show(
                    context,
                    message: 'Modo Developer Desactivado',
                    subtitle: 'Has vuelto al modo estándar de socio',
                    icon: CupertinoIcons.lock,
                  );
                },
                child: const Text(
                  'Desactivar Modo Developer',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: LuxevaTheme.redNegative),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaucetChip(String label, double amount) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: const Color(0x16FFFFFF),
      borderRadius: BorderRadius.circular(10),
      onPressed: _isProcessing ? null : () => _handleFaucet(amount),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: LuxevaTheme.goldLight),
      ),
    );
  }

  Widget _buildSimulateButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0x14FFFFFF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: LuxevaTheme.borderSubtle, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: LuxevaTheme.goldLight),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: LuxevaTheme.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 9, color: LuxevaTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
