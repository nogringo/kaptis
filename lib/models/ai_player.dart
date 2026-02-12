import 'dart:math';
import 'game_state.dart';

class AIPlayer {
  final Random _random = Random();

  /// Calcule le meilleur coup pour le Bouddha
  Position? getBestBuddhaMove(GameState state) {
    final validMoves = state.getValidBuddhaMoves();
    if (validMoves.isEmpty) return null;

    // Évaluer chaque mouvement
    final scoredMoves = <MapEntry<Position, int>>[];

    for (final move in validMoves) {
      int score = _evaluateBuddhaMove(state, move);
      scoredMoves.add(MapEntry(move, score));
    }

    // Trier par score décroissant
    scoredMoves.sort((a, b) => b.value.compareTo(a.value));

    // Prendre le meilleur coup (avec un peu d'aléatoire parmi les meilleurs)
    final bestScore = scoredMoves.first.value;
    final bestMoves = scoredMoves.where((m) => m.value == bestScore).toList();

    return bestMoves[_random.nextInt(bestMoves.length)].key;
  }

  /// Calcule le meilleur coup pour un pion
  (Piece, Position)? getBestPawnMove(GameState state) {
    final pawns = state.getPawns(Player.player2);
    final allMoves = <(Piece, Position, int)>[];

    for (final pawn in pawns) {
      final moves = state.getValidPawnMoves(pawn);
      for (final move in moves) {
        final score = _evaluatePawnMove(state, pawn, move);
        allMoves.add((pawn, move, score));
      }
    }

    if (allMoves.isEmpty) return null;

    // Trier par score décroissant
    allMoves.sort((a, b) => b.$3.compareTo(a.$3));

    // Prendre le meilleur coup
    final bestScore = allMoves.first.$3;
    final bestMoves = allMoves.where((m) => m.$3 == bestScore).toList();
    final chosen = bestMoves[_random.nextInt(bestMoves.length)];

    return (chosen.$1, chosen.$2);
  }

  /// Évalue un mouvement du Bouddha pour l'IA (Player 2)
  int _evaluateBuddhaMove(GameState state, Position move) {
    int score = 0;

    // L'IA veut amener le Bouddha vers la ligne boardSize-1 (sa ligne de victoire)
    // Plus on est proche de cette ligne, mieux c'est
    score += move.row * 10;

    // Victoire immédiate
    if (move.row == state.boardSize - 1) {
      return 1000;
    }

    // Éviter de le rapprocher de la ligne 0 (victoire adversaire)
    if (move.row == 1) {
      score -= 20;
    }
    if (move.row == 0) {
      return -1000; // Ne jamais faire ça
    }

    // Préférer le centre (plus de mobilité)
    final center = state.boardSize ~/ 2;
    final distanceFromCenter = (move.col - center).abs();
    score -= distanceFromCenter * 2;

    // Évaluer la mobilité après ce mouvement
    final tempState = state.moveBuddha(move);
    final futureMoves = tempState.getValidBuddhaMoves();
    score += futureMoves.length * 3;

    return score;
  }

  /// Évalue un mouvement de pion pour l'IA
  int _evaluatePawnMove(GameState state, Piece pawn, Position move) {
    int score = 0;
    final buddhaPos = state.buddha.position;

    // Simuler le mouvement
    final newState = _simulatePawnMove(state, pawn, move);

    // Vérifier si ça bloque le Bouddha (victoire!)
    if (newState.isBuddhaBlocked()) {
      return 500;
    }

    // Réduire la mobilité du Bouddha
    final currentBuddhaMoves = state.getValidBuddhaMoves().length;
    final newBuddhaMoves = newState.getValidBuddhaMoves().length;
    score += (currentBuddhaMoves - newBuddhaMoves) * 15;

    // Bloquer les chemins vers la ligne 0 (ligne adverse)
    if (_blocksPathToRow(state, move, 0)) {
      score += 25;
    }

    // Se positionner près du Bouddha pour le contrôler
    final distanceToBuddha = _manhattanDistance(move, buddhaPos);
    if (distanceToBuddha <= 2) {
      score += 10;
    }

    // Préférer les positions qui créent des lignes de blocage
    score += _countBlockingPotential(state, move) * 5;

    // Éviter de trop s'éloigner du centre
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

    // Vérifier si le pion est entre le Bouddha et la ligne cible
    if (pawnPos.col == buddhaPos.col) {
      if (targetRow < buddhaPos.row) {
        return pawnPos.row < buddhaPos.row && pawnPos.row >= targetRow;
      }
    }

    // Vérifier les diagonales
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

    // Compter combien de directions du Bouddha cette position bloque
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
