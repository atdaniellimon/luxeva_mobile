import 'package:flutter/cupertino.dart';

class LuxevaTheme {
  // Ultra-Luxury Obsidian & Champagne Gold Palette
  static const Color obsidianBg = Color(0xFF09090B);
  static const Color cardBg = Color(0xFF131317);
  static const Color cardElevated = Color(0xFF18181E);
  static const Color glassBg = Color(0xE00E0E12);

  // Gold Accents
  static const Color goldAccent = Color(0xFFCBBD93);
  static const Color goldLight = Color(0xFFDFD4B3);
  static const Color goldDark = Color(0xFFA69668);
  static const Color borderGold = Color(0x38CBBD93);

  // Text & Neutral Colors
  static const Color textPrimary = Color(0xFFF2F2F7);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textMuted = Color(0x60FFFFFF);
  static const Color borderSubtle = Color(0x14FFFFFF);

  // Status Colors
  static const Color greenPositive = Color(0xFF34C759);
  static const Color redNegative = Color(0xFFFF453A);

  static CupertinoThemeData get cupertinoTheme {
    return const CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: goldAccent,
      primaryContrastingColor: obsidianBg,
      barBackgroundColor: glassBg,
      scaffoldBackgroundColor: obsidianBg,
      textTheme: CupertinoTextThemeData(
        primaryColor: textPrimary,
        textStyle: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontFamily: '.SF Pro Text',
        ),
        navTitleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
