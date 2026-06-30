import 'package:flutter/material.dart';
import 'package:mindloop/shared/theme/pfm_theme.dart';

/// Shared fintech form styling — external labels avoid dropdown label overlap.
class PfmFormFields {
  PfmFormFields._();

  static const double fieldGap = 14;

  static const TextStyle labelStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: PfmTheme.textSecondary,
    letterSpacing: 0.1,
  );

  static InputDecoration decoration({String? hint}) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: PfmTheme.textMuted, fontSize: 15),
        filled: true,
        fillColor: const Color(0xFFF3F4F8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: PfmTheme.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: PfmTheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: PfmTheme.expense),
        ),
      );

  static ButtonStyle primaryButtonStyle() => FilledButton.styleFrom(
        backgroundColor: PfmTheme.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      );
}

class PfmFormSheet extends StatelessWidget {
  const PfmFormSheet({
    super.key,
    required this.title,
    required this.children,
    this.primaryLabel = 'Save',
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String title;
  final List<Widget> children;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Material(
          color: PfmTheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: PfmTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: PfmTheme.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, color: PfmTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    16 + MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  children: [
                    ...children,
                    if (onPrimary != null) ...[
                      const SizedBox(height: 8),
                      FilledButton(
                        style: PfmFormFields.primaryButtonStyle(),
                        onPressed: onPrimary,
                        child: Text(primaryLabel),
                      ),
                    ],
                    if (onSecondary != null && secondaryLabel != null) ...[
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: onSecondary,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: PfmTheme.expense,
                          side: const BorderSide(color: PfmTheme.expense),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: Text(secondaryLabel!),
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PfmFormTextField extends StatelessWidget {
  const PfmFormTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PfmFormFields.fieldGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: PfmFormFields.labelStyle),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 15, color: PfmTheme.textPrimary),
            decoration: PfmFormFields.decoration(hint: hint),
          ),
        ],
      ),
    );
  }
}

class PfmFormDropdown<T> extends StatelessWidget {
  const PfmFormDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required     this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PfmFormFields.fieldGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: PfmFormFields.labelStyle),
          const SizedBox(height: 8),
          DropdownButtonFormField<T>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: PfmTheme.textSecondary),
            decoration: PfmFormFields.decoration(),
            style: const TextStyle(fontSize: 15, color: PfmTheme.textPrimary, fontWeight: FontWeight.w500),
            borderRadius: BorderRadius.circular(14),
            items: items,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class PfmQuickAddTile extends StatelessWidget {
  const PfmQuickAddTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.22)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color.withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
