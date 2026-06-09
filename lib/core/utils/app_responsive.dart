import 'package:flutter/material.dart';

/// Global layout helpers for phones, tall phones, and small tablets.
class AppResponsive {
  AppResponsive._();

  static const double maxContentWidth = 560;

  /// Keeps large text accessible without breaking tight card layouts.
  static TextScaler clampTextScaler(TextScaler scaler) {
    final scale = scaler.scale(1.0).clamp(0.9, 1.3);
    return TextScaler.linear(scale);
  }

  static EdgeInsets pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width < 360 ? 16.0 : width < 600 ? 20.0 : 24.0;
    return EdgeInsets.symmetric(horizontal: horizontal);
  }

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 360;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 600;
}

/// Centers scrollable content on wide screens (Play Store tablet screenshots).
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = AppResponsive.maxContentWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
