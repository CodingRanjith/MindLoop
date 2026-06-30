import 'package:flutter/material.dart';
import 'package:mindloop/shared/theme/app_colors.dart';

class PfmNoDataBox extends StatelessWidget {
  const PfmNoDataBox({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ),
    );
  }
}
