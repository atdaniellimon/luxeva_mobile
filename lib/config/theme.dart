import 'dart:ui';
import 'package:flutter/cupertino.dart';

class LuxevaTheme {
  // Apple HIG & Liquid Glass Palette (Obsidian & Champagne)
  static const Color obsidianBg = Color(0xFF08090C);
  static const Color surfaceLayer = Color(0xFF111217);
  static const Color surfaceElevated = Color(0xFF17181F);
  static const Color cardBg = Color(0xFF121318);
  static const Color cardElevated = Color(0xFF1A1B22);
  static const Color glassBg = Color(0xB8121318); // Liquid Glass translucent tint

  // Champagne Gold Accent (Applied with restraint per Apple HIG)
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF3E5AB);
  static const Color goldDark = Color(0xFFA68A2E);
  static const Color borderGold = Color(0x33D4AF37);

  // Optical Typography & Contrast Ratios (>4.5:1 compliant)
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textMuted = Color(0x50FFFFFF);
  static const Color borderSubtle = Color(0x14FFFFFF); // 0.5px hairline stroke
  static const Color dividerColor = Color(0x10FFFFFF);

  // Status & Semantic Feedback
  static const Color greenPositive = Color(0xFF34C759);
  static const Color redNegative = Color(0xFFFF453A);
  static const Color amberSandbox = Color(0xFFFF9F0A);

  // Layout & Material Metrics
  static const double liquidBlur = 24.0;
  static const double radiusCompact = 12.0;
  static const double radiusStandard = 16.0;
  static const double radiusCard = 20.0;
  static const double continuousRadius = 24.0;
  static const double hairline = 0.5;

  /// Tabular numbers helper for financial balance and counters
  static TextStyle tabularFigures({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
    Color color = textPrimary,
    double letterSpacing = -0.2,
    String? fontFamily,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      fontFamily: fontFamily,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  /// Laser-etched card typography (Apple Card Titanium spec)
  static TextStyle cardLaserNumber({
    double fontSize = 16,
    Color color = textPrimary,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      letterSpacing: 2.8,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

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
          letterSpacing: -0.2,
        ),
        navTitleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.0,
        ),
      ),
    );
  }
}
