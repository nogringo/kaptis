import 'dart:math' as math;
import 'package:flutter/material.dart';

class StarPainter extends CustomPainter {
  final Color color1;
  final Color color2;
  final Color color3;
  final double glowValue;

  StarPainter({
    required this.color1,
    required this.color2,
    required this.color3,
    this.glowValue = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 3;
    final innerRadius = outerRadius * 0.4;
    final path = Path();

    for (int i = 0; i < 8; i++) {
      final angle = (i * 45 - 90) * math.pi / 180;
      final radius = i.isEven ? outerRadius : innerRadius;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color1, color2, color3],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: outerRadius));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant StarPainter oldDelegate) =>
      glowValue != oldDelegate.glowValue;
}
