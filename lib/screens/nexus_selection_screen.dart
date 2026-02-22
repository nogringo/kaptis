import 'package:flutter/material.dart';
import '../models/nexus_skin.dart';
import '../services/preferences_service.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import '../widgets/nexus_widget.dart';

class NexusSelectionScreen extends StatefulWidget {
  const NexusSelectionScreen({super.key});

  @override
  State<NexusSelectionScreen> createState() => _NexusSelectionScreenState();
}

class _NexusSelectionScreenState extends State<NexusSelectionScreen> {
  NexusSkin _selectedSkin = PreferencesService.nexusSkin;
  NexusColor _selectedColor = PreferencesService.nexusColor;

  Color get _colorBright => _selectedColor.bright;

  Future<void> _selectSkin(NexusSkin skin) async {
    setState(() => _selectedSkin = skin);
    await PreferencesService.setNexusSkin(skin);
  }

  Future<void> _selectColor(NexusColor color) async {
    setState(() => _selectedColor = color);
    await PreferencesService.setNexusColor(color);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Personnaliser le Nexus',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: Responsive.screenPadding(context),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.contentMaxWidth(context),
            ),
            child: Column(
              children: [
                Text(
                  'Couleur',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: theme.primaryText,
                  ),
                ),
                const SizedBox(height: 16),
                _buildColorSelector(theme),
                const SizedBox(height: 32),
                Text(
                  'Forme',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: theme.primaryText,
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildDesignCard(
                        context,
                        skin: NexusSkin.core,
                        title: 'Noyau',
                        subtitle: 'Noyau energetique',
                      ),
                      _buildDesignCard(
                        context,
                        skin: NexusSkin.diamond,
                        title: 'Diamant',
                        subtitle: 'Forme diamant',
                      ),
                      _buildDesignCard(
                        context,
                        skin: NexusSkin.crystal,
                        title: 'Cristal',
                        subtitle: 'Gemme hexagonale',
                      ),
                      _buildDesignCard(
                        context,
                        skin: NexusSkin.pulsingOrb,
                        title: 'Orbe',
                        subtitle: 'Sphere pulsante',
                      ),
                      _buildDesignCard(
                        context,
                        skin: NexusSkin.vortex,
                        title: 'Vortex',
                        subtitle: 'Spirale rotative',
                      ),
                      _buildDesignCard(
                        context,
                        skin: NexusSkin.star,
                        title: 'Etoile',
                        subtitle: 'Etoile brillante',
                      ),
                      _buildDesignCard(
                        context,
                        skin: NexusSkin.sun,
                        title: 'Soleil',
                        subtitle: 'Soleil rayonnant',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorSelector(AppColors theme) {
    return Align(
      alignment: Alignment.center,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: NexusColor.values.map((color) {
          final isSelected = _selectedColor == color;
          return GestureDetector(
            onTap: () => _selectColor(color),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: RadialGradient(colors: [color.bright, color.dark]),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 3,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: color.bright.withAlpha(150),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDesignCard(
    BuildContext context, {
    required NexusSkin skin,
    required String title,
    required String subtitle,
  }) {
    final theme = context.colors;
    final isSelected = _selectedSkin == skin;

    return GestureDetector(
      onTap: () => _selectSkin(skin),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 180,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? _colorBright : theme.cardBorder,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? _colorBright.withAlpha(50)
                      : theme.shadowColor.withAlpha(25),
                  blurRadius: isSelected ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? _colorBright : theme.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: theme.secondaryText),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  width: 100,
                  height: 100,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.boardLightCell,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: NexusWidget(skin: skin, color: _selectedColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
