import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/ai_player.dart';
import '../models/game_state.dart';
import '../theme/app_colors.dart';
import '../widgets/game_board.dart';
import '../widgets/victory/victory_overlay.dart';

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
  bool _showVictoryOverlay = false;
  Player? _lastWinner;

  AppColors get _theme => context.colors;

  void _triggerRebuild() {
    final boardState = _gameBoardKey.currentState;
    final currentWinner = boardState?.winner;

    // Detect winner transition: null -> Player
    if (currentWinner != null && _lastWinner == null) {
      _showVictoryOverlay = true;
    }
    _lastWinner = currentWinner;

    setState(() {});
  }

  void _handleReplay() {
    _gameBoardKey.currentState?.resetGame();
    setState(() {
      _showVictoryOverlay = false;
      _lastWinner = null;
    });
  }

  void _handleMenu() {
    Navigator.pop(context);
  }

  Widget _buildVictoryOverlay() {
    final boardState = _gameBoardKey.currentState;
    if (boardState == null || boardState.winner == null) {
      return const SizedBox.shrink();
    }

    final winner = boardState.winner!;
    String winnerName;
    if (widget.vsAI) {
      winnerName = winner == Player.player1
          ? AppLocalizations.of(context)!.you
          : AppLocalizations.of(context)!.computer;
    } else {
      winnerName = winner == Player.player1
          ? AppLocalizations.of(context)!.player1
          : AppLocalizations.of(context)!.player2;
    }

    final winnerColor = winner == Player.player1
        ? _theme.player1Color
        : _theme.player2Color;

    return VictoryOverlay(
      winner: winner,
      winnerName: winnerName,
      winnerColor: winnerColor,
      onReplay: _handleReplay,
      onMenu: _handleMenu,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1000;

    Widget scaffold;
    if (isDesktop) {
      scaffold = Scaffold(body: SafeArea(child: _buildDesktopLayout()));
    } else {
      scaffold = Scaffold(
        appBar: AppBar(
          title: const Text(
            "Kaptis",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: AppLocalizations.of(context)!.newGame,
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

    return Stack(
      children: [scaffold, if (_showVictoryOverlay) _buildVictoryOverlay()],
    );
  }

  Widget _buildMobileLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = 16.0;
        final availableWidth = constraints.maxWidth - (padding * 2);
        // Reserve space for the status bar (~120px) + spacing (24px)
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
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  right: BorderSide(color: _theme.cardBorder, width: 1),
                ),
              ),
              child: _buildSidebar(),
            ),
            // Game board
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
        // Options at the top
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button + title
                Row(
                  children: [
                    const BackButton(),
                    const SizedBox(width: 4),
                    Text(
                      "Kaptis",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _theme.primaryText,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // New game button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _gameBoardKey.currentState?.resetGame();
                      _triggerRebuild();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(AppLocalizations.of(context)!.newGame),
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
        // Status at the bottom
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
      playerName = widget.vsAI
          ? AppLocalizations.of(context)!.you
          : AppLocalizations.of(context)!.player1;
      actionText = AppLocalizations.of(context)!.moveNexusAction;
      statusColor = _theme.player1Color;
    } else if (boardState.winner != null) {
      if (widget.vsAI) {
        playerName = boardState.winner == Player.player1
            ? AppLocalizations.of(context)!.you
            : AppLocalizations.of(context)!.computer;
      } else {
        playerName = boardState.winner == Player.player1
            ? AppLocalizations.of(context)!.player1
            : AppLocalizations.of(context)!.player2;
      }
      actionText = AppLocalizations.of(context)!.wins;
      statusColor = boardState.winner == Player.player1
          ? _theme.player1Color
          : _theme.player2Color;
    } else if (boardState.aiThinking) {
      playerName = AppLocalizations.of(context)!.computer;
      actionText = AppLocalizations.of(context)!.thinking;
      statusColor = _theme.player2Color;
      isThinking = true;
    } else {
      if (widget.vsAI) {
        playerName = boardState.currentPlayer == Player.player1
            ? AppLocalizations.of(context)!.you
            : AppLocalizations.of(context)!.computer;
      } else {
        playerName = boardState.currentPlayer == Player.player1
            ? AppLocalizations.of(context)!.player1
            : AppLocalizations.of(context)!.player2;
      }
      actionText = boardState.phase == GamePhase.moveNexus
          ? AppLocalizations.of(context)!.moveNexusAction
          : AppLocalizations.of(context)!.movePawnAction;
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
