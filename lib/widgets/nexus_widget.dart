import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/nexus_skin.dart';
import 'nexus_painters/nexus_painters.dart';

class NexusWidget extends StatefulWidget {
  final NexusSkin skin;
  final NexusColor color;

  const NexusWidget({super.key, required this.skin, required this.color});

  @override
  State<NexusWidget> createState() => _NexusWidgetState();
}

class _NexusWidgetState extends State<NexusWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _glowController;

  // Reference size for drawing the Nexus
  static const double _referenceSize = 60.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: _referenceSize,
        height: _referenceSize,
        child: _buildNexus(),
      ),
    );
  }

  Widget _buildNexus() {
    switch (widget.skin) {
      case NexusSkin.diamond:
        return _buildDiamond();
      case NexusSkin.crystal:
        return _buildCrystal();
      case NexusSkin.pulsingOrb:
        return _buildPulsingOrb();
      case NexusSkin.vortex:
        return _buildVortex();
      case NexusSkin.star:
        return _buildStar();
      case NexusSkin.core:
        return _buildCore();
      case NexusSkin.sun:
        return _buildSun();
    }
  }

  Widget _buildDiamond() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(_referenceSize, _referenceSize),
          painter: DiamondPainter(
            color1: Colors.white,
            color2: widget.color.bright,
            color3: widget.color.dark,
            glowValue: _glowController.value,
          ),
        );
      },
    );
  }

  Widget _buildCrystal() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(_referenceSize, _referenceSize),
          painter: CrystalPainter(
            color1: widget.color.bright,
            color2: widget.color.dark,
            glowValue: _glowController.value,
          ),
        );
      },
    );
  }

  Widget _buildPulsingOrb() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + _pulseController.value * 0.15;
        return Center(
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white,
                    widget.color.bright,
                    widget.color.medium,
                    widget.color.dark,
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVortex() {
    return AnimatedBuilder(
      animation: _rotateController,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(_referenceSize, _referenceSize),
          painter: VortexPainter(
            rotation: _rotateController.value * 2 * math.pi,
            color1: widget.color.bright,
            color2: widget.color.dark,
          ),
        );
      },
    );
  }

  Widget _buildStar() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(_referenceSize, _referenceSize),
          painter: StarPainter(
            color1: Colors.white,
            color2: widget.color.bright,
            color3: widget.color.dark,
            glowValue: _pulseController.value,
          ),
        );
      },
    );
  }

  Widget _buildCore() {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotateController, _pulseController]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: _rotateController.value * 2 * math.pi,
              child: Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color.bright.withAlpha(153),
                    width: 2,
                  ),
                ),
              ),
            ),
            Transform.rotate(
              angle: -_rotateController.value * 2 * math.pi,
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color.medium.withAlpha(204),
                    width: 2,
                  ),
                ),
              ),
            ),
            Container(
              width: 25 + _pulseController.value * 5,
              height: 25 + _pulseController.value * 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white,
                    widget.color.bright,
                    widget.color.dark,
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSun() {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotateController, _pulseController]),
      builder: (context, child) {
        return CustomPaint(
          size: const Size(_referenceSize, _referenceSize),
          painter: SunPainter(
            rotation: _rotateController.value * math.pi / 6,
            color1: Colors.white,
            color2: widget.color.bright,
            color3: widget.color.dark,
            pulseValue: _pulseController.value,
          ),
        );
      },
    );
  }
}
