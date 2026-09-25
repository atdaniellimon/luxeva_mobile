import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  static const String _sessionKey = 'luxeva_secure_user_session';

  final ValueNotifier<UserSession?> currentSession = ValueNotifier<UserSession?>(null);

  bool get isAuthenticated => currentSession.value != null;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_sessionKey);
      if (raw != null) {
        final data = jsonDecode(raw);
        final session = UserSession.fromJson(data);
        currentSession.value = session;
        // Background refresh balance
        refreshBalance();
      }
    } catch (_) {}
  }

  Future<void> setSession(UserSession session) async {
    currentSession.value = session;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
    } catch (_) {}
  }

  Future<void> refreshBalance() async {
    final session = currentSession.value;
    if (session == null || session.accountNumber.isEmpty) return;
    try {
      final newBalance = await ApiService.instance.getBalance(session.accountNumber);
      currentSession.value = session.copyWith(balance: newBalance);
    } catch (_) {}
  }

  Future<void> logout() async {
    currentSession.value = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
    } catch (_) {}
  }
}
