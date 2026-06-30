import 'package:flutter/material.dart';
import 'package:mindloop/core/constants/app_constants.dart';
import 'package:mindloop/shared/widgets/dynamic_background.dart';

/// In-app privacy summary for Play Store review (replace URL before publish).
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: DynamicBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              Text(
                AppConstants.appName,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 12),
              Text(
                'MindLoop stores reminders, budget entries, and account preferences '
                'locally on your device. We do not sell your personal data.',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 16),
              Text(
                'Data we store on device',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              Text(
                '• Reminders and schedules\n'
                '• Budget transactions\n'
                '• Login email and display name (local demo auth)\n'
                '• Notification and sound preferences',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 16),
              Text(
                'Permissions',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              Text(
                'Notifications and exact alarms are used only to deliver your reminders. '
                'Optional microphone or file access is requested only when you use related features.',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 16),
              Text(
                'Contact',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              Text(
                'Before publishing, add your support email and hosted privacy policy URL '
                'in the Play Console listing.',
                style: TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
