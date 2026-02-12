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
    final safeMoves = validMoves.where((m) => m.row != 0).toList();
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

    // Position du Bouddha (plus proche de la ligne de l'IA = mieux)
    score += buddhaPos.row * 15;

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

    return score;
  }

  // ============== FONCTIONS COMMUNES ==============

  int _evaluateBuddhaMove(GameState state, Position move) {
    int score = 0;

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

    final center = state.boardSize ~/ 2;
    final distanceFromCenter = (move.col - center).abs();
    score -= distanceFromCenter * 2;

    final tempState = state.moveBuddha(move);
    final futureMoves = tempState.getValidBuddhaMoves();
    score += futureMoves.length * 3;

    return score;
  }

  int _evaluatePawnMove(GameState state, Piece pawn, Position move) {
    int score = 0;
    final buddhaPos = state.buddha.position;

    final newState = _simulatePawnMove(state, pawn, move);

    if (newState.isBuddhaBlocked()) {
      return 500;
    }

    final currentBuddhaMoves = state.getValidBuddhaMoves().length;
    final newBuddhaMoves = newState.getValidBuddhaMoves().length;
    score += (currentBuddhaMoves - newBuddhaMoves) * 15;

    if (_blocksPathToRow(state, move, 0)) {
      score += 25;
    }

    final distanceToBuddha = _manhattanDistance(move, buddhaPos);
    if (distanceToBuddha <= 2) {
      score += 10;
    }

    score += _countBlockingPotential(state, move) * 5;

    final center = state.boardSize ~/ 2;
    final distanceFromCenter =
        (move.row - center).abs() + (move.col - center).abs();
    score -= distanceFromCenter;

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
    );
  }

  int _manhattanDistance(Position a, Position b) {
    return (a.row - b.row).abs() + (a.col - b.col).abs();
  }

  bool _blocksPathToRow(GameState state, Position pawnPos, int targetRow) {
    final buddhaPos = state.buddha.position;

    if (pawnPos.col == buddhaPos.col) {
      if (targetRow < buddhaPos.row) {
        return pawnPos.row < buddhaPos.row && pawnPos.row >= targetRow;
      }
    }

    final rowDiff = pawnPos.row - buddhaPos.row;
    final colDiff = pawnPos.col - buddhaPos.col;
    if (rowDiff.abs() == colDiff.abs() && rowDiff < 0) {
      return true;
    }

    return false;
  }

  int _countBlockingPotential(GameState state, Position pos) {
    int count = 0;
    final buddhaPos = state.buddha.position;

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

    return count;
  }
}
