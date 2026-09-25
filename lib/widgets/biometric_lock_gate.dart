import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../models/user.dart';
import '../services/biometric_service.dart';

class BiometricLockGate extends StatefulWidget {
  final UserSession user;
  final Widget child;

  const BiometricLockGate({
    super.key,
    required this.user,
    required this.child,
  });

  @override
  State<BiometricLockGate> createState() => _BiometricLockGateState();
}

class _BiometricLockGateState extends State<BiometricLockGate> with WidgetsBindingObserver {
  bool _isLocked = true;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkBiometrics();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkBiometrics();
    }
  }

  Future<void> _checkBiometrics() async {
    final enabled = await BiometricService.instance.isEnabled();
    if (!enabled) {
      if (mounted) {
        setState(() {
          _isLocked = false;
          _isChecking = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLocked = true;
        _isChecking = true;
      });
    }

    final success = await BiometricService.instance.authenticate(
      reason: 'Desbloquee para acceder a su cuenta Luxeva',
    );

    if (mounted) {
      setState(() {
        _isLocked = !success;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLocked) {
      return widget.child;
    }

    return CupertinoPageScaffold(
      backgroundColor: LuxevaTheme.obsidianBg,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Crown / Logo mark
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [LuxevaTheme.goldLight, LuxevaTheme.goldAccent, LuxevaTheme.goldDark],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: LuxevaTheme.goldAccent.withOpacity(0.25),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.user.initials,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: LuxevaTheme.obsidianBg,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'LUXEVA',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4.0,
                  color: LuxevaTheme.goldLight,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.user.fullName,
                style: const TextStyle(fontSize: 14, color: LuxevaTheme.textSecondary),
              ),

              const Spacer(),

              // Unlock Button
              if (_isChecking)
                const CupertinoActivityIndicator(color: LuxevaTheme.goldAccent, radius: 14)
              else
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CupertinoButton(
                    color: const Color(0x1ACBBD93),
                    borderRadius: BorderRadius.circular(14),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _checkBiometrics();
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.viewfinder, size: 20, color: LuxevaTheme.goldLight),
                        SizedBox(width: 10),
                        Text(
                          'Desbloquear con Face ID',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: LuxevaTheme.goldLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
