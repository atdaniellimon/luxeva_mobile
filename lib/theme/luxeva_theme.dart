import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LuxevaTheme {
  // Ultra-Luxury Obsidian & Champagne Gold Palette
  static const Color background = Color(0xFF09090B);
  static const Color card = Color(0xFF131317);
  static const Color cardElevated = Color(0xFF18181E);
  static const Color accentGold = Color(0xFFCBBD93);
  static const Color accentGoldLight = Color(0xFFDFD4B3);
  static const Color textPrimary = Color(0xFFF2F2F7);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textMuted = Color(0x61FFFFFF);
  static const Color borderSubtle = Color(0x14FFFFFF);
  static const Color borderGold = Color(0x38CBBD93);
  static const Color greenPositive = Color(0xFF34C759);
  static const Color redNegative = Color(0xFFFF453A);

  static CupertinoThemeData get darkTheme {
    return const CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: accentGold,
      barBackgroundColor: Color(0xE60D0D11),
      scaffoldBackgroundColor: background,
      textTheme: CupertinoTextThemeData(
        primaryColor: textPrimary,
        textStyle: TextStyle(
          color: textPrimary,
          fontSize: 16,
          letterSpacing: -0.2,
          fontFamily: '.SF Pro Text',
        ),
      ),
    );
  }

  static BoxDecoration get glassCardDecoration => BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderSubtle, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      );

  static BoxDecoration get goldBorderCardDecoration => BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1C1C22), Color(0xFF121216)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderGold, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 30,
            offset: Offset(0, 12),
          ),
        ],
      );
}
