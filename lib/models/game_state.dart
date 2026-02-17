enum Player { player1, player2 }

enum PieceType { pawn, nexus }

enum GamePhase { moveNexus, movePawn }

enum GameMode { square, hexagonal }

enum WinCondition { ownCamp, opponentCamp }

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

  Map<String, dynamic> toJson() => {'row': row, 'col': col};

  factory Position.fromJson(Map<String, dynamic> json) =>
      Position(json['row'] as int, json['col'] as int);
}

class Piece {
  final PieceType type;
  final Player? owner;
  Position position;

  Piece({required this.type, this.owner, required this.position});

  Piece copyWith({Position? position}) {
    return Piece(type: type, owner: owner, position: position ?? this.position);
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'owner': owner?.name,
    'position': position.toJson(),
  };

  factory Piece.fromJson(Map<String, dynamic> json) => Piece(
    type: PieceType.values.byName(json['type'] as String),
    owner: json['owner'] != null
        ? Player.values.byName(json['owner'] as String)
        : null,
    position: Position.fromJson(json['position'] as Map<String, dynamic>),
  );
}

class GameState {
  final int boardSize;
  final List<Piece> pieces;
  final Player currentPlayer;
  final GamePhase phase;
  final Player? winner;
  final GameMode gameMode;
  final WinCondition winCondition;

  // Hauteurs des colonnes pour le mode hexagonal (7 colonnes)
  static const List<int> hexColumnHeights = [4, 5, 6, 7, 6, 5, 4];

  // 6 directions hexagonales : 0=N, 1=S, 2=NW, 3=SW, 4=NE, 5=SE
  static const int hexDirN = 0;
  static const int hexDirS = 1;
  static const int hexDirNW = 2;
  static const int hexDirSW = 3;
  static const int hexDirNE = 4;
  static const int hexDirSE = 5;

  GameState({
    required this.boardSize,
    required this.pieces,
    required this.currentPlayer,
    required this.phase,
    this.winner,
    this.gameMode = GameMode.square,
    this.winCondition = WinCondition.ownCamp,
  });

  factory GameState.initial({
    int size = 5,
    WinCondition winCondition = WinCondition.ownCamp,
    Player startingPlayer = Player.player1,
  }) {
    assert(size == 5 || size == 7, 'Board size must be 5 or 7');

    final pieces = <Piece>[];
    final center = size ~/ 2;

    // Nexus au centre
    pieces.add(
      Piece(
        type: PieceType.nexus,
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
      currentPlayer: startingPlayer,
      phase: GamePhase.moveNexus,
      winner: null,
      gameMode: GameMode.square,
      winCondition: winCondition,
    );
  }

  // Initialisation pour le mode hexagonal (37 cellules, 7 colonnes)
  factory GameState.initialHex({
    WinCondition winCondition = WinCondition.ownCamp,
    Player startingPlayer = Player.player1,
  }) {
    final pieces = <Piece>[];

    // Nexus au centre (col=3, row=3)
    pieces.add(
      Piece(
        type: PieceType.nexus,
        owner: null,
        position: Position(3, 3), // row=3 dans la colonne centrale (hauteur 7)
      ),
    );

    // Pions joueur 1 (en haut de chaque colonne, row=0)
    for (int col = 0; col < 7; col++) {
      pieces.add(
        Piece(
          type: PieceType.pawn,
          owner: Player.player1,
          position: Position(0, col),
        ),
      );
    }

    // Pions joueur 2 (en bas de chaque colonne, row=max-1)
    for (int col = 0; col < 7; col++) {
      final maxRow = hexColumnHeights[col] - 1;
      pieces.add(
        Piece(
          type: PieceType.pawn,
          owner: Player.player2,
          position: Position(maxRow, col),
        ),
      );
    }

    return GameState(
      boardSize: 7, // 7 colonnes pour le mode hexagonal
      pieces: pieces,
      currentPlayer: startingPlayer,
      phase: GamePhase.moveNexus,
      winner: null,
      gameMode: GameMode.hexagonal,
      winCondition: winCondition,
    );
  }

  Piece get nexus => pieces.firstWhere((p) => p.type == PieceType.nexus);

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
    if (gameMode == GameMode.hexagonal) {
      return isValidHexPosition(pos);
    }
    return pos.row >= 0 &&
        pos.row < boardSize &&
        pos.col >= 0 &&
        pos.col < boardSize;
  }

  // Validation pour le mode hexagonal
  bool isValidHexPosition(Position pos) {
    if (pos.col < 0 || pos.col >= 7) return false;
    final maxRow = hexColumnHeights[pos.col];
    return pos.row >= 0 && pos.row < maxRow;
  }

  // Obtenir la cellule suivante dans une direction hexagonale
  // direction: 0=N, 1=S, 2=NW, 3=SW, 4=NE, 5=SE
  Position? getNextHexCell(Position pos, int direction) {
    final curHeight = hexColumnHeights[pos.col];

    switch (direction) {
      case 0: // N (haut même colonne)
        if (pos.row > 0) return Position(pos.row - 1, pos.col);
        return null;

      case 1: // S (bas même colonne)
        if (pos.row < curHeight - 1) return Position(pos.row + 1, pos.col);
        return null;

      case 2: // NW (haut-gauche)
        if (pos.col == 0) return null;
        final leftHeight = hexColumnHeights[pos.col - 1];
        // Si colonne adjacente plus courte: row-1, sinon: row
        final newRow = leftHeight < curHeight ? pos.row - 1 : pos.row;
        if (newRow >= 0 && newRow < leftHeight) {
          return Position(newRow, pos.col - 1);
        }
        return null;

      case 3: // SW (bas-gauche)
        if (pos.col == 0) return null;
        final leftHeight2 = hexColumnHeights[pos.col - 1];
        // Si colonne adjacente plus courte: row, sinon: row+1
        final newRow2 = leftHeight2 < curHeight ? pos.row : pos.row + 1;
        if (newRow2 >= 0 && newRow2 < leftHeight2) {
          return Position(newRow2, pos.col - 1);
        }
        return null;

      case 4: // NE (haut-droite)
        if (pos.col >= 6) return null;
        final rightHeight = hexColumnHeights[pos.col + 1];
        final newRow3 = rightHeight < curHeight ? pos.row - 1 : pos.row;
        if (newRow3 >= 0 && newRow3 < rightHeight) {
          return Position(newRow3, pos.col + 1);
        }
        return null;

      case 5: // SE (bas-droite)
        if (pos.col >= 6) return null;
        final rightHeight2 = hexColumnHeights[pos.col + 1];
        final newRow4 = rightHeight2 < curHeight ? pos.row : pos.row + 1;
        if (newRow4 >= 0 && newRow4 < rightHeight2) {
          return Position(newRow4, pos.col + 1);
        }
        return null;
    }
    return null;
  }

  // Obtenir tous les voisins hexagonaux d'une position
  List<Position> getHexNeighbors(Position pos) {
    final neighbors = <Position>[];
    for (int dir = 0; dir < 6; dir++) {
      final neighbor = getNextHexCell(pos, dir);
      if (neighbor != null) {
        neighbors.add(neighbor);
      }
    }
    return neighbors;
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

  // Mouvements valides pour le Nexus (1 case dans toutes directions)
  List<Position> getValidNexusMoves() {
    final nexusPos = nexus.position;
    final validMoves = <Position>[];

    if (gameMode == GameMode.hexagonal) {
      // Mode hexagonal : 6 directions
      final neighbors = getHexNeighbors(nexusPos);
      for (final newPos in neighbors) {
        if (getPieceAt(newPos) == null) {
          validMoves.add(newPos);
        }
      }
    } else {
      // Mode carré : 8 directions
      for (final dir in directions) {
        final newPos = nexusPos + dir;
        if (isValidPosition(newPos) && getPieceAt(newPos) == null) {
          validMoves.add(newPos);
        }
      }
    }

    return validMoves;
  }

  // Mouvements valides pour un pion (jusqu'au bout ou jusqu'à un obstacle)
  List<Position> getValidPawnMoves(Piece pawn) {
    if (pawn.type != PieceType.pawn) return [];

    final validMoves = <Position>[];

    if (gameMode == GameMode.hexagonal) {
      // Mode hexagonal : 6 directions, glisse jusqu'à l'obstacle
      for (int dir = 0; dir < 6; dir++) {
        Position lastValid = pawn.position;
        Position? current = getNextHexCell(pawn.position, dir);

        while (current != null && getPieceAt(current) == null) {
          lastValid = current;
          current = getNextHexCell(current, dir);
        }

        if (lastValid != pawn.position) {
          validMoves.add(lastValid);
        }
      }
    } else {
      // Mode carré : 8 directions
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
    }

    return validMoves;
  }

  // Vérifie si le Nexus est bloqué
  bool isNexusBlocked() {
    return getValidNexusMoves().isEmpty;
  }

  // Vérifie si un joueur a gagné
  Player? checkWinner() {
    final nexusPos = nexus.position;

    if (gameMode == GameMode.hexagonal) {
      // Mode hexagonal
      final maxRow = hexColumnHeights[nexusPos.col] - 1;

      if (winCondition == WinCondition.ownCamp) {
        // P1 gagne si Nexus atteint row == 0 (son camp)
        if (nexusPos.row == 0) {
          return Player.player1;
        }
        // P2 gagne si Nexus atteint la dernière row (son camp)
        if (nexusPos.row == maxRow) {
          return Player.player2;
        }
      } else {
        // opponentCamp: P1 gagne si Nexus atteint le camp adverse (bas)
        if (nexusPos.row == maxRow) {
          return Player.player1;
        }
        // P2 gagne si Nexus atteint le camp adverse (haut)
        if (nexusPos.row == 0) {
          return Player.player2;
        }
      }
    } else {
      // Mode carré
      if (winCondition == WinCondition.ownCamp) {
        // P1 gagne si Nexus atteint son camp (row 0)
        if (nexusPos.row == 0) {
          return Player.player1;
        }
        // P2 gagne si Nexus atteint son camp (dernière row)
        if (nexusPos.row == boardSize - 1) {
          return Player.player2;
        }
      } else {
        // opponentCamp: P1 gagne si Nexus atteint le camp adverse (dernière row)
        if (nexusPos.row == boardSize - 1) {
          return Player.player1;
        }
        // P2 gagne si Nexus atteint le camp adverse (row 0)
        if (nexusPos.row == 0) {
          return Player.player2;
        }
      }
    }

    return null;
  }

  // Vérifie si le joueur actuel peut jouer
  bool canCurrentPlayerPlay() {
    if (phase == GamePhase.moveNexus) {
      return getValidNexusMoves().isNotEmpty;
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

  GameState moveNexus(Position newPos) {
    if (phase != GamePhase.moveNexus) return this;
    if (!getValidNexusMoves().contains(newPos)) return this;

    final newPieces = pieces.map((p) {
      if (p.type == PieceType.nexus) {
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
      gameMode: gameMode,
      winCondition: winCondition,
    );

    // Vérifier victoire après déplacement du Nexus
    final winner = newState.checkWinner();
    if (winner != null) {
      return GameState(
        boardSize: boardSize,
        pieces: newPieces,
        currentPlayer: currentPlayer,
        phase: GamePhase.movePawn,
        winner: winner,
        gameMode: gameMode,
        winCondition: winCondition,
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
      phase: GamePhase.moveNexus,
      winner: null,
      gameMode: gameMode,
      winCondition: winCondition,
    );

    // Vérifier si le Nexus est bloqué (victoire pour le joueur actuel)
    if (newState.isNexusBlocked()) {
      return GameState(
        boardSize: boardSize,
        pieces: newPieces,
        currentPlayer: nextPlayer,
        phase: GamePhase.moveNexus,
        winner: currentPlayer,
        gameMode: gameMode,
        winCondition: winCondition,
      );
    }

    return newState;
  }

  Map<String, dynamic> toJson() => {
    'boardSize': boardSize,
    'pieces': pieces.map((p) => p.toJson()).toList(),
    'currentPlayer': currentPlayer.name,
    'phase': phase.name,
    'winner': winner?.name,
    'gameMode': gameMode.name,
    'winCondition': winCondition.name,
  };

  factory GameState.fromJson(Map<String, dynamic> json) => GameState(
    boardSize: json['boardSize'] as int,
    pieces: (json['pieces'] as List)
        .map((p) => Piece.fromJson(p as Map<String, dynamic>))
        .toList(),
    currentPlayer: Player.values.byName(json['currentPlayer'] as String),
    phase: GamePhase.values.byName(json['phase'] as String),
    winner: json['winner'] != null
        ? Player.values.byName(json['winner'] as String)
        : null,
    gameMode: GameMode.values.byName(json['gameMode'] as String),
    winCondition: WinCondition.values.byName(json['winCondition'] as String),
  );
}
