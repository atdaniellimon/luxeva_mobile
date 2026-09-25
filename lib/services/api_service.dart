import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_constants.dart';
import '../models/user.dart';
import '../models/transaction.dart';
import '../models/spei_details.dart';

class ApiService {
  static final ApiService instance = ApiService._internal();
  ApiService._internal();

  String? _workingBaseUrl;

  Future<http.Response> _executeWithFallback(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final candidates = _workingBaseUrl != null
        ? [_workingBaseUrl!, ...ApiConstants.candidateBaseUrls.where((u) => u != _workingBaseUrl)]
        : ApiConstants.candidateBaseUrls;

    Exception? lastError;
    for (final base in candidates) {
      try {
        final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
        final uri = Uri.parse('$base$cleanEndpoint');
        final headers = {'Content-Type': 'application/json'};

        http.Response response;
        if (method == 'POST') {
          response = await http
              .post(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(const Duration(seconds: 8));
        } else {
          response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 8));
        }

        _workingBaseUrl = base;
        return response;
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
      }
    }

    throw lastError ?? Exception('No se pudo establecer conexión con el banco central');
  }

  Future<UserSession> login(String email, String password) async {
    final response = await _executeWithFallback(
      '/login',
      method: 'POST',
      body: {'email': email.trim(), 'password': password.trim()},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return UserSession.fromJson(data);
    } else {
      final err = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(err['detail'] ?? 'Credenciales de acceso no autorizadas');
    }
  }

  Future<UserSession> signup(String fullName, String email, String password) async {
    final response = await _executeWithFallback(
      '/signup',
      method: 'POST',
      body: {
        'full_name': fullName.trim(),
        'email': email.trim(),
        'password': password.trim(),
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return UserSession.fromJson(data);
    } else {
      final err = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(err['detail'] ?? 'Error al emitir membresía');
    }
  }

  Future<double> getBalance(String accountNumber) async {
    final response = await _executeWithFallback(
      '/api/account/balance?account_number=${Uri.encodeComponent(accountNumber)}',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return (data['balance'] is num) ? (data['balance'] as num).toDouble() : 0.0;
    }
    return 0.0;
  }

  Future<List<TransactionItem>> getTransactions(String accountNumber) async {
    final response = await _executeWithFallback(
      '/api/account/transactions?account_number=${Uri.encodeComponent(accountNumber)}',
    );

    if (response.statusCode == 200) {
      final List list = jsonDecode(utf8.decode(response.bodyBytes));
      return list.map((item) => TransactionItem.fromJson(item)).toList();
    }
    return [];
  }

  Future<SpeiInstructions> getSpeiInstructions(String accountNumber) async {
    try {
      final response = await _executeWithFallback(
        '/api/deposit/spei-instructions',
        method: 'POST',
        body: {'account_number': accountNumber},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return SpeiInstructions.fromJson(data);
      }
    } catch (_) {}

    return SpeiInstructions(
      bankName: ApiConstants.defaultBankName,
      clabe: ApiConstants.defaultClabe,
      beneficiary: ApiConstants.defaultBeneficiary,
      concept: accountNumber.isNotEmpty ? accountNumber : 'LX-000000',
      accountNumber: accountNumber,
    );
  }

  Future<void> notifyAndApproveDeposit({
    required String accountNumber,
    required double amount,
    required String concept,
    String? trackingKey,
  }) async {
    final notifyRes = await _executeWithFallback(
      '/api/deposit/notify',
      method: 'POST',
      body: {
        'account_number': accountNumber,
        'amount': amount,
        'concept': concept,
        if (trackingKey != null && trackingKey.isNotEmpty) 'tracking_key': trackingKey,
      },
    );

    if (notifyRes.statusCode == 200) {
      final data = jsonDecode(utf8.decode(notifyRes.bodyBytes));
      final txId = data['id'] ?? data['deposit_id'];
      if (txId != null) {
        await _executeWithFallback(
          '/api/deposit/approve',
          method: 'POST',
          body: {'transaction_id': txId},
        );
      }
    } else {
      throw Exception('Fallo en la instrucción de acreditación SPEI');
    }
  }

  Future<void> sendTransfer({
    required String accountNumber,
    required String to,
    required double amount,
    required String concept,
  }) async {
    final res = await _executeWithFallback(
      '/api/service/charge',
      method: 'POST',
      body: {
        'account_number': accountNumber,
        'service': 'transferencia',
        'amount': amount,
        'concept': '$concept a $to',
      },
    );

    if (res.statusCode != 200) {
      final err = jsonDecode(utf8.decode(res.bodyBytes));
      throw Exception(err['detail'] ?? 'Fondos insuficientes para dispersión');
    }
  }
}
