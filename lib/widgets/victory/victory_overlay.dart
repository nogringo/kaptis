import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/game_state.dart';
import '../../theme/app_colors.dart';
import 'confetti_particle.dart';
import 'confetti_painter.dart';

class VictoryOverlay extends StatefulWidget {
  final Player winner;
  final String winnerName;
  final Color winnerColor;
  final VoidCallback? onReplay;
  final VoidCallback onMenu;

  const VictoryOverlay({
    super.key,
    required this.winner,
    required this.winnerName,
    required this.winnerColor,
    this.onReplay,
    required this.onMenu,
  });

  @override
  State<VictoryOverlay> createState() => _VictoryOverlayState();
}

class _VictoryOverlayState extends State<VictoryOverlay>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _dialogController;
  late Animation<double> _dialogScaleAnimation;

  final List<ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  static const int _particleCount = 100;
  static const double _gravity = 0.15;

  @override
  void initState() {
    super.initState();

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _dialogController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _dialogScaleAnimation = CurvedAnimation(
      parent: _dialogController,
      curve: Curves.elasticOut,
    );

    _confettiController.addListener(_updateParticles);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initParticles();
      _confettiController.repeat();
      _dialogController.forward();
    });
  }

  void _initParticles() {
    if (!mounted) return;
    final screenSize = MediaQuery.of(context).size;

    _particles.clear();
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(
        ConfettiParticle.random(
          screenWidth: screenSize.width,
          screenHeight: screenSize.height,
          baseColor: widget.winnerColor,
          random: _random,
          initialSpawn: true,
        ),
      );
    }
  }

  void _updateParticles() {
    if (!mounted) return;
    final screenSize = MediaQuery.of(context).size;

    setState(() {
      for (final particle in _particles) {
        particle.update(_gravity, screenSize.height);

        if (particle.isOffScreen(screenSize.height)) {
          final newParticle = ConfettiParticle.random(
            screenWidth: screenSize.width,
            screenHeight: screenSize.height,
            baseColor: widget.winnerColor,
            random: _random,
          );
          particle.x = newParticle.x;
          particle.y = newParticle.y;
          particle.velocityX = newParticle.velocityX;
          particle.velocityY = newParticle.velocityY;
          particle.rotation = newParticle.rotation;
          particle.rotationSpeed = newParticle.rotationSpeed;
          particle.size = newParticle.size;
          particle.color = newParticle.color;
          particle.shape = newParticle.shape;
        }
      }
    });
  }

  @override
  void dispose() {
    _confettiController.removeListener(_updateParticles);
    _confettiController.dispose();
    _dialogController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Semi-transparent overlay
          Container(color: Colors.black.withAlpha(150)),

          // Confetti animation
          CustomPaint(
            painter: ConfettiPainter(particles: _particles),
            size: Size.infinite,
          ),

          // Victory dialog
          Center(
            child: ScaleTransition(
              scale: _dialogScaleAnimation,
              child: _buildVictoryDialog(theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVictoryDialog(AppColors theme) {
    return Container(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.all(32),
      constraints: const BoxConstraints(maxWidth: 320),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: widget.winnerColor.withAlpha(100), width: 2),
        boxShadow: [
          BoxShadow(
            color: widget.winnerColor.withAlpha(50),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Winner badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: widget.winnerColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: widget.winnerColor.withAlpha(100),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              widget.winnerName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // "Gagne !" text
          Text(
            AppLocalizations.of(context)!.wins,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: widget.winnerColor,
            ),
          ),

          const SizedBox(height: 32),

          // Buttons
          if (widget.onReplay != null) ...[
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: widget.onReplay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.winnerColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.replay,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: widget.onMenu,
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.primaryText,
                side: BorderSide(color: theme.cardBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.menu,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
