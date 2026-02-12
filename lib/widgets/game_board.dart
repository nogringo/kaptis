import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/ai_player.dart';
import '../theme/app_theme.dart';

class GameBoard extends StatefulWidget {
  final int boardSize;
  final bool vsAI;
  final AIDifficulty difficulty;

  const GameBoard({
    super.key,
    required this.boardSize,
    required this.vsAI,
    required this.difficulty,
  });

  @override
  GameBoardState createState() => GameBoardState();
}

class GameBoardState extends State<GameBoard> {
  bool _aiThinking = false;
  late GameState gameState;
  Piece? selectedPawn;
  List<Position> validMoves = [];
  late AIPlayer _ai;

  void resetGame() {
    setState(() {
      gameState = GameState.initial(size: widget.boardSize);
      selectedPawn = null;
      validMoves = [];
      _aiThinking = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _ai = AIPlayer(difficulty: widget.difficulty);
    gameState = GameState.initial(size: widget.boardSize);
  }

  void _handleCellTap(Position pos) {
    if (gameState.winner != null) return;
    if (_aiThinking) return;
    if (widget.vsAI && gameState.currentPlayer == Player.player2) return;

    if (gameState.phase == GamePhase.moveBuddha) {
      if (validMoves.contains(pos)) {
        setState(() {
          gameState = gameState.moveBuddha(pos);
          validMoves = [];
        });
        _checkAndPlayAI();
      } else {
        setState(() {
          validMoves = gameState.getValidBuddhaMoves();
        });
      }
    } else {
      final piece = gameState.getPieceAt(pos);

      if (selectedPawn != null && validMoves.contains(pos)) {
        setState(() {
          gameState = gameState.movePawn(selectedPawn!, pos);
          selectedPawn = null;
          validMoves = [];
        });
        _checkAndPlayAI();
      } else if (piece != null &&
          piece.type == PieceType.pawn &&
          piece.owner == gameState.currentPlayer) {
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

  void _checkAndPlayAI() {
    if (!widget.vsAI) return;
    if (gameState.winner != null) return;
    if (gameState.currentPlayer != Player.player2) return;

    setState(() {
      _aiThinking = true;
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
      _playAITurn();
    });
  }

  void _playAITurn() {
    if (gameState.winner != null) {
      setState(() {
        _aiThinking = false;
      });
      return;
    }

    if (gameState.phase == GamePhase.moveBuddha) {
      final buddhaMove = _ai.getBestBuddhaMove(gameState);
      if (buddhaMove != null) {
        setState(() {
          gameState = gameState.moveBuddha(buddhaMove);
        });
      }
    }

    if (gameState.winner != null) {
      setState(() {
        _aiThinking = false;
      });
      return;
    }

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (gameState.phase == GamePhase.movePawn &&
          gameState.currentPlayer == Player.player2) {
        final pawnMove = _ai.getBestPawnMove(gameState);
        if (pawnMove != null) {
          setState(() {
            gameState = gameState.movePawn(pawnMove.$1, pawnMove.$2);
            _aiThinking = false;
          });
        } else {
          setState(() {
            _aiThinking = false;
          });
        }
      } else {
        setState(() {
          _aiThinking = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatusBar(theme),
        const SizedBox(height: 24),
        _buildBoard(theme),
      ],
    );
  }

  Widget _buildStatusBar(AppTheme theme) {
    String playerName;
    String actionText;
    Color statusColor;

    if (gameState.winner != null) {
      if (widget.vsAI) {
        playerName = gameState.winner == Player.player1 ? 'Vous' : 'Ordinateur';
      } else {
        playerName = gameState.winner == Player.player1
            ? 'Joueur 1'
            : 'Joueur 2';
      }
      actionText = 'Gagne !';
      statusColor = gameState.winner == Player.player1
          ? AppTheme.player1Color
          : AppTheme.player2Color;
    } else if (_aiThinking) {
      playerName = 'Ordinateur';
      actionText = 'Reflechit...';
      statusColor = AppTheme.player2Color;
    } else {
      if (widget.vsAI) {
        playerName = gameState.currentPlayer == Player.player1
            ? 'Vous'
            : 'Ordinateur';
      } else {
        playerName = gameState.currentPlayer == Player.player1
            ? 'Joueur 1'
            : 'Joueur 2';
      }
      actionText = gameState.phase == GamePhase.moveBuddha
          ? 'Deplacez le Bouddha'
          : 'Deplacez un pion';
      statusColor = gameState.currentPlayer == Player.player1
          ? AppTheme.player1Color
          : AppTheme.player2Color;
    }

    final boardPixelSize = widget.boardSize == 5 ? 350.0 : 420.0;

    return Container(
      width: boardPixelSize,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(50),
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
              if (_aiThinking)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: statusColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            actionText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(AppTheme theme) {
    final boardPixelSize = widget.boardSize == 5 ? 350.0 : 420.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: boardPixelSize,
          child: AspectRatio(
            aspectRatio: 1.0,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gameState.boardSize,
              ),
              itemCount: gameState.boardSize * gameState.boardSize,
              itemBuilder: (context, index) {
                final row = index ~/ gameState.boardSize;
                final col = index % gameState.boardSize;
                final pos = Position(row, col);
                return _buildCell(pos, theme);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(Position pos, AppTheme theme) {
    final piece = gameState.getPieceAt(pos);
    final isValidMove = validMoves.contains(pos);
    final isSelected = selectedPawn?.position == pos;

    final isLightCell = (pos.row + pos.col) % 2 == 0;
    Color cellColor = isLightCell ? theme.boardLightCell : theme.boardDarkCell;

    if (isValidMove) {
      cellColor = theme.validMoveColor.withAlpha(153);
    }

    if (isSelected) {
      cellColor = theme.selectedColor.withAlpha(153);
    }

    Widget? zoneIndicator;
    if (pos.row == 0) {
      zoneIndicator = Positioned(
        top: 2,
        right: 2,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.player1Color.withAlpha(127),
            shape: BoxShape.circle,
          ),
        ),
      );
    } else if (pos.row == gameState.boardSize - 1) {
      zoneIndicator = Positioned(
        top: 2,
        right: 2,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.player2Color.withAlpha(127),
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
          border: Border.all(color: theme.boardBorder, width: 0.5),
        ),
        child: Stack(
          children: [
            ?zoneIndicator,
            if (piece != null) _buildPiece(piece, theme),
            if (isValidMove && piece == null)
              Center(
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: theme.validMoveColor.withAlpha(127),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPiece(Piece piece, AppTheme theme) {
    final pieceSize = widget.boardSize == 5 ? 50.0 : 42.0;
    final pawnSize = widget.boardSize == 5 ? 44.0 : 36.0;
    final pawnSelectedSize = widget.boardSize == 5 ? 48.0 : 40.0;

    if (piece.type == PieceType.buddha) {
      return Center(
        child: Container(
          width: pieceSize,
          height: pieceSize,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [theme.accentColorBright, theme.accentColorSecondary],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor,
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '\u2638',
              style: TextStyle(
                fontSize: widget.boardSize == 5 ? 28 : 24,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    final color = piece.owner == Player.player1
        ? AppTheme.player1Color
        : AppTheme.player2Color;
    final isSelected = selectedPawn == piece;

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isSelected ? pawnSelectedSize : pawnSize,
        height: isSelected ? pawnSelectedSize : pawnSize,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? theme.selectedColor : Colors.white,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor,
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
      ),
    );
  }
}
