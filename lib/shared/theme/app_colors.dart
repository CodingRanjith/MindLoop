import 'package:flutter/material.dart';
import 'package:mindloop/modules/reminder/core/constants/reminder_categories.dart';

/// Fintech-inspired light palette (layout/style only — not copied content).
class AppColors {
  AppColors._();

  // Surfaces
  static const Color scaffold = Color(0xFFF5F6F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFE8EEF4);
  static const Color surfaceElevated = Color(0xFFFAFBFD);

  // Brand
  static const Color primary = Color(0xFF0F3D56);
  static const Color primaryDark = Color(0xFF0A2A3C);
  static const Color accent = Color(0xFF14B8A6);
  static const Color accentSoft = Color(0xFF99F6E4);

  // Semantic
  static const Color income = Color(0xFF10B981);
  static const Color expense = Color(0xFFF97316);
  static const Color warning = Color(0xFFFBBF24);
  static const Color info = Color(0xFF38BDF8);

  // Chart / category accents
  static const Color chartMint = Color(0xFF6EE7B7);
  static const Color chartLavender = Color(0xFFC4B5FD);
  static const Color chartCoral = Color(0xFFFB7185);
  static const Color chartSky = Color(0xFF7DD3FC);
  static const Color chartAmber = Color(0xFFFCD34D);

  // Typography
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Lines & depth
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE8EDF3);
  static const Color shadow = Color(0x1A0F3D56);
  static const Color shadowSoft = Color(0x0D0F3D56);

  static const List<Color> chartPalette = [
    chartCoral,
    chartLavender,
    chartMint,
    chartSky,
    chartAmber,
    accent,
  ];

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [primaryDark, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF8FAFC), scaffold, Color(0xFFE8F4F8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient meshAccent = LinearGradient(
    colors: [Color(0xFFE0F2FE), Color(0xFFF5F3FF), Color(0xFFCCFBF1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkGradient = LinearGradient(
    colors: [chartCoral, chartLavender],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color categoryAccent(ReminderCategory category) {
    return switch (category) {
      ReminderCategory.birthday => chartAmber,
      ReminderCategory.anniversary => chartCoral,
      ReminderCategory.meeting => primary,
      ReminderCategory.study => chartLavender,
      ReminderCategory.finance => income,
      ReminderCategory.personal => accent,
      ReminderCategory.health => chartMint,
      ReminderCategory.goalTracking => chartSky,
    };
  }

  // Legacy aliases (dark-era names) for gradual migration
  static const Color neonPurple = primary;
  static const Color electricBlue = accent;
  static const Color softPink = expense;
  static const Color darkBg = scaffold;
  static const Color cardBg = surface;
  static const Color surfaceLight = surfaceMuted;
}
