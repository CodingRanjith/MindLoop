import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mindloop/shared/widgets/coming_soon_card.dart';
import 'package:mindloop/shared/widgets/dynamic_background.dart';
import 'package:mindloop/shared/theme/app_colors.dart';

class FutureFeaturesScreen extends StatelessWidget {
  const FutureFeaturesScreen({super.key});

  static const _features = [
    (Icons.timer_rounded, 'Pomodoro Clock', 'Focus timer with smart breaks', true, '/pomodoro'),
    (Icons.directions_walk_rounded, 'Step Counter', 'Shake-based dynamic steps', true, '/steps'),
    (Icons.psychology_rounded, 'AI Assistant', 'Personalized memory companion', false, ''),
    (Icons.mic_rounded, 'Smart Voice AI', 'Voice-to-reminder creation', false, ''),
    (Icons.watch_rounded, 'Wearable Sync', 'Apple Watch & Wear OS', false, ''),
    (Icons.family_restroom_rounded, 'Family Sharing', 'Shared reminders & budgets', false, ''),
    (Icons.home_rounded, 'Smart Home', 'IoT integration hub', false, ''),
    (Icons.music_note_rounded, 'AI Mood Music', 'Soundtracks for your mood', false, ''),
    (Icons.wallpaper_rounded, 'Dynamic Wallpapers', 'Live ambient backgrounds', false, ''),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coming Soon')),
      body: DynamicBackground(
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: _features.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final f = _features[i];
              if (f.$4) {
                return _AvailableFeatureCard(
                  icon: f.$1,
                  title: f.$2,
                  subtitle: f.$3,
                  onTap: () => context.push(f.$5),
                );
              }
              return ComingSoonCard(
                icon: f.$1,
                title: f.$2,
                subtitle: f.$3,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AvailableFeatureCard extends StatelessWidget {
  const _AvailableFeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 22, color: const Color(0xFFE85D4C)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.accent),
            ],
          ),
        ),
      ),
    );
  }
}
