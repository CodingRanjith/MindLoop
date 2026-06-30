import 'package:flutter/material.dart';

enum ReminderCategory {
  birthday,
  anniversary,
  meeting,
  study,
  finance,
  personal,
  health,
  goalTracking,
}

extension ReminderCategoryX on ReminderCategory {
  String get label => switch (this) {
        ReminderCategory.birthday => 'Birthday',
        ReminderCategory.anniversary => 'Anniversary',
        ReminderCategory.meeting => 'Meeting',
        ReminderCategory.study => 'Study',
        ReminderCategory.finance => 'Finance',
        ReminderCategory.personal => 'Personal',
        ReminderCategory.health => 'Health',
        ReminderCategory.goalTracking => 'Goal Tracking',
      };

  IconData get icon => switch (this) {
        ReminderCategory.birthday => Icons.cake_rounded,
        ReminderCategory.anniversary => Icons.favorite_rounded,
        ReminderCategory.meeting => Icons.groups_rounded,
        ReminderCategory.study => Icons.menu_book_rounded,
        ReminderCategory.finance => Icons.account_balance_wallet_rounded,
        ReminderCategory.personal => Icons.person_rounded,
        ReminderCategory.health => Icons.favorite_border_rounded,
        ReminderCategory.goalTracking => Icons.flag_rounded,
      };

  static ReminderCategory fromString(String value) {
    return ReminderCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => ReminderCategory.personal,
    );
  }
}
