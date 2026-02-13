import 'package:flutter/material.dart';
import '../models/ai_player.dart';
import '../models/game_state.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
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
  WinCondition _winCondition = WinCondition.ownCamp;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final isLarge = Responsive.isLargeScreen(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        title: Text(
          'Nouvelle partie',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isLarge ? 24 : 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.appBarBackground,
        foregroundColor: theme.appBarForeground,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: Responsive.screenPadding(context),
                clipBehavior: Clip.none,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: Responsive.contentMaxWidth(context),
                    ),
                    child: isDesktop
                        ? _buildDesktopLayout(theme)
                        : _buildMobileLayout(theme),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.screenPadding(context).horizontal / 2,
                vertical: 16,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Responsive.contentMaxWidth(context),
                  ),
                  child: _buildStartButton(theme, isLarge),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Mode de jeu', theme, true),
                  const SizedBox(height: 16),
                  _buildModeSelector(theme, true),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _vsAI
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 32),
                              _buildSectionTitle('Difficulte', theme, true),
                              const SizedBox(height: 16),
                              _buildDifficultySelector(theme, true),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Condition de victoire', theme, true),
                  const SizedBox(height: 16),
                  _buildWinConditionSelector(theme, true),
                ],
              ),
            ),
            const SizedBox(width: 48),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Type de plateau', theme, true),
                  const SizedBox(height: 16),
                  _buildBoardTypeSelector(theme, true),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _gameMode == GameMode.square
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 32),
                              _buildSectionTitle(
                                'Taille du plateau',
                                theme,
                                true,
                              ),
                              const SizedBox(height: 16),
                              _buildSizeSelector(theme, true),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileLayout(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Mode de jeu', theme, false),
        const SizedBox(height: 16),
        _buildModeSelector(theme, false),
        const SizedBox(height: 32),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _vsAI
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Difficulte', theme, false),
                    const SizedBox(height: 16),
                    _buildDifficultySelector(theme, false),
                    const SizedBox(height: 32),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        _buildSectionTitle('Type de plateau', theme, false),
        const SizedBox(height: 16),
        _buildBoardTypeSelector(theme, false),
        const SizedBox(height: 32),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _gameMode == GameMode.square
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Taille du plateau', theme, false),
                    const SizedBox(height: 16),
                    _buildSizeSelector(theme, false),
                    const SizedBox(height: 32),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        _buildSectionTitle('Condition de victoire', theme, false),
        const SizedBox(height: 16),
        _buildWinConditionSelector(theme, false),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionTitle(String title, AppTheme theme, bool isLarge) {
    return Text(
      title,
      style: TextStyle(
        fontSize: isLarge ? 22 : 18,
        fontWeight: FontWeight.bold,
        color: theme.primaryText,
      ),
    );
  }

  Widget _buildModeSelector(AppTheme theme, bool isLarge) {
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
              isLarge: isLarge,
            ),
          ),
          SizedBox(width: isLarge ? 20 : 16),
          Expanded(
            child: _buildModeCard(
              icon: Icons.smart_toy_rounded,
              title: 'vs IA',
              subtitle: 'Jouer contre l\'ordinateur',
              isSelected: _vsAI,
              onTap: () => setState(() => _vsAI = true),
              theme: theme,
              isLarge: isLarge,
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
    required bool isLarge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(isLarge ? 24 : 20),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.accentColor.withAlpha(25)
                : theme.cardBackground,
            borderRadius: BorderRadius.circular(isLarge ? 20 : 16),
            border: Border.all(
              color: isSelected ? theme.accentColor : theme.cardBorder,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: isLarge ? 48 : 40,
                color: isSelected ? theme.accentColor : theme.tertiaryText,
              ),
              SizedBox(height: isLarge ? 16 : 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: isLarge ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? theme.accentColor : theme.primaryText,
                ),
              ),
              SizedBox(height: isLarge ? 6 : 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isLarge ? 14 : 12,
                  color: theme.tertiaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoardTypeSelector(AppTheme theme, bool isLarge) {
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
              isLarge: isLarge,
            ),
          ),
          SizedBox(width: isLarge ? 20 : 16),
          Expanded(
            child: _buildBoardTypeCard(
              icon: Icons.hexagon_rounded,
              title: 'Hexagonal',
              subtitle: '37 hexagones',
              isSelected: _gameMode == GameMode.hexagonal,
              onTap: () => setState(() => _gameMode = GameMode.hexagonal),
              theme: theme,
              isLarge: isLarge,
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
    required bool isLarge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(isLarge ? 24 : 20),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.accentColor.withAlpha(25)
                : theme.cardBackground,
            borderRadius: BorderRadius.circular(isLarge ? 20 : 16),
            border: Border.all(
              color: isSelected ? theme.accentColor : theme.cardBorder,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: isLarge ? 48 : 40,
                color: isSelected ? theme.accentColor : theme.tertiaryText,
              ),
              SizedBox(height: isLarge ? 16 : 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: isLarge ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? theme.accentColor : theme.primaryText,
                ),
              ),
              SizedBox(height: isLarge ? 6 : 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isLarge ? 14 : 12,
                  color: theme.tertiaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultySelector(AppTheme theme, bool isLarge) {
    return Row(
      children: [
        Expanded(
          child: _buildDifficultyCard(
            label: 'Facile',
            icon: Icons.sentiment_satisfied_rounded,
            difficulty: AIDifficulty.easy,
            color: Colors.green,
            theme: theme,
            isLarge: isLarge,
          ),
        ),
        SizedBox(width: isLarge ? 16 : 12),
        Expanded(
          child: _buildDifficultyCard(
            label: 'Normal',
            icon: Icons.sentiment_neutral_rounded,
            difficulty: AIDifficulty.normal,
            color: Colors.orange,
            theme: theme,
            isLarge: isLarge,
          ),
        ),
        SizedBox(width: isLarge ? 16 : 12),
        Expanded(
          child: _buildDifficultyCard(
            label: 'Difficile',
            icon: Icons.sentiment_very_dissatisfied_rounded,
            difficulty: AIDifficulty.hard,
            color: Colors.red,
            theme: theme,
            isLarge: isLarge,
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
    required bool isLarge,
  }) {
    final isSelected = _difficulty == difficulty;
    return GestureDetector(
      onTap: () => setState(() => _difficulty = difficulty),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          height: isLarge ? 100 : 80,
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(30) : theme.cardBackground,
            borderRadius: BorderRadius.circular(isLarge ? 16 : 12),
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
                size: isLarge ? 36 : 28,
                color: isSelected ? color : theme.tertiaryText,
              ),
              SizedBox(height: isLarge ? 12 : 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: isLarge ? 15 : 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : theme.tertiaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSizeSelector(AppTheme theme, bool isLarge) {
    return Row(
      children: [
        Expanded(
          child: _buildSizeCard(
            size: 5,
            description: '5 pions par joueur\nParties rapides',
            theme: theme,
            isLarge: isLarge,
          ),
        ),
        SizedBox(width: isLarge ? 20 : 16),
        Expanded(
          child: _buildSizeCard(
            size: 7,
            description: '7 pions par joueur\nParties longues',
            theme: theme,
            isLarge: isLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildSizeCard({
    required int size,
    required String description,
    required AppTheme theme,
    required bool isLarge,
  }) {
    final isSelected = _boardSize == size;
    return GestureDetector(
      onTap: () => setState(() => _boardSize = size),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(isLarge ? 24 : 20),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.accentColor.withAlpha(25)
                : theme.cardBackground,
            borderRadius: BorderRadius.circular(isLarge ? 20 : 16),
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
                  fontSize: isLarge ? 34 : 28,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? theme.accentColor : theme.primaryText,
                ),
              ),
              SizedBox(height: isLarge ? 12 : 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isLarge ? 14 : 12,
                  color: theme.tertiaryText,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWinConditionSelector(AppTheme theme, bool isLarge) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildWinConditionCard(
              icon: Icons.home_rounded,
              title: 'Son camp',
              subtitle: 'Ramener le Bouddha dans son camp',
              isSelected: _winCondition == WinCondition.ownCamp,
              onTap: () => setState(() => _winCondition = WinCondition.ownCamp),
              theme: theme,
              isLarge: isLarge,
            ),
          ),
          SizedBox(width: isLarge ? 20 : 16),
          Expanded(
            child: _buildWinConditionCard(
              icon: Icons.flag_rounded,
              title: 'Camp adverse',
              subtitle: 'Amener le Bouddha chez l\'adversaire',
              isSelected: _winCondition == WinCondition.opponentCamp,
              onTap: () =>
                  setState(() => _winCondition = WinCondition.opponentCamp),
              theme: theme,
              isLarge: isLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinConditionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required AppTheme theme,
    required bool isLarge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(isLarge ? 24 : 20),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.accentColor.withAlpha(25)
                : theme.cardBackground,
            borderRadius: BorderRadius.circular(isLarge ? 20 : 16),
            border: Border.all(
              color: isSelected ? theme.accentColor : theme.cardBorder,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: isLarge ? 48 : 40,
                color: isSelected ? theme.accentColor : theme.tertiaryText,
              ),
              SizedBox(height: isLarge ? 16 : 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: isLarge ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? theme.accentColor : theme.primaryText,
                ),
              ),
              SizedBox(height: isLarge ? 6 : 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isLarge ? 14 : 12,
                  color: theme.tertiaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton(AppTheme theme, bool isLarge) {
    return SizedBox(
      width: isLarge ? 400 : double.infinity,
      height: isLarge ? 64 : 56,
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
                winCondition: _winCondition,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryButtonBackground,
          foregroundColor: theme.primaryButtonForeground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isLarge ? 20 : 16),
          ),
          elevation: 4,
        ),
        child: Text(
          'COMMENCER',
          style: TextStyle(
            fontSize: isLarge ? 20 : 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
