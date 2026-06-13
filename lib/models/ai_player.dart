import 'dart:math';
import 'game_state.dart';

enum AIDifficulty { easy, normal, hard }

class AIPlayer {
  final Random _random = Random();
  AIDifficulty difficulty;

  AIPlayer({this.difficulty = AIDifficulty.normal});

  /// Calculates the best move for the Nexus
  Position? getBestNexusMove(GameState state) {
    final validMoves = state.getValidNexusMoves();
    if (validMoves.isEmpty) return null;

    switch (difficulty) {
      case AIDifficulty.easy:
        return _getEasyNexusMove(state, validMoves);
      case AIDifficulty.normal:
        return _getNormalNexusMove(state, validMoves);
      case AIDifficulty.hard:
        return _getHardNexusMove(state, validMoves);
    }
  }

  /// Calculates the best move for a pawn
  (Piece, Position)? getBestPawnMove(GameState state) {
    final pawns = state.getPawns(Player.player2);
    final allMoves = <(Piece, Position)>[];

    for (final pawn in pawns) {
      final moves = state.getValidPawnMoves(pawn);
      for (final move in moves) {
        allMoves.add((pawn, move));
      }
    }

    if (allMoves.isEmpty) return null;

    switch (difficulty) {
      case AIDifficulty.easy:
        return _getEasyPawnMove(state, allMoves);
      case AIDifficulty.normal:
        return _getNormalPawnMove(state, allMoves);
      case AIDifficulty.hard:
        return _getHardPawnMove(state, allMoves);
    }
  }

  // ============== EASY LEVEL ==============

  Position _getEasyNexusMove(GameState state, List<Position> validMoves) {
    // 1. Look for a winning move (P2 wins)
    for (final move in validMoves) {
      if (_isWinningMoveForAI(state, move)) {
        return move;
      }
    }

    // 2. Avoid losing moves (giving the win to P1)
    List<Position> safeMoves;
    if (state.winCondition == WinCondition.ownCamp) {
      // P1 wins if the Nexus reaches row 0
      safeMoves = validMoves.where((m) => m.row != 0).toList();
    } else {
      // opponentCamp: P1 wins if the Nexus reaches maxRow
      if (state.gameMode == GameMode.hexagonal) {
        safeMoves = validMoves.where((m) {
          final maxRow = GameState.hexColumnHeights[m.col] - 1;
          return m.row != maxRow;
        }).toList();
      } else {
        safeMoves = validMoves
            .where((m) => m.row != state.boardSize - 1)
            .toList();
      }
    }

    // If all moves are losing, play randomly
    if (safeMoves.isEmpty) {
      return validMoves[_random.nextInt(validMoves.length)];
    }

    // 3. Play randomly among the safe moves
    return safeMoves[_random.nextInt(safeMoves.length)];
  }

  /// Checks if a Nexus move makes the AI (P2) win
  bool _isWinningMoveForAI(GameState state, Position move) {
    if (state.winCondition == WinCondition.ownCamp) {
      // P2 wins if the Nexus reaches maxRow
      if (state.gameMode == GameMode.hexagonal) {
        final maxRow = GameState.hexColumnHeights[move.col] - 1;
        return move.row == maxRow;
      } else {
        return move.row == state.boardSize - 1;
      }
    } else {
      // opponentCamp: P2 wins if the Nexus reaches row 0
      return move.row == 0;
    }
  }

  (Piece, Position)? _getEasyPawnMove(
    GameState state,
    List<(Piece, Position)> allMoves,
  ) {
    // 1. Look for a move that blocks the Nexus (win)
    for (final move in allMoves) {
      final newState = _simulatePawnMove(state, move.$1, move.$2);
      if (newState.isNexusBlocked()) {
        return move;
      }
    }

    // 2. Play randomly
    return allMoves[_random.nextInt(allMoves.length)];
  }

  // ============== NORMAL LEVEL ==============

  Position _getNormalNexusMove(GameState state, List<Position> validMoves) {
    final scoredMoves = <MapEntry<Position, int>>[];

    for (final move in validMoves) {
      int score = _evaluateNexusMove(state, move);
      scoredMoves.add(MapEntry(move, score));
    }

    scoredMoves.sort((a, b) => b.value.compareTo(a.value));

    final bestScore = scoredMoves.first.value;
    final bestMoves = scoredMoves.where((m) => m.value == bestScore).toList();

    return bestMoves[_random.nextInt(bestMoves.length)].key;
  }

  (Piece, Position)? _getNormalPawnMove(
    GameState state,
    List<(Piece, Position)> allMoves,
  ) {
    final scoredMoves = <(Piece, Position, int)>[];

    for (final move in allMoves) {
      final score = _evaluatePawnMove(state, move.$1, move.$2);
      scoredMoves.add((move.$1, move.$2, score));
    }

    scoredMoves.sort((a, b) => b.$3.compareTo(a.$3));

    final bestScore = scoredMoves.first.$3;
    final bestMoves = scoredMoves.where((m) => m.$3 == bestScore).toList();
    final chosen = bestMoves[_random.nextInt(bestMoves.length)];

    return (chosen.$1, chosen.$2);
  }

  // ============== HARD LEVEL ==============

  Position _getHardNexusMove(GameState state, List<Position> validMoves) {
    final scoredMoves = <MapEntry<Position, int>>[];

    for (final move in validMoves) {
      // Simulate the move and evaluate with minimax.
      // moveNexus does not change currentPlayer: it is still the AI's (P2)
      // turn, which must then move a pawn -> we stay maximizing.
      final newState = state.moveNexus(move);
      int score = _minimax(newState, 3, true, -10000, 10000);
      scoredMoves.add(MapEntry(move, score));
    }

    scoredMoves.sort((a, b) => b.value.compareTo(a.value));
    return scoredMoves.first.key;
  }

  (Piece, Position)? _getHardPawnMove(
    GameState state,
    List<(Piece, Position)> allMoves,
  ) {
    final scoredMoves = <(Piece, Position, int)>[];

    for (final move in allMoves) {
      final newState = _simulatePawnMove(state, move.$1, move.$2);
      int score = _minimax(newState, 3, false, -10000, 10000);
      scoredMoves.add((move.$1, move.$2, score));
    }

    scoredMoves.sort((a, b) => b.$3.compareTo(a.$3));
    return (scoredMoves.first.$1, scoredMoves.first.$2);
  }

  /// Minimax algorithm with alpha-beta pruning
  int _minimax(
    GameState state,
    int depth,
    bool isMaximizing,
    int alpha,
    int beta,
  ) {
    // Terminal conditions
    if (state.winner == Player.player2) return 1000 + depth;
    if (state.winner == Player.player1) return -1000 - depth;
    if (depth == 0) return _evaluateState(state);

    if (isMaximizing) {
      // AI's turn (Player 2)
      int maxEval = -10000;

      if (state.phase == GamePhase.moveNexus) {
        for (final move in state.getValidNexusMoves()) {
          final newState = state.moveNexus(move);
          int eval = _minimax(newState, depth - 1, true, alpha, beta);
          maxEval = max(maxEval, eval);
          alpha = max(alpha, eval);
          if (beta <= alpha) break;
        }
      } else {
        for (final pawn in state.getPawns(Player.player2)) {
          for (final move in state.getValidPawnMoves(pawn)) {
            final newState = state.movePawn(pawn, move);
            int eval = _minimax(newState, depth - 1, false, alpha, beta);
            maxEval = max(maxEval, eval);
            alpha = max(alpha, eval);
            if (beta <= alpha) break;
          }
        }
      }

      return maxEval;
    } else {
      // Player's turn (Player 1)
      int minEval = 10000;

      if (state.phase == GamePhase.moveNexus) {
        for (final move in state.getValidNexusMoves()) {
          final newState = state.moveNexus(move);
          int eval = _minimax(newState, depth - 1, false, alpha, beta);
          minEval = min(minEval, eval);
          beta = min(beta, eval);
          if (beta <= alpha) break;
        }
      } else {
        for (final pawn in state.getPawns(Player.player1)) {
          for (final move in state.getValidPawnMoves(pawn)) {
            final newState = state.movePawn(pawn, move);
            int eval = _minimax(newState, depth - 1, true, alpha, beta);
            minEval = min(minEval, eval);
            beta = min(beta, eval);
            if (beta <= alpha) break;
          }
        }
      }

      return minEval;
    }
  }

  /// Evaluates the game state for the AI
  int _evaluateState(GameState state) {
    int score = 0;
    final nexusPos = state.nexus.position;

    // In ownCamp mode: P2 wants to bring the Nexus down (high row)
    // In opponentCamp mode: P2 wants to bring the Nexus up (row 0)
    final isOpponentCamp = state.winCondition == WinCondition.opponentCamp;

    if (state.gameMode == GameMode.hexagonal) {
      // Hexagonal mode
      final maxRow = GameState.hexColumnHeights[nexusPos.col] - 1;

      if (isOpponentCamp) {
        // P2 wants to bring the Nexus up (row 0)
        score += (maxRow - nexusPos.row) * 15;
      } else {
        // P2 wants to bring the Nexus down
        score += nexusPos.row * 15;
      }

      // Nexus mobility
      final nexusMovesCount = state.getValidNexusMoves().length;
      if (state.currentPlayer == Player.player2) {
        score += nexusMovesCount * 5;
      } else {
        score -= nexusMovesCount * 5;
      }

      // Center control (col 3 is the center)
      final centerCol = 3;
      final distFromCenter = (nexusPos.col - centerCol).abs();
      score -= distFromCenter * 3;

      // Position of the AI's pawns
      for (final pawn in state.getPawns(Player.player2)) {
        final distToNexus = _hexDistance(pawn.position, nexusPos);
        if (distToNexus <= 2) score += 8;
      }

      // Position of the opponent's pawns
      for (final pawn in state.getPawns(Player.player1)) {
        final distToNexus = _hexDistance(pawn.position, nexusPos);
        if (distToNexus <= 2) score -= 8;
      }
    } else {
      // Square mode
      if (isOpponentCamp) {
        // P2 wants to bring the Nexus up (row 0)
        score += (state.boardSize - 1 - nexusPos.row) * 15;
      } else {
        // P2 wants to bring the Nexus down
        score += nexusPos.row * 15;
      }

      // Nexus mobility
      final nexusMovesCount = state.getValidNexusMoves().length;
      if (state.currentPlayer == Player.player2) {
        score += nexusMovesCount * 5;
      } else {
        score -= nexusMovesCount * 5;
      }

      // Center control
      final center = state.boardSize ~/ 2;
      final distFromCenter =
          (nexusPos.row - center).abs() + (nexusPos.col - center).abs();
      score -= distFromCenter * 3;

      // Position of the AI's pawns
      for (final pawn in state.getPawns(Player.player2)) {
        final distToNexus = _manhattanDistance(pawn.position, nexusPos);
        if (distToNexus <= 2) score += 8;
      }

      // Position of the opponent's pawns (penalty if near the Nexus)
      for (final pawn in state.getPawns(Player.player1)) {
        final distToNexus = _manhattanDistance(pawn.position, nexusPos);
        if (distToNexus <= 2) score -= 8;
      }
    }

    return score;
  }

  // ============== COMMON FUNCTIONS ==============

  int _evaluateNexusMove(GameState state, Position move) {
    int score = 0;
    final isOpponentCamp = state.winCondition == WinCondition.opponentCamp;

    if (state.gameMode == GameMode.hexagonal) {
      // Hexagonal mode
      final colHeight = GameState.hexColumnHeights[move.col];
      final maxRow = colHeight - 1;

      if (isOpponentCamp) {
        // P2 wants to go up (row 0)
        score += (maxRow - move.row) * 10;

        // Win if it reaches the top
        if (move.row == 0) {
          return 1000;
        }

        // Penalty if near the bottom (opponent win)
        if (move.row == maxRow - 1) {
          score -= 20;
        }
        if (move.row == maxRow) {
          return -1000;
        }
      } else {
        // ownCamp: P2 wants to go down
        score += move.row * 10;

        // Win if it reaches the bottom of the column
        if (move.row == maxRow) {
          return 1000;
        }

        // Penalty if near the top
        if (move.row == 1) {
          score -= 20;
        }
        if (move.row == 0) {
          return -1000;
        }
      }

      // Prefer the center (column 3)
      final distanceFromCenter = (move.col - 3).abs();
      score -= distanceFromCenter * 2;

      final tempState = state.moveNexus(move);
      final futureMoves = tempState.getValidNexusMoves();
      score += futureMoves.length * 3;
    } else {
      // Square mode
      if (isOpponentCamp) {
        // P2 wants to go up (row 0)
        score += (state.boardSize - 1 - move.row) * 10;

        // Win if it reaches the top
        if (move.row == 0) {
          return 1000;
        }

        // Penalty if near the bottom (opponent win)
        if (move.row == state.boardSize - 2) {
          score -= 20;
        }
        if (move.row == state.boardSize - 1) {
          return -1000;
        }
      } else {
        // ownCamp: P2 wants to go down
        score += move.row * 10;

        if (move.row == state.boardSize - 1) {
          return 1000;
        }

        if (move.row == 1) {
          score -= 20;
        }
        if (move.row == 0) {
          return -1000;
        }
      }

      final center = state.boardSize ~/ 2;
      final distanceFromCenter = (move.col - center).abs();
      score -= distanceFromCenter * 2;

      final tempState = state.moveNexus(move);
      final futureMoves = tempState.getValidNexusMoves();
      score += futureMoves.length * 3;
    }

    return score;
  }

  int _evaluatePawnMove(GameState state, Piece pawn, Position move) {
    int score = 0;
    final nexusPos = state.nexus.position;
    final isOpponentCamp = state.winCondition == WinCondition.opponentCamp;

    final newState = _simulatePawnMove(state, pawn, move);

    if (newState.isNexusBlocked()) {
      return 500;
    }

    final currentNexusMoves = state.getValidNexusMoves().length;
    final newNexusMoves = newState.getValidNexusMoves().length;
    score += (currentNexusMoves - newNexusMoves) * 15;

    // Block the path to P1's winning row
    // In ownCamp: P1 wins at row 0
    // In opponentCamp: P1 wins at maxRow
    // In hexagonal mode the last row depends on the Nexus column.
    final int maxRow = state.gameMode == GameMode.hexagonal
        ? GameState.hexColumnHeights[nexusPos.col] - 1
        : state.boardSize - 1;
    final targetRow = isOpponentCamp ? maxRow : 0;
    if (_blocksPathToRow(state, move, targetRow)) {
      score += 25;
    }

    final distanceToNexus = _getDistance(state, move, nexusPos);
    if (distanceToNexus <= 2) {
      score += 10;
    }

    score += _countBlockingPotential(state, move) * 5;

    if (state.gameMode == GameMode.hexagonal) {
      // Hexagonal mode: prefer the center (column 3)
      final distanceFromCenter = (move.col - 3).abs();
      score -= distanceFromCenter;
    } else {
      // Square mode
      final center = state.boardSize ~/ 2;
      final distanceFromCenter =
          (move.row - center).abs() + (move.col - center).abs();
      score -= distanceFromCenter;
    }

    return score;
  }

  GameState _simulatePawnMove(GameState state, Piece pawn, Position newPos) {
    final newPieces = state.pieces.map((p) {
      if (p == pawn) {
        return p.copyWith(position: newPos);
      }
      return p;
    }).toList();

    // The pawn is played by the AI (P2): after the move, it is P1's turn
    // to move the Nexus.
    final newState = GameState(
      boardSize: state.boardSize,
      pieces: newPieces,
      currentPlayer: Player.player1,
      phase: GamePhase.moveNexus,
      winner: null,
      gameMode: state.gameMode,
      winCondition: state.winCondition,
    );

    // If the move blocks the Nexus, the AI (P2) wins. Without this, minimax
    // would never see wins by blocking.
    if (newState.isNexusBlocked()) {
      return GameState(
        boardSize: state.boardSize,
        pieces: newPieces,
        currentPlayer: Player.player1,
        phase: GamePhase.moveNexus,
        winner: pawn.owner,
        gameMode: state.gameMode,
        winCondition: state.winCondition,
      );
    }

    return newState;
  }

  int _manhattanDistance(Position a, Position b) {
    return (a.row - b.row).abs() + (a.col - b.col).abs();
  }

  // Distance hexagonale (cube coordinates conversion)
  int _hexDistance(Position a, Position b) {
    // Convert offset coordinates to cube coordinates
    final ax = a.col;
    final az = a.row - (a.col - (a.col & 1)) ~/ 2;
    final ay = -ax - az;

    final bx = b.col;
    final bz = b.row - (b.col - (b.col & 1)) ~/ 2;
    final by = -bx - bz;

    return ((ax - bx).abs() + (ay - by).abs() + (az - bz).abs()) ~/ 2;
  }

  int _getDistance(GameState state, Position a, Position b) {
    if (state.gameMode == GameMode.hexagonal) {
      return _hexDistance(a, b);
    }
    return _manhattanDistance(a, b);
  }

  bool _blocksPathToRow(GameState state, Position pawnPos, int targetRow) {
    final nexusPos = state.nexus.position;

    if (state.gameMode == GameMode.hexagonal) {
      // Scan the 6 hex directions. The pawn blocks the path if it sits on a
      // ray whose first step moves the Nexus closer to the target row.
      for (int dir = 0; dir < 6; dir++) {
        final firstStep = state.getNextHexCell(nexusPos, dir);
        if (firstStep == null) continue;
        // Keep only directions heading toward the target row.
        final towardTarget =
            (firstStep.row - nexusPos.row) * (targetRow - nexusPos.row) > 0;
        if (!towardTarget) continue;

        Position? check = firstStep;
        while (check != null) {
          if (check == pawnPos) return true;
          check = state.getNextHexCell(check, dir);
        }
      }
      return false;
    }

    // Checks if the pawn is on the same column as the Nexus
    if (pawnPos.col == nexusPos.col) {
      if (targetRow < nexusPos.row) {
        // Nexus must go up
        return pawnPos.row < nexusPos.row && pawnPos.row >= targetRow;
      } else if (targetRow > nexusPos.row) {
        // Nexus must go down
        return pawnPos.row > nexusPos.row && pawnPos.row <= targetRow;
      }
    }

    // Checks the diagonals
    final rowDiff = pawnPos.row - nexusPos.row;
    final colDiff = pawnPos.col - nexusPos.col;
    if (rowDiff.abs() == colDiff.abs()) {
      if (targetRow < nexusPos.row && rowDiff < 0) {
        // Nexus must go up, pawn is above
        return true;
      } else if (targetRow > nexusPos.row && rowDiff > 0) {
        // Nexus must go down, pawn is below
        return true;
      }
    }

    return false;
  }

  int _countBlockingPotential(GameState state, Position pos) {
    int count = 0;
    final nexusPos = state.nexus.position;

    if (state.gameMode == GameMode.hexagonal) {
      // Hexagonal mode: checks the 6 directions
      for (int dir = 0; dir < 6; dir++) {
        Position? check = state.getNextHexCell(nexusPos, dir);

        while (check != null) {
          if (check == pos) {
            count++;
            break;
          }
          check = state.getNextHexCell(check, dir);
        }
      }
    } else {
      // Square mode: checks the 8 directions
      for (final dir in GameState.directions) {
        Position check = nexusPos + dir;
        while (state.isValidPosition(check)) {
          if (check == pos) {
            count++;
            break;
          }
          check = check + dir;
        }
      }
    }

    return count;
  }
}
