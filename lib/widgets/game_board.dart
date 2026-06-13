import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/ai_player.dart';
import '../services/preferences_service.dart';
import '../theme/app_colors.dart';
import 'nexus_widget.dart';

class GameBoard extends StatefulWidget {
  final int boardSize;
  final bool vsAI;
  final AIDifficulty difficulty;
  final GameMode gameMode;
  final WinCondition winCondition;
  final Player startingPlayer;
  final double? maxWidth;
  final double? maxHeight;
  final bool showStatusBar;
  final VoidCallback? onStateChanged;

  // Multiplayer parameters
  final bool isMultiplayer;
  final Player? localPlayer;
  final void Function(GameState, String, Position, Position?)?
  onMultiplayerMove;
  final GameState? initialState;

  const GameBoard({
    super.key,
    required this.boardSize,
    required this.vsAI,
    this.difficulty = AIDifficulty.normal,
    this.gameMode = GameMode.square,
    this.winCondition = WinCondition.ownCamp,
    this.startingPlayer = Player.player1,
    this.maxWidth,
    this.maxHeight,
    this.showStatusBar = true,
    this.onStateChanged,
    this.isMultiplayer = false,
    this.localPlayer,
    this.onMultiplayerMove,
    this.initialState,
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

  AppColors get _theme => context.colors;

  // Getters to expose the state to the parent
  bool get aiThinking => _aiThinking;
  Player? get winner => gameState.winner;
  Player get currentPlayer => gameState.currentPlayer;
  GamePhase get phase => gameState.phase;

  void _notifyStateChanged() {
    widget.onStateChanged?.call();
  }

  double get _boardPixelSize {
    final maxWidth = widget.maxWidth ?? 400;
    if (widget.gameMode == GameMode.hexagonal) {
      return maxWidth;
    }
    return maxWidth.clamp(280.0, 700.0);
  }

  double get _cellSize => _boardPixelSize / widget.boardSize;

  double get _nexusSize => _cellSize * 0.72;
  double get _pawnSize => _cellSize * 0.62;
  double get _pawnSelectedSize => _cellSize * 0.68;

  Widget _buildNexus(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: NexusWidget(
        skin: PreferencesService.nexusSkin,
        color: PreferencesService.nexusColor,
      ),
    );
  }

  void resetGame() {
    setState(() {
      if (widget.gameMode == GameMode.hexagonal) {
        gameState = GameState.initialHex(
          winCondition: widget.winCondition,
          startingPlayer: widget.startingPlayer,
        );
      } else {
        gameState = GameState.initial(
          size: widget.boardSize,
          winCondition: widget.winCondition,
          startingPlayer: widget.startingPlayer,
        );
      }
      selectedPawn = null;
      validMoves = [];
      _aiThinking = false;
    });
    _notifyStateChanged();
    // If the AI starts, trigger its turn with a delay
    if (widget.vsAI && widget.startingPlayer == Player.player2) {
      _startAITurnWithDelay();
    }
  }

  /// Set game state from external source (for multiplayer)
  void setGameState(GameState newState) {
    setState(() {
      gameState = newState;
      selectedPawn = null;
      validMoves = [];
    });
    _notifyStateChanged();
  }

  @override
  void initState() {
    super.initState();
    _ai = AIPlayer(difficulty: widget.difficulty);

    // Use initial state if provided (for multiplayer)
    if (widget.initialState != null) {
      gameState = widget.initialState!;
    } else if (widget.gameMode == GameMode.hexagonal) {
      gameState = GameState.initialHex(
        winCondition: widget.winCondition,
        startingPlayer: widget.startingPlayer,
      );
    } else {
      gameState = GameState.initial(
        size: widget.boardSize,
        winCondition: widget.winCondition,
        startingPlayer: widget.startingPlayer,
      );
    }

    // If the AI starts, trigger its turn after the build with a delay
    if (widget.vsAI && widget.startingPlayer == Player.player2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startAITurnWithDelay();
      });
    }
  }

  void _startAITurnWithDelay() {
    setState(() {
      _aiThinking = true;
    });
    _notifyStateChanged();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _playAITurn();
      }
    });
  }

  void _handleCellTap(Position pos) {
    if (gameState.winner != null) return;
    if (_aiThinking) return;
    if (widget.vsAI && gameState.currentPlayer == Player.player2) return;

    // Block interaction if not local player's turn in multiplayer
    if (widget.isMultiplayer &&
        widget.localPlayer != null &&
        gameState.currentPlayer != widget.localPlayer) {
      return;
    }

    if (gameState.phase == GamePhase.moveNexus) {
      if (validMoves.contains(pos)) {
        final newState = gameState.moveNexus(pos);
        setState(() {
          gameState = newState;
          validMoves = [];
        });
        _notifyStateChanged();

        // Notify multiplayer service
        if (widget.isMultiplayer && widget.onMultiplayerMove != null) {
          widget.onMultiplayerMove!(newState, 'nexus', pos, null);
        } else {
          _checkAndPlayAI();
        }
      } else {
        setState(() {
          validMoves = gameState.getValidNexusMoves();
        });
      }
    } else {
      final piece = gameState.getPieceAt(pos);

      if (selectedPawn != null && validMoves.contains(pos)) {
        final fromPos = selectedPawn!.position;
        final newState = gameState.movePawn(selectedPawn!, pos);
        setState(() {
          gameState = newState;
          selectedPawn = null;
          validMoves = [];
        });
        _notifyStateChanged();

        // Notify multiplayer service
        if (widget.isMultiplayer && widget.onMultiplayerMove != null) {
          widget.onMultiplayerMove!(newState, 'pawn', pos, fromPos);
        } else {
          _checkAndPlayAI();
        }
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
    _notifyStateChanged();

    Future.delayed(const Duration(milliseconds: 2000), () {
      _playAITurn();
    });
  }

  void _playAITurn() {
    if (gameState.winner != null) {
      setState(() {
        _aiThinking = false;
      });
      _notifyStateChanged();
      return;
    }

    if (gameState.phase == GamePhase.moveNexus) {
      final nexusMove = _ai.getBestNexusMove(gameState);
      if (nexusMove != null) {
        setState(() {
          gameState = gameState.moveNexus(nexusMove);
        });
        _notifyStateChanged();
      }
    }

    if (gameState.winner != null) {
      setState(() {
        _aiThinking = false;
      });
      _notifyStateChanged();
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
      _notifyStateChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showStatusBar) {
      return _buildBoard();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [_buildStatusBar(), const SizedBox(height: 24), _buildBoard()],
    );
  }

  Widget _buildStatusBar() {
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
          ? _theme.player1Color
          : _theme.player2Color;
    } else if (_aiThinking) {
      playerName = 'Ordinateur';
      actionText = 'Reflechit...';
      statusColor = _theme.player2Color;
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
      actionText = gameState.phase == GamePhase.moveNexus
          ? 'Déplacez le Nexus'
          : 'Déplacez un pion';
      statusColor = gameState.currentPlayer == Player.player1
          ? _theme.player1Color
          : _theme.player2Color;
    }

    final double statusWidth;
    if (widget.gameMode == GameMode.hexagonal) {
      statusWidth = _hexBoardWidth;
    } else {
      statusWidth = _boardPixelSize;
    }

    final isLarge = statusWidth > 450;

    return Container(
      width: statusWidth,
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 20 : 16,
        vertical: isLarge ? 16 : 12,
      ),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(25),
        borderRadius: BorderRadius.circular(isLarge ? 16 : 12),
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
                padding: EdgeInsets.symmetric(
                  horizontal: isLarge ? 16 : 12,
                  vertical: isLarge ? 6 : 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  playerName,
                  style: TextStyle(
                    fontSize: isLarge ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (_aiThinking)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: SizedBox(
                    width: isLarge ? 20 : 16,
                    height: isLarge ? 20 : 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: statusColor,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: isLarge ? 12 : 8),
          Text(
            actionText,
            style: TextStyle(
              fontSize: isLarge ? 22 : 18,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard() {
    if (widget.gameMode == GameMode.hexagonal) {
      return _buildHexBoard();
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: _theme.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: _boardPixelSize,
          child: AspectRatio(
            aspectRatio: 1.0,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gameState.boardSize,
              ),
              itemCount: gameState.boardSize * gameState.boardSize,
              itemBuilder: (context, index) {
                final visualRow = index ~/ gameState.boardSize;
                final col = index % gameState.boardSize;
                // Invert so that the local player is at the bottom
                final shouldInvert =
                    !widget.isMultiplayer ||
                    widget.localPlayer == Player.player1;
                final logicalRow = shouldInvert
                    ? gameState.boardSize - 1 - visualRow
                    : visualRow;
                final pos = Position(logicalRow, col);
                return _buildCell(pos);
              },
            ),
          ),
        ),
      ),
    );
  }

  double get _hexSize {
    final maxWidth = widget.maxWidth ?? 400;
    final maxHeight = widget.maxHeight;

    // Compute hexSize based on the width
    final hexSizeFromWidth = maxWidth / 5.5;

    // If there is a height constraint, also compute hexSize based on the height
    // The height/hexSize ratio is about 7 * sqrt(3)/2 + 0.5 ≈ 6.56
    if (maxHeight != null) {
      final hexSizeFromHeight = maxHeight / 6.56;
      return min(hexSizeFromWidth, hexSizeFromHeight).clamp(40.0, 100.0);
    }

    return hexSizeFromWidth.clamp(40.0, 100.0);
  }

  double get _hexBoardWidth {
    final hexSize = _hexSize;
    final horizontalSpacing = hexSize * 0.75;
    return 6 * horizontalSpacing + hexSize;
  }

  Widget _buildHexBoard() {
    final hexSize = _hexSize;
    final horizontalSpacing = hexSize * 0.75;
    final totalWidth = 6 * horizontalSpacing + hexSize;
    final boardWidth = totalWidth;
    final hexHeight = hexSize * sqrt(3) / 2;
    final boardHeight = 7 * hexHeight + hexSize * 0.5;

    return SizedBox(
      width: boardWidth,
      height: boardHeight,
      child: Stack(children: _buildHexCells(hexSize, boardWidth, boardHeight)),
    );
  }

  List<Widget> _buildHexCells(
    double hexSize,
    double boardWidth,
    double boardHeight,
  ) {
    final List<Widget> cells = [];
    final hexWidth = hexSize;
    final hexHeight = hexSize * sqrt(3) / 2;
    final horizontalSpacing = hexWidth * 0.75;
    final totalWidth = 6 * horizontalSpacing + hexWidth;
    final startX = (boardWidth - totalWidth) / 2;
    final centerY = boardHeight / 2;

    for (int col = 0; col < 7; col++) {
      final colHeight = GameState.hexColumnHeights[col];
      final colCenterY = centerY;
      final colStartY = colCenterY - (colHeight - 1) * hexHeight / 2;

      for (int row = 0; row < colHeight; row++) {
        final x = startX + hexWidth / 2 + col * horizontalSpacing;
        // Invert so that the local player is at the bottom
        final shouldInvert =
            !widget.isMultiplayer || widget.localPlayer == Player.player1;
        final invertedRow = shouldInvert ? colHeight - 1 - row : row;
        final y = colStartY + invertedRow * hexHeight;
        final pos = Position(row, col);

        cells.add(_buildHexCell(pos, x, y, hexSize));
      }
    }

    return cells;
  }

  Widget _buildHexCell(Position pos, double x, double y, double hexSize) {
    final piece = gameState.getPieceAt(pos);
    final isValidMove = validMoves.contains(pos);
    final isSelected = selectedPawn?.position == pos;

    final colHeight = GameState.hexColumnHeights[pos.col];
    final isTopRow = pos.row == 0;
    final isBottomRow = pos.row == colHeight - 1;

    final colorIndex = (2 * pos.row - colHeight + 100) % 3;
    Color cellColor;
    switch (colorIndex) {
      case 0:
        cellColor = _theme.boardLightCell;
        break;
      case 1:
        cellColor = _theme.boardDarkCell;
        break;
      case 2:
      default:
        cellColor = Color.lerp(
          _theme.boardLightCell,
          _theme.boardDarkCell,
          0.5,
        )!;
        break;
    }

    if (isValidMove) {
      cellColor = _theme.validMoveColor.withAlpha(180);
    }

    if (isSelected) {
      cellColor = _theme.selectedColor.withAlpha(180);
    }

    final hexPieceSize = hexSize * 0.55;
    final hexPawnSize = hexSize * 0.45;
    final hexPawnSelectedSize = hexSize * 0.52;
    final indicatorSize = hexSize * 0.12;
    final validMoveIndicatorSize = hexSize * 0.24;

    return Positioned(
      left: x - hexSize / 2,
      top: y - hexSize * sqrt(3) / 4,
      child: GestureDetector(
        onTap: () => _handleCellTap(pos),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: SizedBox(
            width: hexSize,
            height: hexSize * sqrt(3) / 2,
            child: CustomPaint(
              painter: HexagonPainter(
                fillColor: cellColor,
                borderColor: _theme.boardBorder,
              ),
              child: Stack(
                children: [
                  // isTopRow = row 0 (player 1 camp) -> objective depends on winCondition
                  if (isTopRow)
                    Positioned(
                      bottom: 6,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: indicatorSize,
                          height: indicatorSize,
                          decoration: BoxDecoration(
                            color: widget.winCondition == WinCondition.ownCamp
                                ? _theme.player1Color.withAlpha(180)
                                : _theme.player2Color.withAlpha(180),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  // isBottomRow = row max (player 2 camp) -> objective depends on winCondition
                  if (isBottomRow)
                    Positioned(
                      top: 6,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: indicatorSize,
                          height: indicatorSize,
                          decoration: BoxDecoration(
                            color: widget.winCondition == WinCondition.ownCamp
                                ? _theme.player2Color.withAlpha(180)
                                : _theme.player1Color.withAlpha(180),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  if (piece != null)
                    Center(
                      child: _buildHexPiece(
                        piece,
                        hexPieceSize,
                        hexPawnSize,
                        hexPawnSelectedSize,
                      ),
                    ),
                  if (isValidMove && piece == null)
                    Center(
                      child: Container(
                        width: validMoveIndicatorSize,
                        height: validMoveIndicatorSize,
                        decoration: BoxDecoration(
                          color: _theme.validMoveColor.withAlpha(150),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHexPiece(
    Piece piece,
    double pieceSize,
    double pawnSize,
    double pawnSelectedSize,
  ) {
    if (piece.type == PieceType.nexus) {
      return _buildNexus(pieceSize);
    }

    final color = piece.owner == Player.player1
        ? _theme.player1Color
        : _theme.player2Color;
    final isSelected = selectedPawn == piece;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isSelected ? pawnSelectedSize : pawnSize,
      height: isSelected ? pawnSelectedSize : pawnSize,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? _theme.selectedColor : Colors.white,
          width: isSelected ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _theme.shadowColor,
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(Position pos) {
    final piece = gameState.getPieceAt(pos);
    final isValidMove = validMoves.contains(pos);
    final isSelected = selectedPawn?.position == pos;

    final isLightCell = (pos.row + pos.col) % 2 == 0;
    Color cellColor = isLightCell
        ? _theme.boardLightCell
        : _theme.boardDarkCell;

    if (isValidMove) {
      cellColor = _theme.validMoveColor.withAlpha(153);
    }

    if (isSelected) {
      cellColor = _theme.selectedColor.withAlpha(153);
    }

    final indicatorSize = _cellSize * 0.12;

    Widget? zoneIndicator;
    // row 0 (player 1 camp) -> objective depends on winCondition
    if (pos.row == 0) {
      zoneIndicator = Positioned(
        bottom: 2,
        right: 2,
        child: Container(
          width: indicatorSize,
          height: indicatorSize,
          decoration: BoxDecoration(
            color: widget.winCondition == WinCondition.ownCamp
                ? _theme.player1Color.withAlpha(127)
                : _theme.player2Color.withAlpha(127),
            shape: BoxShape.circle,
          ),
        ),
      );
      // row max (player 2 camp) -> objective depends on winCondition
    } else if (pos.row == gameState.boardSize - 1) {
      zoneIndicator = Positioned(
        top: 2,
        right: 2,
        child: Container(
          width: indicatorSize,
          height: indicatorSize,
          decoration: BoxDecoration(
            color: widget.winCondition == WinCondition.ownCamp
                ? _theme.player2Color.withAlpha(127)
                : _theme.player1Color.withAlpha(127),
            shape: BoxShape.circle,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _handleCellTap(pos),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            color: cellColor,
            border: Border.all(color: _theme.boardBorder, width: 0.5),
          ),
          child: Stack(
            children: [
              ?zoneIndicator,
              if (piece != null) _buildPiece(piece),
              if (isValidMove && piece == null)
                Center(
                  child: Container(
                    width: _cellSize * 0.3,
                    height: _cellSize * 0.3,
                    decoration: BoxDecoration(
                      color: _theme.validMoveColor.withAlpha(127),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPiece(Piece piece) {
    if (piece.type == PieceType.nexus) {
      return Center(child: _buildNexus(_nexusSize));
    }

    final color = piece.owner == Player.player1
        ? _theme.player1Color
        : _theme.player2Color;
    final isSelected = selectedPawn == piece;

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isSelected ? _pawnSelectedSize : _pawnSize,
        height: isSelected ? _pawnSelectedSize : _pawnSize,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? _theme.selectedColor : Colors.white,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _theme.shadowColor,
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class HexagonPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;

  HexagonPainter({required this.fillColor, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = _createHexagonPath(size);

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  Path _createHexagonPath(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(w * 0.25, 0);
    path.lineTo(w * 0.75, 0);
    path.lineTo(w, h * 0.5);
    path.lineTo(w * 0.75, h);
    path.lineTo(w * 0.25, h);
    path.lineTo(0, h * 0.5);
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(covariant HexagonPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor;
  }
}
