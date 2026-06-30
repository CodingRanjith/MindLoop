import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mindloop/app/di/injection.dart';
import 'package:mindloop/modules/finance/core/utils/expense_reminder_preferences.dart';
import 'package:mindloop/modules/finance/services/expense_reminder_service.dart';
import 'package:mindloop/shared/widgets/app_list_rows.dart';
import 'package:mindloop/shared/widgets/glass_card.dart';
import 'package:mindloop/modules/finance/presentation/widgets/expense_reminder_feedback.dart';

class ExpenseReminderSettingsSection extends StatefulWidget {
  const ExpenseReminderSettingsSection({super.key});

  @override
  State<ExpenseReminderSettingsSection> createState() =>
      _ExpenseReminderSettingsSectionState();
}

class _ExpenseReminderSettingsSectionState extends State<ExpenseReminderSettingsSection> {
  late bool _enabled;
  late ExpenseReminderFrequency _frequency;
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    _enabled = ExpenseReminderPreferences.enabled;
    _frequency = ExpenseReminderPreferences.frequency;
    _time = TimeOfDay(
      hour: ExpenseReminderPreferences.hour,
      minute: ExpenseReminderPreferences.minute,
    );
  }

  Future<void> _applySchedule() async {
    if (kIsWeb) return;
    await sl<ExpenseReminderService>().reschedule();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked == null || !mounted) return;
    setState(() => _time = picked);
    await ExpenseReminderPreferences.setTime(hour: picked.hour, minute: picked.minute);
    await _applySchedule();
    if (!mounted) return;
    await ExpenseReminderFeedback.show(
      context,
      outcome: ExpenseReminderOutcome.success,
      title: 'Reminder time updated',
      message: 'Next alert at ${picked.format(context)}.',
    );
  }

  Future<void> _pickFrequency() async {
    final selected = await showModalBottomSheet<ExpenseReminderFrequency>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ExpenseReminderFrequency.values.map((f) {
            return RadioListTile<ExpenseReminderFrequency>(
              value: f,
              groupValue: _frequency,
              title: Text(_frequencyLabel(f)),
              onChanged: (v) => Navigator.pop(ctx, v),
            );
          }).toList(),
        ),
      ),
    );
    if (selected == null || !mounted) return;
    setState(() => _frequency = selected);
    await ExpenseReminderPreferences.setFrequency(selected);
    await _applySchedule();
    if (!mounted) return;
    await ExpenseReminderFeedback.show(
      context,
      outcome: ExpenseReminderOutcome.success,
      title: 'Schedule updated',
      message: '${_frequencyLabel(selected)} reminders are now active.',
    );
  }

  String _frequencyLabel(ExpenseReminderFrequency f) => switch (f) {
        ExpenseReminderFrequency.daily => 'Daily',
        ExpenseReminderFrequency.weekly => 'Weekly',
        ExpenseReminderFrequency.custom => 'Custom (daily time)',
      };

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      animate: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Smart Expense Reminders',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            'High-priority alerts to build a daily expense tracking habit.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          AppSwitchRow(
            title: 'Enable reminders',
            value: _enabled,
            onChanged: (v) async {
              setState(() => _enabled = v);
              await ExpenseReminderPreferences.setEnabled(v);
              await _applySchedule();
              if (!mounted) return;
              await ExpenseReminderFeedback.show(
                context,
                outcome: v ? ExpenseReminderOutcome.success : ExpenseReminderOutcome.info,
                title: v ? 'Reminders enabled' : 'Reminders paused',
                message: v
                    ? 'You will receive expense tracking alerts outside the app.'
                    : 'Expense reminders are turned off until you enable them again.',
              );
            },
          ),
          AppNavRow(
            title: 'Frequency',
            subtitle: _frequencyLabel(_frequency),
            icon: Icons.repeat_rounded,
            onTap: _enabled ? _pickFrequency : null,
          ),
          AppNavRow(
            title: 'Reminder time',
            subtitle: _time.format(context),
            icon: Icons.schedule_rounded,
            onTap: _enabled ? _pickTime : null,
          ),
          AppNavRow(
            title: 'Preview reminder screen',
            subtitle: 'See the full-screen expense prompt',
            icon: Icons.fullscreen_rounded,
            onTap: () => context.push('/expense-alert'),
          ),
        ],
      ),
    );
  }
}
