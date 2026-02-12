import 'package:flutter/material.dart';
import '../models/game_state.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  GameState gameState = GameState.initial();
  Piece? selectedPawn;
  List<Position> validMoves = [];

  void _handleCellTap(Position pos) {
    if (gameState.winner != null) return;

    if (gameState.phase == GamePhase.moveBuddha) {
      // Phase 1: Déplacer le Bouddha
      if (validMoves.contains(pos)) {
        setState(() {
          gameState = gameState.moveBuddha(pos);
          validMoves = [];
        });
      } else {
        // Montrer les mouvements valides du Bouddha
        setState(() {
          validMoves = gameState.getValidBuddhaMoves();
        });
      }
    } else {
      // Phase 2: Déplacer un pion
      final piece = gameState.getPieceAt(pos);

      if (selectedPawn != null && validMoves.contains(pos)) {
        // Déplacer le pion sélectionné
        setState(() {
          gameState = gameState.movePawn(selectedPawn!, pos);
          selectedPawn = null;
          validMoves = [];
        });
      } else if (piece != null &&
          piece.type == PieceType.pawn &&
          piece.owner == gameState.currentPlayer) {
        // Sélectionner un pion
        setState(() {
          selectedPawn = piece;
          validMoves = gameState.getValidPawnMoves(piece);
        });
      } else {
        setState(() {
          selectedPawn = null;
          validMoves = [];
        });
      }
    }
  }

  void _resetGame() {
    setState(() {
      gameState = GameState.initial();
      selectedPawn = null;
      validMoves = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatusBar(),
        const SizedBox(height: 20),
        _buildBoard(),
        const SizedBox(height: 20),
        _buildResetButton(),
      ],
    );
  }

  Widget _buildStatusBar() {
    String statusText;
    Color statusColor;

    if (gameState.winner != null) {
      final winnerName = gameState.winner == Player.player1
          ? 'Joueur 1'
          : 'Joueur 2';
      statusText = '$winnerName a gagn\u00e9 !';
      statusColor = gameState.winner == Player.player1
          ? Colors.blue
          : Colors.red;
    } else {
      final playerName = gameState.currentPlayer == Player.player1
          ? 'Joueur 1'
          : 'Joueur 2';
      final phaseText = gameState.phase == GamePhase.moveBuddha
          ? 'D\u00e9placez le Bouddha'
          : 'D\u00e9placez un pion';
      statusText = '$playerName - $phaseText';
      statusColor = gameState.currentPlayer == Player.player1
          ? Colors.blue
          : Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: statusColor,
        ),
      ),
    );
  }

  Widget _buildBoard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 350,
          height: 350,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: GameState.boardSize,
            ),
            itemCount: GameState.boardSize * GameState.boardSize,
            itemBuilder: (context, index) {
              final row = index ~/ GameState.boardSize;
              final col = index % GameState.boardSize;
              final pos = Position(row, col);
              return _buildCell(pos);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCell(Position pos) {
    final piece = gameState.getPieceAt(pos);
    final isValidMove = validMoves.contains(pos);
    final isSelected = selectedPawn?.position == pos;

    // Couleur de la case (damier)
    final isLightCell = (pos.row + pos.col) % 2 == 0;
    Color cellColor = isLightCell
        ? const Color(0xFFE8D4B8)
        : const Color(0xFFB58863);

    // Surbrillance pour les mouvements valides
    if (isValidMove) {
      cellColor = Colors.green.withOpacity(0.6);
    }

    // Surbrillance pour la pi\u00e8ce s\u00e9lectionn\u00e9e
    if (isSelected) {
      cellColor = Colors.yellow.withOpacity(0.6);
    }

    // Zones de d\u00e9part (lignes 0 et 4)
    Widget? zoneIndicator;
    if (pos.row == 0) {
      zoneIndicator = Positioned(
        top: 2,
        right: 2,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        ),
      );
    } else if (pos.row == 4) {
      zoneIndicator = Positioned(
        top: 2,
        right: 2,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _handleCellTap(pos),
      child: Container(
        decoration: BoxDecoration(
          color: cellColor,
          border: Border.all(color: Colors.black26, width: 0.5),
        ),
        child: Stack(
          children: [
            if (zoneIndicator != null) zoneIndicator,
            if (piece != null) _buildPiece(piece),
            if (isValidMove && piece == null)
              Center(
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPiece(Piece piece) {
    if (piece.type == PieceType.buddha) {
      return Center(
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              colors: [Color(0xFFFFD700), Color(0xFFDAA520)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '\u2638',
              style: TextStyle(fontSize: 28, color: Colors.white),
            ),
          ),
        ),
      );
    }

    final color = piece.owner == Player.player1 ? Colors.blue : Colors.red;
    final isSelected = selectedPawn == piece;

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isSelected ? 48 : 44,
        height: isSelected ? 48 : 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.yellow : Colors.white,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return ElevatedButton.icon(
      onPressed: _resetGame,
      icon: const Icon(Icons.refresh),
      label: const Text('Nouvelle partie'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
}
