import 'package:flutter/material.dart';
import '../models/ai_player.dart';
import '../models/game_state.dart';
import '../theme/app_colors.dart';
import '../widgets/game_board.dart';

class GameScreen extends StatefulWidget {
  final int boardSize;
  final bool vsAI;
  final AIDifficulty difficulty;
  final GameMode gameMode;
  final WinCondition winCondition;
  final Player startingPlayer;

  const GameScreen({
    super.key,
    required this.boardSize,
    required this.vsAI,
    required this.difficulty,
    this.gameMode = GameMode.square,
    this.winCondition = WinCondition.ownCamp,
    this.startingPlayer = Player.player1,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GlobalKey<GameBoardState> _gameBoardKey = GlobalKey<GameBoardState>();

  AppColors get _theme => context.colors;

  void _triggerRebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1000;

    if (isDesktop) {
      return Scaffold(body: SafeArea(child: _buildDesktopLayout()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Aboul'",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Nouvelle partie',
            onPressed: () {
              _gameBoardKey.currentState?.resetGame();
              _triggerRebuild();
            },
          ),
        ],
      ),
      body: SafeArea(child: _buildMobileLayout()),
    );
  }

  Widget _buildMobileLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = 16.0;
        final availableWidth = constraints.maxWidth - (padding * 2);
        // Réserver espace pour status bar (~120px) + spacing (24px)
        final statusBarHeight = 144.0;
        final availableHeight =
            constraints.maxHeight - (padding * 2) - statusBarHeight;
        final maxBoardSize = availableWidth < availableHeight
            ? availableWidth
            : availableHeight;

        return Center(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: GameBoard(
              key: _gameBoardKey,
              boardSize: widget.boardSize,
              vsAI: widget.vsAI,
              difficulty: widget.difficulty,
              gameMode: widget.gameMode,
              winCondition: widget.winCondition,
              startingPlayer: widget.startingPlayer,
              maxWidth: maxBoardSize.clamp(200.0, 700.0),
              maxHeight: availableHeight.clamp(200.0, 700.0),
              showStatusBar: true,
              onStateChanged: _triggerRebuild,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const sidebarWidth = 280.0;
        final availableWidth = constraints.maxWidth - sidebarWidth - 64;
        final availableHeight = constraints.maxHeight - 64;
        final maxBoardSize = availableWidth < availableHeight
            ? availableWidth
            : availableHeight;

        return Row(
          children: [
            // Sidebar
            Container(
              width: sidebarWidth,
              decoration: BoxDecoration(
                color: _theme.cardBackground,
                border: Border(
                  right: BorderSide(color: _theme.cardBorder, width: 1),
                ),
              ),
              child: _buildSidebar(),
            ),
            // Plateau de jeu
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: GameBoard(
                    key: _gameBoardKey,
                    boardSize: widget.boardSize,
                    vsAI: widget.vsAI,
                    difficulty: widget.difficulty,
                    gameMode: widget.gameMode,
                    winCondition: widget.winCondition,
                    startingPlayer: widget.startingPlayer,
                    maxWidth: maxBoardSize.clamp(200.0, 700.0),
                    maxHeight: availableHeight.clamp(200.0, 700.0),
                    showStatusBar: false,
                    onStateChanged: _triggerRebuild,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSidebar() {
    return Column(
      children: [
        // Options en haut
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bouton retour + titre
                Row(
                  children: [
                    const BackButton(),
                    const SizedBox(width: 4),
                    Text(
                      "Aboul'",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _theme.primaryText,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Bouton nouvelle partie
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _gameBoardKey.currentState?.resetGame();
                      _triggerRebuild();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Nouvelle partie'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _theme.accentColor,
                      side: BorderSide(color: _theme.accentColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Status en bas
        _buildStatusPanel(),
      ],
    );
  }

  Widget _buildStatusPanel() {
    final boardState = _gameBoardKey.currentState;

    String playerName;
    String actionText;
    Color statusColor;
    bool isThinking = false;

    if (boardState == null) {
      playerName = widget.vsAI ? 'Vous' : 'Joueur 1';
      actionText = 'Deplacez le Bouddha';
      statusColor = _theme.player1Color;
    } else if (boardState.winner != null) {
      if (widget.vsAI) {
        playerName = boardState.winner == Player.player1
            ? 'Vous'
            : 'Ordinateur';
      } else {
        playerName = boardState.winner == Player.player1
            ? 'Joueur 1'
            : 'Joueur 2';
      }
      actionText = 'Gagne !';
      statusColor = boardState.winner == Player.player1
          ? _theme.player1Color
          : _theme.player2Color;
    } else if (boardState.aiThinking) {
      playerName = 'Ordinateur';
      actionText = 'Reflechit...';
      statusColor = _theme.player2Color;
      isThinking = true;
    } else {
      if (widget.vsAI) {
        playerName = boardState.currentPlayer == Player.player1
            ? 'Vous'
            : 'Ordinateur';
      } else {
        playerName = boardState.currentPlayer == Player.player1
            ? 'Joueur 1'
            : 'Joueur 2';
      }
      actionText = boardState.phase == GamePhase.moveBuddha
          ? 'Deplacez le Bouddha'
          : 'Deplacez un pion';
      statusColor = boardState.currentPlayer == Player.player1
          ? _theme.player1Color
          : _theme.player2Color;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(20),
        border: Border(
          top: BorderSide(color: statusColor.withAlpha(50), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  playerName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (isThinking)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: statusColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            actionText,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
