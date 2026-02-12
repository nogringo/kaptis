import 'package:flutter/material.dart';
import '../models/ai_player.dart';
import '../widgets/game_board.dart';

class GameScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2D2D),
      appBar: AppBar(
        title: const Text(
          "Aboul'",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GameBoard(
              boardSize: boardSize,
              vsAI: vsAI,
              difficulty: difficulty,
            ),
          ),
        ),
      ),
    );
  }
}
