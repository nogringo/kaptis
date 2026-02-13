import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  // Backgrounds
  final Color primaryBackground;
  final Color secondaryBackground;
  final Color cardBackground;

  // Accent
  final Color accentColor;
  final Color accentColorBright;
  final Color accentColorSecondary;
  final Color accentColorTertiary;

  // Text
  final Color primaryText;
  final Color secondaryText;
  final Color tertiaryText;
  final Color subtitleText;

  // AppBar
  final Color appBarBackground;
  final Color appBarForeground;

  // Buttons
  final Color primaryButtonBackground;
  final Color primaryButtonForeground;
  final Color outlineButtonBorder;
  final Color outlineButtonForeground;

  // Borders
  final Color cardBorder;
  final Color selectedBorder;

  // Board
  final Color boardLightCell;
  final Color boardDarkCell;
  final Color boardBorder;

  // Game states
  final Color validMoveColor;
  final Color selectedColor;

  // Player colors
  final Color player1Color;
  final Color player2Color;

  // Shadows
  final Color shadowColor;
  final Color accentShadow;

  // Gradients
  final List<Color> logoGradient;
  final List<Color> titleGradient;

  const AppColors({
    required this.primaryBackground,
    required this.secondaryBackground,
    required this.cardBackground,
    required this.accentColor,
    required this.accentColorBright,
    required this.accentColorSecondary,
    required this.accentColorTertiary,
    required this.primaryText,
    required this.secondaryText,
    required this.tertiaryText,
    required this.subtitleText,
    required this.appBarBackground,
    required this.appBarForeground,
    required this.primaryButtonBackground,
    required this.primaryButtonForeground,
    required this.outlineButtonBorder,
    required this.outlineButtonForeground,
    required this.cardBorder,
    required this.selectedBorder,
    required this.boardLightCell,
    required this.boardDarkCell,
    required this.boardBorder,
    required this.validMoveColor,
    required this.selectedColor,
    required this.player1Color,
    required this.player2Color,
    required this.shadowColor,
    required this.accentShadow,
    required this.logoGradient,
    required this.titleGradient,
  });

  // Light theme
  static const light = AppColors(
    primaryBackground: Color(0xFFF5F5F5),
    secondaryBackground: Colors.white,
    cardBackground: Color(0xFFFAFAFA),
    accentColor: Color(0xFF234d3f),
    accentColorBright: Color(0xFF3A8A6E),
    accentColorSecondary: Color(0xFF234d3f),
    accentColorTertiary: Color(0xFF1A3A2F),
    primaryText: Color(0xFF1A1A2E),
    secondaryText: Color(0xFF757575),
    tertiaryText: Color(0xFF616161),
    subtitleText: Color(0xFF616161),
    appBarBackground: Color(0xFFF5F5F5),
    appBarForeground: Color(0xFF1A1A2E),
    primaryButtonBackground: Color(0xFF234d3f),
    primaryButtonForeground: Colors.white,
    outlineButtonBorder: Colors.black38,
    outlineButtonForeground: Color(0xFF1A1A2E),
    cardBorder: Color(0x19000000),
    selectedBorder: Color(0xFF234d3f),
    boardLightCell: Color(0xFFB8D4C8),
    boardDarkCell: Color(0xFF234d3f),
    boardBorder: Colors.transparent,
    validMoveColor: Color(0xFF2E7D32),
    selectedColor: Color(0xFFFF8F00),
    player1Color: Colors.blue,
    player2Color: Colors.red,
    shadowColor: Color(0x4C000000),
    accentShadow: Color(0x32000000),
    logoGradient: [Color(0xFF3A8A6E), Color(0xFF234d3f), Color(0xFF1A3A2F)],
    titleGradient: [Color(0xFF3A8A6E), Color(0xFF234d3f)],
  );

  // Dark theme
  static const dark = AppColors(
    primaryBackground: Color(0xFF0D1F1A),
    secondaryBackground: Color(0xFF142923),
    cardBackground: Color(0xFF142923),
    accentColor: Color(0xFF2E6B55),
    accentColorBright: Color(0xFF3A8A6E),
    accentColorSecondary: Color(0xFF234d3f),
    accentColorTertiary: Color(0xFF1A3A2F),
    primaryText: Colors.white,
    secondaryText: Color(0xFFBDBDBD),
    tertiaryText: Color(0xFF9E9E9E),
    subtitleText: Color(0xFFE0E0E0),
    appBarBackground: Color(0xFF0D1F1A),
    appBarForeground: Colors.white,
    primaryButtonBackground: Color(0xFF234d3f),
    primaryButtonForeground: Colors.white,
    outlineButtonBorder: Colors.white54,
    outlineButtonForeground: Colors.white,
    cardBorder: Color(0x19FFFFFF),
    selectedBorder: Color(0xFF234d3f),
    boardLightCell: Color(0xFF4A7A68),
    boardDarkCell: Color(0xFF1A3A2F),
    boardBorder: Colors.black26,
    validMoveColor: Colors.green,
    selectedColor: Colors.yellow,
    player1Color: Colors.blue,
    player2Color: Colors.red,
    shadowColor: Color(0x4C000000),
    accentShadow: Color(0x64234d3f),
    logoGradient: [Color(0xFF3A8A6E), Color(0xFF234d3f), Color(0xFF1A3A2F)],
    titleGradient: [Color(0xFF3A8A6E), Color(0xFF234d3f)],
  );

  @override
  AppColors copyWith({
    Color? primaryBackground,
    Color? secondaryBackground,
    Color? cardBackground,
    Color? accentColor,
    Color? accentColorBright,
    Color? accentColorSecondary,
    Color? accentColorTertiary,
    Color? primaryText,
    Color? secondaryText,
    Color? tertiaryText,
    Color? subtitleText,
    Color? appBarBackground,
    Color? appBarForeground,
    Color? primaryButtonBackground,
    Color? primaryButtonForeground,
    Color? outlineButtonBorder,
    Color? outlineButtonForeground,
    Color? cardBorder,
    Color? selectedBorder,
    Color? boardLightCell,
    Color? boardDarkCell,
    Color? boardBorder,
    Color? validMoveColor,
    Color? selectedColor,
    Color? player1Color,
    Color? player2Color,
    Color? shadowColor,
    Color? accentShadow,
    List<Color>? logoGradient,
    List<Color>? titleGradient,
  }) {
    return AppColors(
      primaryBackground: primaryBackground ?? this.primaryBackground,
      secondaryBackground: secondaryBackground ?? this.secondaryBackground,
      cardBackground: cardBackground ?? this.cardBackground,
      accentColor: accentColor ?? this.accentColor,
      accentColorBright: accentColorBright ?? this.accentColorBright,
      accentColorSecondary: accentColorSecondary ?? this.accentColorSecondary,
      accentColorTertiary: accentColorTertiary ?? this.accentColorTertiary,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      tertiaryText: tertiaryText ?? this.tertiaryText,
      subtitleText: subtitleText ?? this.subtitleText,
      appBarBackground: appBarBackground ?? this.appBarBackground,
      appBarForeground: appBarForeground ?? this.appBarForeground,
      primaryButtonBackground:
          primaryButtonBackground ?? this.primaryButtonBackground,
      primaryButtonForeground:
          primaryButtonForeground ?? this.primaryButtonForeground,
      outlineButtonBorder: outlineButtonBorder ?? this.outlineButtonBorder,
      outlineButtonForeground:
          outlineButtonForeground ?? this.outlineButtonForeground,
      cardBorder: cardBorder ?? this.cardBorder,
      selectedBorder: selectedBorder ?? this.selectedBorder,
      boardLightCell: boardLightCell ?? this.boardLightCell,
      boardDarkCell: boardDarkCell ?? this.boardDarkCell,
      boardBorder: boardBorder ?? this.boardBorder,
      validMoveColor: validMoveColor ?? this.validMoveColor,
      selectedColor: selectedColor ?? this.selectedColor,
      player1Color: player1Color ?? this.player1Color,
      player2Color: player2Color ?? this.player2Color,
      shadowColor: shadowColor ?? this.shadowColor,
      accentShadow: accentShadow ?? this.accentShadow,
      logoGradient: logoGradient ?? this.logoGradient,
      titleGradient: titleGradient ?? this.titleGradient,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primaryBackground: Color.lerp(
        primaryBackground,
        other.primaryBackground,
        t,
      )!,
      secondaryBackground: Color.lerp(
        secondaryBackground,
        other.secondaryBackground,
        t,
      )!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      accentColor: Color.lerp(accentColor, other.accentColor, t)!,
      accentColorBright: Color.lerp(
        accentColorBright,
        other.accentColorBright,
        t,
      )!,
      accentColorSecondary: Color.lerp(
        accentColorSecondary,
        other.accentColorSecondary,
        t,
      )!,
      accentColorTertiary: Color.lerp(
        accentColorTertiary,
        other.accentColorTertiary,
        t,
      )!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      tertiaryText: Color.lerp(tertiaryText, other.tertiaryText, t)!,
      subtitleText: Color.lerp(subtitleText, other.subtitleText, t)!,
      appBarBackground: Color.lerp(
        appBarBackground,
        other.appBarBackground,
        t,
      )!,
      appBarForeground: Color.lerp(
        appBarForeground,
        other.appBarForeground,
        t,
      )!,
      primaryButtonBackground: Color.lerp(
        primaryButtonBackground,
        other.primaryButtonBackground,
        t,
      )!,
      primaryButtonForeground: Color.lerp(
        primaryButtonForeground,
        other.primaryButtonForeground,
        t,
      )!,
      outlineButtonBorder: Color.lerp(
        outlineButtonBorder,
        other.outlineButtonBorder,
        t,
      )!,
      outlineButtonForeground: Color.lerp(
        outlineButtonForeground,
        other.outlineButtonForeground,
        t,
      )!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      selectedBorder: Color.lerp(selectedBorder, other.selectedBorder, t)!,
      boardLightCell: Color.lerp(boardLightCell, other.boardLightCell, t)!,
      boardDarkCell: Color.lerp(boardDarkCell, other.boardDarkCell, t)!,
      boardBorder: Color.lerp(boardBorder, other.boardBorder, t)!,
      validMoveColor: Color.lerp(validMoveColor, other.validMoveColor, t)!,
      selectedColor: Color.lerp(selectedColor, other.selectedColor, t)!,
      player1Color: Color.lerp(player1Color, other.player1Color, t)!,
      player2Color: Color.lerp(player2Color, other.player2Color, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      accentShadow: Color.lerp(accentShadow, other.accentShadow, t)!,
      logoGradient: _lerpGradient(logoGradient, other.logoGradient, t),
      titleGradient: _lerpGradient(titleGradient, other.titleGradient, t),
    );
  }

  static List<Color> _lerpGradient(List<Color> a, List<Color> b, double t) {
    final length = a.length < b.length ? a.length : b.length;
    return List.generate(length, (i) => Color.lerp(a[i], b[i], t)!);
  }
}

extension AppColorsExtension on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
