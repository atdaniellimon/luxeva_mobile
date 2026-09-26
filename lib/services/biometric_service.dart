import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  static final BiometricService instance = BiometricService._internal();
  BiometricService._internal();

  final LocalAuthentication _auth = LocalAuthentication();
  static const String _prefKey = 'luxeva_biometrics_enabled';
  bool _isAuthenticating = false;
  bool get isAuthenticating => _isAuthenticating;

  Future<bool> isBiometricsAvailable() async {
    try {
      final bool canCheck = await _auth.canCheckBiometrics;
      final bool isSupported = await _auth.isDeviceSupported();
      return canCheck || isSupported;
    } catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, enabled);
  }

  Future<bool> authenticate({
    String reason = 'Confirme su identidad para acceder a Luxeva',
  }) async {
    if (_isAuthenticating) return false;
    _isAuthenticating = true;

    try {
      final bool isAvail = await isBiometricsAvailable();
      if (!isAvail) return true; // If device has no hardware, bypass gracefully

      final success = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );
      return success;
    } on PlatformException catch (_) {
      return false;
    } catch (_) {
      return false;
    } finally {
      // Cooldown to avoid system sheet dismiss re-triggering lifecycle events
      await Future.delayed(const Duration(milliseconds: 600));
      _isAuthenticating = false;
    }
  }
}
