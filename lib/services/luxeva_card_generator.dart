import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class LuxevaCardDetails {
  final String cardNumber; // 16 digits
  final String maskedCardNumber;
  final String cardHolder;
  final String expiry;
  final String cvv;
  final String pin;
  final bool isFrozen;
  final double dailyLimit;

  LuxevaCardDetails({
    required this.cardNumber,
    required this.maskedCardNumber,
    required this.cardHolder,
    required this.expiry,
    required this.cvv,
    required this.pin,
    required this.isFrozen,
    required this.dailyLimit,
  });

  String get formattedCardNumber {
    if (cardNumber.length == 16) {
      return '${cardNumber.substring(0, 4)}  ${cardNumber.substring(4, 8)}  ${cardNumber.substring(8, 12)}  ${cardNumber.substring(12, 16)}';
    }
    return cardNumber;
  }

  String get formattedMaskedNumber {
    if (cardNumber.length == 16) {
      return '${cardNumber.substring(0, 4)}  ••••  ••••  ${cardNumber.substring(12, 16)}';
    }
    return '8840  ••••  ••••  1234';
  }
}

class AtmWithdrawalToken {
  final String code; // 6 digits
  final DateTime expiresAt;
  final String qrPayload;

  AtmWithdrawalToken({
    required this.code,
    required this.expiresAt,
    required this.qrPayload,
  });

  int get secondsRemaining {
    final diff = expiresAt.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  bool get isExpired => secondsRemaining <= 0;

  String get formattedTimeRemaining {
    final totalSec = secondsRemaining;
    final min = totalSec ~/ 60;
    final sec = totalSec % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}

class LuxevaCardGenerator {
  static const String bin = '8840'; // Private Closed Network ISO/IEC 7812
  static const String salt = 'LUXEVA_SECRET_VAULT_KEY_2026';

  /// Generates the proprietary 16-digit card number deterministically for the user
  static Future<LuxevaCardDetails> getCardForUser(UserSession user) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Tier code: 20 for standard, 30 for private/zenith
    final tierCode = user.tier.toLowerCase() == 'zenith' ? '30' : '20';

    // Member code: 6 digits deterministically derived from account number
    final acc = user.accountNumber.replaceAll(RegExp(r'[^0-9]'), '');
    String memberCode;
    if (acc.length >= 6) {
      memberCode = acc.substring(acc.length - 6);
    } else {
      final h = (user.accountNumber + salt).hashCode.abs();
      memberCode = (h % 900000 + 100000).toString();
    }

    // 4-digit proprietary cryptographic checksum
    final checkRaw = '$bin$tierCode$memberCode$salt';
    final checkHash = checkRaw.hashCode.abs() % 10000;
    final checksum = checkHash.toString().padLeft(4, '7');

    final pan = '$bin$tierCode$memberCode$checksum';

    // CVV: 3 digits deterministically computed
    final cvvHash = (pan + 'CVV' + salt).hashCode.abs() % 900 + 100;
    final cvv = cvvHash.toString();

    // Check stored user overrides
    final isFrozen = prefs.getBool('lxc_card_frozen_${user.accountNumber}') ?? false;
    final pin = prefs.getString('lxc_card_pin_${user.accountNumber}') ?? '4829';
    final dailyLimit = prefs.getDouble('lxc_card_limit_${user.accountNumber}') ?? 15000.0;

    return LuxevaCardDetails(
      cardNumber: pan,
      maskedCardNumber: '$bin •••• •••• $checksum',
      cardHolder: user.fullName.toUpperCase(),
      expiry: '12/29',
      cvv: cvv,
      pin: pin,
      isFrozen: isFrozen,
      dailyLimit: dailyLimit,
    );
  }

  static Future<void> setCardFrozen(String accountNumber, bool frozen) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('lxc_card_frozen_$accountNumber', frozen);
  }

  static Future<void> setCardPin(String accountNumber, String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lxc_card_pin_$accountNumber', pin);
  }

  static Future<void> setDailyLimit(String accountNumber, double limit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('lxc_card_limit_$accountNumber', limit);
  }

  /// Generates a single-use 6-digit ATM Withdrawal Token valid for 15 minutes
  static AtmWithdrawalToken generateAtmToken(String accountNumber) {
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(minutes: 15));
    
    // 6-digit OTP
    final randSeed = (now.millisecondsSinceEpoch + accountNumber.hashCode).abs();
    final tokenCode = (randSeed % 900000 + 100000).toString();

    final payload = jsonEncode({
      'issuer': 'LUXEVA_ATM_NETWORK',
      'account': accountNumber,
      'token': tokenCode,
      'exp': expiresAt.millisecondsSinceEpoch,
    });

    return AtmWithdrawalToken(
      code: tokenCode,
      expiresAt: expiresAt,
      qrPayload: payload,
    );
  }
}
