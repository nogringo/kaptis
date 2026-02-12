import 'package:flutter/material.dart';
import '../models/ai_player.dart';
import '../models/game_state.dart';
import '../theme/app_theme.dart';
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
  GameMode _gameMode = GameMode.square;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        title: const Text(
          'Nouvelle partie',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.appBarBackground,
        foregroundColor: theme.appBarForeground,
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
                      _buildSectionTitle('Mode de jeu', theme),
                      const SizedBox(height: 16),
                      _buildModeSelector(theme),
                      const SizedBox(height: 32),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _vsAI
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle('Difficulte', theme),
                                  const SizedBox(height: 16),
                                  _buildDifficultySelector(theme),
                                  const SizedBox(height: 32),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                      _buildSectionTitle('Type de plateau', theme),
                      const SizedBox(height: 16),
                      _buildBoardTypeSelector(theme),
                      const SizedBox(height: 32),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _gameMode == GameMode.square
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle(
                                    'Taille du plateau',
                                    theme,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildSizeSelector(theme),
                                  const SizedBox(height: 24),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
              _buildStartButton(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, AppTheme theme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: theme.primaryText,
      ),
    );
  }

  Widget _buildModeSelector(AppTheme theme) {
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
              theme: theme,
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
              theme: theme,
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
    required AppTheme theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.accentColor.withAlpha(25)
              : theme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.accentColor : theme.cardBorder,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? theme.accentColor : theme.tertiaryText,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? theme.accentColor : theme.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: theme.tertiaryText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoardTypeSelector(AppTheme theme) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildBoardTypeCard(
              icon: Icons.grid_4x4_rounded,
              title: 'Carre',
              subtitle: '5x5 ou 7x7 cases',
              isSelected: _gameMode == GameMode.square,
              onTap: () => setState(() => _gameMode = GameMode.square),
              theme: theme,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildBoardTypeCard(
              icon: Icons.hexagon_rounded,
              title: 'Hexagonal',
              subtitle: '37 hexagones',
              isSelected: _gameMode == GameMode.hexagonal,
              onTap: () => setState(() => _gameMode = GameMode.hexagonal),
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardTypeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required AppTheme theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.accentColor.withAlpha(25)
              : theme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.accentColor : theme.cardBorder,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? theme.accentColor : theme.tertiaryText,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? theme.accentColor : theme.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: theme.tertiaryText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySelector(AppTheme theme) {
    return Row(
      children: [
        Expanded(
          child: _buildDifficultyCard(
            label: 'Facile',
            icon: Icons.sentiment_satisfied_rounded,
            difficulty: AIDifficulty.easy,
            color: Colors.green,
            theme: theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDifficultyCard(
            label: 'Normal',
            icon: Icons.sentiment_neutral_rounded,
            difficulty: AIDifficulty.normal,
            color: Colors.orange,
            theme: theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDifficultyCard(
            label: 'Difficile',
            icon: Icons.sentiment_very_dissatisfied_rounded,
            difficulty: AIDifficulty.hard,
            color: Colors.red,
            theme: theme,
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
    required AppTheme theme,
  }) {
    final isSelected = _difficulty == difficulty;
    return GestureDetector(
      onTap: () => setState(() => _difficulty = difficulty),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(30) : theme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : theme.cardBorder,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? color : theme.tertiaryText,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : theme.tertiaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeSelector(AppTheme theme) {
    return Row(
      children: [
        Expanded(
          child: _buildSizeCard(
            size: 5,
            description: '5 pions par joueur\nParties rapides',
            theme: theme,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSizeCard(
            size: 7,
            description: '7 pions par joueur\nParties longues',
            theme: theme,
          ),
        ),
      ],
    );
  }

  Widget _buildSizeCard({
    required int size,
    required String description,
    required AppTheme theme,
  }) {
    final isSelected = _boardSize == size;
    return GestureDetector(
      onTap: () => setState(() => _boardSize = size),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.accentColor.withAlpha(25)
              : theme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.accentColor : theme.cardBorder,
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
                color: isSelected ? theme.accentColor : theme.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: theme.tertiaryText,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton(AppTheme theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => GameScreen(
                boardSize: _gameMode == GameMode.hexagonal ? 7 : _boardSize,
                vsAI: _vsAI,
                difficulty: _difficulty,
                gameMode: _gameMode,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryButtonBackground,
          foregroundColor: theme.primaryButtonForeground,
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
