import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mindloop/themes/pfm_theme.dart';

enum ExpenseReminderOutcome { success, failed, info }

class ExpenseReminderFeedback {
  ExpenseReminderFeedback._();

  static Future<void> show(
    BuildContext context, {
    required ExpenseReminderOutcome outcome,
    required String title,
    required String message,
  }) {
    final (icon, color, bg) = switch (outcome) {
      ExpenseReminderOutcome.success => (
          Icons.check_circle_rounded,
          PfmTheme.income,
          const Color(0xFFECFDF5),
        ),
      ExpenseReminderOutcome.failed => (
          Icons.error_outline_rounded,
          PfmTheme.expense,
          const Color(0xFFFEF2F2),
        ),
      ExpenseReminderOutcome.info => (
          Icons.info_outline_rounded,
          PfmTheme.primary,
          const Color(0xFFEEF2FF),
        ),
    };

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: BoxDecoration(
              color: PfmTheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: PfmTheme.cardShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: bg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 36),
                ).animate().scale(duration: 320.ms, curve: Curves.elasticOut),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: PfmTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: PfmTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Got it', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.08, end: 0),
        ),
      ),
    );
  }
}
