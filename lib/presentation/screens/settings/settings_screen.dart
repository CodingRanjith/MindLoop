import 'package:flutter/material.dart';
import 'package:mindloop/widgets/app_list_rows.dart';
import 'package:mindloop/widgets/dynamic_background.dart';
import 'package:mindloop/widgets/glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _haptics = true;
  bool _dynamicTheme = true;

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
                      title: 'Dynamic Theme',
                      value: _dynamicTheme,
                      onChanged: (v) => setState(() => _dynamicTheme = v),
                    ),
                  ],
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
