import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ndk/ndk.dart';
import '../models/game_room.dart';
import '../models/game_state.dart';
import 'key_service.dart';
import 'nostr_service.dart';

// TODO: Future multiplayer improvements
//
// Potential issues:
// - If a guest leaves, the host keeps guestPubkey and can no longer accept anyone else
// - A malicious bot can spam "join" on all public rooms
// - No disconnection detection (AFK player during a game)
//
// Possible solutions:
// - Implement kick (host) and leave (guest) with session republication
// - Approval system: join-request → host accept/reject
// - Heartbeat to detect disconnections
// - Web of trust (limit to follows)
// - Proof of Work (NIP-13) to slow down bots

/// Known multiplayer error cases (localized at the UI layer).
enum MultiplayerError { roomNotFound, roomFull, alreadyStarted }

/// Player profile info
class PlayerProfile {
  final String pubkey;
  final String? name;
  final String? picture;

  PlayerProfile({required this.pubkey, this.name, this.picture});

  String get displayName {
    if (name != null) return name!;
    // shortened npub: npub1abc...xyz
    final npub = Nip19.encodePubKey(pubkey);
    return '${npub.substring(0, 10)}...${npub.substring(npub.length - 4)}';
  }
}

/// Represents a move received from the network
class NetworkMove {
  final String moveType; // 'nexus' or 'pawn'
  final Position to;
  final Position? from; // For pawn moves
  final int sequenceNumber;
  final String playerPubkey;

  NetworkMove({
    required this.moveType,
    required this.to,
    this.from,
    required this.sequenceNumber,
    required this.playerPubkey,
  });

  factory NetworkMove.fromNostrEvent(Nip01Event event) {
    Map<String, dynamic> data = {};
    int seq = 0;

    for (final tag in event.tags) {
      if (tag.isEmpty) continue;
      if (tag[0] == 'data' && tag.length > 1) {
        try {
          data = jsonDecode(tag[1]) as Map<String, dynamic>;
        } catch (_) {}
      }
      if (tag[0] == 'seq' && tag.length > 1) {
        seq = int.tryParse(tag[1]) ?? 0;
      }
    }

    final toData = data['to'] as Map<String, dynamic>?;
    final fromData = data['from'] as Map<String, dynamic>?;

    return NetworkMove(
      moveType: data['moveType'] as String? ?? 'nexus',
      to: toData != null
          ? Position(toData['row'] as int, toData['col'] as int)
          : const Position(0, 0),
      from: fromData != null
          ? Position(fromData['row'] as int, fromData['col'] as int)
          : null,
      sequenceNumber: seq,
      playerPubkey: event.pubKey,
    );
  }
}

class MultiplayerService extends ChangeNotifier {
  final NostrService _nostrService = NostrService();

  GameRoom? _currentRoom;
  GameState? _gameState;
  Player? _localPlayer;
  int _sequenceNumber = 0;
  bool _isConnecting = false;
  String? _error;
  MultiplayerError? _errorCode;

  StreamSubscription<Nip01Event>? _sessionSubscription;
  StreamSubscription<Nip01Event>? _movesSubscription;

  final _moveController = StreamController<NetworkMove>.broadcast();
  final _gameStartController = StreamController<void>.broadcast();

  // Player profiles cache
  final Map<String, PlayerProfile> _profileCache = {};
  PlayerProfile? _localProfile;

  // Getters
  GameRoom? get currentRoom => _currentRoom;
  GameState? get gameState => _gameState;
  Player? get localPlayer => _localPlayer;
  bool get isConnecting => _isConnecting;
  String? get error => _error;
  MultiplayerError? get errorCode => _errorCode;
  bool get isHost => _currentRoom?.hostPubkey == _localPublicKey;
  bool get isMyTurn =>
      _gameState != null && _localPlayer == _gameState!.currentPlayer;

  Stream<NetworkMove> get onMoveReceived => _moveController.stream;
  Stream<void> get onGameStarted => _gameStartController.stream;

  PlayerProfile? get localProfile => _localProfile;
  PlayerProfile? get hostProfile =>
      _currentRoom != null ? _profileCache[_currentRoom!.hostPubkey] : null;
  PlayerProfile? get guestProfile => _currentRoom?.guestPubkey != null
      ? _profileCache[_currentRoom!.guestPubkey!]
      : null;

  String? _localPublicKey;

  /// Initialize the service
  Future<void> init() async {
    _localPublicKey = await KeyService.getPublicKey();
    await _nostrService.connect();

    // Create the profile immediately (npub available)
    _localProfile = _getOrCreateProfile(_localPublicKey!);
    notifyListeners();

    // Load metadata in the background
    loadPlayerProfile(_localPublicKey!).then((_) {
      _localProfile = _profileCache[_localPublicKey!];
    });
  }

  /// Get or create a player's profile (instant, then enriches with metadata)
  PlayerProfile _getOrCreateProfile(String pubkey) {
    if (!_profileCache.containsKey(pubkey)) {
      // Create immediately with just the pubkey (npub available instantly)
      _profileCache[pubkey] = PlayerProfile(pubkey: pubkey);
    }
    return _profileCache[pubkey]!;
  }

  /// Load profile metadata from network and update cache
  Future<void> loadPlayerProfile(String pubkey) async {
    // Ensure the profile exists
    _getOrCreateProfile(pubkey);

    // Load metadata in the background
    final metadata = await _nostrService.getUserMetadata(pubkey);
    if (metadata != null) {
      _profileCache[pubkey] = PlayerProfile(
        pubkey: pubkey,
        name: metadata.name ?? metadata.displayName,
        picture: metadata.picture,
      );
      notifyListeners();
    }
  }

  /// Create a new game room
  Future<GameRoom?> createRoom({
    required int boardSize,
    required GameMode gameMode,
    required WinCondition winCondition,
    required Player hostPlayer,
  }) async {
    _isConnecting = true;
    _error = null;
    _errorCode = null;
    notifyListeners();

    try {
      await init();

      final code = KeyService.generateRoomCode();
      final hostPubkey = await KeyService.getPublicKey();

      final room = GameRoom(
        code: code,
        hostPubkey: hostPubkey,
        status: RoomStatus.waiting,
        boardSize: boardSize,
        gameMode: gameMode,
        winCondition: winCondition,
        hostPlayer: hostPlayer,
        createdAt: DateTime.now(),
      );

      // Publish to Nostr
      await _nostrService.publishGameSession(
        sessionId: code,
        status: 'waiting',
        maxPlayers: 2,
        currentPlayers: 1,
        gameMode: room.gameModeString,
        rules: room.rulesMap,
        hostPubkey: hostPubkey,
      );

      _currentRoom = room;
      _localPlayer = hostPlayer;
      _sequenceNumber = 0;

      // Subscribe to events
      _subscribeToRoom(code, hostPubkey);

      _isConnecting = false;
      notifyListeners();
      return room;
    } catch (e) {
      _error = e.toString();
      _isConnecting = false;
      notifyListeners();
      return null;
    }
  }

  /// Update room config (republish addressable event)
  Future<void> updateRoomConfig({
    required int boardSize,
    required GameMode gameMode,
    required WinCondition winCondition,
    required Player startingPlayer,
  }) async {
    if (_currentRoom == null) return;

    final updatedRoom = GameRoom(
      code: _currentRoom!.code,
      hostPubkey: _currentRoom!.hostPubkey,
      status: _currentRoom!.status,
      boardSize: boardSize,
      gameMode: gameMode,
      winCondition: winCondition,
      hostPlayer: _currentRoom!.hostPlayer,
      startingPlayer: startingPlayer,
      guestPubkey: _currentRoom!.guestPubkey,
      createdAt: _currentRoom!.createdAt,
    );

    // Republish - the addressable event replaces the old one
    await _nostrService.publishGameSession(
      sessionId: updatedRoom.code,
      status: updatedRoom.status == RoomStatus.waiting ? 'waiting' : 'playing',
      maxPlayers: 2,
      currentPlayers: updatedRoom.guestPubkey != null ? 2 : 1,
      gameMode: updatedRoom.gameModeString,
      rules: updatedRoom.rulesMap,
      hostPubkey: updatedRoom.hostPubkey,
      guestPubkey: updatedRoom.guestPubkey,
    );

    _currentRoom = updatedRoom;
    notifyListeners();
  }

  /// Create a room with a specific code (for config updates)
  Future<GameRoom?> createRoomWithCode({
    required String code,
    required int boardSize,
    required GameMode gameMode,
    required WinCondition winCondition,
    required Player hostPlayer,
    required Player startingPlayer,
  }) async {
    try {
      await init();

      final hostPubkey = await KeyService.getPublicKey();

      final room = GameRoom(
        code: code,
        hostPubkey: hostPubkey,
        status: RoomStatus.waiting,
        boardSize: boardSize,
        gameMode: gameMode,
        winCondition: winCondition,
        hostPlayer: hostPlayer,
        startingPlayer: startingPlayer,
        createdAt: DateTime.now(),
      );

      // Publish to Nostr
      await _nostrService.publishGameSession(
        sessionId: code,
        status: 'waiting',
        maxPlayers: 2,
        currentPlayers: 1,
        gameMode: room.gameModeString,
        rules: room.rulesMap,
        hostPubkey: hostPubkey,
      );

      _currentRoom = room;
      _localPlayer = hostPlayer;
      _sequenceNumber = 0;

      // Subscribe to events
      _subscribeToRoom(code, hostPubkey);

      notifyListeners();
      return room;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Join an existing room by code
  Future<GameRoom?> joinRoom(String code) async {
    _isConnecting = true;
    _error = null;
    _errorCode = null;
    notifyListeners();

    try {
      await init();

      // Find the room
      final event = await _nostrService.findGameSession(code);
      if (event == null) {
        _errorCode = MultiplayerError.roomNotFound;
        _isConnecting = false;
        notifyListeners();
        return null;
      }

      final room = GameRoom.fromNostrEvent(event);

      if (room.isFull) {
        _errorCode = MultiplayerError.roomFull;
        _isConnecting = false;
        notifyListeners();
        return null;
      }

      if (room.status != RoomStatus.waiting) {
        _errorCode = MultiplayerError.alreadyStarted;
        _isConnecting = false;
        notifyListeners();
        return null;
      }

      final localPubkey = await KeyService.getPublicKey();

      // Publish join event
      await _nostrService.publishJoinEvent(
        sessionId: code,
        hostPubkey: room.hostPubkey,
      );

      // Update room with guest (still waiting for host to start)
      final updatedRoom = room.copyWith(
        guestPubkey: localPubkey,
        status: RoomStatus.waiting,
      );

      _currentRoom = updatedRoom;
      _localPlayer = room.hostPlayer == Player.player1
          ? Player.player2
          : Player.player1;
      _sequenceNumber = 0;

      // Load host profile
      loadPlayerProfile(room.hostPubkey);

      // Don't create game state yet - wait for host to start

      // Subscribe to events
      _subscribeToRoom(code, room.hostPubkey);

      _isConnecting = false;
      notifyListeners();
      return updatedRoom;
    } catch (e) {
      _error = e.toString();
      _isConnecting = false;
      notifyListeners();
      return null;
    }
  }

  /// Send a move
  Future<bool> sendMove({
    required String moveType,
    required Position to,
    Position? from,
  }) async {
    if (_currentRoom == null || !isMyTurn) return false;

    try {
      _sequenceNumber++;

      final moveData = <String, dynamic>{'to': to.toJson()};
      if (from != null) {
        moveData['from'] = from.toJson();
      }

      await _nostrService.publishGameMove(
        sessionId: _currentRoom!.code,
        hostPubkey: _currentRoom!.hostPubkey,
        moveType: moveType,
        moveData: moveData,
        sequenceNumber: _sequenceNumber,
        opponentPubkey: isHost
            ? _currentRoom!.guestPubkey
            : _currentRoom!.hostPubkey,
      );

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Publish game start event (host only)
  Future<void> publishGameStart() async {
    if (_currentRoom == null || !isHost) return;

    await _nostrService.publishGameAction(
      sessionId: _currentRoom!.code,
      hostPubkey: _currentRoom!.hostPubkey,
      action: 'start',
      opponentPubkey: _currentRoom!.guestPubkey,
    );

    // Update room status
    _currentRoom = _currentRoom!.copyWith(status: RoomStatus.playing);
    notifyListeners();
  }

  /// Apply a move to local state
  void applyMove(NetworkMove move) {
    if (_gameState == null) return;

    if (move.moveType == 'nexus') {
      _gameState = _gameState!.moveNexus(move.to);
    } else if (move.moveType == 'pawn' && move.from != null) {
      final pawn = _gameState!.getPieceAt(move.from!);
      if (pawn != null && pawn.type == PieceType.pawn) {
        _gameState = _gameState!.movePawn(pawn, move.to);
      }
    }

    notifyListeners();
  }

  /// Update game state directly (for local moves)
  void updateGameState(GameState newState) {
    _gameState = newState;
    notifyListeners();
  }

  /// Subscribe to room events
  void _subscribeToRoom(String code, String hostPubkey) {
    // Subscribe to session updates (player joins, status changes)
    _sessionSubscription?.cancel();
    _sessionSubscription = _nostrService
        .subscribeToGameSession(code)
        .listen(_handleSessionEvent);

    // Subscribe to moves
    _movesSubscription?.cancel();
    _movesSubscription = _nostrService
        .subscribeToGameMoves(code, hostPubkey)
        .listen(_handleMoveEvent);
  }

  /// Handle session event (player join, status change)
  void _handleSessionEvent(Nip01Event event) {
    final room = GameRoom.fromNostrEvent(event);
    if (_currentRoom == null) return;

    bool changed = false;

    // Sync config changes (for the guest when the host modifies)
    if (!isHost) {
      if (_currentRoom!.boardSize != room.boardSize ||
          _currentRoom!.gameMode != room.gameMode ||
          _currentRoom!.winCondition != room.winCondition ||
          _currentRoom!.startingPlayer != room.startingPlayer) {
        _currentRoom = _currentRoom!.copyWith(
          boardSize: room.boardSize,
          gameMode: room.gameMode,
          winCondition: room.winCondition,
          startingPlayer: room.startingPlayer,
        );
        changed = true;
      }
    }

    // Check if a guest joined
    if (_currentRoom!.guestPubkey == null && room.guestPubkey != null) {
      _currentRoom = _currentRoom!.copyWith(
        guestPubkey: room.guestPubkey,
        status: RoomStatus.playing,
      );

      // Initialize game state if we're the host
      if (isHost) {
        _gameState = _currentRoom!.createInitialGameState(
          _currentRoom!.startingPlayer,
        );
      }

      changed = true;
    }

    if (changed) {
      notifyListeners();
    }
  }

  /// Handle move event
  void _handleMoveEvent(Nip01Event event) {
    // Check action type
    for (final tag in event.tags) {
      if (tag.length > 1 && tag[0] == 'action') {
        final action = tag[1];

        // Handle player join
        if (action == 'join') {
          if (isHost &&
              _currentRoom != null &&
              _currentRoom!.guestPubkey == null) {
            _currentRoom = _currentRoom!.copyWith(guestPubkey: event.pubKey);

            // Load guest profile
            loadPlayerProfile(event.pubKey);

            // Update session on Nostr
            _nostrService.publishGameSession(
              sessionId: _currentRoom!.code,
              status: 'waiting',
              maxPlayers: 2,
              currentPlayers: 2,
              gameMode: _currentRoom!.gameModeString,
              rules: _currentRoom!.rulesMap,
              hostPubkey: _currentRoom!.hostPubkey,
              guestPubkey: _currentRoom!.guestPubkey,
            );

            notifyListeners();
          }
          return;
        }

        // Handle game start
        if (action == 'start') {
          if (!isHost && _currentRoom != null) {
            _currentRoom = _currentRoom!.copyWith(status: RoomStatus.playing);
            _gameState = _currentRoom!.createInitialGameState(
              _currentRoom!.startingPlayer,
            );
            _gameStartController.add(null);
            notifyListeners();
          }
          return;
        }
      }
    }

    // It's a move event
    if (event.pubKey == _localPublicKey) return; // Ignore own moves

    final move = NetworkMove.fromNostrEvent(event);

    // Emit move for external handling
    _moveController.add(move);
  }

  /// Leave current room
  Future<void> leaveRoom() async {
    _sessionSubscription?.cancel();
    _movesSubscription?.cancel();
    _currentRoom = null;
    _gameState = null;
    _localPlayer = null;
    _sequenceNumber = 0;
    _error = null;
    _errorCode = null;
    notifyListeners();
  }

  /// Publish game result
  Future<void> publishResult(Player winner) async {
    if (_currentRoom == null) return;

    final hostPubkey = _currentRoom!.hostPubkey;
    final guestPubkey = _currentRoom!.guestPubkey;
    if (guestPubkey == null) return;

    String winnerPubkey;
    String loserPubkey;

    if (winner == _currentRoom!.hostPlayer) {
      winnerPubkey = hostPubkey;
      loserPubkey = guestPubkey;
    } else {
      winnerPubkey = guestPubkey;
      loserPubkey = hostPubkey;
    }

    final duration = DateTime.now()
        .difference(_currentRoom!.createdAt)
        .inSeconds;

    await _nostrService.publishGameResult(
      sessionId: _currentRoom!.code,
      hostPubkey: hostPubkey,
      duration: duration,
      winnerPubkey: winnerPubkey,
      loserPubkey: loserPubkey,
    );
  }

  @override
  void dispose() {
    _sessionSubscription?.cancel();
    _movesSubscription?.cancel();
    _moveController.close();
    _gameStartController.close();
    super.dispose();
  }
}
