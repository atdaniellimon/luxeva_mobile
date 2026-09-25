import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  static final ApiService instance = ApiService._internal();
  ApiService._internal();

  static const List<String> candidateHosts = [
    'https://luxeva.daniellimon.uk',
    'http://api.luxeva.daniellimon.uk',
    'http://127.0.0.1:8000',
  ];

  String? _workingHost;
  final LocalAuthentication _localAuth = LocalAuthentication();

  UserSession? currentSession;

  Future<http.Response> _request(
    String path, {
    String method = 'GET',
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final List<String> hostsToTry = _workingHost != null
        ? [_workingHost!, ...candidateHosts.where((h) => h != _workingHost)]
        : candidateHosts;

    Object? lastError;
    final defaultHeaders = {'Content-Type': 'application/json', ...?headers};
    final encodedBody = body != null ? jsonEncode(body) : null;

    for (final host in hostsToTry) {
      try {
        final url = Uri.parse('$host$path');
        http.Response res;
        if (method == 'POST') {
          res = await http
              .post(url, headers: defaultHeaders, body: encodedBody)
              .timeout(const Duration(seconds: 8));
        } else {
          res = await http
              .get(url, headers: defaultHeaders)
              .timeout(const Duration(seconds: 8));
        }
        _workingHost = host;
        return res;
      } catch (e) {
        lastError = e;
        debugPrint('[Luxeva Client] Falló $host$path: $e');
      }
    }
    throw Exception('Error de conexión con el banco: $lastError');
  }

  // ===== AUTHENTICATION =====
  Future<UserSession> login(String email, String password) async {
    final res = await _request(
      '/login',
      method: 'POST',
      body: {'email': email.trim(), 'password': password.trim()},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      final user = UserSession.fromJson(data);
      currentSession = user;
      await saveSession(user);
      return user;
    } else {
      final err = jsonDecode(utf8.decode(res.bodyBytes));
      throw Exception(err['detail'] ?? 'Credenciales incorrectas');
    }
  }

  Future<UserSession> signup(String fullName, String email, String password) async {
    final res = await _request(
      '/signup',
      method: 'POST',
      body: {
        'full_name': fullName.trim(),
        'email': email.trim(),
        'password': password.trim(),
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      final user = UserSession.fromJson(data);
      currentSession = user;
      await saveSession(user);
      return user;
    } else {
      final err = jsonDecode(utf8.decode(res.bodyBytes));
      throw Exception(err['detail'] ?? 'Error al aperturar cuenta');
    }
  }

  // ===== BIOMETRICS (FACE ID / TOUCH ID) =====
  Future<bool> canUseBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Acceso seguro al Club Privado Luxeva',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      debugPrint('Biometrics error: $e');
      return false;
    }
  }

  // ===== DATA SYNC =====
  Future<double> refreshBalance(String accountNumber) async {
    final res = await _request('/api/account/balance?account_number=${Uri.encodeComponent(accountNumber)}');
    if (res.statusCode == 200) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      final newBalance = (data['balance'] is num) ? (data['balance'] as num).toDouble() : 0.0;
      if (currentSession != null) {
        currentSession = currentSession!.copyWith(balance: newBalance);
        await saveSession(currentSession!);
      }
      return newBalance;
    }
    return currentSession?.balance ?? 0.0;
  }

  Future<List<TransactionItem>> getTransactions(String accountNumber) async {
    final res = await _request('/api/account/transactions?account_number=${Uri.encodeComponent(accountNumber)}');
    if (res.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(res.bodyBytes));
      return data.map((item) => TransactionItem.fromJson(item)).toList();
    }
    return [];
  }

  Future<SpeiDetails> getSpeiInstructions(String accountNumber) async {
    final res = await _request(
      '/api/deposit/spei-instructions',
      method: 'POST',
      body: {'account_number': accountNumber},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      return SpeiDetails.fromJson(data);
    }
    throw Exception('No se pudieron obtener las coordenadas SPEI');
  }

  Future<void> confirmSpeiDeposit({
    required String accountNumber,
    required double amount,
    required String concept,
    String? trackingKey,
  }) async {
    final res = await _request(
      '/api/deposit/notify',
      method: 'POST',
      body: {
        'account_number': accountNumber,
        'amount': amount,
        'concept': concept,
        'tracking_key': trackingKey,
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      final depositId = data['id'] ?? data['deposit_id'];
      // Instant approval in ecosystem
      await _request(
        '/api/deposit/approve',
        method: 'POST',
        body: {'transaction_id': depositId},
      );
      await refreshBalance(accountNumber);
    } else {
      throw Exception('Fallo en la instrucción de acreditación SPEI');
    }
  }

  Future<void> sendTransfer({
    required String accountNumber,
    required String recipient,
    required double amount,
    required String concept,
  }) async {
    final res = await _request(
      '/api/service/charge',
      method: 'POST',
      body: {
        'account_number': accountNumber,
        'service': 'transferencia',
        'amount': amount,
        'concept': '$concept a $recipient',
      },
    );

    if (res.statusCode == 200) {
      await refreshBalance(accountNumber);
    } else {
      final err = jsonDecode(utf8.decode(res.bodyBytes));
      throw Exception(err['detail'] ?? 'Fondos insuficientes para la transferencia');
    }
  }

  // ===== PERSISTENCE =====
  Future<void> saveSession(UserSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('luxeva_session', jsonEncode(session.toJson()));
  }

  Future<UserSession?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('luxeva_session');
    if (raw != null) {
      try {
        final data = jsonDecode(raw);
        currentSession = UserSession.fromJson(data);
        return currentSession;
      } catch (_) {}
    }
    return null;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('luxeva_session');
    currentSession = null;
  }
}
