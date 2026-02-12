import 'package:flutter/material.dart';
import 'widgets/game_board.dart';

void main() {
  runApp(const AboulApp());
}

class AboulApp extends StatelessWidget {
  const AboulApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Aboul'",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

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
      ),
      body: const Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [GameBoard(), SizedBox(height: 30), RulesCard()],
            ),
          ),
        ),
      ),
    );
  }
}

class RulesCard extends StatelessWidget {
  const RulesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Regles du jeu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          SizedBox(height: 12),
          Text(
            '1. Deplacez le Bouddha d\'une case\n'
            '2. Deplacez un de vos pions jusqu\'au bout\n\n'
            'Victoire:\n'
            '- Amenez le Bouddha sur la ligne adverse\n'
            '- Bloquez le Bouddha',
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }
}
