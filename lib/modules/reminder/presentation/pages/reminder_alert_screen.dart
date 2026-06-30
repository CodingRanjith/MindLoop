import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mindloop/modules/reminder/presentation/bloc/reminder_bloc.dart';
import 'package:mindloop/modules/reminder/core/constants/reminder_categories.dart';
import 'package:mindloop/core/utils/local_file_image.dart';
import 'package:mindloop/modules/reminder/core/utils/reminder_sound_player.dart';
import 'package:mindloop/modules/reminder/domain/entities/reminder_entity.dart';
import 'package:mindloop/shared/theme/app_colors.dart';
import 'package:mindloop/shared/widgets/dynamic_background.dart';
import 'package:mindloop/shared/widgets/rigging_alarm_background.dart';

class ReminderAlertScreen extends StatefulWidget {
  const ReminderAlertScreen({super.key, required this.reminder});

  final ReminderEntity reminder;

  ReminderAlertScreen.demo({super.key})
      : reminder = ReminderEntity(
          id: 'demo',
          title: 'MindLoop Demo',
          scheduledAt: DateTime.now(),
          note: 'Your notes appear here above the photo.',
          category: ReminderCategory.personal,
        );

  @override
  State<ReminderAlertScreen> createState() => _ReminderAlertScreenState();
}

class _ReminderAlertScreenState extends State<ReminderAlertScreen> {
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();
    _playAlert();
  }

  Future<void> _playAlert() async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await ReminderSoundPlayer.play(_player, widget.reminder.musicAsset);
    } catch (_) {
      // Sound optional on web or missing asset
    }
  }

  Future<void> _stopSound() async {
    try {
      await _player.stop();
    } catch (_) {}
  }

  Future<void> _snooze(BuildContext context) async {
    HapticFeedback.lightImpact();
    await _stopSound();
    if (!context.mounted) return;
    final r = widget.reminder;
    if (r.id != 'demo') {
      context.read<ReminderBloc>().add(ReminderSnoozeRequested(r.id));
    }
    context.pop();
  }

  Future<void> _dismiss(BuildContext context) async {
    HapticFeedback.mediumImpact();
    await _stopSound();
    if (!context.mounted) return;
    final r = widget.reminder;
    if (r.id != 'demo') {
      context.read<ReminderBloc>().add(ReminderDismissRequested(r.id));
    }
    context.pop();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reminder;
    final hasImage = LocalFileImage.canShowFile(r.imagePath);

    if (hasImage) {
      return _RiggingAlarmImageScreen(
        imagePath: r.imagePath!,
        onSnooze: () => _snooze(context),
        onDismiss: () => _dismiss(context),
      );
    }

    return _ClassicReminderAlert(
      reminder: r,
      onSnooze: () => _snooze(context),
      onDismiss: () => _dismiss(context),
    );
  }
}

class _RiggingAlarmImageScreen extends StatefulWidget {
  const _RiggingAlarmImageScreen({
    required this.imagePath,
    required this.onSnooze,
    required this.onDismiss,
  });

  final String imagePath;
  final VoidCallback onSnooze;
  final VoidCallback onDismiss;

  @override
  State<_RiggingAlarmImageScreen> createState() => _RiggingAlarmImageScreenState();
}

class _RiggingAlarmImageScreenState extends State<_RiggingAlarmImageScreen> {
  late DateTime _now;
  Timer? _clockTimer;
  final _timeFmt = DateFormat.jm();

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity > 420) {
      widget.onDismiss();
    } else if (velocity < -420) {
      widget.onSnooze();
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final top = media.padding.top;
    final bottom = media.padding.bottom;
    final bodyHeight = media.size.height - top - bottom;
    const headerHeight = 52.0;
    final imageHeight = (bodyHeight - headerHeight) * 0.90;

    return Scaffold(
      backgroundColor: const Color(0xFF081018),
      body: RiggingAlarmBackground(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragEnd: _onVerticalDragEnd,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: _RiggingAlarmHeader(timeLabel: _timeFmt.format(_now)),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: imageHeight,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: LocalFileImage(
                          path: widget.imagePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: bottom + 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RiggingAlarmHeader extends StatelessWidget {
  const _RiggingAlarmHeader({required this.timeLabel});

  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF22D3EE).withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Text(
                'Rigging Alarm',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: Color(0xFFE2E8F0),
                ),
              ),
              const Spacer(),
              Text(
                timeLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.85),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.08, end: 0);
  }
}

class _ClassicReminderAlert extends StatelessWidget {
  const _ClassicReminderAlert({
    required this.reminder,
    required this.onSnooze,
    required this.onDismiss,
  });

  final ReminderEntity reminder;
  final VoidCallback onSnooze;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final r = reminder;

    return Scaffold(
      body: DynamicBackground(
        category: r.category,
        child: SafeArea(
          child: Stack(
            children: [
              const _SideBalloons(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Icon(
                      Icons.notifications_active,
                      size: 56,
                      color: AppColors.softPink,
                    )
                        .animate(onPlay: (c) => c.repeat())
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.12, 1.12),
                          duration: 900.ms,
                        ),
                    const SizedBox(height: 16),
                    Text(
                      r.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ).animate().fadeIn().slideY(begin: 0.15, end: 0),
                    const Spacer(),
                    if (r.note != null && r.note!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text(
                          r.note!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            height: 1.45,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onSnooze,
                            child: const Text('Snooze 5m'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.neonPurple,
                            ),
                            onPressed: onDismiss,
                            child: const Text('Dismiss'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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

class _SideBalloons extends StatelessWidget {
  const _SideBalloons();

  @override
  Widget build(BuildContext context) {
    const colors = [
      AppColors.softPink,
      AppColors.electricBlue,
      AppColors.neonPurple,
      AppColors.electricBlue,
    ];
    const sides = [
      Alignment(-1.05, -0.35),
      Alignment(-1.0, 0.25),
      Alignment(1.05, -0.2),
      Alignment(1.0, 0.35),
    ];

    return Stack(
      children: List.generate(4, (i) {
        return Align(
          alignment: sides[i],
          child: _Balloon(color: colors[i], size: 44 + (i % 2) * 10)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(
                begin: -8,
                end: 8,
                duration: (2200 + i * 300).ms,
                curve: Curves.easeInOut,
              ),
        );
      }),
    );
  }
}

class _Balloon extends StatelessWidget {
  const _Balloon({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size * 1.15,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.95),
                color.withValues(alpha: 0.55),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.45),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: size * 0.22,
              height: size * 0.14,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Container(
          width: 2,
          height: size * 0.55,
          color: Colors.white.withValues(alpha: 0.35),
        ),
      ],
    );
  }
}
