import 'package:flutter/material.dart';
import 'setup_screen.dart';
import 'rules_screen.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final isLarge = Responsive.isLargeScreen(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: Responsive.screenPadding(context),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Responsive.contentMaxWidth(context),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogo(theme, isLarge),
                  SizedBox(height: isLarge ? 50 : 40),
                  _buildTitle(theme, isLarge),
                  SizedBox(height: isLarge ? 20 : 16),
                  _buildSubtitle(theme, isLarge),
                  SizedBox(height: isLarge ? 80 : 60),
                  _buildButtons(context, theme, isLarge),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(AppTheme theme, bool isLarge) {
    final size = isLarge ? 200.0 : 150.0;
    final iconSize = isLarge ? 110.0 : 80.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: theme.logoGradient,
          stops: const [0.3, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.accentShadow,
            blurRadius: isLarge ? 40 : 30,
            spreadRadius: isLarge ? 8 : 5,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '\u2638',
          style: TextStyle(
            fontSize: iconSize,
            color: Colors.white,
            shadows: const [
              Shadow(
                color: Colors.black54,
                blurRadius: 10,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(AppTheme theme, bool isLarge) {
    return ShaderMask(
      shaderCallback: (bounds) =>
          LinearGradient(colors: theme.titleGradient).createShader(bounds),
      child: Text(
        "Aboul'",
        style: TextStyle(
          fontSize: isLarge ? 72 : 56,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: isLarge ? 6 : 4,
        ),
      ),
    );
  }

  Widget _buildSubtitle(AppTheme theme, bool isLarge) {
    return Text(
      'Jeu de strategie pour 2 joueurs',
      style: TextStyle(
        fontSize: isLarge ? 20 : 16,
        color: theme.secondaryText,
        letterSpacing: isLarge ? 2 : 1,
      ),
    );
  }

  Widget _buildButtons(BuildContext context, AppTheme theme, bool isLarge) {
    final buttonWidth = isLarge ? 280.0 : 220.0;
    final buttonHeight = isLarge ? 64.0 : 56.0;
    final secondaryHeight = isLarge ? 56.0 : 50.0;

    if (isLarge) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPlayButton(context, theme, buttonWidth, buttonHeight),
          const SizedBox(width: 24),
          _buildRulesButton(context, theme, buttonWidth, secondaryHeight),
        ],
      );
    }

    return Column(
      children: [
        _buildPlayButton(context, theme, buttonWidth, buttonHeight),
        const SizedBox(height: 20),
        _buildRulesButton(context, theme, buttonWidth, secondaryHeight),
      ],
    );
  }

  Widget _buildPlayButton(
    BuildContext context,
    AppTheme theme,
    double width,
    double height,
  ) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SetupScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryButtonBackground,
          foregroundColor: theme.primaryButtonForeground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height / 2),
          ),
          elevation: 8,
          shadowColor: theme.accentShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, size: height * 0.5),
            const SizedBox(width: 8),
            Text(
              'JOUER',
              style: TextStyle(
                fontSize: height * 0.32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesButton(
    BuildContext context,
    AppTheme theme,
    double width,
    double height,
  ) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RulesScreen()),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.outlineButtonForeground,
          side: BorderSide(color: theme.outlineButtonBorder, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_rounded, size: height * 0.45),
            const SizedBox(width: 8),
            Text(
              'REGLES',
              style: TextStyle(
                fontSize: height * 0.3,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
