import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_room.dart';
import '../models/game_state.dart';
import '../services/multiplayer_service.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import 'multiplayer_game_screen.dart';

class WaitingRoomScreen extends StatefulWidget {
  final MultiplayerService multiplayerService;

  const WaitingRoomScreen({super.key, required this.multiplayerService});

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _copied = false;

  AppColors get _theme => context.colors;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Listen for player join
    widget.multiplayerService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    widget.multiplayerService.removeListener(_onServiceUpdate);
    _animationController.dispose();
    super.dispose();
  }

  void _onServiceUpdate() {
    if (widget.multiplayerService.currentRoom?.isFull == true) {
      // Player joined, navigate to game
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MultiplayerGameScreen(
            multiplayerService: widget.multiplayerService,
          ),
        ),
      );
    }
  }

  void _copyCode() {
    final code = widget.multiplayerService.currentRoom?.code;
    if (code != null) {
      Clipboard.setData(ClipboardData(text: code));
      setState(() => _copied = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _copied = false);
        }
      });
    }
  }

  Future<void> _cancel() async {
    await widget.multiplayerService.leaveRoom();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLarge = Responsive.isLargeScreen(context);
    final room = widget.multiplayerService.currentRoom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _cancel();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'En attente...',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isLarge ? 24 : 20,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _cancel,
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: Responsive.screenPadding(context),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Responsive.contentMaxWidth(context),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCodeCard(isLarge, room?.code ?? '------'),
                    SizedBox(height: isLarge ? 48 : 32),
                    _buildWaitingIndicator(isLarge),
                    SizedBox(height: isLarge ? 48 : 32),
                    _buildInfoSection(isLarge, room),
                    SizedBox(height: isLarge ? 48 : 32),
                    _buildCancelButton(isLarge),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeCard(bool isLarge, String code) {
    return Container(
      padding: EdgeInsets.all(isLarge ? 40 : 32),
      decoration: BoxDecoration(
        color: _theme.cardBackground,
        borderRadius: BorderRadius.circular(isLarge ? 24 : 20),
        border: Border.all(color: _theme.accentColor, width: 2),
      ),
      child: Column(
        children: [
          Text(
            'Code de la partie',
            style: TextStyle(
              fontSize: isLarge ? 18 : 16,
              color: _theme.secondaryText,
            ),
          ),
          SizedBox(height: isLarge ? 24 : 16),
          Text(
            code,
            style: TextStyle(
              fontSize: isLarge ? 56 : 44,
              fontWeight: FontWeight.bold,
              letterSpacing: 12,
              color: _theme.accentColor,
            ),
          ),
          SizedBox(height: isLarge ? 24 : 16),
          ElevatedButton.icon(
            onPressed: _copyCode,
            icon: Icon(
              _copied ? Icons.check : Icons.copy,
              size: isLarge ? 20 : 18,
            ),
            label: Text(
              _copied ? 'Copie !' : 'Copier',
              style: TextStyle(fontSize: isLarge ? 16 : 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _copied ? Colors.green : _theme.accentColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isLarge ? 24 : 16,
                vertical: isLarge ? 12 : 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isLarge ? 12 : 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingIndicator(bool isLarge) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final delay = index * 0.2;
                final value = (_animationController.value + delay) % 1.0;
                final scale = 0.5 + (0.5 * (1 - (value - 0.5).abs() * 2));
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: isLarge ? 16 : 12,
                    height: isLarge ? 16 : 12,
                    margin: EdgeInsets.symmetric(horizontal: isLarge ? 8 : 6),
                    decoration: BoxDecoration(
                      color: _theme.accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            );
          },
        ),
        SizedBox(height: isLarge ? 24 : 16),
        Text(
          'En attente d\'un adversaire...',
          style: TextStyle(
            fontSize: isLarge ? 18 : 16,
            color: _theme.secondaryText,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Partagez le code avec votre adversaire',
          style: TextStyle(
            fontSize: isLarge ? 14 : 12,
            color: _theme.tertiaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(bool isLarge, GameRoom? room) {
    if (room == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(isLarge ? 24 : 16),
      decoration: BoxDecoration(
        color: _theme.cardBackground.withAlpha(128),
        borderRadius: BorderRadius.circular(isLarge ? 16 : 12),
        border: Border.all(color: _theme.cardBorder),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            isLarge,
            'Plateau',
            room.gameMode == GameMode.hexagonal
                ? 'Hexagonal'
                : '${room.boardSize}x${room.boardSize}',
          ),
          SizedBox(height: isLarge ? 12 : 8),
          _buildInfoRow(
            isLarge,
            'Victoire',
            room.winCondition == WinCondition.ownCamp
                ? 'Son camp'
                : 'Camp adverse',
          ),
          SizedBox(height: isLarge ? 12 : 8),
          _buildInfoRow(
            isLarge,
            'Votre couleur',
            room.hostPlayer == Player.player1 ? 'Bleus' : 'Rouges',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(bool isLarge, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isLarge ? 14 : 12,
            color: _theme.tertiaryText,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? 14 : 12,
            fontWeight: FontWeight.bold,
            color: _theme.primaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildCancelButton(bool isLarge) {
    return TextButton(
      onPressed: _cancel,
      child: Text(
        'Annuler',
        style: TextStyle(
          fontSize: isLarge ? 16 : 14,
          color: _theme.tertiaryText,
        ),
      ),
    );
  }
}
