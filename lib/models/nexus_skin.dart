import 'package:flutter/material.dart';

enum NexusSkin { diamond, crystal, pulsingOrb, vortex, star, core, sun }

enum NexusColor {
  gold('Dore', Color(0xFFFFD700), Color(0xFFDAA520), Color(0xFFB8860B)),
  blue('Bleu', Color(0xFF64B5F6), Color(0xFF2196F3), Color(0xFF1565C0)),
  red('Rouge', Color(0xFFEF5350), Color(0xFFE53935), Color(0xFFC62828)),
  green('Vert', Color(0xFF81C784), Color(0xFF4CAF50), Color(0xFF2E7D32)),
  purple('Violet', Color(0xFFBA68C8), Color(0xFF9C27B0), Color(0xFF6A1B9A)),
  cyan('Cyan', Color(0xFF4DD0E1), Color(0xFF00BCD4), Color(0xFF00838F)),
  pink('Rose', Color(0xFFF48FB1), Color(0xFFE91E63), Color(0xFFAD1457)),
  orange('Orange', Color(0xFFFFB74D), Color(0xFFFF9800), Color(0xFFE65100));

  final String label;
  final Color bright;
  final Color medium;
  final Color dark;

  const NexusColor(this.label, this.bright, this.medium, this.dark);
}
