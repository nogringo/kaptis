import 'package:flutter/material.dart';

class AppTheme {
  final bool isDark;

  const AppTheme._({required this.isDark});

  static AppTheme of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return AppTheme._(isDark: brightness == Brightness.dark);
  }

  // Backgrounds
  Color get primaryBackground =>
      isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F5F5);

  Color get secondaryBackground =>
      isDark ? const Color(0xFF16213E) : Colors.white;

  Color get cardBackground =>
      isDark ? const Color(0xFF16213E) : const Color(0xFFFAFAFA);

  // Accent (Gold)
  Color get accentColor =>
      isDark ? const Color(0xFFFFD700) : const Color(0xFFDAA520);

  Color get accentColorBright => const Color(0xFFFFD700);

  Color get accentColorSecondary => const Color(0xFFDAA520);

  Color get accentColorTertiary => const Color(0xFFB8860B);

  // Text
  Color get primaryText => isDark ? Colors.white : const Color(0xFF1A1A2E);

  Color get secondaryText =>
      isDark ? Colors.grey.shade400 : Colors.grey.shade600;

  Color get tertiaryText =>
      isDark ? Colors.grey.shade500 : Colors.grey.shade700;

  Color get subtitleText =>
      isDark ? Colors.grey.shade300 : Colors.grey.shade700;

  // AppBar
  Color get appBarBackground => primaryBackground;

  Color get appBarForeground => primaryText;

  // Buttons
  Color get primaryButtonBackground => const Color(0xFFFFD700);

  Color get primaryButtonForeground => Colors.black;

  Color get outlineButtonBorder => isDark ? Colors.white54 : Colors.black38;

  Color get outlineButtonForeground =>
      isDark ? Colors.white : const Color(0xFF1A1A2E);

  // Borders
  Color get cardBorder =>
      isDark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(25);

  Color get selectedBorder => const Color(0xFFFFD700);

  // Board
  Color get boardLightCell =>
      isDark ? const Color(0xFFE8D4B8) : const Color(0xFFF0E6D3);

  Color get boardDarkCell =>
      isDark ? const Color(0xFFB58863) : const Color(0xFFC9A86C);

  Color get boardBorder => isDark ? Colors.black26 : Colors.transparent;

  // Game states
  Color get validMoveColor => Colors.green;

  Color get selectedColor => Colors.yellow;

  // Player colors (same for both themes)
  static const Color player1Color = Colors.blue;
  static const Color player2Color = Colors.red;

  // Shadows
  Color get shadowColor => Colors.black.withAlpha(76);

  Color get accentShadow => isDark
      ? const Color(0xFFFFD700).withAlpha(100)
      : Colors.black.withAlpha(50);

  // Logo gradient colors
  List<Color> get logoGradient => const [
    Color(0xFFFFD700),
    Color(0xFFDAA520),
    Color(0xFFB8860B),
  ];

  // Title gradient colors
  List<Color> get titleGradient => const [Color(0xFFFFD700), Color(0xFFFFA500)];
}
