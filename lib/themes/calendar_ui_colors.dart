import 'package:flutter/material.dart';
import 'package:mindloop/core/constants/reminder_categories.dart';
import 'package:mindloop/themes/app_colors.dart';

/// Calendar screen tokens — aligned with global fintech theme.
class CalendarUiColors {
  CalendarUiColors._();

  static const Color background = AppColors.scaffold;
  static const Color surface = AppColors.surface;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textMuted = AppColors.textMuted;
  static const Color border = AppColors.border;
  static const Color shadow = AppColors.shadow;
  static const Color chipActive = AppColors.primaryDark;
  static const Color chipInactive = AppColors.surfaceMuted;
  static const Color selectedDay = AppColors.primaryDark;
  static const Color progressTrack = AppColors.surfaceMuted;
  static const Color progressFill = AppColors.accent;

  static Color categoryAccent(ReminderCategory category) =>
      AppColors.categoryAccent(category);
}
