import 'package:flutter/material.dart';
import '../../models/nexus_skin.dart';

class CorePainter extends CustomPainter {
  final double rotation;
  final double pulseValue;
  final NexusColor? color;

  CorePainter({this.rotation = 0, this.pulseValue = 0.5, this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 - 5;

    final bright = color?.bright ?? NexusColor.gold.bright;
    final medium = color?.medium ?? NexusColor.gold.medium;
    final dark = color?.dark ?? NexusColor.gold.dark;

    // Outer ring
    final outerRingPaint = Paint()
      ..color = bright.withAlpha(153)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawCircle(center, maxRadius, outerRingPaint);
    canvas.restore();

    // Inner ring
    final innerRingPaint = Paint()
      ..color = medium.withAlpha(204)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-rotation);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawCircle(center, maxRadius * 0.75, innerRingPaint);
    canvas.restore();

    // Core
    final coreRadius = (maxRadius * 0.4) + pulseValue * 3;
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, bright, dark],
      ).createShader(Rect.fromCircle(center: center, radius: coreRadius));
    canvas.drawCircle(center, coreRadius, corePaint);
  }

  @override
  bool shouldRepaint(covariant CorePainter oldDelegate) =>
      rotation != oldDelegate.rotation ||
      pulseValue != oldDelegate.pulseValue ||
      color != oldDelegate.color;
}
