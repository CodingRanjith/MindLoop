import 'package:flutter/material.dart';

/// Premium fintech palette (reference mockups — purple accent).
class PfmTheme {
  PfmTheme._();

  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF5B4BD4);
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color scaffold = Color(0xFFF8F9FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E1E2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color income = Color(0xFF22C55E);
  static const Color expense = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color border = Color(0xFFE5E7EB);

  /// Primary brand gradient (purple → blue) — balance card, FAB, buttons.
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF5B4BD4), Color(0xFF6C5CE7), Color(0xFF48C6EF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.45, 1.0],
  );

  static const LinearGradient heroGradient = brandGradient;

  static const LinearGradient profileGradient = brandGradient;

  static const Color chartNeeds = Color(0xFF5B7CFA);
  static const Color chartWants = Color(0xFFEF4444);
  static const Color chartSavings = Color(0xFF22C55E);
  static const Color chartOther = Color(0xFFF59E0B);

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static BoxDecoration cardDecoration({Color? color}) => BoxDecoration(
        color: color ?? surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: cardShadow,
      );

  static TextStyle get titleStyle => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      );
}
