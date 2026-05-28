import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:mindloop/core/constants/reminder_categories.dart';
import 'package:mindloop/core/utils/local_file_image.dart';
import 'package:mindloop/core/utils/reminder_sound_player.dart';
import 'package:mindloop/domain/entities/reminder_entity.dart';
import 'package:mindloop/themes/app_colors.dart';
import 'package:mindloop/widgets/dynamic_background.dart';

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

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reminder;
    final hasImage = LocalFileImage.canShowFile(r.imagePath);

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
                    if (hasImage)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: LocalFileImage(
                          path: r.imagePath!,
                          height: 220,
                          width: 220,
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ).animate().fadeIn(delay: 300.ms).scale(
                            begin: const Offset(0.92, 0.92),
                            end: const Offset(1, 1),
                          ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              _player.stop();
                              context.pop();
                            },
                            child: const Text('Snooze 5m'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.neonPurple,
                            ),
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              _player.stop();
                              context.pop();
                            },
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
