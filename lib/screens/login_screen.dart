import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../theme/luxeva_theme.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _canBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final available = await ApiService.instance.canUseBiometrics();
    setState(() => _canBiometrics = available);
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      _showToast('Completa las credenciales de acceso');
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      await ApiService.instance.login(email, pass);
      HapticFeedback.lightImpact();
      widget.onLoginSuccess();
    } catch (e) {
      HapticFeedback.heavyImpact();
      _showToast(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleBiometricLogin() async {
    final success = await ApiService.instance.authenticateBiometrics();
    if (success) {
      final saved = await ApiService.instance.loadSession();
      if (saved != null) {
        HapticFeedback.lightImpact();
        widget.onLoginSuccess();
      } else {
        _showToast('Inicia sesión con contraseña la primera vez');
      }
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
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Logo & Prestige Title
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [LuxevaTheme.accentGoldLight, LuxevaTheme.accentGold],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x40CBBD93),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'LX',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: LuxevaTheme.background,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'LUXEVA',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 28,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                    color: LuxevaTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'WEALTH & PRIVATE BANKING',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                    color: LuxevaTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 48),

                // Form Container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: LuxevaTheme.glassCardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'IDENTIFICADOR DE ACCESO',
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

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: CupertinoButton(
                          color: LuxevaTheme.accentGold,
                          borderRadius: BorderRadius.circular(14),
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading
                              ? const CupertinoActivityIndicator(color: LuxevaTheme.background)
                              : const Text(
                                  'Acceder al Club Privado',
                                  style: TextStyle(
                                    color: LuxevaTheme.background,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),

                      if (_canBiometrics) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: CupertinoButton(
                            color: const Color(0x14CBBD93),
                            borderRadius: BorderRadius.circular(14),
                            onPressed: _handleBiometricLogin,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.viewfinder, color: LuxevaTheme.accentGold, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Acceder con Face ID',
                                  style: TextStyle(
                                    color: LuxevaTheme.accentGold,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => SignupScreen(onSignupSuccess: widget.onLoginSuccess),
                      ),
                    );
                  },
                  child: const Text(
                    '¿Sin credenciales? Solicitar Membresía Exclusiva',
                    style: TextStyle(
                      color: LuxevaTheme.accentGold,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
