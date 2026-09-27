import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'auth_service.dart';
import '../widgets/dynamic_notice.dart';

class SandboxAccount {
  final String fullName;
  final String email;
  final String accountNumber;
  final String tier;

  const SandboxAccount({
    required this.fullName,
    required this.email,
    required this.accountNumber,
    required this.tier,
  });
}

class DeveloperService {
  static final DeveloperService instance = DeveloperService._internal();
  DeveloperService._internal();

  static const String _prefDevKey = 'luxeva_developer_mode_active';

  final ValueNotifier<bool> isDeveloperMode = ValueNotifier<bool>(false);

  // Pre-configured Member Profiles for Sandbox testing
  static const List<SandboxAccount> sandboxMembers = [
    SandboxAccount(
      fullName: 'Daniel Limón',
      email: 'daniel.test@luxeva.com',
      accountNumber: 'LX-6365121453',
      tier: 'zenith',
    ),
    SandboxAccount(
      fullName: 'Alpha User',
      email: 'alpha@luxeva.com',
      accountNumber: 'LX-2124905283',
      tier: 'tungsten',
    ),
    SandboxAccount(
      fullName: 'Beta User',
      email: 'beta@luxeva.com',
      accountNumber: 'LX-5565946497',
      tier: 'standard',
    ),
  ];

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isDeveloperMode.value = prefs.getBool(_prefDevKey) ?? false;
    } catch (_) {}
  }

  Future<void> setDeveloperMode(bool enabled) async {
    isDeveloperMode.value = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefDevKey, enabled);
    } catch (_) {}
  }

  Future<void> toggleDeveloperMode() async {
    await setDeveloperMode(!isDeveloperMode.value);
  }

  Future<void> switchToSandboxAccount(BuildContext context, SandboxAccount member) async {
    HapticFeedback.mediumImpact();
    try {
      final balance = await ApiService.instance.getBalance(member.accountNumber);
      final newSession = UserSession(
        id: 'sandbox_${member.accountNumber}',
        fullName: member.fullName,
        email: member.email,
        accountNumber: member.accountNumber,
        balance: balance,
        tier: member.tier,
        token: 'lx_sandbox_${member.accountNumber}',
      );

      await AuthService.instance.setSession(newSession);

      if (context.mounted) {
        DynamicNotice.show(
          context,
          message: 'Sesión Conmutada',
          subtitle: '${member.fullName} (${member.accountNumber})',
          icon: CupertinoIcons.person_crop_circle_badge_checkmark,
        );
      }
    } catch (e) {
      if (context.mounted) {
        DynamicNotice.show(
          context,
          message: 'Error al cambiar cuenta',
          subtitle: e.toString(),
          icon: CupertinoIcons.exclamationmark_circle,
        );
      }
    }
  }

  Future<void> applyFaucet(BuildContext context, {required String accountNumber, required double amount}) async {
    HapticFeedback.heavyImpact();
    try {
      await ApiService.instance.instantFund(accountNumber: accountNumber, amount: amount);
      await AuthService.instance.refreshBalance();

      if (context.mounted) {
        DynamicNotice.show(
          context,
          message: 'Faucet Acreditado',
          subtitle: '+\$${amount.toStringAsFixed(2)} MXN en Sandbox',
          icon: CupertinoIcons.sparkles,
        );
      }
    } catch (e) {
      if (context.mounted) {
        DynamicNotice.show(
          context,
          message: 'Error en Faucet',
          subtitle: e.toString(),
          icon: CupertinoIcons.exclamationmark_circle,
        );
      }
    }
  }
}
