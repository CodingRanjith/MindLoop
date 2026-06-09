import 'package:flutter/material.dart';
import 'package:mindloop/themes/app_colors.dart';
import 'package:mindloop/themes/app_decorations.dart';

class PfmSummaryCard extends StatelessWidget {
  const PfmSummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accent = AppColors.primary,
    this.compact = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 140 : null,
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: AppDecorations.card(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          SizedBox(height: compact ? 8 : 10),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? 14 : 16,
              fontWeight: FontWeight.w800,
              color: accent == AppColors.expense ? AppColors.expense : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class PfmHealthBadge extends StatelessWidget {
  const PfmHealthBadge({super.key, required this.score, required this.levelLabel});

  final int score;
  final String levelLabel;

  @override
  Widget build(BuildContext context) {
    final color = switch (score) {
      >= 90 => AppColors.income,
      >= 75 => AppColors.accent,
      >= 50 => AppColors.warning,
      _ => AppColors.expense,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.15), AppColors.surface],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 5,
                  color: color,
                  backgroundColor: AppColors.surfaceMuted,
                ),
              ),
              Text(
                '$score',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: color),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Financial Health',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                Text(levelLabel, style: TextStyle(fontSize: 12, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
