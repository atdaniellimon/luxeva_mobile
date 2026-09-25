import 'package:intl/intl.dart';

class UserSession {
  final String id;
  final String fullName;
  final String email;
  final String accountNumber;
  final double balance;
  final String tier;
  final String token;

  UserSession({
    required this.id,
    required this.fullName,
    required this.email,
    required this.accountNumber,
    required this.balance,
    required this.tier,
    required this.token,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      id: json['user_id'] ?? json['id'] ?? '',
      fullName: json['full_name'] ?? json['name'] ?? 'Cliente Luxeva',
      email: json['email'] ?? '',
      accountNumber: json['account_number'] ?? '',
      balance: (json['balance'] is num) ? (json['balance'] as num).toDouble() : 0.0,
      tier: json['tier'] ?? 'standard',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'full_name': fullName,
      'email': email,
      'account_number': accountNumber,
      'balance': balance,
      'tier': tier,
      'token': token,
    };
  }

  String get formattedBalance {
    final formatter = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    return '${formatter.format(balance)} MXN';
  }

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'LX';
  }

  String get maskedAccount {
    if (accountNumber.length >= 4) {
      return '**** **** **** ${accountNumber.substring(accountNumber.length - 4)}';
    }
    return '**** **** **** 1234';
  }

  UserSession copyWith({double? balance}) {
    return UserSession(
      id: id,
      fullName: fullName,
      email: email,
      accountNumber: accountNumber,
      balance: balance ?? this.balance,
      tier: tier,
      token: token,
    );
  }
}
