class ApiConstants {
  // Primary gateway on custom domain (HTTPS with Cloudflare SSL)
  static const String primaryBaseUrl = 'https://luxeva.daniellimon.uk';

  // Direct backend tunnel candidates
  static const String directHttpUrl = 'http://api.luxeva.daniellimon.uk';
  static const String fallbackLocalUrl = 'http://127.0.0.1:8000';

  static const List<String> candidateBaseUrls = [
    primaryBaseUrl,
    directHttpUrl,
    fallbackLocalUrl,
  ];

  // Official Spin by OXXO details
  static const String defaultBankName = 'Spin by OXXO';
  static const String defaultClabe = '728969000044989306';
  static const String defaultBeneficiary = 'Luxeva';
}
