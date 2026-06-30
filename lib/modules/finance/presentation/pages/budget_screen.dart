import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Legacy route — redirects to the PFM hub.
class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.go('/finance/dashboard');
    });
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
