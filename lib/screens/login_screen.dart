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
  // Mode: 0 = Iniciar Sesión, 1 = Solicitar Membresía
  int _authMode = 0;

  final TextEditingController _loginEmailCtrl = TextEditingController();
  final TextEditingController _loginPassCtrl = TextEditingController();

  final TextEditingController _signupNameCtrl = TextEditingController();
  final TextEditingController _signupEmailCtrl = TextEditingController();
  final TextEditingController _signupPassCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _signupNameCtrl.dispose();
    _signupEmailCtrl.dispose();
    _signupPassCtrl.dispose();
    super.dispose();
  }

  void _showCupertinoAlert(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            message,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text(
              'Entendido',
              style: TextStyle(color: LuxevaTheme.goldAccent, fontWeight: FontWeight.w600),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    HapticFeedback.lightImpact();

    if (_authMode == 0) {
      // Login
      final email = _loginEmailCtrl.text.trim();
      final pass = _loginPassCtrl.text.trim();

      if (email.isEmpty || pass.isEmpty) {
        _showCupertinoAlert('Credenciales Requeridas', 'Por favor ingrese su correo institucional y clave de acceso.');
        return;
      }

      setState(() => _isLoading = true);
      try {
        final session = await ApiService.instance.login(email, pass);
        await AuthService.instance.setSession(session);
        HapticFeedback.mediumImpact();
      } catch (e) {
        final msg = e.toString().replaceAll('Exception: ', '');
        _showCupertinoAlert('Acceso No Autorizado', msg);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      // Signup
      final name = _signupNameCtrl.text.trim();
      final email = _signupEmailCtrl.text.trim();
      final pass = _signupPassCtrl.text.trim();

      if (name.isEmpty || email.isEmpty || pass.isEmpty) {
        _showCupertinoAlert('Datos Incompletos', 'Complete todos los campos para emitir su membresía privada.');
        return;
      }

      setState(() => _isLoading = true);
      try {
        final session = await ApiService.instance.signup(name, email, pass);
        await AuthService.instance.setSession(session);
        HapticFeedback.heavyImpact();
      } catch (e) {
        final msg = e.toString().replaceAll('Exception: ', '');
        _showCupertinoAlert('Error de Emisión', msg);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: LuxevaTheme.obsidianBg,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                // Luxury Emblem
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFF26262F), Color(0xFF0F0F13)],
                      center: Alignment(-0.2, -0.2),
                      radius: 0.9,
                    ),
                    border: Border.all(color: LuxevaTheme.goldAccent.withOpacity(0.6), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: LuxevaTheme.goldAccent.withOpacity(0.2),
                        blurRadius: 28,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: LuxevaTheme.borderGold.withOpacity(0.35), width: 0.5),
                      ),
                      child: const Center(
                        child: Text(
                          'LX',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                            color: LuxevaTheme.goldLight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Brand Title
                const Text(
                  'LUXEVA',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 6.0,
                    color: LuxevaTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'WEALTH & PRIVATE BANKING',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.5,
                    color: LuxevaTheme.goldAccent,
                  ),
                ),
                const SizedBox(height: 28),

                // Segmented Selector (Acceso Privado / Emitir Membresía)
                Container(
                  height: 44,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: LuxevaTheme.cardElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: LuxevaTheme.borderSubtle, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (_authMode != 0) {
                              HapticFeedback.selectionClick();
                              setState(() => _authMode = 0);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: _authMode == 0 ? LuxevaTheme.cardBg : CupertinoColors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              border: _authMode == 0
                                  ? Border.all(color: LuxevaTheme.borderGold, width: 0.6)
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                'Ingreso de Socio',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: _authMode == 0 ? FontWeight.w700 : FontWeight.w500,
                                  color: _authMode == 0 ? LuxevaTheme.goldLight : LuxevaTheme.textSecondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (_authMode != 1) {
                              HapticFeedback.selectionClick();
                              setState(() => _authMode = 1);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: _authMode == 1 ? LuxevaTheme.cardBg : CupertinoColors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              border: _authMode == 1
                                  ? Border.all(color: LuxevaTheme.borderGold, width: 0.6)
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                'Nueva Membresía',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: _authMode == 1 ? FontWeight.w700 : FontWeight.w500,
                                  color: _authMode == 1 ? LuxevaTheme.goldLight : LuxevaTheme.textSecondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Main Card Form
                GlassPanel(
                  hasGoldBorder: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_authMode == 1) ...[
                        _buildFieldLabel('TITULAR DE LA CUENTA'),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _signupNameCtrl,
                          placeholder: 'Nombre y Apellidos',
                          icon: CupertinoIcons.person,
                          keyboardType: TextInputType.name,
                        ),
                        const SizedBox(height: 18),
                      ],

                      _buildFieldLabel(_authMode == 0 ? 'CORREO INSTITUCIONAL' : 'CORREO ELECTRÓNICO'),
                      const SizedBox(height: 8),
                      _buildInputField(
                        controller: _authMode == 0 ? _loginEmailCtrl : _signupEmailCtrl,
                        placeholder: 'socio@luxeva.com',
                        icon: CupertinoIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 18),

                      _buildFieldLabel('CLAVE DE SEGURIDAD BLINDADA'),
                      const SizedBox(height: 8),
                      _buildInputField(
                        controller: _authMode == 0 ? _loginPassCtrl : _signupPassCtrl,
                        placeholder: '••••••••',
                        icon: CupertinoIcons.lock_shield,
                        obscureText: true,
                      ),
                      const SizedBox(height: 26),

                      // Submit Button with Gold Gradient
                      GestureDetector(
                        onTap: _isLoading ? null : _handleSubmit,
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [LuxevaTheme.goldLight, LuxevaTheme.goldAccent, LuxevaTheme.goldDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: LuxevaTheme.goldAccent.withOpacity(0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _isLoading
                                ? const CupertinoActivityIndicator(color: LuxevaTheme.obsidianBg)
                                : Text(
                                    _authMode == 0 ? 'Acceder al Club Privado' : 'Emitir Credenciales de Socio',
                                    style: const TextStyle(
                                      color: LuxevaTheme.obsidianBg,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Institutional Security Footnote
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.checkmark_shield, size: 14, color: LuxevaTheme.textSecondary),
                    SizedBox(width: 6),
                    Text(
                      'Custodia Blindada · SPEI Banxico 256-bit',
                      style: TextStyle(
                        fontSize: 11,
                        color: LuxevaTheme.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: LuxevaTheme.textSecondary,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: LuxevaTheme.cardElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LuxevaTheme.borderGold.withOpacity(0.35), width: 0.8),
      ),
      child: CupertinoTextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        placeholder: placeholder,
        placeholderStyle: const TextStyle(color: LuxevaTheme.textMuted, fontSize: 14),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        prefix: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Icon(icon, size: 18, color: LuxevaTheme.goldAccent),
        ),
        decoration: null,
        style: const TextStyle(color: LuxevaTheme.textPrimary, fontSize: 15),
      ),
    );
  }
}
