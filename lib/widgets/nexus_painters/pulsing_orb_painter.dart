import 'package:flutter/material.dart';
import '../../models/nexus_skin.dart';

class PulsingOrbPainter extends CustomPainter {
  final double pulseValue;
  final NexusColor? color;

  PulsingOrbPainter({this.pulseValue = 0.5, this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2 - 5) * (1.0 + pulseValue * 0.1);

    final bright = color?.bright ?? NexusColor.gold.bright;
    final medium = color?.medium ?? NexusColor.gold.medium;
    final dark = color?.dark ?? NexusColor.gold.dark;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, bright, medium, dark],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant PulsingOrbPainter oldDelegate) =>
      pulseValue != oldDelegate.pulseValue || color != oldDelegate.color;
}
