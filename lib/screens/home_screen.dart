import 'package:flutter/material.dart';
import 'setup_screen.dart';
import 'rules_screen.dart';
import 'nexus_selection_screen.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppColors get _theme => context.colors;

  bool get _isLarge => Responsive.isLargeScreen(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

  Widget _buildTitle() {
    return ShaderMask(
      shaderCallback: (bounds) =>
          LinearGradient(colors: _theme.titleGradient).createShader(bounds),
      child: Text(
        "Kaptis",
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
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPlayButton(buttonWidth, buttonHeight),
              const SizedBox(width: 24),
              _buildRulesButton(buttonWidth, secondaryHeight),
            ],
          ),
          const SizedBox(height: 20),
          _buildCustomizeButton(buttonWidth, secondaryHeight),
        ],
      );
    }

    return Column(
      children: [
        _buildPlayButton(buttonWidth, buttonHeight),
        const SizedBox(height: 20),
        _buildRulesButton(buttonWidth, secondaryHeight),
        const SizedBox(height: 20),
        _buildCustomizeButton(buttonWidth, secondaryHeight),
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

  Widget _buildCustomizeButton(double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NexusSelectionScreen(),
            ),
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
            Icon(Icons.auto_awesome, size: height * 0.45),
            const SizedBox(width: 8),
            Text(
              'NEXUS',
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
