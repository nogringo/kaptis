import 'package:flutter/material.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text(
          'Regles du jeu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              icon: Icons.grid_on_rounded,
              title: 'Le plateau',
              content:
                  'Le jeu se joue sur un plateau de 5x5 ou 7x7 cases. '
                  'Chaque joueur possede 5 ou 7 pions places sur sa ligne de depart. '
                  'Le Bouddha (piece doree) est place au centre du plateau.',
            ),
            _buildSection(
              icon: Icons.emoji_events_rounded,
              title: 'Objectif',
              content:
                  'Un joueur gagne la partie s\'il reussit a :\n\n'
                  '1. Ramener le Bouddha sur sa propre ligne de depart\n\n'
                  '2. Bloquer le Bouddha de facon a ce qu\'il ne puisse plus etre deplace',
            ),
            _buildSection(
              icon: Icons.swap_horiz_rounded,
              title: 'Deroulement d\'un tour',
              content:
                  'A son tour, un joueur effectue 2 actions dans cet ordre :\n\n'
                  '1. Deplacer le Bouddha d\'une seule case (dans n\'importe quelle direction)\n\n'
                  '2. Deplacer un de ses pions jusqu\'au bout de la ligne ou jusqu\'a un obstacle',
            ),
            _buildSection(
              icon: Icons.info_outline_rounded,
              title: 'Regles importantes',
              content:
                  '- Le Bouddha se deplace d\'une seule case a la fois\n\n'
                  '- Les pions doivent aller le plus loin possible dans la direction choisie\n\n'
                  '- Aucun pion ne peut sauter par-dessus un autre pion ou le Bouddha\n\n'
                  '- 8 directions possibles : horizontale, verticale et diagonales',
            ),
            _buildPiecesLegend(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFFFFD700), size: 24),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade300,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPiecesLegend() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.category_rounded,
                  color: Color(0xFFFFD700),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'Les pieces',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPieceRow(
            color: const Color(0xFFFFD700),
            icon: '\u2638',
            name: 'Bouddha',
            description: 'Piece centrale, se deplace d\'une case',
          ),
          const SizedBox(height: 16),
          _buildPieceRow(
            color: Colors.blue,
            icon: null,
            name: 'Pions Joueur 1',
            description: 'Ligne du haut, vont jusqu\'au bout',
          ),
          const SizedBox(height: 16),
          _buildPieceRow(
            color: Colors.red,
            icon: null,
            name: 'Pions Joueur 2',
            description: 'Ligne du bas, vont jusqu\'au bout',
          ),
        ],
      ),
    );
  }

  Widget _buildPieceRow({
    required Color color,
    String? icon,
    required String name,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: color.withAlpha(100), blurRadius: 8)],
          ),
          child: icon != null
              ? Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                )
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                description,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
