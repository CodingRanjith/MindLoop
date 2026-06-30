import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:mindloop/app/di/injection.dart';
import 'package:mindloop/modules/steps/core/theme/steps_themes.dart';
import 'package:mindloop/modules/steps/core/utils/steps_preferences.dart';
import 'package:mindloop/modules/steps/presentation/widgets/steps_settings_sheet.dart';
import 'package:mindloop/modules/steps/services/shake_step_detector.dart';

class StepsScreen extends StatefulWidget {
  const StepsScreen({super.key});

  @override
  State<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> with TickerProviderStateMixin {
  late final ShakeStepDetector _detector;
  late final AnimationController _shakeAnim;

  @override
  void initState() {
    super.initState();
    _detector = ShakeStepDetector(StepsPreferences(sl()));
    _detector.addListener(_onUpdate);
    _shakeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _detector.startListening();
  }

  void _onUpdate() {
    if (!mounted) return;
    setState(() {});
    if (_detector.intensity > _detector.dynamicThreshold * 0.85) {
      _shakeAnim.forward(from: 0);
      HapticFeedback.lightImpact();
    }
  }

  @override
  void dispose() {
    _detector.removeListener(_onUpdate);
    _detector.dispose();
    _shakeAnim.dispose();
    super.dispose();
  }

  StepsTheme get _theme =>
      StepsTheme.of(StepsThemeId.fromKey(_detector.preferences.themeId));

  Future<void> _openSettings() async {
    HapticFeedback.selectionClick();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StepsSettingsSheet(detector: _detector),
    );
    if (mounted) setState(() {});
  }

  Future<void> _cycleTheme() async {
    HapticFeedback.selectionClick();
    final themes = StepsThemeId.values;
    final current = StepsThemeId.fromKey(_detector.preferences.themeId);
    final next = themes[(themes.indexOf(current) + 1) % themes.length];
    await _detector.setTheme(next.storageKey);
    if (mounted) setState(() {});
  }

  void _toggleListening() {
    HapticFeedback.mediumImpact();
    if (_detector.isListening) {
      _detector.stopListening();
    } else {
      _detector.startListening();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = _theme;
    final size = MediaQuery.sizeOf(context);
    final ringSize = (size.width * 0.76).clamp(250.0, 330.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.statusBarBrightness,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(gradient: theme.background),
          child: SafeArea(
            child: Column(
              children: [
                _TopBar(
                  theme: theme,
                  onBack: () => context.pop(),
                  onSettings: _openSettings,
                  onCycleTheme: _cycleTheme,
                ),
                const SizedBox(height: 8),
                _StatsRow(
                  theme: theme,
                  stepsToday: _detector.stepsToday,
                  sessionSteps: _detector.sessionSteps,
                  shakes: _detector.shakesToday,
                  goal: _detector.dailyGoal,
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _shakeAnim,
                      builder: (context, child) {
                        final wobble = math.sin(_shakeAnim.value * math.pi) * 0.04;
                        return Transform.rotate(angle: wobble, child: child);
                      },
                      child: _StepRing(
                        size: ringSize,
                        theme: theme,
                        steps: _detector.stepsToday,
                        goal: _detector.dailyGoal,
                        progress: _detector.progress,
                        isListening: _detector.isListening,
                        onTap: _toggleListening,
                      ),
                    ),
                  ),
                ),
                _IntensityMeter(
                  theme: theme,
                  intensity: _detector.intensity,
                  threshold: _detector.dynamicThreshold,
                ),
                const SizedBox(height: 12),
                Text(
                  _detector.isListening
                      ? 'Shake your phone to count steps'
                      : 'Tap ring to resume listening',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.onBackgroundMuted,
                  ),
                ),
                if (kIsWeb) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      await _detector.simulateShake();
                    },
                    child: Text(
                      'Simulate shake (web)',
                      style: TextStyle(color: theme.onBackground),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _BottomBar(
                  theme: theme,
                  isListening: _detector.isListening,
                  onToggle: _toggleListening,
                  onResetSession: () {
                    HapticFeedback.lightImpact();
                    _detector.resetSession();
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.theme,
    required this.onBack,
    required this.onSettings,
    required this.onCycleTheme,
  });

  final StepsTheme theme;
  final VoidCallback onBack;
  final VoidCallback onSettings;
  final VoidCallback onCycleTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          _GlassButton(
            theme: theme,
            icon: Icons.arrow_back_rounded,
            onTap: onBack,
          ),
          const Spacer(),
          _GlassChip(
            theme: theme,
            icon: theme.icon,
            label: theme.name,
            onTap: onCycleTheme,
          ),
          const SizedBox(width: 8),
          _GlassButton(
            theme: theme,
            icon: Icons.tune_rounded,
            onTap: onSettings,
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.theme,
    required this.stepsToday,
    required this.sessionSteps,
    required this.shakes,
    required this.goal,
  });

  final StepsTheme theme;
  final int stepsToday;
  final int sessionSteps;
  final int shakes;
  final int goal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _StatTile(
              theme: theme,
              icon: Icons.directions_walk_rounded,
              value: '$stepsToday',
              label: 'Today',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatTile(
              theme: theme,
              icon: Icons.bolt_rounded,
              value: '$sessionSteps',
              label: 'Session',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatTile(
              theme: theme,
              icon: Icons.flag_rounded,
              value: '$stepsToday/$goal',
              label: 'Goal',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.theme,
    required this.icon,
    required this.value,
    required this.label,
  });

  final StepsTheme theme;
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.controlSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: theme.onBackground),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: theme.onBackground,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: theme.onBackgroundMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRing extends StatelessWidget {
  const _StepRing({
    required this.size,
    required this.theme,
    required this.steps,
    required this.goal,
    required this.progress,
    required this.isListening,
    required this.onTap,
  });

  final double size;
  final StepsTheme theme;
  final int steps;
  final int goal;
  final double progress;
  final bool isListening;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inner = size - 36;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: _RingPainter(
                progress: progress,
                trackColor: theme.meterTrack,
                accent: theme.accent,
              ),
            ),
            Container(
              width: inner,
              height: inner,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [theme.accentSecondary, theme.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.accent.withValues(alpha: 0.4),
                    blurRadius: 36,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isListening
                        ? Icons.vibration_rounded
                        : Icons.pause_circle_outline_rounded,
                    color: theme.onBackground.withValues(alpha: 0.8),
                    size: 28,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'STEPS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.6,
                      color: theme.onBackground.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$steps',
                    style: TextStyle(
                      fontSize: size * 0.2,
                      fontWeight: FontWeight.w300,
                      color: theme.onBackground,
                      height: 1,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: theme.onBackground.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isListening ? 'LISTENING' : 'PAUSED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: theme.onBackground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.accent,
  });

  final double progress;
  final Color trackColor;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const stroke = 12.0;

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final arc = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        arc,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _IntensityMeter extends StatelessWidget {
  const _IntensityMeter({
    required this.theme,
    required this.intensity,
    required this.threshold,
  });

  final StepsTheme theme;
  final double intensity;
  final double threshold;

  @override
  Widget build(BuildContext context) {
    final max = math.max(threshold * 1.5, 2.5);
    final fill = (intensity / max).clamp(0.0, 1.0);
    final thresholdPos = (threshold / max).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shake intensity',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.onBackgroundMuted,
                ),
              ),
              Text(
                'Threshold ${threshold.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: theme.onBackgroundMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: theme.meterTrack,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 80),
                    height: 10,
                    width: constraints.maxWidth * fill,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.accentSecondary, theme.accent],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Positioned(
                    left: constraints.maxWidth * thresholdPos - 1,
                    child: Container(
                      width: 2,
                      height: 10,
                      color: theme.onBackground.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.theme,
    required this.isListening,
    required this.onToggle,
    required this.onResetSession,
  });

  final StepsTheme theme;
  final bool isListening;
  final VoidCallback onToggle;
  final VoidCallback onResetSession;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _GlassButton(
          theme: theme,
          icon: Icons.restart_alt_rounded,
          label: 'Reset session',
          onTap: onResetSession,
        ),
        const SizedBox(width: 24),
        Material(
          color: theme.onBackground.withValues(alpha: 0.2),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onToggle,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 64,
              height: 64,
              child: Icon(
                isListening ? Icons.sensors_off_rounded : Icons.sensors_rounded,
                color: theme.onBackground,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.theme,
    required this.icon,
    required this.onTap,
    this.label,
  });

  final StepsTheme theme;
  final IconData icon;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: theme.controlSurface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: label == null ? 44 : 52,
          height: label == null ? 44 : 52,
          child: Icon(icon, color: theme.onBackground, size: 22),
        ),
      ),
    );

    if (label == null) return button;

    return Column(
      children: [
        button,
        const SizedBox(height: 6),
        Text(
          label!,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: theme.onBackgroundMuted,
          ),
        ),
      ],
    );
  }
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({
    required this.theme,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final StepsTheme theme;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.controlSurface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: theme.onBackground),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: theme.onBackground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
