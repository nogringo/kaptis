import 'package:flutter/material.dart';
import 'setup_screen.dart';
import 'rules_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: 40),
                _buildTitle(),
                const SizedBox(height: 16),
                _buildSubtitle(),
                const SizedBox(height: 60),
                _buildPlayButton(context),
                const SizedBox(height: 20),
                _buildRulesButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFFFD700), Color(0xFFDAA520), Color(0xFFB8860B)],
          stops: [0.3, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withAlpha(100),
            blurRadius: 30,
            spreadRadius: 5,
          ),
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

  Widget _buildTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
      ).createShader(bounds),
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

  Widget _buildSubtitle() {
    return Text(
      'Jeu de strategie pour 2 joueurs',
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey.shade400,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context) {
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
          backgroundColor: const Color(0xFFFFD700),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 8,
          shadowColor: const Color(0xFFFFD700).withAlpha(100),
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

  Widget _buildRulesButton(BuildContext context) {
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
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white54, width: 2),
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
