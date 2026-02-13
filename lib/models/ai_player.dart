import 'dart:math';
import 'game_state.dart';

enum AIDifficulty { easy, normal, hard }

class AIPlayer {
  final Random _random = Random();
  AIDifficulty difficulty;

  AIPlayer({this.difficulty = AIDifficulty.normal});

  /// Calcule le meilleur coup pour le Bouddha
  Position? getBestBuddhaMove(GameState state) {
    final validMoves = state.getValidBuddhaMoves();
    if (validMoves.isEmpty) return null;

    switch (difficulty) {
      case AIDifficulty.easy:
        return _getEasyBuddhaMove(state, validMoves);
      case AIDifficulty.normal:
        return _getNormalBuddhaMove(state, validMoves);
      case AIDifficulty.hard:
        return _getHardBuddhaMove(state, validMoves);
    }
  }

  /// Calcule le meilleur coup pour un pion
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

  // ============== NIVEAU FACILE ==============

  Position _getEasyBuddhaMove(GameState state, List<Position> validMoves) {
    // 70% de chance de jouer au hasard, 30% de jouer intelligemment
    if (_random.nextDouble() < 0.7) {
      return validMoves[_random.nextInt(validMoves.length)];
    }

    // Éviter juste la victoire adverse
    // En mode ownCamp: P1 gagne si row == 0, donc éviter row 0
    // En mode opponentCamp: P1 gagne si row == maxRow, donc éviter maxRow
    List<Position> safeMoves;
    if (state.winCondition == WinCondition.ownCamp) {
      safeMoves = validMoves.where((m) => m.row != 0).toList();
    } else {
      // opponentCamp: éviter les rows max (victoire de P1)
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
    if (safeMoves.isNotEmpty) {
      return safeMoves[_random.nextInt(safeMoves.length)];
    }

    return validMoves[_random.nextInt(validMoves.length)];
  }

  (Piece, Position)? _getEasyPawnMove(
    GameState state,
    List<(Piece, Position)> allMoves,
  ) {
    // Jouer complètement au hasard
    return allMoves[_random.nextInt(allMoves.length)];
  }

  // ============== NIVEAU NORMAL ==============

  Position _getNormalBuddhaMove(GameState state, List<Position> validMoves) {
    final scoredMoves = <MapEntry<Position, int>>[];

    for (final move in validMoves) {
      int score = _evaluateBuddhaMove(state, move);
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

  // ============== NIVEAU DIFFICILE ==============

  Position _getHardBuddhaMove(GameState state, List<Position> validMoves) {
    final scoredMoves = <MapEntry<Position, int>>[];

    for (final move in validMoves) {
      // Simuler le coup et évaluer avec minimax
      final newState = state.moveBuddha(move);
      int score = _minimax(newState, 3, false, -10000, 10000);
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

  /// Algorithme Minimax avec élagage alpha-beta
  int _minimax(
    GameState state,
    int depth,
    bool isMaximizing,
    int alpha,
    int beta,
  ) {
    // Conditions terminales
    if (state.winner == Player.player2) return 1000 + depth;
    if (state.winner == Player.player1) return -1000 - depth;
    if (depth == 0) return _evaluateState(state);

    if (isMaximizing) {
      // Tour de l'IA (Player 2)
      int maxEval = -10000;

      if (state.phase == GamePhase.moveBuddha) {
        for (final move in state.getValidBuddhaMoves()) {
          final newState = state.moveBuddha(move);
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
      // Tour du joueur (Player 1)
      int minEval = 10000;

      if (state.phase == GamePhase.moveBuddha) {
        for (final move in state.getValidBuddhaMoves()) {
          final newState = state.moveBuddha(move);
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

  /// Évalue l'état du jeu pour l'IA
  int _evaluateState(GameState state) {
    int score = 0;
    final buddhaPos = state.buddha.position;

    // En mode ownCamp: P2 veut amener le Buddha vers le bas (row élevée)
    // En mode opponentCamp: P2 veut amener le Buddha vers le haut (row 0)
    final isOpponentCamp = state.winCondition == WinCondition.opponentCamp;

    if (state.gameMode == GameMode.hexagonal) {
      // Mode hexagonal
      final maxRow = GameState.hexColumnHeights[buddhaPos.col] - 1;

      if (isOpponentCamp) {
        // P2 veut amener le Buddha vers le haut (row 0)
        score += (maxRow - buddhaPos.row) * 15;
      } else {
        // P2 veut amener le Buddha vers le bas
        score += buddhaPos.row * 15;
      }

      // Mobilité du Bouddha
      final buddhaMovesCount = state.getValidBuddhaMoves().length;
      if (state.currentPlayer == Player.player2) {
        score += buddhaMovesCount * 5;
      } else {
        score -= buddhaMovesCount * 5;
      }

      // Contrôle du centre (col 3 est le centre)
      final centerCol = 3;
      final distFromCenter = (buddhaPos.col - centerCol).abs();
      score -= distFromCenter * 3;

      // Position des pions de l'IA
      for (final pawn in state.getPawns(Player.player2)) {
        final distToBuddha = _hexDistance(pawn.position, buddhaPos);
        if (distToBuddha <= 2) score += 8;
      }

      // Position des pions adverses
      for (final pawn in state.getPawns(Player.player1)) {
        final distToBuddha = _hexDistance(pawn.position, buddhaPos);
        if (distToBuddha <= 2) score -= 8;
      }
    } else {
      // Mode carré
      if (isOpponentCamp) {
        // P2 veut amener le Buddha vers le haut (row 0)
        score += (state.boardSize - 1 - buddhaPos.row) * 15;
      } else {
        // P2 veut amener le Buddha vers le bas
        score += buddhaPos.row * 15;
      }

      // Mobilité du Bouddha
      final buddhaMovesCount = state.getValidBuddhaMoves().length;
      if (state.currentPlayer == Player.player2) {
        score += buddhaMovesCount * 5;
      } else {
        score -= buddhaMovesCount * 5;
      }

      // Contrôle du centre
      final center = state.boardSize ~/ 2;
      final distFromCenter =
          (buddhaPos.row - center).abs() + (buddhaPos.col - center).abs();
      score -= distFromCenter * 3;

      // Position des pions de l'IA
      for (final pawn in state.getPawns(Player.player2)) {
        final distToBuddha = _manhattanDistance(pawn.position, buddhaPos);
        if (distToBuddha <= 2) score += 8;
      }

      // Position des pions adverses (pénalité si proches du Bouddha)
      for (final pawn in state.getPawns(Player.player1)) {
        final distToBuddha = _manhattanDistance(pawn.position, buddhaPos);
        if (distToBuddha <= 2) score -= 8;
      }
    }

    return score;
  }

  // ============== FONCTIONS COMMUNES ==============

  int _evaluateBuddhaMove(GameState state, Position move) {
    int score = 0;
    final isOpponentCamp = state.winCondition == WinCondition.opponentCamp;

    if (state.gameMode == GameMode.hexagonal) {
      // Mode hexagonal
      final colHeight = GameState.hexColumnHeights[move.col];
      final maxRow = colHeight - 1;

      if (isOpponentCamp) {
        // P2 veut aller vers le haut (row 0)
        score += (maxRow - move.row) * 10;

        // Victoire si atteint le haut
        if (move.row == 0) {
          return 1000;
        }

        // Pénalité si proche du bas (victoire adverse)
        if (move.row == maxRow - 1) {
          score -= 20;
        }
        if (move.row == maxRow) {
          return -1000;
        }
      } else {
        // ownCamp: P2 veut aller vers le bas
        score += move.row * 10;

        // Victoire si atteint le bas de la colonne
        if (move.row == maxRow) {
          return 1000;
        }

        // Pénalité si proche du haut
        if (move.row == 1) {
          score -= 20;
        }
        if (move.row == 0) {
          return -1000;
        }
      }

      // Préférer le centre (colonne 3)
      final distanceFromCenter = (move.col - 3).abs();
      score -= distanceFromCenter * 2;

      final tempState = state.moveBuddha(move);
      final futureMoves = tempState.getValidBuddhaMoves();
      score += futureMoves.length * 3;
    } else {
      // Mode carré
      if (isOpponentCamp) {
        // P2 veut aller vers le haut (row 0)
        score += (state.boardSize - 1 - move.row) * 10;

        // Victoire si atteint le haut
        if (move.row == 0) {
          return 1000;
        }

        // Pénalité si proche du bas (victoire adverse)
        if (move.row == state.boardSize - 2) {
          score -= 20;
        }
        if (move.row == state.boardSize - 1) {
          return -1000;
        }
      } else {
        // ownCamp: P2 veut aller vers le bas
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

      final tempState = state.moveBuddha(move);
      final futureMoves = tempState.getValidBuddhaMoves();
      score += futureMoves.length * 3;
    }

    return score;
  }

  int _evaluatePawnMove(GameState state, Piece pawn, Position move) {
    int score = 0;
    final buddhaPos = state.buddha.position;
    final isOpponentCamp = state.winCondition == WinCondition.opponentCamp;

    final newState = _simulatePawnMove(state, pawn, move);

    if (newState.isBuddhaBlocked()) {
      return 500;
    }

    final currentBuddhaMoves = state.getValidBuddhaMoves().length;
    final newBuddhaMoves = newState.getValidBuddhaMoves().length;
    score += (currentBuddhaMoves - newBuddhaMoves) * 15;

    // Bloquer le chemin vers la row de victoire de P1
    // En ownCamp: P1 gagne à row 0
    // En opponentCamp: P1 gagne à maxRow
    final targetRow = isOpponentCamp ? state.boardSize - 1 : 0;
    if (_blocksPathToRow(state, move, targetRow)) {
      score += 25;
    }

    final distanceToBuddha = _getDistance(state, move, buddhaPos);
    if (distanceToBuddha <= 2) {
      score += 10;
    }

    score += _countBlockingPotential(state, move) * 5;

    if (state.gameMode == GameMode.hexagonal) {
      // Mode hexagonal : préférer le centre (colonne 3)
      final distanceFromCenter = (move.col - 3).abs();
      score -= distanceFromCenter;
    } else {
      // Mode carré
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

    return GameState(
      boardSize: state.boardSize,
      pieces: newPieces,
      currentPlayer: Player.player1,
      phase: GamePhase.moveBuddha,
      winner: null,
      gameMode: state.gameMode,
      winCondition: state.winCondition,
    );
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
    final buddhaPos = state.buddha.position;

    // Vérifie si le pion est sur la même colonne que le Buddha
    if (pawnPos.col == buddhaPos.col) {
      if (targetRow < buddhaPos.row) {
        // Buddha doit aller vers le haut
        return pawnPos.row < buddhaPos.row && pawnPos.row >= targetRow;
      } else if (targetRow > buddhaPos.row) {
        // Buddha doit aller vers le bas
        return pawnPos.row > buddhaPos.row && pawnPos.row <= targetRow;
      }
    }

    // Vérifie les diagonales
    final rowDiff = pawnPos.row - buddhaPos.row;
    final colDiff = pawnPos.col - buddhaPos.col;
    if (rowDiff.abs() == colDiff.abs()) {
      if (targetRow < buddhaPos.row && rowDiff < 0) {
        // Buddha doit aller vers le haut, pion est en haut
        return true;
      } else if (targetRow > buddhaPos.row && rowDiff > 0) {
        // Buddha doit aller vers le bas, pion est en bas
        return true;
      }
    }

    return false;
  }

  int _countBlockingPotential(GameState state, Position pos) {
    int count = 0;
    final buddhaPos = state.buddha.position;

    if (state.gameMode == GameMode.hexagonal) {
      // Mode hexagonal : vérifie les 6 directions
      for (int dir = 0; dir < 6; dir++) {
        Position? check = state.getNextHexCell(buddhaPos, dir);

        while (check != null) {
          if (check == pos) {
            count++;
            break;
          }
          check = state.getNextHexCell(check, dir);
        }
      }
    } else {
      // Mode carré : vérifie les 8 directions
      for (final dir in GameState.directions) {
        Position check = buddhaPos + dir;
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
