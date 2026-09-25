import '../config/api_constants.dart';

class SpeiInstructions {
  final String bankName;
  final String clabe;
  final String beneficiary;
  final String concept;
  final String accountNumber;

  SpeiInstructions({
    required this.bankName,
    required this.clabe,
    required this.beneficiary,
    required this.concept,
    required this.accountNumber,
  });

  factory SpeiInstructions.fromJson(Map<String, dynamic> json) {
    return SpeiInstructions(
      bankName: json['bank_name'] ?? ApiConstants.defaultBankName,
      clabe: json['clabe'] ?? ApiConstants.defaultClabe,
      beneficiary: json['beneficiary'] ?? ApiConstants.defaultBeneficiary,
      concept: json['concept'] ?? 'LX-000000',
      accountNumber: json['account_number'] ?? '',
    );
  }

  String get formattedClabe {
    final cleaned = clabe.replaceAll(RegExp(r'\s+'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(cleaned[i]);
    }
    return buffer.toString();
  }
}
