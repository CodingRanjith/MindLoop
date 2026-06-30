import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Legacy analytics route — opens the PFM analytics module.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.go('/finance/analytics');
    });
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
