import 'package:flutter/material.dart';
import '../models/ai_player.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text(
          "Aboul'",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
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
