import 'package:flutter/material.dart';
import 'package:mindloop/modules/pomodoro/services/pomodoro_controller.dart';

/// Visual theme presets for the Pomodoro fullscreen timer.
enum PomodoroThemeId {
  coral('coral', 'Coral'),
  ocean('ocean', 'Ocean'),
  midnight('midnight', 'Midnight'),
  forest('forest', 'Forest'),
  sunset('sunset', 'Sunset'),
  aurora('aurora', 'Aurora');

  const PomodoroThemeId(this.storageKey, this.label);

  final String storageKey;
  final String label;

  static PomodoroThemeId fromKey(String? key) {
    return PomodoroThemeId.values.firstWhere(
      (t) => t.storageKey == key,
      orElse: () => PomodoroThemeId.coral,
    );
  }
}

class PomodoroPhaseStyle {
  const PomodoroPhaseStyle({
    required this.accent,
    required this.ringGradient,
    required this.backgroundGradient,
    required this.glowColor,
  });

  final Color accent;
  final LinearGradient ringGradient;
  final LinearGradient backgroundGradient;
  final Color glowColor;
}

class PomodoroTheme {
  const PomodoroTheme({
    required this.id,
    required this.name,
    required this.icon,
    required this.focus,
    required this.shortBreak,
    required this.longBreak,
    required this.onBackground,
    required this.onBackgroundMuted,
    required this.controlSurface,
    required this.trackColor,
    required this.statusBarBrightness,
  });

  final PomodoroThemeId id;
  final String name;
  final IconData icon;
  final PomodoroPhaseStyle focus;
  final PomodoroPhaseStyle shortBreak;
  final PomodoroPhaseStyle longBreak;
  final Color onBackground;
  final Color onBackgroundMuted;
  final Color controlSurface;
  final Color trackColor;
  final Brightness statusBarBrightness;

  PomodoroPhaseStyle phaseStyle(PomodoroPhase phase) => switch (phase) {
        PomodoroPhase.focus => focus,
        PomodoroPhase.shortBreak => shortBreak,
        PomodoroPhase.longBreak => longBreak,
      };

  static PomodoroTheme of(PomodoroThemeId id) =>
      _all.firstWhere((t) => t.id == id);

  static List<PomodoroTheme> get all => List.unmodifiable(_all);

  static const _all = [
    PomodoroTheme(
      id: PomodoroThemeId.coral,
      name: 'Coral',
      icon: Icons.local_fire_department_rounded,
      statusBarBrightness: Brightness.light,
      onBackground: Color(0xFFFFFFFF),
      onBackgroundMuted: Color(0xCCFFFFFF),
      controlSurface: Color(0x33FFFFFF),
      trackColor: Color(0x40FFFFFF),
      focus: PomodoroPhaseStyle(
        accent: Color(0xFFE85D4C),
        glowColor: Color(0xFFE85D4C),
        ringGradient: LinearGradient(
          colors: [Color(0xFFFF8A7A), Color(0xFFE85D4C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        backgroundGradient: LinearGradient(
          colors: [Color(0xFFFFB4A8), Color(0xFFE85D4C), Color(0xFFC94A3A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      shortBreak: PomodoroPhaseStyle(
        accent: Color(0xFF14B8A6),
        glowColor: Color(0xFF14B8A6),
        ringGradient: LinearGradient(
          colors: [Color(0xFF5EEAD4), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        backgroundGradient: LinearGradient(
          colors: [Color(0xFF99F6E4), Color(0xFF14B8A6), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      longBreak: PomodoroPhaseStyle(
        accent: Color(0xFF6366F1),
        glowColor: Color(0xFF6366F1),
        ringGradient: LinearGradient(
          colors: [Color(0xFF818CF8), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        backgroundGradient: LinearGradient(
          colors: [Color(0xFFA5B4FC), Color(0xFF6366F1), Color(0xFF4F46E5)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    ),
    PomodoroTheme(
      id: PomodoroThemeId.ocean,
      name: 'Ocean',
      icon: Icons.waves_rounded,
      statusBarBrightness: Brightness.light,
      onBackground: Color(0xFFFFFFFF),
      onBackgroundMuted: Color(0xCCFFFFFF),
      controlSurface: Color(0x33FFFFFF),
      trackColor: Color(0x40FFFFFF),
      focus: PomodoroPhaseStyle(
        accent: Color(0xFF0284C7),
        glowColor: Color(0xFF0284C7),
        ringGradient: LinearGradient(
          colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        backgroundGradient: LinearGradient(
          colors: [Color(0xFF7DD3FC), Color(0xFF0284C7), Color(0xFF0369A1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      shortBreak: PomodoroPhaseStyle(
        accent: Color(0xFF06B6D4),
        glowColor: Color(0xFF06B6D4),
        ringGradient: LinearGradient(
          colors: [Color(0xFF67E8F9), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        backgroundGradient: LinearGradient(
          colors: [Color(0xFFA5F3FC), Color(0xFF06B6D4), Color(0xFF0891B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      longBreak: PomodoroPhaseStyle(
        accent: Color(0xFF2563EB),
        glowColor: Color(0xFF2563EB),
        ringGradient: LinearGradient(
          colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        backgroundGradient: LinearGradient(
          colors: [Color(0xFF93C5FD), Color(0xFF2563EB), Color(0xFF1D4ED8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    ),
    PomodoroTheme(
      id: PomodoroThemeId.midnight,
      name: 'Midnight',
      icon: Icons.nightlight_round,
      statusBarBrightness: Brightness.light,
      onBackground: Color(0xFFFFFFFF),
      onBackgroundMuted: Color(0xB3FFFFFF),
      controlSurface: Color(0x26FFFFFF),
      trackColor: Color(0x33FFFFFF),
      focus: PomodoroPhaseStyle(
        accent: Color(0xFF8B5CF6),
        glowColor: Color(0xFF8B5CF6),
        ringGradient: LinearGradient(
          colors: [Color(0xFFA78BFA), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        backgroundGradient: LinearGradient(
          colors: [Color(0xFF312E81), Color(0xFF1E1B4B), Color(0xFF0F0A1E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      shortBreak: PomodoroPhaseStyle(
        accent: Color(0xFF6366F1),
        glowColor: Color(0xFF6366F1),
        ringGradient: LinearGradient(
          colors: [Color(0xFF818CF8), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        backgroundGradient: LinearGradient(
          colors: [Color(0xFF3730A3), Color(0xFF1E1B4B), Color(0xFF0F0A1E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      longBreak: PomodoroPhaseStyle(
        accent: Color(0xFFEC4899),
        glowColor: Color(0xFFEC4899),
        ringGradient: LinearGradient(
          colors: [Color(0xFFF472B6), Color(0xFFDB2777)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        backgroundGradient: LinearGradient(
          colors: [Color(0xFF831843), Color(0xFF1E1B4B), Color(0xFF0F0A1E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    ),
    PomodoroTheme(
      id: PomodoroThemeId.forest,
      name: 'Forest',
      icon: Icons.park_rounded,
      statusBarBrightness: Brightness.light,
      onBackground: Color(0xFFFFFFFF),
      onBackgroundMuted: Color(0xCCFFFFFF),
      controlSurface: Color(0x33FFFFFF),
      trackColor: Color(0x40FFFFFF),
      focus: PomodoroPhaseStyle(
        accent: Color(0xFF16A34A),
        glowColor: Color(0xFF16A34A),
        ringGradient: LinearGradient(
          colors: [Color(0xFF4ADE80), Color(0xFF16A34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        backgroundGradient: LinearGradient(
          colors: [Color(0xFF86EFAC), Color(0xFF16A34A), Color(0xFF14532D)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      shortBreak: PomodoroPhaseStyle(
        accent: Color(0xFF65A30D),
        glowColor: Color(0xFF65A30D),
        ringGradient: LinearGradient(
          colors: [Color(0xFFA3E635), Color(0xFF65A30D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        backgroundGradient: LinearGradient(
          colors: [Color(0xFFBEF264), Color(0xFF65A30D), Color(0xFF3F6212)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      longBreak: PomodoroPhaseStyle(
        accent: Color(0xFF0D9488),
        glowColor: Color(0xFF0D9488),
        ringGradient: LinearGradient(
          colors: [Color(0xFF2DD4BF), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        backgroundGradient: LinearGradient(
          colors: [Color(0xFF5EEAD4), Color(0xFF0D9488), Color(0xFF134E4A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    ),
    PomodoroTheme(
      id: PomodoroThemeId.sunset,
      name: 'Sunset',
      icon: Icons.wb_twilight_rounded,
      statusBarBrightness: Brightness.light,
      onBackground: Color(0xFFFFFFFF),
      onBackgroundMuted: Color(0xCCFFFFFF),
      controlSurface: Color(0x33FFFFFF),
      trackColor: Color(0x40FFFFFF),
      focus: PomodoroPhaseStyle(
        accent: Color(0xFFEA580C),
        glowColor: Color(0xFFEA580C),
        ringGradient: LinearGradient(
          colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        backgroundGradient: LinearGradient(
          colors: [Color(0xFFFDBA74), Color(0xFFEA580C), Color(0xFF9A3412)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      shortBreak: PomodoroPhaseStyle(
        accent: Color(0xFFF59E0B),
        glowColor: Color(0xFFF59E0B),
        ringGradient: LinearGradient(
          colors: [Color(0xFFFCD34D), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        backgroundGradient: LinearGradient(
          colors: [Color(0xFFFDE68A), Color(0xFFF59E0B), Color(0xFFB45309)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      longBreak: PomodoroPhaseStyle(
        accent: Color(0xFFE11D48),
        glowColor: Color(0xFFE11D48),
        ringGradient: LinearGradient(
          colors: [Color(0xFFFB7185), Color(0xFFE11D48)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        backgroundGradient: LinearGradient(
          colors: [Color(0xFFFDA4AF), Color(0xFFE11D48), Color(0xFF9F1239)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    ),
    PomodoroTheme(
      id: PomodoroThemeId.aurora,
      name: 'Aurora',
      icon: Icons.auto_awesome_rounded,
      statusBarBrightness: Brightness.light,
      onBackground: Color(0xFFFFFFFF),
      onBackgroundMuted: Color(0xCCFFFFFF),
      controlSurface: Color(0x33FFFFFF),
      trackColor: Color(0x40FFFFFF),
      focus: PomodoroPhaseStyle(
        accent: Color(0xFF22D3EE),
        glowColor: Color(0xFF22D3EE),
        ringGradient: LinearGradient(
          colors: [Color(0xFF67E8F9), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        backgroundGradient: LinearGradient(
          colors: [Color(0xFF22D3EE), Color(0xFF8B5CF6), Color(0xFF1E1B4B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      shortBreak: PomodoroPhaseStyle(
        accent: Color(0xFFA78BFA),
        glowColor: Color(0xFFA78BFA),
        ringGradient: LinearGradient(
          colors: [Color(0xFFC4B5FD), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        backgroundGradient: LinearGradient(
          colors: [Color(0xFFC4B5FD), Color(0xFF6366F1), Color(0xFF312E81)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      longBreak: PomodoroPhaseStyle(
        accent: Color(0xFF34D399),
        glowColor: Color(0xFF34D399),
        ringGradient: LinearGradient(
          colors: [Color(0xFF6EE7B7), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        backgroundGradient: LinearGradient(
          colors: [Color(0xFF6EE7B7), Color(0xFF14B8A6), Color(0xFF134E4A)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
    ),
  ];
}
