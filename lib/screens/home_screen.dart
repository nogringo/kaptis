import 'package:flutter/material.dart';
import 'setup_screen.dart';
import 'rules_screen.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(theme),
                const SizedBox(height: 40),
                _buildTitle(theme),
                const SizedBox(height: 16),
                _buildSubtitle(theme),
                const SizedBox(height: 60),
                _buildPlayButton(context, theme),
                const SizedBox(height: 20),
                _buildRulesButton(context, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(AppTheme theme) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: theme.logoGradient,
          stops: const [0.3, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(color: theme.accentShadow, blurRadius: 30, spreadRadius: 5),
        ],
      ),
      child: const Center(
        child: Text(
          '\u2638',
          style: TextStyle(
            fontSize: 80,
            color: Colors.white,
            shadows: [
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

  Widget _buildTitle(AppTheme theme) {
    return ShaderMask(
      shaderCallback: (bounds) =>
          LinearGradient(colors: theme.titleGradient).createShader(bounds),
      child: const Text(
        "Aboul'",
        style: TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 4,
        ),
      ),
    );
  }

  Widget _buildSubtitle(AppTheme theme) {
    return Text(
      'Jeu de strategie pour 2 joueurs',
      style: TextStyle(
        fontSize: 16,
        color: theme.secondaryText,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context, AppTheme theme) {
    return SizedBox(
      width: 220,
      height: 56,
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
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 8,
          shadowColor: theme.accentShadow,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, size: 32),
            SizedBox(width: 8),
            Text(
              'JOUER',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesButton(BuildContext context, AppTheme theme) {
    return SizedBox(
      width: 220,
      height: 50,
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
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_rounded, size: 24),
            SizedBox(width: 8),
            Text(
              'REGLES',
              style: TextStyle(
                fontSize: 16,
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
