import 'package:flutter/material.dart';
import '../models/ai_player.dart';
import 'game_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int _boardSize = 5;
  bool _vsAI = false;
  AIDifficulty _difficulty = AIDifficulty.normal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text(
          'Nouvelle partie',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Mode de jeu'),
                      const SizedBox(height: 16),
                      _buildModeSelector(),
                      const SizedBox(height: 32),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _vsAI
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle('Difficulte'),
                                  const SizedBox(height: 16),
                                  _buildDifficultySelector(),
                                  const SizedBox(height: 32),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                      _buildSectionTitle('Taille du plateau'),
                      const SizedBox(height: 16),
                      _buildSizeSelector(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              _buildStartButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildModeSelector() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildModeCard(
              icon: Icons.people_rounded,
              title: '2 Joueurs',
              subtitle: 'Jouer en local',
              isSelected: !_vsAI,
              onTap: () => setState(() => _vsAI = false),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildModeCard(
              icon: Icons.smart_toy_rounded,
              title: 'vs IA',
              subtitle: 'Jouer contre l\'ordinateur',
              isSelected: _vsAI,
              onTap: () => setState(() => _vsAI = true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFD700).withAlpha(25)
              : const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFD700)
                : Colors.white.withAlpha(25),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected
                  ? const Color(0xFFFFD700)
                  : Colors.grey.shade500,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFFFFD700) : Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Row(
      children: [
        Expanded(
          child: _buildDifficultyCard(
            label: 'Facile',
            icon: Icons.sentiment_satisfied_rounded,
            difficulty: AIDifficulty.easy,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDifficultyCard(
            label: 'Normal',
            icon: Icons.sentiment_neutral_rounded,
            difficulty: AIDifficulty.normal,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDifficultyCard(
            label: 'Difficile',
            icon: Icons.sentiment_very_dissatisfied_rounded,
            difficulty: AIDifficulty.hard,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyCard({
    required String label,
    required IconData icon,
    required AIDifficulty difficulty,
    required Color color,
  }) {
    final isSelected = _difficulty == difficulty;
    return GestureDetector(
      onTap: () => setState(() => _difficulty = difficulty),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(30) : const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.white.withAlpha(25),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? color : Colors.grey.shade500,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildSizeCard(
            size: 5,
            description: '5 pions par joueur\nParties rapides',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSizeCard(
            size: 7,
            description: '7 pions par joueur\nParties longues',
          ),
        ),
      ],
    );
  }

  Widget _buildSizeCard({required int size, required String description}) {
    final isSelected = _boardSize == size;
    return GestureDetector(
      onTap: () => setState(() => _boardSize = size),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFD700).withAlpha(25)
              : const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFD700)
                : Colors.white.withAlpha(25),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              '$size x $size',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFFFFD700) : Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => GameScreen(
                boardSize: _boardSize,
                vsAI: _vsAI,
                difficulty: _difficulty,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFD700),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: const Text(
          'COMMENCER',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
