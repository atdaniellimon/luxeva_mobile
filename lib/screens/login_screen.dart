import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/glass_panel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showCupertinoAlert(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(message),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Entendido', style: TextStyle(color: LuxevaTheme.goldAccent)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showCupertinoAlert('Atención', 'Ingrese su identificador institucional y clave de seguridad.');
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    try {
      final session = await ApiService.instance.login(email, password);
      await AuthService.instance.setSession(session);
      HapticFeedback.mediumImpact();
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      _showCupertinoAlert('Acceso Denegado', msg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openSignupSheet() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    bool isSigningUp = false;

    showCupertinoModalPopup(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (ctx, setSheetState) => CupertinoActionSheet(
          title: const Text(
            'SOLICITUD DE MEMBRESÍA',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              color: LuxevaTheme.goldAccent,
            ),
          ),
          message: const Text(
            'Incorporación al Ecosistema Luxeva Private Banking',
            style: TextStyle(fontSize: 12, color: LuxevaTheme.textSecondary),
          ),
          actions: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CupertinoTextField(
                    controller: nameCtrl,
                    placeholder: 'Nombre y Apellidos del Titular',
                    placeholderStyle: const TextStyle(color: LuxevaTheme.textMuted, fontSize: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0x18FFFFFF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: LuxevaTheme.borderGold),
                    ),
                    style: const TextStyle(color: LuxevaTheme.textPrimary, fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  CupertinoTextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    placeholder: 'Correo Electrónico (socio@luxeva.com)',
                    placeholderStyle: const TextStyle(color: LuxevaTheme.textMuted, fontSize: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0x18FFFFFF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: LuxevaTheme.borderGold),
                    ),
                    style: const TextStyle(color: LuxevaTheme.textPrimary, fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  CupertinoTextField(
                    controller: passCtrl,
                    obscureText: true,
                    placeholder: 'Clave Institucional',
                    placeholderStyle: const TextStyle(color: LuxevaTheme.textMuted, fontSize: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0x18FFFFFF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: LuxevaTheme.borderGold),
                    ),
                    style: const TextStyle(color: LuxevaTheme.textPrimary, fontSize: 15),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: LuxevaTheme.goldAccent,
                      borderRadius: BorderRadius.circular(14),
                      onPressed: isSigningUp
                          ? null
                          : () async {
                              final name = nameCtrl.text.trim();
                              final email = emailCtrl.text.trim();
                              final pass = passCtrl.text.trim();

                              if (name.isEmpty || email.isEmpty || pass.isEmpty) {
                                return;
                              }

                              setSheetState(() => isSigningUp = true);
                              try {
                                final session = await ApiService.instance.signup(name, email, pass);
                                await AuthService.instance.setSession(session);
                                if (ctx.mounted) Navigator.of(ctx).pop();
                              } catch (e) {
                                setSheetState(() => isSigningUp = false);
                                _showCupertinoAlert('Error de Emisión', e.toString().replaceAll('Exception: ', ''));
                              }
                            },
                      child: isSigningUp
                          ? const CupertinoActivityIndicator(color: LuxevaTheme.obsidianBg)
                          : const Text(
                              'Emitir Credenciales de Socio',
                              style: TextStyle(
                                color: LuxevaTheme.obsidianBg,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: const Text('Cancelar', style: TextStyle(color: LuxevaTheme.textSecondary)),
            onPressed: () => Navigator.of(sheetContext).pop(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: LuxevaTheme.obsidianBg,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Luxury Emblem
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [LuxevaTheme.goldLight, LuxevaTheme.goldAccent, LuxevaTheme.goldDark],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: LuxevaTheme.goldAccent.withOpacity(0.25),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'LX',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        color: LuxevaTheme.obsidianBg,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Brand Title
                const Text(
                  'LUXEVA',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 5.0,
                    color: LuxevaTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'WEALTH & PRIVATE BANKING',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.5,
                    color: LuxevaTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),

                // Form Panel
                GlassPanel(
                  hasGoldBorder: true,
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'IDENTIFICADOR DE ACCESO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: LuxevaTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CupertinoTextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        placeholder: 'socio@luxeva.com',
                        placeholderStyle: const TextStyle(color: LuxevaTheme.textMuted, fontSize: 15),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                          color: const Color(0x10FFFFFF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: LuxevaTheme.borderSubtle),
                        ),
                        style: const TextStyle(color: LuxevaTheme.textPrimary, fontSize: 15),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'CLAVE DE SEGURIDAD INSTITUCIONAL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: LuxevaTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CupertinoTextField(
                        controller: _passwordController,
                        obscureText: true,
                        placeholder: '••••••••',
                        placeholderStyle: const TextStyle(color: LuxevaTheme.textMuted, fontSize: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                          color: const Color(0x10FFFFFF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: LuxevaTheme.borderSubtle),
                        ),
                        style: const TextStyle(color: LuxevaTheme.textPrimary, fontSize: 15),
                      ),
                      const SizedBox(height: 28),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: CupertinoButton(
                          color: LuxevaTheme.goldAccent,
                          borderRadius: BorderRadius.circular(14),
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading
                              ? const CupertinoActivityIndicator(color: LuxevaTheme.obsidianBg)
                              : const Text(
                                  'Acceder al Club Privado',
                                  style: TextStyle(
                                    color: LuxevaTheme.obsidianBg,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Waitlist / Signup
                      Center(
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: _openSignupSheet,
                          child: const Text(
                            '¿Sin credenciales? Solicitar Membresía Exclusiva',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: LuxevaTheme.goldAccent,
                              letterSpacing: 0.3,
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
      ),
    );
  }
}
