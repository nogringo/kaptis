import 'package:flutter/material.dart';
import '../models/ai_player.dart';
import '../theme/app_theme.dart';
import '../widgets/game_board.dart';

class GameScreen extends StatefulWidget {
  final int boardSize;
  final bool vsAI;
  final AIDifficulty difficulty;

  const GameScreen({
    super.key,
    required this.boardSize,
    required this.vsAI,
    required this.difficulty,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GlobalKey<GameBoardState> _gameBoardKey = GlobalKey<GameBoardState>();

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        title: const Text(
          "Aboul'",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.appBarBackground,
        foregroundColor: theme.appBarForeground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Nouvelle partie',
            onPressed: () => _gameBoardKey.currentState?.resetGame(),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GameBoard(
              key: _gameBoardKey,
              boardSize: widget.boardSize,
              vsAI: widget.vsAI,
              difficulty: widget.difficulty,
            ),
          ),
        ),
      ),
    );
  }
}
