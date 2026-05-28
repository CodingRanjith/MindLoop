import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mindloop/themes/app_colors.dart';
import 'package:mindloop/themes/app_decorations.dart';

class GlowButton extends StatelessWidget {
  const GlowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: outlined
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(AppDecorations.radiusButton),
              border: Border.all(color: AppColors.primary, width: 1.5),
              color: AppColors.surface,
            )
          : AppDecorations.primaryPillButton,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDecorations.radiusButton),
          onTap: isLoading
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed?.call();
                },
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textOnPrimary,
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: outlined ? AppColors.primary : AppColors.textOnPrimary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
