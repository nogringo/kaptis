import 'package:flutter/material.dart';
import 'setup_screen.dart';
import 'rules_screen.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppTheme get _theme => AppTheme.of(context);

  bool get _isLarge => Responsive.isLargeScreen(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _theme.primaryBackground,
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
                  _buildLogo(),
                  SizedBox(height: _isLarge ? 50 : 40),
                  _buildTitle(),
                  SizedBox(height: _isLarge ? 20 : 16),
                  _buildSubtitle(),
                  SizedBox(height: _isLarge ? 80 : 60),
                  _buildButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    final size = _isLarge ? 200.0 : 150.0;
    final iconSize = _isLarge ? 110.0 : 80.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: _theme.logoGradient,
          stops: const [0.3, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: _theme.accentShadow,
            blurRadius: _isLarge ? 40 : 30,
            spreadRadius: _isLarge ? 8 : 5,
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

  Widget _buildTitle() {
    return ShaderMask(
      shaderCallback: (bounds) =>
          LinearGradient(colors: _theme.titleGradient).createShader(bounds),
      child: Text(
        "Aboul'",
        style: TextStyle(
          fontSize: _isLarge ? 72 : 56,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: _isLarge ? 6 : 4,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Jeu de strategie pour 2 joueurs',
      style: TextStyle(
        fontSize: _isLarge ? 20 : 16,
        color: _theme.secondaryText,
        letterSpacing: _isLarge ? 2 : 1,
      ),
    );
  }

  Widget _buildButtons() {
    final buttonWidth = _isLarge ? 280.0 : 220.0;
    final buttonHeight = _isLarge ? 64.0 : 56.0;
    final secondaryHeight = _isLarge ? 56.0 : 50.0;

    if (_isLarge) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPlayButton(buttonWidth, buttonHeight),
          const SizedBox(width: 24),
          _buildRulesButton(buttonWidth, secondaryHeight),
        ],
      );
    }

    return Column(
      children: [
        _buildPlayButton(buttonWidth, buttonHeight),
        const SizedBox(height: 20),
        _buildRulesButton(buttonWidth, secondaryHeight),
      ],
    );
  }

  Widget _buildPlayButton(double width, double height) {
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
          backgroundColor: _theme.primaryButtonBackground,
          foregroundColor: _theme.primaryButtonForeground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height / 2),
          ),
          elevation: 8,
          shadowColor: _theme.accentShadow,
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

  Widget _buildRulesButton(double width, double height) {
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
          foregroundColor: _theme.outlineButtonForeground,
          side: BorderSide(color: _theme.outlineButtonBorder, width: 2),
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
