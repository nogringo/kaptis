import 'dart:math' as math;
import 'package:flutter/material.dart';

class VortexPainter extends CustomPainter {
  final double rotation;
  final Color color1;
  final Color color2;

  VortexPainter({
    required this.color1,
    required this.color2,
    this.rotation = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 - 2;

    for (int i = 0; i < 4; i++) {
      final startAngle = rotation + i * math.pi / 2;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + math.pi / 2,
          colors: [color1, color2.withAlpha(51)],
        ).createShader(Rect.fromCircle(center: center, radius: maxRadius));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: maxRadius - i * 5),
        startAngle,
        math.pi / 2,
        false,
        paint,
      );
    }

    final centerPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, color1],
      ).createShader(Rect.fromCircle(center: center, radius: 8));
    canvas.drawCircle(center, 8, centerPaint);
  }

  @override
  bool shouldRepaint(covariant VortexPainter oldDelegate) =>
      rotation != oldDelegate.rotation;
}
