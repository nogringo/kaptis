enum Player { player1, player2 }

enum PieceType { pawn, buddha }

enum GamePhase { moveBuddha, movePawn }

class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      other is Position && other.row == row && other.col == col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  Position operator +(Position other) =>
      Position(row + other.row, col + other.col);
}

class Piece {
  final PieceType type;
  final Player? owner;
  Position position;

  Piece({required this.type, this.owner, required this.position});

  Piece copyWith({Position? position}) {
    return Piece(type: type, owner: owner, position: position ?? this.position);
  }
}

class GameState {
  final int boardSize;
  final List<Piece> pieces;
  final Player currentPlayer;
  final GamePhase phase;
  final Player? winner;

  GameState({
    required this.boardSize,
    required this.pieces,
    required this.currentPlayer,
    required this.phase,
    this.winner,
  });

  factory GameState.initial({int size = 5}) {
    assert(size == 5 || size == 7, 'Board size must be 5 or 7');

    final pieces = <Piece>[];
    final center = size ~/ 2;

    // Bouddha au centre
    pieces.add(
      Piece(
        type: PieceType.buddha,
        owner: null,
        position: Position(center, center),
      ),
    );

    // Pions joueur 1 (en haut, ligne 0)
    for (int col = 0; col < size; col++) {
      pieces.add(
        Piece(
          type: PieceType.pawn,
          owner: Player.player1,
          position: Position(0, col),
        ),
      );
    }

    // Pions joueur 2 (en bas, dernière ligne)
    for (int col = 0; col < size; col++) {
      pieces.add(
        Piece(
          type: PieceType.pawn,
          owner: Player.player2,
          position: Position(size - 1, col),
        ),
      );
    }

    return GameState(
      boardSize: size,
      pieces: pieces,
      currentPlayer: Player.player1,
      phase: GamePhase.moveBuddha,
      winner: null,
    );
  }

  Piece get buddha => pieces.firstWhere((p) => p.type == PieceType.buddha);

  List<Piece> getPawns(Player player) => pieces
      .where((p) => p.type == PieceType.pawn && p.owner == player)
      .toList();

  Piece? getPieceAt(Position pos) {
    for (final piece in pieces) {
      if (piece.position == pos) return piece;
    }
    return null;
  }

  bool isValidPosition(Position pos) {
    return pos.row >= 0 &&
        pos.row < boardSize &&
        pos.col >= 0 &&
        pos.col < boardSize;
  }

  // Directions possibles (8 directions)
  static const List<Position> directions = [
    Position(-1, 0), // haut
    Position(1, 0), // bas
    Position(0, -1), // gauche
    Position(0, 1), // droite
    Position(-1, -1), // diag haut-gauche
    Position(-1, 1), // diag haut-droite
    Position(1, -1), // diag bas-gauche
    Position(1, 1), // diag bas-droite
  ];

  // Mouvements valides pour le Bouddha (1 case dans toutes directions)
  List<Position> getValidBuddhaMoves() {
    final buddhaPos = buddha.position;
    final validMoves = <Position>[];

    for (final dir in directions) {
      final newPos = buddhaPos + dir;
      if (isValidPosition(newPos) && getPieceAt(newPos) == null) {
        validMoves.add(newPos);
      }
    }

    return validMoves;
  }

  // Mouvements valides pour un pion (jusqu'au bout ou jusqu'à un obstacle)
  List<Position> getValidPawnMoves(Piece pawn) {
    if (pawn.type != PieceType.pawn) return [];

    final validMoves = <Position>[];

    for (final dir in directions) {
      Position lastValid = pawn.position;
      Position current = pawn.position + dir;

      while (isValidPosition(current) && getPieceAt(current) == null) {
        lastValid = current;
        current = current + dir;
      }

      // Le pion doit se déplacer le plus loin possible
      if (lastValid != pawn.position) {
        validMoves.add(lastValid);
      }
    }

    return validMoves;
  }

  // Vérifie si le Bouddha est bloqué
  bool isBuddhaBlocked() {
    return getValidBuddhaMoves().isEmpty;
  }

  // Vérifie si un joueur a gagné
  Player? checkWinner() {
    final buddhaPos = buddha.position;

    // Victoire si le Bouddha est sur sa propre ligne de départ
    if (buddhaPos.row == 0) {
      return Player.player1; // Joueur 1 a ramené le Bouddha sur son camp
    }
    if (buddhaPos.row == boardSize - 1) {
      return Player.player2; // Joueur 2 a ramené le Bouddha sur son camp
    }

    return null;
  }

  // Vérifie si le joueur actuel peut jouer
  bool canCurrentPlayerPlay() {
    if (phase == GamePhase.moveBuddha) {
      return getValidBuddhaMoves().isNotEmpty;
    } else {
      final pawns = getPawns(currentPlayer);
      for (final pawn in pawns) {
        if (getValidPawnMoves(pawn).isNotEmpty) {
          return true;
        }
      }
      return false;
    }
  }

  GameState moveBuddha(Position newPos) {
    if (phase != GamePhase.moveBuddha) return this;
    if (!getValidBuddhaMoves().contains(newPos)) return this;

    final newPieces = pieces.map((p) {
      if (p.type == PieceType.buddha) {
        return p.copyWith(position: newPos);
      }
      return p;
    }).toList();

    final newState = GameState(
      boardSize: boardSize,
      pieces: newPieces,
      currentPlayer: currentPlayer,
      phase: GamePhase.movePawn,
      winner: null,
    );

    // Vérifier victoire après déplacement du Bouddha
    final winner = newState.checkWinner();
    if (winner != null) {
      return GameState(
        boardSize: boardSize,
        pieces: newPieces,
        currentPlayer: currentPlayer,
        phase: GamePhase.movePawn,
        winner: winner,
      );
    }

    return newState;
  }

  GameState movePawn(Piece pawn, Position newPos) {
    if (phase != GamePhase.movePawn) return this;
    if (pawn.owner != currentPlayer) return this;
    if (!getValidPawnMoves(pawn).contains(newPos)) return this;

    final newPieces = pieces.map((p) {
      if (p == pawn) {
        return p.copyWith(position: newPos);
      }
      return p;
    }).toList();

    final nextPlayer = currentPlayer == Player.player1
        ? Player.player2
        : Player.player1;

    final newState = GameState(
      boardSize: boardSize,
      pieces: newPieces,
      currentPlayer: nextPlayer,
      phase: GamePhase.moveBuddha,
      winner: null,
    );

    // Vérifier si le Bouddha est bloqué (victoire pour le joueur actuel)
    if (newState.isBuddhaBlocked()) {
      return GameState(
        boardSize: boardSize,
        pieces: newPieces,
        currentPlayer: nextPlayer,
        phase: GamePhase.moveBuddha,
        winner: currentPlayer,
      );
    }

    return newState;
  }
}
