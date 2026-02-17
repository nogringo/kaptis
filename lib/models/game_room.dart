import 'dart:convert';
import 'package:ndk/ndk.dart';
import 'game_state.dart';

enum RoomStatus { waiting, playing, completed, cancelled }

class GameRoom {
  final String code;
  final String hostPubkey;
  final String? guestPubkey;
  final RoomStatus status;
  final int boardSize;
  final GameMode gameMode;
  final WinCondition winCondition;
  final Player hostPlayer; // Which player the host is (player1 or player2)
  final DateTime createdAt;

  const GameRoom({
    required this.code,
    required this.hostPubkey,
    this.guestPubkey,
    required this.status,
    required this.boardSize,
    required this.gameMode,
    required this.winCondition,
    required this.hostPlayer,
    required this.createdAt,
  });

  bool get isFull => guestPubkey != null;
  bool get isWaiting => status == RoomStatus.waiting;
  bool get isPlaying => status == RoomStatus.playing;

  GameRoom copyWith({
    String? code,
    String? hostPubkey,
    String? guestPubkey,
    RoomStatus? status,
    int? boardSize,
    GameMode? gameMode,
    WinCondition? winCondition,
    Player? hostPlayer,
    DateTime? createdAt,
  }) {
    return GameRoom(
      code: code ?? this.code,
      hostPubkey: hostPubkey ?? this.hostPubkey,
      guestPubkey: guestPubkey ?? this.guestPubkey,
      status: status ?? this.status,
      boardSize: boardSize ?? this.boardSize,
      gameMode: gameMode ?? this.gameMode,
      winCondition: winCondition ?? this.winCondition,
      hostPlayer: hostPlayer ?? this.hostPlayer,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Create GameRoom from Nostr event
  factory GameRoom.fromNostrEvent(Nip01Event event) {
    String? code;
    String? hostPubkey;
    String? guestPubkey;
    String statusStr = 'waiting';
    String gameModeStr = 'square';
    Map<String, dynamic> rules = {};

    for (final tag in event.tags) {
      if (tag.isEmpty) continue;
      final key = tag[0];

      switch (key) {
        case 'd':
          if (tag.length > 1) {
            // Extract code from "kaptis-ABC123"
            final value = tag[1];
            if (value.startsWith('kaptis-')) {
              code = value.substring(7);
            }
          }
          break;
        case 'status':
          if (tag.length > 1) statusStr = tag[1];
          break;
        case 'game-mode':
          if (tag.length > 1) gameModeStr = tag[1];
          break;
        case 'rules':
          if (tag.length > 1) {
            try {
              rules = jsonDecode(tag[1]) as Map<String, dynamic>;
            } catch (_) {}
          }
          break;
        case 'p':
          if (tag.length >= 4) {
            final role = tag[3];
            if (role == 'host') {
              hostPubkey = tag[1];
            } else if (role == 'player') {
              guestPubkey = tag[1];
            }
          }
          break;
      }
    }

    // Parse rules
    final boardSize = rules['boardSize'] as int? ?? 5;
    final winConditionStr = rules['winCondition'] as String? ?? 'ownCamp';
    final hostPlayerStr = rules['hostPlayer'] as String? ?? 'player1';

    // Parse enums
    RoomStatus status;
    switch (statusStr) {
      case 'waiting':
        status = RoomStatus.waiting;
        break;
      case 'in-progress':
      case 'playing':
        status = RoomStatus.playing;
        break;
      case 'completed':
        status = RoomStatus.completed;
        break;
      case 'cancelled':
        status = RoomStatus.cancelled;
        break;
      default:
        status = RoomStatus.waiting;
    }

    GameMode gameMode;
    if (gameModeStr.contains('hex')) {
      gameMode = GameMode.hexagonal;
    } else {
      gameMode = GameMode.square;
    }

    WinCondition winCondition;
    if (winConditionStr == 'opponentCamp') {
      winCondition = WinCondition.opponentCamp;
    } else {
      winCondition = WinCondition.ownCamp;
    }

    Player hostPlayer;
    if (hostPlayerStr == 'player2') {
      hostPlayer = Player.player2;
    } else {
      hostPlayer = Player.player1;
    }

    return GameRoom(
      code: code ?? '',
      hostPubkey: hostPubkey ?? event.pubKey,
      guestPubkey: guestPubkey,
      status: status,
      boardSize: boardSize,
      gameMode: gameMode,
      winCondition: winCondition,
      hostPlayer: hostPlayer,
      createdAt: DateTime.fromMillisecondsSinceEpoch(event.createdAt * 1000),
    );
  }

  /// Get game mode string for Nostr event
  String get gameModeString {
    if (gameMode == GameMode.hexagonal) {
      return 'hexagonal';
    }
    return 'square-${boardSize}x$boardSize';
  }

  /// Get rules map for Nostr event
  Map<String, dynamic> get rulesMap => {
    'boardSize': boardSize,
    'winCondition': winCondition.name,
    'hostPlayer': hostPlayer.name,
  };

  /// Create initial GameState for this room
  GameState createInitialGameState(Player startingPlayer) {
    if (gameMode == GameMode.hexagonal) {
      return GameState.initialHex(
        winCondition: winCondition,
        startingPlayer: startingPlayer,
      );
    }
    return GameState.initial(
      size: boardSize,
      winCondition: winCondition,
      startingPlayer: startingPlayer,
    );
  }
}
