import 'dart:math' as math;
import 'package:flutter/material.dart';

class ConfettiParticle {
  double x;
  double y;
  double velocityX;
  double velocityY;
  double rotation;
  double rotationSpeed;
  double size;
  Color color;
  ConfettiShape shape;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.color,
    required this.shape,
  });

  factory ConfettiParticle.random({
    required double screenWidth,
    required Color baseColor,
    required math.Random random,
  }) {
    // Generate color variations based on the winner's color
    final hslColor = HSLColor.fromColor(baseColor);
    final variatedColor = hslColor
        .withLightness(
          (hslColor.lightness + random.nextDouble() * 0.3).clamp(0.3, 0.9),
        )
        .withSaturation(
          (hslColor.saturation + random.nextDouble() * 0.2).clamp(0.5, 1.0),
        )
        .toColor();

    // Some particles are gold/silver for extra celebration
    final colors = [
      variatedColor,
      variatedColor,
      variatedColor,
      Colors.amber,
      Colors.white,
    ];

    return ConfettiParticle(
      x: random.nextDouble() * screenWidth,
      y: -random.nextDouble() * 100 - 20,
      velocityX: (random.nextDouble() - 0.5) * 4,
      velocityY: random.nextDouble() * 3 + 2,
      rotation: random.nextDouble() * 2 * math.pi,
      rotationSpeed: (random.nextDouble() - 0.5) * 0.2,
      size: random.nextDouble() * 8 + 4,
      color: colors[random.nextInt(colors.length)],
      shape: ConfettiShape.values[random.nextInt(ConfettiShape.values.length)],
    );
  }

  void update(double gravity, double screenHeight) {
    velocityY += gravity;
    x += velocityX;
    y += velocityY;
    rotation += rotationSpeed;

    // Add some swaying motion
    velocityX += math.sin(y * 0.01) * 0.1;
    velocityX = velocityX.clamp(-5.0, 5.0);
  }

  bool isOffScreen(double screenHeight) {
    return y > screenHeight + 50;
  }
}

enum ConfettiShape { rectangle, circle, triangle }
