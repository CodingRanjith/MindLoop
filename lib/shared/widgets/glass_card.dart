import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mindloop/shared/theme/app_colors.dart';
import 'package:mindloop/shared/theme/app_decorations.dart';

/// Elevated fintech card. Uses [Material] as the surface so [ListTile] ink works correctly.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.animate = true,
    this.delay = Duration.zero,
    this.variant = GlassCardVariant.elevated,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final bool animate;
  final Duration delay;
  final GlassCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppDecorations.radiusCard);

    final surfaceColor = variant == GlassCardVariant.highlight
        ? AppColors.surfaceElevated
        : AppColors.surface;

    Widget surface = Material(
      color: variant == GlassCardVariant.primary ? Colors.transparent : surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: variant == GlassCardVariant.primary
            ? BorderSide.none
            : BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? Padding(padding: padding, child: child)
          : InkWell(
              onTap: onTap,
              borderRadius: radius,
              child: Padding(padding: padding, child: child),
            ),
    );

    Widget card = Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: variant == GlassCardVariant.primary ? AppColors.cardGradient : null,
        boxShadow: AppDecorations.cardShadow,
      ),
      child: surface,
    );

    if (animate) {
      card = card
          .animate()
          .fadeIn(duration: 400.ms, delay: delay)
          .slideY(begin: 0.06, end: 0, duration: 400.ms, delay: delay);
    }

    return card;
  }
}

enum GlassCardVariant { elevated, highlight, primary }
