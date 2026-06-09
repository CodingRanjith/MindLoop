import 'package:flutter/material.dart';
import 'package:mindloop/core/utils/user_friendly_errors.dart';

/// Consistent floating SnackBars across the app.
class AppFeedback {
  AppFeedback._();

  static void showError(BuildContext context, Object message) {
    final text = message is String ? message : UserFriendlyErrors.format(message);
    _show(context, text, isError: true);
  }

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, isError: false);
  }

  static void _show(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? const Color(0xFFB91C1C) : null,
      ),
    );
  }
}
