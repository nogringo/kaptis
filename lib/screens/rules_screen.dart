import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
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
        title: Text(
          AppLocalizations.of(context)!.rulesTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
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
                  title: AppLocalizations.of(context)!.rulesBoardTitle,
                  content: AppLocalizations.of(context)!.rulesBoardContent,
                ),
                _buildSection(
                  icon: Icons.emoji_events_rounded,
                  title: AppLocalizations.of(context)!.rulesObjectiveTitle,
                  content: AppLocalizations.of(context)!.rulesObjectiveContent,
                ),
                _buildSection(
                  icon: Icons.swap_horiz_rounded,
                  title: AppLocalizations.of(context)!.rulesTurnTitle,
                  content: AppLocalizations.of(context)!.rulesTurnContent,
                ),
                _buildSection(
                  icon: Icons.info_outline_rounded,
                  title: AppLocalizations.of(context)!.rulesImportantTitle,
                  content: AppLocalizations.of(context)!.rulesImportantContent,
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
                AppLocalizations.of(context)!.rulesPiecesTitle,
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
            name: AppLocalizations.of(context)!.rulesPiecesP1,
            description: AppLocalizations.of(context)!.rulesPawnMove,
          ),
          const SizedBox(height: 16),
          _buildPieceRow(
            color: _theme.player2Color,
            icon: null,
            name: AppLocalizations.of(context)!.rulesPiecesP2,
            description: AppLocalizations.of(context)!.rulesPawnMove,
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
                AppLocalizations.of(context)!.nexus,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _theme.primaryText,
                ),
              ),
              Text(
                AppLocalizations.of(context)!.rulesNexusMove,
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
