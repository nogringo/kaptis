import 'dart:async';
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../services/multiplayer_service.dart';
import '../theme/app_colors.dart';
import '../widgets/game_board.dart';

class MultiplayerGameScreen extends StatefulWidget {
  final MultiplayerService multiplayerService;

  const MultiplayerGameScreen({super.key, required this.multiplayerService});

  @override
  State<MultiplayerGameScreen> createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen> {
  final GlobalKey<GameBoardState> _gameBoardKey = GlobalKey<GameBoardState>();
  StreamSubscription<NetworkMove>? _moveSubscription;

  AppColors get _theme => context.colors;

  @override
  void initState() {
    super.initState();
    widget.multiplayerService.addListener(_onServiceUpdate);

    // Listen for opponent moves
    _moveSubscription = widget.multiplayerService.onMoveReceived.listen(
      _onMoveReceived,
    );
  }

  @override
  void dispose() {
    widget.multiplayerService.removeListener(_onServiceUpdate);
    _moveSubscription?.cancel();
    super.dispose();
  }

  void _onServiceUpdate() {
    setState(() {});
  }

  void _onMoveReceived(NetworkMove move) {
    // Apply opponent's move to local state
    widget.multiplayerService.applyMove(move);

    // Update the game board
    final boardState = _gameBoardKey.currentState;
    if (boardState != null && widget.multiplayerService.gameState != null) {
      boardState.setGameState(widget.multiplayerService.gameState!);
    }

    setState(() {});
  }

  void _onLocalMove(
    GameState newState,
    String moveType,
    Position to,
    Position? from,
  ) async {
    // Send move to network
    await widget.multiplayerService.sendMove(
      moveType: moveType,
      to: to,
      from: from,
    );

    // Update local service state
    widget.multiplayerService.updateGameState(newState);

    // Check for winner
    if (newState.winner != null) {
      widget.multiplayerService.publishResult(newState.winner!);
    }

    setState(() {});
  }

  void _triggerRebuild() {
    setState(() {});
  }

  Future<bool> _onWillPop() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitter la partie ?'),
        content: const Text('Vous allez abandonner la partie en cours.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );

    if (shouldLeave == true) {
      await widget.multiplayerService.leaveRoom();
    }

    return shouldLeave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1000;
    final room = widget.multiplayerService.currentRoom;

    if (room == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Connexion perdue'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }

    if (isDesktop) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) {
            final canPop = await _onWillPop();
            if (canPop && mounted) {
              Navigator.pop(context);
            }
          }
        },
        child: Scaffold(body: SafeArea(child: _buildDesktopLayout())),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final canPop = await _onWillPop();
          if (canPop && mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Kaptis",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final canPop = await _onWillPop();
              if (canPop && mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: SafeArea(child: _buildMobileLayout()),
      ),
    );
  }

  Widget _buildMobileLayout() {
    final room = widget.multiplayerService.currentRoom!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = 16.0;
        final availableWidth = constraints.maxWidth - (padding * 2);
        final statusBarHeight = 180.0; // Plus grand pour infos multijoueur
        final availableHeight =
            constraints.maxHeight - (padding * 2) - statusBarHeight;
        final maxBoardSize = availableWidth < availableHeight
            ? availableWidth
            : availableHeight;

        return Center(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                _buildConnectionStatus(),
                const SizedBox(height: 8),
                Expanded(
                  child: GameBoard(
                    key: _gameBoardKey,
                    boardSize: room.boardSize,
                    vsAI: false,
                    gameMode: room.gameMode,
                    winCondition: room.winCondition,
                    startingPlayer: room.startingPlayer,
                    maxWidth: maxBoardSize.clamp(200.0, 700.0),
                    maxHeight: (availableHeight - 40).clamp(200.0, 700.0),
                    showStatusBar: true,
                    onStateChanged: _triggerRebuild,
                    isMultiplayer: true,
                    localPlayer: widget.multiplayerService.localPlayer,
                    onMultiplayerMove: _onLocalMove,
                    initialState: widget.multiplayerService.gameState,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout() {
    final room = widget.multiplayerService.currentRoom!;

    return LayoutBuilder(
      builder: (context, constraints) {
        const sidebarWidth = 280.0;
        final availableWidth = constraints.maxWidth - sidebarWidth - 64;
        final availableHeight = constraints.maxHeight - 64;
        final maxBoardSize = availableWidth < availableHeight
            ? availableWidth
            : availableHeight;

        return Row(
          children: [
            Container(
              width: sidebarWidth,
              decoration: BoxDecoration(
                color: _theme.cardBackground,
                border: Border(
                  right: BorderSide(color: _theme.cardBorder, width: 1),
                ),
              ),
              child: _buildSidebar(),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: GameBoard(
                    key: _gameBoardKey,
                    boardSize: room.boardSize,
                    vsAI: false,
                    gameMode: room.gameMode,
                    winCondition: room.winCondition,
                    startingPlayer: room.startingPlayer,
                    maxWidth: maxBoardSize.clamp(200.0, 700.0),
                    maxHeight: availableHeight.clamp(200.0, 700.0),
                    showStatusBar: false,
                    onStateChanged: _triggerRebuild,
                    isMultiplayer: true,
                    localPlayer: widget.multiplayerService.localPlayer,
                    onMultiplayerMove: _onLocalMove,
                    initialState: widget.multiplayerService.gameState,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConnectionStatus() {
    final isConnected = widget.multiplayerService.isMyTurn;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isConnected
            ? Colors.green.withAlpha(25)
            : Colors.orange.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isConnected ? Colors.green : Colors.orange),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isConnected ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isConnected ? 'Votre tour' : 'En attente...',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isConnected ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final room = widget.multiplayerService.currentRoom;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () async {
                        final canPop = await _onWillPop();
                        if (canPop && mounted) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Kaptis",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _theme.primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildConnectionStatus(),
                const SizedBox(height: 24),
                if (room != null) ...[
                  Text(
                    'Code: ${room.code}',
                    style: TextStyle(
                      fontSize: 14,
                      color: _theme.secondaryText,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vous jouez les ${widget.multiplayerService.localPlayer == Player.player1 ? "Bleus" : "Rouges"}',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          widget.multiplayerService.localPlayer ==
                              Player.player1
                          ? _theme.player1Color
                          : _theme.player2Color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const Spacer(),
              ],
            ),
          ),
        ),
        _buildStatusPanel(),
      ],
    );
  }

  Widget _buildStatusPanel() {
    final boardState = _gameBoardKey.currentState;
    final localPlayer = widget.multiplayerService.localPlayer;

    String playerName;
    String actionText;
    Color statusColor;

    if (boardState == null) {
      playerName = 'Chargement';
      actionText = '...';
      statusColor = _theme.accentColor;
    } else if (boardState.winner != null) {
      final isLocalWinner = boardState.winner == localPlayer;
      playerName = isLocalWinner ? 'Vous' : 'Adversaire';
      actionText = 'Gagne !';
      statusColor = boardState.winner == Player.player1
          ? _theme.player1Color
          : _theme.player2Color;
    } else {
      final isMyTurn = boardState.currentPlayer == localPlayer;
      playerName = isMyTurn ? 'Vous' : 'Adversaire';
      actionText = boardState.phase == GamePhase.moveNexus
          ? 'Deplacez le Nexus'
          : 'Deplacez un pion';
      statusColor = boardState.currentPlayer == Player.player1
          ? _theme.player1Color
          : _theme.player2Color;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(20),
        border: Border(
          top: BorderSide(color: statusColor.withAlpha(50), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              playerName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            actionText,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
