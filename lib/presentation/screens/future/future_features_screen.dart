import 'package:flutter/material.dart';
import 'package:mindloop/widgets/coming_soon_card.dart';
import 'package:mindloop/widgets/dynamic_background.dart';

class FutureFeaturesScreen extends StatelessWidget {
  const FutureFeaturesScreen({super.key});

  static const _features = [
    (Icons.psychology_rounded, 'AI Assistant', 'Personalized memory companion'),
    (Icons.mic_rounded, 'Smart Voice AI', 'Voice-to-reminder creation'),
    (Icons.watch_rounded, 'Wearable Sync', 'Apple Watch & Wear OS'),
    (Icons.family_restroom_rounded, 'Family Sharing', 'Shared reminders & budgets'),
    (Icons.home_rounded, 'Smart Home', 'IoT integration hub'),
    (Icons.music_note_rounded, 'AI Mood Music', 'Soundtracks for your mood'),
    (Icons.wallpaper_rounded, 'Dynamic Wallpapers', 'Live ambient backgrounds'),
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
