import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../theme/luxeva_theme.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback onSignupSuccess;
  const SignupScreen({super.key, required this.onSignupSuccess});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSignup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      _showToast('Completa todos los requerimientos');
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      await ApiService.instance.signup(name, email, pass);
      HapticFeedback.lightImpact();
      if (mounted) {
        Navigator.pop(context);
        widget.onSignupSuccess();
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      _showToast(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 16,
            letterSpacing: 2,
            color: LuxevaTheme.textPrimary,
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Apertura de Cuenta Digital',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: LuxevaTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Incorporación al Ecosistema Luxeva Private Banking',
                style: TextStyle(
                  fontSize: 12,
                  color: LuxevaTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(22),
                decoration: LuxevaTheme.glassCardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NOMBRE COMPLETO DEL TITULAR',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                        color: LuxevaTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _nameController,
                      placeholder: 'Nombre y Apellidos',
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
                      'IDENTIFICADOR DE ACCESO (EMAIL)',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                        color: LuxevaTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _emailController,
                      placeholder: 'socio@luxeva.com',
                      keyboardType: TextInputType.emailAddress,
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
                      'CLAVE DE SEGURIDAD INSTITUCIONAL',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                        color: LuxevaTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _passwordController,
                      obscureText: true,
                      placeholder: '••••••••',
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
                        onPressed: _isLoading ? null : _handleSignup,
                        child: _isLoading
                            ? const CupertinoActivityIndicator(color: LuxevaTheme.background)
                            : const Text(
                                'Emitir Credenciales de Socio',
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
