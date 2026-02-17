import 'package:flutter/material.dart';

class DiamondPainter extends CustomPainter {
  final Color color1;
  final Color color2;
  final Color color3;
  final double glowValue;

  DiamondPainter({
    required this.color1,
    required this.color2,
    required this.color3,
    this.glowValue = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final width = size.width - 10;
    final height = size.height - 6;

    final path = Path()
      ..moveTo(center.dx, center.dy - height / 2)
      ..lineTo(center.dx + width / 2, center.dy)
      ..lineTo(center.dx, center.dy + height / 2)
      ..lineTo(center.dx - width / 2, center.dy)
      ..close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color1, color2, color3],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);

    final linePaint = Paint()
      ..color = color1.withAlpha((127 + glowValue * 76).toInt())
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(center.dx - width / 2, center.dy),
      Offset(center.dx + width / 2, center.dy),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant DiamondPainter oldDelegate) =>
      glowValue != oldDelegate.glowValue;
}
