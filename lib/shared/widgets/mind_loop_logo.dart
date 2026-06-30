import 'package:flutter/material.dart';
import 'package:mindloop/shared/theme/app_colors.dart';

class MindLoopLogo extends StatelessWidget {
  const MindLoopLogo({super.key, this.size = 80});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: size * 0.35,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _LoopPainter(),
        child: Center(
          child: Icon(
            Icons.all_inclusive_rounded,
            color: AppColors.textOnPrimary,
            size: size * 0.45,
          ),
        ),
      ),
    );
  }
}

class _LoopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..shader = const LinearGradient(
        colors: [AppColors.textOnPrimary, AppColors.accentSoft],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.5,
      5.0,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
