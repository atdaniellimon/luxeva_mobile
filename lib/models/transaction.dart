import 'package:intl/intl.dart';

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

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'] ?? '',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0.0,
      description: json['description'] ?? json['concept'] ?? 'Movimiento Institucional',
      status: json['status'] ?? 'completed',
      createdAt: json['created_at'] ?? 'Hoy',
    );
  }

  bool get isPositive => amount > 0;

  String get formattedAmount {
    final formatter = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final absFormatted = formatter.format(amount.abs());
    return isPositive ? '+$absFormatted' : '-$absFormatted';
  }
}
