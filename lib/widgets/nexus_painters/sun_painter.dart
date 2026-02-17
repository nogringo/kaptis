import 'dart:math' as math;
import 'package:flutter/material.dart';

class SunPainter extends CustomPainter {
  final double rotation;
  final Color color1;
  final Color color2;
  final Color color3;
  final double pulseValue;

  SunPainter({
    required this.color1,
    required this.color2,
    required this.color3,
    this.rotation = 0,
    this.pulseValue = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 - 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    final rayPaint = Paint()
      ..shader = RadialGradient(
        colors: [color2, color3.withAlpha(76)],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 12; i++) {
      final angle = i * 30 * math.pi / 180;
      final innerRadius = 12.0 + pulseValue * 2;
      final outerRadius = maxRadius - 2;
      final start = Offset(
        center.dx + innerRadius * math.cos(angle),
        center.dy + innerRadius * math.sin(angle),
      );
      final end = Offset(
        center.dx + outerRadius * math.cos(angle),
        center.dy + outerRadius * math.sin(angle),
      );
      canvas.drawLine(start, end, rayPaint);
    }

    canvas.restore();

    final centerPaint = Paint()
      ..shader = RadialGradient(
        colors: [color1, color2, color3],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: 12));
    canvas.drawCircle(center, 10 + pulseValue * 2, centerPaint);
  }

  @override
  bool shouldRepaint(covariant SunPainter oldDelegate) =>
      rotation != oldDelegate.rotation || pulseValue != oldDelegate.pulseValue;
}
