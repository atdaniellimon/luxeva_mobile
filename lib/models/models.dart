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

  String get formattedBalance => NumberFormat.currency(
        locale: 'es_MX',
        symbol: '\$',
        decimalDigits: 2,
      ).format(balance);

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts.first[0] + parts.last[0]).toUpperCase();
    }
    return parts.first.isNotEmpty ? parts.first.substring(0, 1).toUpperCase() : 'LX';
  }

  String get lastFourDigits {
    if (accountNumber.length >= 4) {
      return accountNumber.substring(accountNumber.length - 4);
    }
    return '----';
  }

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      id: json['user_id'] ?? json['id'] ?? '',
      fullName: json['full_name'] ?? 'Cliente Luxeva',
      email: json['email'] ?? '',
      accountNumber: json['account_number'] ?? '',
      balance: (json['balance'] is num) ? (json['balance'] as num).toDouble() : 0.0,
      tier: json['tier'] ?? 'standard',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': id,
        'full_name': fullName,
        'email': email,
        'account_number': accountNumber,
        'balance': balance,
        'tier': tier,
        'token': token,
      };

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

class TransactionItem {
  final String id;
  final double amount;
  final String description;
  final String status;
  final String createdAt;

  TransactionItem({
    required this.id,
    required this.amount,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  bool get isPositive => amount > 0;

  String get formattedAmount {
    final absAmount = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 2,
    ).format(amount.abs());
    return isPositive ? '+$absAmount' : '-$absAmount';
  }

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0.0,
      description: json['description'] ?? json['concept'] ?? 'Movimiento Bancario',
      status: json['status'] ?? 'completed',
      createdAt: json['created_at'] ?? 'Reciente',
    );
  }
}

class SpeiDetails {
  final String bankName;
  final String clabe;
  final String beneficiary;
  final String concept;
  final String accountNumber;

  SpeiDetails({
    required this.bankName,
    required this.clabe,
    required this.beneficiary,
    required this.concept,
    required this.accountNumber,
  });

  String get formattedClabe {
    return clabe.replaceAllMapped(RegExp(r'.{4}'), (match) => '${match.group(0)} ').trim();
  }

  factory SpeiDetails.fromJson(Map<String, dynamic> json) {
    return SpeiDetails(
      bankName: json['bank_name'] ?? 'Spin by OXXO / STP',
      clabe: json['clabe'] ?? '728969000044989306',
      beneficiary: json['beneficiary'] ?? 'Luxeva',
      concept: json['concept'] ?? 'LX-000000',
      accountNumber: json['account_number'] ?? '',
    );
  }
}
