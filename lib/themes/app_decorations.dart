import 'package:flutter/material.dart';
import 'package:mindloop/themes/app_colors.dart';

class AppDecorations {
  AppDecorations._();

  static const double radiusCard = 24;
  static const double radiusButton = 28;
  static const double radiusChip = 20;
  static const double radiusInput = 16;

  static List<BoxShadow> get cardShadow => const [
        BoxShadow(
          color: Color(0x0F000000),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ];

  static BoxDecoration card({Color? color, double radius = radiusCard}) {
    return BoxDecoration(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      boxShadow: cardShadow,
    );
  }

  static BoxDecoration primaryPillButton = BoxDecoration(
    color: AppColors.primaryDark,
    borderRadius: BorderRadius.circular(radiusButton),
    boxShadow: const [
      BoxShadow(
        color: AppColors.shadow,
        blurRadius: 16,
        offset: Offset(0, 6),
      ),
    ],
  );
}
