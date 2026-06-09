import 'package:flutter/material.dart';
import 'package:mindloop/core/constants/app_constants.dart';
import 'package:mindloop/widgets/dynamic_background.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service')),
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
                'By using MindLoop you agree to use the app responsibly. '
                'Reminder alerts and budget tools are provided for personal organization only '
                'and are not financial or medical advice.',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 16),
              Text(
                'Local account',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              Text(
                'Sign-in is stored on your device for convenience. Use a strong password '
                'and do not share your device with untrusted users.',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 16),
              Text(
                'Updates',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              Text(
                'Features marked “Coming soon” may change before release. '
                'We may update these terms when new functionality ships.',
                style: TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
