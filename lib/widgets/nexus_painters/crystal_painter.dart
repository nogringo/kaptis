import 'dart:math' as math;
import 'package:flutter/material.dart';

class CrystalPainter extends CustomPainter {
  final Color color1;
  final Color color2;
  final double glowValue;

  CrystalPainter({
    required this.color1,
    required this.color2,
    this.glowValue = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    final path = Path();

    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * math.pi / 180;
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
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withAlpha(230), color1, color2],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(path, paint);

    final highlightPaint = Paint()
      ..color = Colors.white.withAlpha((102 + glowValue * 76).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CrystalPainter oldDelegate) =>
      glowValue != oldDelegate.glowValue;
}
