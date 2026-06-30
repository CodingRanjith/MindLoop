import 'dart:math';

import 'package:flutter/material.dart';

/// Futuristic industrial backdrop for the rigging alarm image view.
class RiggingAlarmBackground extends StatefulWidget {
  const RiggingAlarmBackground({super.key, required this.child});

  final Widget child;

  @override
  State<RiggingAlarmBackground> createState() => _RiggingAlarmBackgroundState();
}

class _RiggingAlarmBackgroundState extends State<RiggingAlarmBackground>
    with TickerProviderStateMixin {
  late final AnimationController _gradientCtrl;
  late final AnimationController _particleCtrl;

  @override
  void initState() {
    super.initState();
    _gradientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
  }

  @override
  void dispose() {
    _gradientCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_gradientCtrl, _particleCtrl]),
      builder: (context, _) {
        final t = _gradientCtrl.value;
        final p = _particleCtrl.value;
        return Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.8 + t * 0.4, -1),
                  end: Alignment(0.9 - t * 0.3, 1),
                  colors: [
                    Color.lerp(
                      const Color(0xFF0A1628),
                      const Color(0xFF102A4A),
                      t,
                    )!,
                    Color.lerp(
                      const Color(0xFF0E2238),
                      const Color(0xFF163D5C),
                      1 - t,
                    )!,
                    Color.lerp(
                      const Color(0xFF081018),
                      const Color(0xFF0F2840),
                      t * 0.5,
                    )!,
                  ],
                ),
              ),
            ),
            Positioned(
              top: -80 + sin(p * pi * 2) * 24,
              right: -40,
              child: _glowOrb(220, const Color(0xFF22D3EE), 0.16),
            ),
            Positioned(
              bottom: 60 + cos(p * pi * 2) * 30,
              left: -60,
              child: _glowOrb(260, const Color(0xFF38BDF8), 0.12),
            ),
            Positioned(
              top: height * 0.35,
              left: width * 0.15 + sin(p * pi) * 20,
              child: _glowOrb(140, const Color(0xFFF59E0B), 0.1),
            ),
            CustomPaint(
              painter: _IndustrialFxPainter(progress: p, gradientT: t),
              size: Size.infinite,
            ),
            widget.child,
          ],
        );
      },
    );
  }

  double get width => MediaQuery.sizeOf(context).width;
  double get height => MediaQuery.sizeOf(context).height;

  Widget _glowOrb(double size, Color color, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: alpha),
            blurRadius: size * 0.45,
            spreadRadius: size * 0.08,
          ),
        ],
      ),
    );
  }
}

class _IndustrialFxPainter extends CustomPainter {
  _IndustrialFxPainter({required this.progress, required this.gradientT});

  final double progress;
  final double gradientT;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(42);
    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < 48; i++) {
      final seed = rnd.nextDouble();
      final x = (seed * size.width + progress * 120 + i * 17) % size.width;
      final y = ((i * 31.0 + progress * size.height * 0.35) % (size.height + 40)) - 20;
      final radius = 1.2 + (i % 5) * 0.55;
      particlePaint.color = Color.lerp(
        const Color(0xFF67E8F9),
        const Color(0xFFE2E8F0),
        (i % 7) / 7,
      )!.withValues(alpha: 0.15 + (i % 4) * 0.06);
      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }

    final trailPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 6; i++) {
      final phase = progress * pi * 2 + i;
      final start = Offset(
        size.width * (0.1 + i * 0.14) + sin(phase) * 24,
        size.height * (0.15 + (i % 3) * 0.12),
      );
      final end = Offset(
        start.dx + 80 + cos(phase) * 40,
        start.dy + 120 + sin(phase) * 20,
      );
      trailPaint.shader = LinearGradient(
        colors: [
          const Color(0xFF22D3EE).withValues(alpha: 0.0),
          const Color(0xFF22D3EE).withValues(alpha: 0.35),
          const Color(0xFF38BDF8).withValues(alpha: 0.0),
        ],
        stops: const [0, 0.5, 1],
      ).createShader(Rect.fromPoints(start, end));
      canvas.drawLine(start, end, trailPaint);
    }

    final sparklePaint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 18; i++) {
      final flicker = sin(progress * pi * 4 + i * 1.7);
      if (flicker < 0.35) continue;
      final cx = size.width * ((i * 0.17 + gradientT * 0.2) % 1.0);
      final cy = size.height * ((i * 0.11 + progress * 0.25) % 1.0);
      sparklePaint.color = Colors.white.withValues(alpha: 0.12 * flicker);
      _drawSparkle(canvas, Offset(cx, cy), 3 + (i % 3), sparklePaint);
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.drawCircle(center, size * 0.35, paint);
    final linePaint = Paint()
      ..color = paint.color
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx - size, center.dy),
      Offset(center.dx + size, center.dy),
      linePaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - size),
      Offset(center.dx, center.dy + size),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _IndustrialFxPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.gradientT != gradientT;
  }
}
