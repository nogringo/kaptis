import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../theme/app_colors.dart';
import '../widgets/nexus_widget.dart';

class RulesScreen extends StatefulWidget {
  const RulesScreen({super.key});

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  AppColors get _theme => context.colors;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Règles du jeu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  icon: Icons.grid_on_rounded,
                  title: 'Le plateau',
                  content:
                      'Le jeu se joue sur un plateau carré (5x5 ou 7x7 cases) ou hexagonal. '
                      'Chaque joueur possède 5 ou 7 pions placés sur sa ligne de départ. '
                      'Le Nexus est placé au centre du plateau.',
                ),
                _buildSection(
                  icon: Icons.emoji_events_rounded,
                  title: 'Objectif',
                  content:
                      'Un joueur gagne la partie s\'il réussit à :\n\n'
                      '1. Amener le Nexus sur la ligne de sa couleur\n\n'
                      '2. Immobiliser le Nexus par encerclement stratégique (inspiré du Go)',
                ),
                _buildSection(
                  icon: Icons.swap_horiz_rounded,
                  title: 'Déroulement d\'un tour',
                  content:
                      'À son tour, un joueur effectue 2 actions dans cet ordre :\n\n'
                      '1. Déplacer le Nexus d\'une seule case (comme le Roi aux échecs)\n\n'
                      '2. Déplacer un de ses pions jusqu\'au bout de la ligne (comme la Dame aux échecs)',
                ),
                _buildSection(
                  icon: Icons.info_outline_rounded,
                  title: 'Règles importantes',
                  content:
                      '• Le Nexus se déplace d\'une case dans toutes les directions (Roi)\n\n'
                      '• Les pions filent jusqu\'au bout dans la direction choisie (Dame)\n\n'
                      '• Aucune pièce ne peut sauter par-dessus une autre\n\n'
                      '• 8 directions sur plateau carré, 6 sur plateau hexagonal',
                ),
                _buildPiecesLegend(),
                const SizedBox(height: 30),
              ],
            ),
          ),
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _theme.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _theme.accentColor.withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _theme.accentColor, size: 24),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _theme.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: _theme.subtitleText,
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _theme.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _theme.accentColor.withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.category_rounded,
                  color: _theme.accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Les pièces',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _theme.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildNexusRow(),
          const SizedBox(height: 16),
          _buildPieceRow(
            color: _theme.player1Color,
            icon: null,
            name: 'Pions Joueur 1',
            description: 'Se déplacent comme la Dame aux échecs',
          ),
          const SizedBox(height: 16),
          _buildPieceRow(
            color: _theme.player2Color,
            icon: null,
            name: 'Pions Joueur 2',
            description: 'Se déplacent comme la Dame aux échecs',
          ),
        ],
      ),
    );
  }

  Widget _buildNexusRow() {
    return Row(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: NexusWidget(
            skin: PreferencesService.nexusSkin,
            color: PreferencesService.nexusColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nexus',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _theme.primaryText,
                ),
              ),
              Text(
                'Se déplace comme le Roi aux échecs',
                style: TextStyle(fontSize: 13, color: _theme.secondaryText),
              ),
            ],
          ),
        ),
      ],
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _theme.primaryText,
                ),
              ),
              Text(
                description,
                style: TextStyle(fontSize: 13, color: _theme.secondaryText),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
