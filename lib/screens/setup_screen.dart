import 'package:flutter/material.dart';
import '../models/ai_player.dart';
import '../models/game_state.dart';
import '../theme/app_colors.dart';
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
  Player _startingPlayer = Player.player1;

  AppColors get _theme => context.colors;

  @override
  Widget build(BuildContext context) {
    final isLarge = Responsive.isLargeScreen(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nouvelle partie',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isLarge ? 24 : 20,
          ),
        ),
        centerTitle: true,
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
                        ? _buildDesktopLayout(isLarge)
                        : _buildMobileLayout(isLarge),
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
                  child: _buildStartButton(isLarge),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(bool isLarge) {
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
                  _buildSectionTitle('Mode de jeu', isLarge),
                  const SizedBox(height: 16),
                  _buildModeSelector(isLarge),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _vsAI
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 32),
                              _buildSectionTitle('Difficulte', isLarge),
                              const SizedBox(height: 16),
                              _buildDifficultySelector(isLarge),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Condition de victoire', isLarge),
                  const SizedBox(height: 16),
                  _buildWinConditionSelector(isLarge),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Premier joueur', isLarge),
                  const SizedBox(height: 16),
                  _buildStartingPlayerSelector(isLarge),
                ],
              ),
            ),
            const SizedBox(width: 48),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Type de plateau', isLarge),
                  const SizedBox(height: 16),
                  _buildBoardTypeSelector(isLarge),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _gameMode == GameMode.square
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 32),
                              _buildSectionTitle('Taille du plateau', isLarge),
                              const SizedBox(height: 16),
                              _buildSizeSelector(isLarge),
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

  Widget _buildMobileLayout(bool isLarge) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Mode de jeu', isLarge),
        const SizedBox(height: 16),
        _buildModeSelector(isLarge),
        const SizedBox(height: 32),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _vsAI
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Difficulte', isLarge),
                    const SizedBox(height: 16),
                    _buildDifficultySelector(isLarge),
                    const SizedBox(height: 32),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        _buildSectionTitle('Type de plateau', isLarge),
        const SizedBox(height: 16),
        _buildBoardTypeSelector(isLarge),
        const SizedBox(height: 32),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _gameMode == GameMode.square
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Taille du plateau', isLarge),
                    const SizedBox(height: 16),
                    _buildSizeSelector(isLarge),
                    const SizedBox(height: 32),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        _buildSectionTitle('Condition de victoire', isLarge),
        const SizedBox(height: 16),
        _buildWinConditionSelector(isLarge),
        const SizedBox(height: 32),
        _buildSectionTitle('Premier joueur', isLarge),
        const SizedBox(height: 16),
        _buildStartingPlayerSelector(isLarge),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isLarge) {
    return Text(
      title,
      style: TextStyle(
        fontSize: isLarge ? 22 : 18,
        fontWeight: FontWeight.bold,
        color: _theme.primaryText,
      ),
    );
  }

  Widget _buildModeSelector(bool isLarge) {
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
                ? _theme.accentColor.withAlpha(25)
                : _theme.cardBackground,
            borderRadius: BorderRadius.circular(isLarge ? 20 : 16),
            border: Border.all(
              color: isSelected ? _theme.accentColor : _theme.cardBorder,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: isLarge ? 48 : 40,
                color: isSelected ? _theme.accentColor : _theme.tertiaryText,
              ),
              SizedBox(height: isLarge ? 16 : 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: isLarge ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? _theme.accentColor : _theme.primaryText,
                ),
              ),
              SizedBox(height: isLarge ? 6 : 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isLarge ? 14 : 12,
                  color: _theme.tertiaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoardTypeSelector(bool isLarge) {
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
                ? _theme.accentColor.withAlpha(25)
                : _theme.cardBackground,
            borderRadius: BorderRadius.circular(isLarge ? 20 : 16),
            border: Border.all(
              color: isSelected ? _theme.accentColor : _theme.cardBorder,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: isLarge ? 48 : 40,
                color: isSelected ? _theme.accentColor : _theme.tertiaryText,
              ),
              SizedBox(height: isLarge ? 16 : 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: isLarge ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? _theme.accentColor : _theme.primaryText,
                ),
              ),
              SizedBox(height: isLarge ? 6 : 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isLarge ? 14 : 12,
                  color: _theme.tertiaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultySelector(bool isLarge) {
    return Row(
      children: [
        Expanded(
          child: _buildDifficultyCard(
            label: 'Facile',
            icon: Icons.sentiment_satisfied_rounded,
            difficulty: AIDifficulty.easy,
            color: Colors.green,
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
            color: isSelected ? color.withAlpha(30) : _theme.cardBackground,
            borderRadius: BorderRadius.circular(isLarge ? 16 : 12),
            border: Border.all(
              color: isSelected ? color : _theme.cardBorder,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: isLarge ? 36 : 28,
                color: isSelected ? color : _theme.tertiaryText,
              ),
              SizedBox(height: isLarge ? 12 : 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: isLarge ? 15 : 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : _theme.tertiaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSizeSelector(bool isLarge) {
    return Row(
      children: [
        Expanded(
          child: _buildSizeCard(
            size: 5,
            description: '5 pions par joueur\nParties rapides',
            isLarge: isLarge,
          ),
        ),
        SizedBox(width: isLarge ? 20 : 16),
        Expanded(
          child: _buildSizeCard(
            size: 7,
            description: '7 pions par joueur\nParties longues',
            isLarge: isLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildSizeCard({
    required int size,
    required String description,
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
                ? _theme.accentColor.withAlpha(25)
                : _theme.cardBackground,
            borderRadius: BorderRadius.circular(isLarge ? 20 : 16),
            border: Border.all(
              color: isSelected ? _theme.accentColor : _theme.cardBorder,
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
                  color: isSelected ? _theme.accentColor : _theme.primaryText,
                ),
              ),
              SizedBox(height: isLarge ? 12 : 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isLarge ? 14 : 12,
                  color: _theme.tertiaryText,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWinConditionSelector(bool isLarge) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildWinConditionCard(
              icon: Icons.home_rounded,
              title: 'Son camp',
              subtitle: 'Ramener le Nexus dans son camp',
              isSelected: _winCondition == WinCondition.ownCamp,
              onTap: () => setState(() => _winCondition = WinCondition.ownCamp),
              isLarge: isLarge,
            ),
          ),
          SizedBox(width: isLarge ? 20 : 16),
          Expanded(
            child: _buildWinConditionCard(
              icon: Icons.flag_rounded,
              title: 'Camp adverse',
              subtitle: 'Amener le Nexus chez l\'adversaire',
              isSelected: _winCondition == WinCondition.opponentCamp,
              onTap: () =>
                  setState(() => _winCondition = WinCondition.opponentCamp),
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
                ? _theme.accentColor.withAlpha(25)
                : _theme.cardBackground,
            borderRadius: BorderRadius.circular(isLarge ? 20 : 16),
            border: Border.all(
              color: isSelected ? _theme.accentColor : _theme.cardBorder,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: isLarge ? 48 : 40,
                color: isSelected ? _theme.accentColor : _theme.tertiaryText,
              ),
              SizedBox(height: isLarge ? 16 : 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: isLarge ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? _theme.accentColor : _theme.primaryText,
                ),
              ),
              SizedBox(height: isLarge ? 6 : 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isLarge ? 14 : 12,
                  color: _theme.tertiaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartingPlayerSelector(bool isLarge) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildStartingPlayerCard(
              title: 'Bleus',
              subtitle: 'Joueur 1 commence',
              color: _theme.player1Color,
              isSelected: _startingPlayer == Player.player1,
              onTap: () => setState(() => _startingPlayer = Player.player1),
              isLarge: isLarge,
            ),
          ),
          SizedBox(width: isLarge ? 20 : 16),
          Expanded(
            child: _buildStartingPlayerCard(
              title: 'Rouges',
              subtitle: 'Joueur 2 commence',
              color: _theme.player2Color,
              isSelected: _startingPlayer == Player.player2,
              onTap: () => setState(() => _startingPlayer = Player.player2),
              isLarge: isLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartingPlayerCard({
    required String title,
    required String subtitle,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
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
            color: isSelected ? color.withAlpha(25) : _theme.cardBackground,
            borderRadius: BorderRadius.circular(isLarge ? 20 : 16),
            border: Border.all(
              color: isSelected ? color : _theme.cardBorder,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: isLarge ? 48 : 40,
                height: isLarge ? 48 : 40,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(height: isLarge ? 16 : 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: isLarge ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : _theme.primaryText,
                ),
              ),
              SizedBox(height: isLarge ? 6 : 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isLarge ? 14 : 12,
                  color: _theme.tertiaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton(bool isLarge) {
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
                startingPlayer: _startingPlayer,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _theme.primaryButtonBackground,
          foregroundColor: _theme.primaryButtonForeground,
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
