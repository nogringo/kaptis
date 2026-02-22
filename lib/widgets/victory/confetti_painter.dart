import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'confetti_particle.dart';

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      canvas.save();
      canvas.translate(particle.x, particle.y);
      canvas.rotate(particle.rotation);

      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      switch (particle.shape) {
        case ConfettiShape.rectangle:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size * 0.6,
            ),
            paint,
          );
          break;

        case ConfettiShape.circle:
          canvas.drawCircle(Offset.zero, particle.size * 0.4, paint);
          break;

        case ConfettiShape.triangle:
          final path = Path();
          final halfSize = particle.size / 2;
          path.moveTo(0, -halfSize);
          path.lineTo(
            -halfSize * math.cos(math.pi / 6),
            halfSize * math.sin(math.pi / 6),
          );
          path.lineTo(
            halfSize * math.cos(math.pi / 6),
            halfSize * math.sin(math.pi / 6),
          );
          path.close();
          canvas.drawPath(path, paint);
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) => true;
}
