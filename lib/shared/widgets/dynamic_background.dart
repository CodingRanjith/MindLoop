import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mindloop/modules/reminder/core/constants/reminder_categories.dart';
import 'package:mindloop/shared/theme/app_colors.dart';

enum BackgroundMood { defaultMood, night, morning, birthday, romantic, office }

class DynamicBackground extends StatefulWidget {
  const DynamicBackground({
    super.key,
    this.mood = BackgroundMood.defaultMood,
    this.category,
    this.child,
  });

  final BackgroundMood mood;
  final ReminderCategory? category;
  final Widget? child;

  @override
  State<DynamicBackground> createState() => _DynamicBackgroundState();
}

class _DynamicBackgroundState extends State<DynamicBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  BackgroundMood get _effectiveMood {
    if (widget.category != null) {
      return switch (widget.category!) {
        ReminderCategory.birthday => BackgroundMood.birthday,
        ReminderCategory.anniversary => BackgroundMood.romantic,
        ReminderCategory.meeting => BackgroundMood.office,
        _ => widget.mood,
      };
    }
    final hour = DateTime.now().hour;
    if (hour >= 20 || hour < 6) return BackgroundMood.night;
    if (hour < 10) return BackgroundMood.morning;
    return widget.mood;
  }

  @override
  Widget build(BuildContext context) {
    final mood = _effectiveMood;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: _gradientFor(mood, _controller.value),
              ),
            ),
            ..._meshBlobsFor(mood, _controller.value),
            if (widget.child != null) widget.child!,
          ],
        );
      },
    );
  }

  LinearGradient _gradientFor(BackgroundMood mood, double t) {
    return switch (mood) {
      BackgroundMood.birthday => LinearGradient(
          colors: [
            const Color(0xFFFFF7ED),
            Color.lerp(AppColors.chartAmber, AppColors.chartCoral, t)!,
            AppColors.scaffold,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      BackgroundMood.romantic => LinearGradient(
          colors: [
            const Color(0xFFFFF1F2),
            Color.lerp(AppColors.chartCoral, AppColors.chartLavender, t)!,
            AppColors.scaffold,
          ],
        ),
      BackgroundMood.night => LinearGradient(
          colors: [
            Color.lerp(const Color(0xFFE2E8F0), const Color(0xFFCBD5E1), t)!,
            const Color(0xFFF1F5F9),
            AppColors.scaffold,
          ],
        ),
      BackgroundMood.morning => LinearGradient(
          colors: [
            Color.lerp(const Color(0xFFE0F2FE), const Color(0xFFCCFBF1), t)!,
            AppColors.scaffold,
            const Color(0xFFF8FAFC),
          ],
        ),
      BackgroundMood.office => const LinearGradient(
          colors: [Color(0xFFF1F5F9), Color(0xFFE8EEF4), AppColors.scaffold],
        ),
      _ => AppColors.backgroundGradient,
    };
  }

  List<Widget> _meshBlobsFor(BackgroundMood mood, double t) {
    final color = switch (mood) {
      BackgroundMood.birthday => AppColors.chartAmber,
      BackgroundMood.romantic => AppColors.chartCoral,
      BackgroundMood.morning => AppColors.accent,
      BackgroundMood.night => AppColors.chartLavender,
      _ => AppColors.accent,
    };
    return [
      Positioned(
        top: -40 + sin(t * pi) * 12,
        right: -30,
        child: _blob(180, color.withValues(alpha: 0.18)),
      ),
      Positioned(
        bottom: 120 + cos(t * pi) * 16,
        left: -50,
        child: _blob(220, AppColors.chartSky.withValues(alpha: 0.14)),
      ),
      Positioned(
        top: 220,
        left: 40 + sin(t * 2 * pi) * 20,
        child: _blob(120, AppColors.chartLavender.withValues(alpha: 0.12)),
      ),
    ];
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
