import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mindloop/core/constants/currency_options.dart';
import 'package:mindloop/core/di/injection.dart';
import 'package:mindloop/core/utils/currency_preferences.dart';
import 'package:mindloop/core/utils/reminder_audio_permissions.dart';
import 'package:mindloop/services/notification_service.dart';
import 'package:mindloop/widgets/app_list_rows.dart';
import 'package:mindloop/widgets/dynamic_background.dart';
import 'package:mindloop/presentation/screens/settings/expense_data_settings_section.dart';
import 'package:mindloop/presentation/screens/settings/expense_reminder_settings_section.dart';
import 'package:mindloop/core/utils/theme_preferences.dart';
import 'package:mindloop/widgets/glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _haptics = true;
  bool _darkMode = false;
  late String _currencyCode;

  @override
  void initState() {
    super.initState();
    _currencyCode = CurrencyPreferences.selectedOption.code;
    ThemePreferences.isDarkMode().then((dark) {
      if (mounted) setState(() => _darkMode = dark);
    });
  }

  Future<void> _pickCurrency() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: CurrencyOptions.all.map((option) {
              return RadioListTile<String>(
                value: option.code,
                groupValue: _currencyCode,
                onChanged: (value) => Navigator.pop(context, value),
                title: Text('${option.label} (${option.symbol})'),
                subtitle: Text(option.code),
              );
            }).toList(),
          ),
        );
      },
    );
    if (selected == null || !mounted || selected == _currencyCode) return;
    await CurrencyPreferences.setSelectedCode(selected);
    if (!mounted) return;
    setState(() => _currencyCode = selected);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Currency updated')),
    );
  }

  Future<void> _fixAlarmPermissions() async {
    if (kIsWeb) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alarms work on the mobile app.')),
      );
      return;
    }
    final ready = await sl<NotificationService>().requestPermissions();
    if (!mounted) return;
    if (ready) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alarm permissions look good.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enable Notifications, Alarms & reminders, and turn off battery restrictions for MindLoop.',
          ),
          duration: Duration(seconds: 5),
        ),
      );
      await ReminderAudioPermissions.openSystemSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: DynamicBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              GlassCard(
                animate: false,
                child: Column(
                  children: [
                    AppSwitchRow(
                      title: 'Notifications',
                      value: _notifications,
                      onChanged: (v) => setState(() => _notifications = v),
                    ),
                    AppSwitchRow(
                      title: 'Haptic Feedback',
                      value: _haptics,
                      onChanged: (v) => setState(() => _haptics = v),
                    ),
                    AppSwitchRow(
                      title: 'Dark Mode',
                      value: _darkMode,
                      onChanged: (v) async {
                        setState(() => _darkMode = v);
                        await ThemePreferences.setThemeMode(
                          v ? ThemeMode.dark : ThemeMode.light,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const ExpenseDataSettingsSection(),
              const SizedBox(height: 16),
              const ExpenseReminderSettingsSection(),
              const SizedBox(height: 16),
              GlassCard(
                animate: false,
                child: AppNavRow(
                  title: 'Alarm permissions',
                  subtitle: 'Notifications, exact alarms, battery',
                  icon: Icons.alarm_rounded,
                  onTap: _fixAlarmPermissions,
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                animate: false,
                child: AppNavRow(
                  title: 'Currency',
                  subtitle:
                      '${CurrencyOptions.byCode(_currencyCode).label} (${CurrencyOptions.byCode(_currencyCode).symbol})',
                  icon: Icons.currency_exchange_rounded,
                  onTap: _pickCurrency,
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                animate: false,
                child: AppNavRow(
                  title: 'Language',
                  subtitle: 'English (more coming soon)',
                  icon: Icons.language,
                  onTap: () {},
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                animate: false,
                child: AppNavRow(
                  title: 'Privacy Policy',
                  subtitle: 'How MindLoop handles your data',
                  icon: Icons.privacy_tip_outlined,
                  onTap: () => context.push('/privacy'),
                ),
              ),
              const SizedBox(height: 8),
              GlassCard(
                animate: false,
                child: AppNavRow(
                  title: 'Terms of Service',
                  subtitle: 'Usage guidelines',
                  icon: Icons.description_outlined,
                  onTap: () => context.push('/terms'),
                ),
              ),
              const SizedBox(height: 8),
              GlassCard(
                animate: false,
                child: const AppNavRow(
                  title: 'Version',
                  subtitle: '1.0.0',
                  icon: Icons.info_outline,
                  trailing: SizedBox.shrink(),
                  onTap: null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
