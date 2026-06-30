import 'package:flutter/material.dart';
import 'package:mindloop/modules/steps/core/theme/steps_themes.dart';
import 'package:mindloop/modules/steps/services/shake_step_detector.dart';
import 'package:mindloop/shared/theme/app_colors.dart';

class StepsSettingsSheet extends StatefulWidget {
  const StepsSettingsSheet({super.key, required this.detector});

  final ShakeStepDetector detector;

  @override
  State<StepsSettingsSheet> createState() => _StepsSettingsSheetState();
}

class _StepsSettingsSheetState extends State<StepsSettingsSheet> {
  late int _goal;
  late double _sensitivity;
  late StepsThemeId _theme;

  @override
  void initState() {
    super.initState();
    final p = widget.detector.preferences;
    _goal = p.dailyGoal;
    _sensitivity = p.sensitivity;
    _theme = StepsThemeId.fromKey(p.themeId);
  }

  Future<void> _save() async {
    await widget.detector.updateSettings(
      dailyGoal: _goal,
      sensitivity: _sensitivity,
      themeId: _theme.storageKey,
    );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _resetToday() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset today\'s steps?'),
        content: const Text('This clears today\'s shake step count.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await widget.detector.resetToday();
      if (mounted) Navigator.pop(context);
    }
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
              'Step Counter Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Each phone shake counts as one step. Sensitivity adapts to your motion pattern.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
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
                itemCount: StepsTheme.all.length,
                separatorBuilder: (context, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final theme = StepsTheme.all[index];
                  final selected = theme.id == _theme;
                  return GestureDetector(
                    onTap: () => setState(() => _theme = theme.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 72,
                      decoration: BoxDecoration(
                        gradient: theme.background,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daily goal',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$_goal steps',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            Slider(
              value: _goal.toDouble(),
              min: 20,
              max: 500,
              divisions: 48,
              onChanged: (v) => setState(() => _goal = v.round()),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Shake sensitivity',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _sensitivity < 1.2
                      ? 'High'
                      : _sensitivity < 1.8
                          ? 'Medium'
                          : 'Low',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            Slider(
              value: _sensitivity,
              min: 0.8,
              max: 2.5,
              divisions: 17,
              onChanged: (v) => setState(() => _sensitivity = v),
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _resetToday,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Reset today\'s count'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
