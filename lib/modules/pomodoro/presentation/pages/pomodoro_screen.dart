import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:mindloop/app/di/injection.dart';
import 'package:mindloop/modules/pomodoro/core/theme/pomodoro_themes.dart';
import 'package:mindloop/modules/pomodoro/core/utils/pomodoro_preferences.dart';
import 'package:mindloop/modules/pomodoro/presentation/widgets/pomodoro_settings_sheet.dart';
import 'package:mindloop/modules/pomodoro/services/pomodoro_controller.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen>
    with WidgetsBindingObserver {
  late final PomodoroController _controller;
  late final TextEditingController _taskController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = PomodoroController(PomodoroPreferences(sl()));
    _controller.addListener(_onTick);
    _taskController = TextEditingController(text: _controller.taskLabel);
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _controller.handleAppLifecycle(state == AppLifecycleState.resumed);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_onTick);
    _controller.dispose();
    _taskController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _openSettings() async {
    HapticFeedback.selectionClick();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PomodoroSettingsSheet(controller: _controller),
    );
    if (mounted) setState(() {});
  }

  void _onTimerTap() {
    HapticFeedback.mediumImpact();
    _controller.toggleTimer();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = _controller.theme;
    final phase = _controller.phase;
    final phaseStyle = theme.phaseStyle(phase);
    final size = MediaQuery.sizeOf(context);
    final ringSize = (size.width * 0.78).clamp(260.0, 340.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.statusBarBrightness,
        statusBarBrightness: theme.statusBarBrightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(gradient: phaseStyle.backgroundGradient),
          child: SafeArea(
            child: Column(
              children: [
                _TopBar(
                  theme: theme,
                  onBack: () => context.pop(),
                  onSettings: _openSettings,
                  onCycleTheme: () async {
                    HapticFeedback.selectionClick();
                    final themes = PomodoroThemeId.values;
                    final next = themes[
                        (themes.indexOf(_controller.themeId) + 1) %
                            themes.length];
                    await _controller.setTheme(next);
                    if (mounted) setState(() {});
                  },
                ),
                const SizedBox(height: 8),
                _SessionStats(
                  theme: theme,
                  completed: _controller.completedToday,
                  tapCount: _controller.tapCountToday,
                  cycleLabel:
                      '${_controller.completedFocusInCycle}/${_controller.preferences.sessionsUntilLongBreak}',
                  focusLabel: PomodoroPreferences.focusTimeLabel(sl()),
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: 12),
                _PhaseSelector(
                  theme: theme,
                  current: phase,
                  enabled: !_controller.isRunning,
                  onSelect: (p) {
                    HapticFeedback.selectionClick();
                    _controller.selectPhase(p);
                    setState(() {});
                  },
                ),
                Expanded(
                  child: Center(
                    child: _FullscreenTimerRing(
                      size: ringSize,
                      progress: _controller.progress,
                      timeLabel: _formatTime(_controller.remainingSeconds),
                      phaseLabel: _controller.phaseLabel,
                      phaseStyle: phaseStyle,
                      theme: theme,
                      isRunning: _controller.isRunning,
                      isPaused: _controller.isPaused,
                      onTap: _onTimerTap,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: TextField(
                    controller: _taskController,
                    onChanged: _controller.setTaskLabel,
                    textInputAction: TextInputAction.done,
                    enabled: !_controller.isRunning,
                    style: TextStyle(color: theme.onBackground),
                    cursorColor: theme.onBackground,
                    decoration: InputDecoration(
                      hintText: 'What are you focusing on?',
                      hintStyle: TextStyle(color: theme.onBackgroundMuted),
                      prefixIcon: Icon(
                        Icons.flag_outlined,
                        color: theme.onBackground.withValues(alpha: 0.9),
                      ),
                      filled: true,
                      fillColor: theme.controlSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _BottomControls(
                  theme: theme,
                  isRunning: _controller.isRunning,
                  onReset: () {
                    HapticFeedback.lightImpact();
                    _controller.reset();
                    setState(() {});
                  },
                  onSkip: () {
                    HapticFeedback.lightImpact();
                    _controller.skip();
                    setState(() {});
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  _controller.isRunning
                      ? 'Tap timer to pause'
                      : _controller.isPaused
                          ? 'Tap timer to resume'
                          : 'Tap timer to start',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: theme.onBackgroundMuted,
                  ),
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

  final PomodoroTheme theme;
  final VoidCallback onBack;
  final VoidCallback onSettings;
  final VoidCallback onCycleTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          _GlassIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: onBack,
            theme: theme,
          ),
          const Spacer(),
          _GlassChip(
            theme: theme,
            icon: theme.icon,
            label: theme.name,
            onTap: onCycleTheme,
          ),
          const SizedBox(width: 8),
          _GlassIconButton(
            icon: Icons.tune_rounded,
            onTap: onSettings,
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _SessionStats extends StatelessWidget {
  const _SessionStats({
    required this.theme,
    required this.completed,
    required this.tapCount,
    required this.cycleLabel,
    required this.focusLabel,
  });

  final PomodoroTheme theme;
  final int completed;
  final int tapCount;
  final String cycleLabel;
  final String focusLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _StatTile(
              theme: theme,
              icon: Icons.local_fire_department_rounded,
              value: '$completed',
              label: 'Sessions',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatTile(
              theme: theme,
              icon: Icons.touch_app_rounded,
              value: '$tapCount',
              label: 'Taps',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatTile(
              theme: theme,
              icon: Icons.loop_rounded,
              value: cycleLabel,
              label: 'Cycle',
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

  final PomodoroTheme theme;
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
            style: TextStyle(
              fontSize: 16,
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

class _PhaseSelector extends StatelessWidget {
  const _PhaseSelector({
    required this.theme,
    required this.current,
    required this.enabled,
    required this.onSelect,
  });

  final PomodoroTheme theme;
  final PomodoroPhase current;
  final bool enabled;
  final ValueChanged<PomodoroPhase> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.controlSurface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: PomodoroPhase.values.map((phase) {
            final selected = phase == current;
            return Expanded(
              child: GestureDetector(
                onTap: enabled ? () => onSelect(phase) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? theme.onBackground.withValues(alpha: 0.18)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    switch (phase) {
                      PomodoroPhase.focus => 'Focus',
                      PomodoroPhase.shortBreak => 'Short',
                      PomodoroPhase.longBreak => 'Long',
                    },
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? theme.onBackground
                          : theme.onBackgroundMuted,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _FullscreenTimerRing extends StatefulWidget {
  const _FullscreenTimerRing({
    required this.size,
    required this.progress,
    required this.timeLabel,
    required this.phaseLabel,
    required this.phaseStyle,
    required this.theme,
    required this.isRunning,
    required this.isPaused,
    required this.onTap,
  });

  final double size;
  final double progress;
  final String timeLabel;
  final String phaseLabel;
  final PomodoroPhaseStyle phaseStyle;
  final PomodoroTheme theme;
  final bool isRunning;
  final bool isPaused;
  final VoidCallback onTap;

  @override
  State<_FullscreenTimerRing> createState() => _FullscreenTimerRingState();
}

class _FullscreenTimerRingState extends State<_FullscreenTimerRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant _FullscreenTimerRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRunning != widget.isRunning) _syncPulse();
  }

  void _syncPulse() {
    if (widget.isRunning) {
      _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inner = widget.size - 40;
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final scale = widget.isRunning ? 1 + (_pulse.value * 0.018) : 1.0;
          return Transform.scale(scale: scale, child: child);
        },
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  progress: widget.progress,
                  trackColor: widget.theme.trackColor,
                  accent: widget.phaseStyle.accent,
                ),
              ),
              Container(
                width: inner,
                height: inner,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: widget.phaseStyle.ringGradient,
                  boxShadow: [
                    BoxShadow(
                      color: widget.phaseStyle.glowColor.withValues(alpha: 0.45),
                      blurRadius: 40,
                      spreadRadius: 2,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.isRunning
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: widget.theme.onBackground.withValues(alpha: 0.7),
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.phaseLabel.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                        color: widget.theme.onBackground.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.timeLabel,
                      style: TextStyle(
                        fontSize: widget.size * 0.19,
                        fontWeight: FontWeight.w200,
                        color: widget.theme.onBackground,
                        letterSpacing: -2,
                        height: 1,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: widget.theme.onBackground.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.isRunning
                            ? 'RUNNING'
                            : widget.isPaused
                                ? 'PAUSED'
                                : 'TAP TO START',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: widget.theme.onBackground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
        -3.14159 / 2,
        2 * 3.14159 * progress,
        false,
        arc,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.accent != accent;
  }
}

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.theme,
    required this.isRunning,
    required this.onReset,
    required this.onSkip,
  });

  final PomodoroTheme theme;
  final bool isRunning;
  final VoidCallback onReset;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _GlassIconButton(
          icon: Icons.refresh_rounded,
          label: 'Reset',
          onTap: onReset,
          theme: theme,
        ),
        const SizedBox(width: 28),
        _GlassIconButton(
          icon: Icons.skip_next_rounded,
          label: 'Skip',
          onTap: onSkip,
          theme: theme,
        ),
      ],
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    required this.theme,
    this.label,
  });

  final IconData icon;
  final VoidCallback onTap;
  final PomodoroTheme theme;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final child = Material(
      color: theme.controlSurface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: label == null ? 44 : 56,
          height: label == null ? 44 : 56,
          child: Icon(icon, color: theme.onBackground, size: 22),
        ),
      ),
    );

    if (label == null) return child;

    return Column(
      children: [
        child,
        const SizedBox(height: 6),
        Text(
          label!,
          style: TextStyle(
            fontSize: 12,
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

  final PomodoroTheme theme;
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
