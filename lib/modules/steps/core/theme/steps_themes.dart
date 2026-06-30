import 'package:flutter/material.dart';

enum StepsThemeId {
  vitality('vitality', 'Vitality'),
  ocean('ocean', 'Ocean'),
  sunset('sunset', 'Sunset'),
  midnight('midnight', 'Midnight'),
  forest('forest', 'Forest');

  const StepsThemeId(this.storageKey, this.label);

  final String storageKey;
  final String label;

  static StepsThemeId fromKey(String? key) {
    return StepsThemeId.values.firstWhere(
      (t) => t.storageKey == key,
      orElse: () => StepsThemeId.vitality,
    );
  }
}

class StepsTheme {
  const StepsTheme({
    required this.id,
    required this.name,
    required this.icon,
    required this.background,
    required this.accent,
    required this.accentSecondary,
    required this.onBackground,
    required this.onBackgroundMuted,
    required this.controlSurface,
    required this.meterTrack,
    required this.statusBarBrightness,
  });

  final StepsThemeId id;
  final String name;
  final IconData icon;
  final LinearGradient background;
  final Color accent;
  final Color accentSecondary;
  final Color onBackground;
  final Color onBackgroundMuted;
  final Color controlSurface;
  final Color meterTrack;
  final Brightness statusBarBrightness;

  static StepsTheme of(StepsThemeId id) =>
      _all.firstWhere((t) => t.id == id);

  static List<StepsTheme> get all => List.unmodifiable(_all);

  static const _all = [
    StepsTheme(
      id: StepsThemeId.vitality,
      name: 'Vitality',
      icon: Icons.fitness_center_rounded,
      statusBarBrightness: Brightness.light,
      accent: Color(0xFF10B981),
      accentSecondary: Color(0xFF34D399),
      onBackground: Color(0xFFFFFFFF),
      onBackgroundMuted: Color(0xCCFFFFFF),
      controlSurface: Color(0x33FFFFFF),
      meterTrack: Color(0x40FFFFFF),
      background: LinearGradient(
        colors: [Color(0xFF6EE7B7), Color(0xFF10B981), Color(0xFF047857)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    StepsTheme(
      id: StepsThemeId.ocean,
      name: 'Ocean',
      icon: Icons.water_drop_rounded,
      statusBarBrightness: Brightness.light,
      accent: Color(0xFF0EA5E9),
      accentSecondary: Color(0xFF38BDF8),
      onBackground: Color(0xFFFFFFFF),
      onBackgroundMuted: Color(0xCCFFFFFF),
      controlSurface: Color(0x33FFFFFF),
      meterTrack: Color(0x40FFFFFF),
      background: LinearGradient(
        colors: [Color(0xFF7DD3FC), Color(0xFF0EA5E9), Color(0xFF0369A1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    StepsTheme(
      id: StepsThemeId.sunset,
      name: 'Sunset',
      icon: Icons.wb_sunny_rounded,
      statusBarBrightness: Brightness.light,
      accent: Color(0xFFF97316),
      accentSecondary: Color(0xFFFBBF24),
      onBackground: Color(0xFFFFFFFF),
      onBackgroundMuted: Color(0xCCFFFFFF),
      controlSurface: Color(0x33FFFFFF),
      meterTrack: Color(0x40FFFFFF),
      background: LinearGradient(
        colors: [Color(0xFFFDBA74), Color(0xFFF97316), Color(0xFFC2410C)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    StepsTheme(
      id: StepsThemeId.midnight,
      name: 'Midnight',
      icon: Icons.nightlight_round,
      statusBarBrightness: Brightness.light,
      accent: Color(0xFF8B5CF6),
      accentSecondary: Color(0xFFA78BFA),
      onBackground: Color(0xFFFFFFFF),
      onBackgroundMuted: Color(0xB3FFFFFF),
      controlSurface: Color(0x26FFFFFF),
      meterTrack: Color(0x33FFFFFF),
      background: LinearGradient(
        colors: [Color(0xFF4C1D95), Color(0xFF1E1B4B), Color(0xFF0F0A1E)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    StepsTheme(
      id: StepsThemeId.forest,
      name: 'Forest',
      icon: Icons.park_rounded,
      statusBarBrightness: Brightness.light,
      accent: Color(0xFF65A30D),
      accentSecondary: Color(0xFFA3E635),
      onBackground: Color(0xFFFFFFFF),
      onBackgroundMuted: Color(0xCCFFFFFF),
      controlSurface: Color(0x33FFFFFF),
      meterTrack: Color(0x40FFFFFF),
      background: LinearGradient(
        colors: [Color(0xFF86EFAC), Color(0xFF16A34A), Color(0xFF14532D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ];
}
