import 'package:flutter/material.dart';
import 'package:mindloop/modules/pomodoro/core/theme/pomodoro_themes.dart';
import 'package:mindloop/modules/pomodoro/services/pomodoro_controller.dart';
import 'package:mindloop/shared/theme/app_colors.dart';

class PomodoroSettingsSheet extends StatefulWidget {
  const PomodoroSettingsSheet({super.key, required this.controller});

  final PomodoroController controller;

  @override
  State<PomodoroSettingsSheet> createState() => _PomodoroSettingsSheetState();
}

class _PomodoroSettingsSheetState extends State<PomodoroSettingsSheet> {
  late int _focus;
  late int _shortBreak;
  late int _longBreak;
  late int _sessionsUntilLong;
  late bool _autoBreaks;
  late bool _autoFocus;
  late bool _sound;
  late PomodoroThemeId _theme;

  @override
  void initState() {
    super.initState();
    final p = widget.controller.preferences;
    _focus = p.focusMinutes;
    _shortBreak = p.shortBreakMinutes;
    _longBreak = p.longBreakMinutes;
    _sessionsUntilLong = p.sessionsUntilLongBreak;
    _autoBreaks = p.autoStartBreaks;
    _autoFocus = p.autoStartFocus;
    _sound = p.soundEnabled;
    _theme = widget.controller.themeId;
  }

  Future<void> _save() async {
    await widget.controller.updateSettings(
      focusMinutes: _focus,
      shortBreakMinutes: _shortBreak,
      longBreakMinutes: _longBreak,
      sessionsUntilLongBreak: _sessionsUntilLong,
      autoStartBreaks: _autoBreaks,
      autoStartFocus: _autoFocus,
      soundEnabled: _sound,
      themeId: _theme.storageKey,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottom),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Timer Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Theme',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: PomodoroTheme.all.length,
                separatorBuilder: (context, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final theme = PomodoroTheme.all[index];
                  final selected = theme.id == _theme;
                  final preview = theme.focus.backgroundGradient;
                  return GestureDetector(
                    onTap: () => setState(() => _theme = theme.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 72,
                      decoration: BoxDecoration(
                        gradient: preview,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? AppColors.textPrimary
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(theme.icon, color: Colors.white, size: 20),
                          const SizedBox(height: 4),
                          Text(
                            theme.name,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            _DurationSlider(
              label: 'Focus',
              value: _focus,
              min: 5,
              max: 60,
              unit: 'min',
              onChanged: (v) => setState(() => _focus = v),
            ),
            _DurationSlider(
              label: 'Short break',
              value: _shortBreak,
              min: 1,
              max: 30,
              unit: 'min',
              onChanged: (v) => setState(() => _shortBreak = v),
            ),
            _DurationSlider(
              label: 'Long break',
              value: _longBreak,
              min: 5,
              max: 45,
              unit: 'min',
              onChanged: (v) => setState(() => _longBreak = v),
            ),
            _DurationSlider(
              label: 'Sessions until long break',
              value: _sessionsUntilLong,
              min: 2,
              max: 8,
              unit: '',
              onChanged: (v) => setState(() => _sessionsUntilLong = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Auto-start breaks'),
              subtitle: const Text('Begin break when focus ends'),
              value: _autoBreaks,
              onChanged: (v) => setState(() => _autoBreaks = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Auto-start focus'),
              subtitle: const Text('Begin focus when break ends'),
              value: _autoFocus,
              onChanged: (v) => setState(() => _autoFocus = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Completion sound'),
              value: _sound,
              onChanged: (v) => setState(() => _sound = v),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Save settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationSlider extends StatelessWidget {
  const _DurationSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final String unit;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                unit.isEmpty ? '$value' : '$value $unit',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            onChanged: (v) => onChanged(v.round()),
          ),
        ],
      ),
    );
  }
}
