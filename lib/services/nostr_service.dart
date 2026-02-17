import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/nips/nip01/key_pair.dart';
import 'package:ndk/shared/nips/nip01/bip340.dart';
import 'package:ndk_flutter/ndk_flutter.dart';

/// Event kinds for gaming on Nostr (NIP-XX Gaming)
class NostrEventKinds {
  static const int gameSession = 38743; // Addressable - Game session
  static const int gameAction = 25211; // Ephemeral - Game action/move
  static const int gameStateUpdate = 25212; // Ephemeral - State sync
  static const int gameResult = 8343; // Regular - Game result
  static const int gameInvitation = 8346; // Regular - Game invitation
}

class NostrService {
  static final NostrService _instance = NostrService._internal();
  factory NostrService() => _instance;
  NostrService._internal();

  Ndk? _ndk;
  NdkFlutter? _ndkFlutter;
  bool _isConnected = false;
  KeyPair? _keyPair;

  static const List<String> defaultRelays = [
    'wss://relay.primal.net',
    'wss://relay.damus.io',
    'wss://nos.lol',
  ];

  bool get isConnected => _isConnected;
  Ndk? get ndk => _ndk;
  NdkFlutter? get ndkFlutter => _ndkFlutter;
  KeyPair? get keyPair => _keyPair;

  /// Get the appropriate event verifier based on platform
  EventVerifier _getEventVerifier() {
    if (kIsWeb) {
      return WebEventVerifier();
    }
    return Bip340EventVerifier();
  }

  /// Initialize NDK and connect to relays
  Future<void> connect({List<String>? relays}) async {
    if (_isConnected && _ndk != null) return;

    _ndk = Ndk(
      NdkConfig(
        eventVerifier: _getEventVerifier(),
        cache: MemCacheManager(),
        bootstrapRelays: relays ?? defaultRelays,
      ),
    );

    _ndkFlutter = NdkFlutter(ndk: _ndk!);

    // Restore accounts from secure storage
    await _ndkFlutter!.restoreAccountsState();

    // Get or create keypair
    _keyPair = await _getOrCreateKeyPair();

    _isConnected = true;
  }

  /// Get or create a keypair
  Future<KeyPair> _getOrCreateKeyPair() async {
    // Check if NdkFlutter restored an account
    final publicKey = _ndk!.accounts.getPublicKey();
    if (publicKey != null) {
      final account = _ndk!.accounts.accounts[publicKey];
      if (account != null && account.signer is Bip340EventSigner) {
        final signer = account.signer as Bip340EventSigner;
        if (signer.privateKey != null) {
          return KeyPair(
            signer.privateKey!,
            publicKey,
            Nip19.encodePrivateKey(signer.privateKey!),
            Nip19.encodePubKey(publicKey),
          );
        }
      }
    }

    // No account restored, generate new one
    final newKeyPair = Bip340.generatePrivateKey();
    _ndk!.accounts.loginPrivateKey(
      pubkey: newKeyPair.publicKey,
      privkey: newKeyPair.privateKey!,
    );
    await _ndkFlutter?.saveAccountsState();

    return newKeyPair;
  }

  /// Get public key
  Future<String> getPublicKey() async {
    await _ensureConnected();
    return _keyPair!.publicKey;
  }

  /// Disconnect from relays
  Future<void> disconnect() async {
    _ndk = null;
    _ndkFlutter = null;
    _isConnected = false;
    _keyPair = null;
  }

  /// Publish a game session event (kind 38743)
  Future<Nip01Event?> publishGameSession({
    required String sessionId,
    required String status,
    required int maxPlayers,
    required int currentPlayers,
    required String gameMode,
    required Map<String, dynamic> rules,
    required String hostPubkey,
    String? guestPubkey,
  }) async {
    if (_ndk == null) await connect();

    final tags = [
      ['d', 'kaptis-$sessionId'],
      ['game', 'kaptis'],
      ['title', 'Partie Kaptis'],
      ['status', status],
      ['max-players', maxPlayers.toString()],
      ['current-players', currentPlayers.toString()],
      ['game-mode', gameMode],
      ['rules', jsonEncode(rules)],
      ['p', hostPubkey, '', 'host'],
    ];

    if (guestPubkey != null) {
      tags.add(['p', guestPubkey, '', 'player']);
    }

    final event = Nip01Event(
      kind: NostrEventKinds.gameSession,
      pubKey: _keyPair!.publicKey,
      content: '',
      tags: tags,
      createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );

    return await _publishEvent(event);
  }

  /// Publish a game move event (kind 25211)
  Future<Nip01Event?> publishGameMove({
    required String sessionId,
    required String hostPubkey,
    required String moveType,
    required Map<String, dynamic> moveData,
    required int sequenceNumber,
    String? opponentPubkey,
  }) async {
    if (_ndk == null) await connect();

    final tags = [
      ['a', '38743:$hostPubkey:kaptis-$sessionId'],
      ['action', 'move'],
      [
        'data',
        jsonEncode({'moveType': moveType, ...moveData}),
      ],
      ['seq', sequenceNumber.toString()],
    ];

    if (opponentPubkey != null) {
      tags.add(['p', opponentPubkey]);
    }

    final event = Nip01Event(
      kind: NostrEventKinds.gameAction,
      pubKey: _keyPair!.publicKey,
      content: '',
      tags: tags,
      createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );

    return await _publishEvent(event);
  }

  /// Publish a join event
  Future<Nip01Event?> publishJoinEvent({
    required String sessionId,
    required String hostPubkey,
  }) async {
    if (_ndk == null) await connect();

    final event = Nip01Event(
      kind: NostrEventKinds.gameAction,
      pubKey: _keyPair!.publicKey,
      content: '',
      tags: [
        ['a', '38743:$hostPubkey:kaptis-$sessionId'],
        ['action', 'join'],
      ],
      createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );

    return await _publishEvent(event);
  }

  /// Publish a game action (start, pause, etc.)
  Future<Nip01Event?> publishGameAction({
    required String sessionId,
    required String hostPubkey,
    required String action,
    String? opponentPubkey,
  }) async {
    if (_ndk == null) await connect();

    final tags = [
      ['a', '38743:$hostPubkey:kaptis-$sessionId'],
      ['action', action],
    ];

    if (opponentPubkey != null) {
      tags.add(['p', opponentPubkey]);
    }

    final event = Nip01Event(
      kind: NostrEventKinds.gameAction,
      pubKey: _keyPair!.publicKey,
      content: '',
      tags: tags,
      createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );

    return await _publishEvent(event);
  }

  /// Publish game result (kind 8343)
  Future<Nip01Event?> publishGameResult({
    required String sessionId,
    required String hostPubkey,
    required int duration,
    required String winnerPubkey,
    required String loserPubkey,
  }) async {
    if (_ndk == null) await connect();

    final event = Nip01Event(
      kind: NostrEventKinds.gameResult,
      pubKey: _keyPair!.publicKey,
      content: '',
      tags: [
        ['a', '38743:$hostPubkey:kaptis-$sessionId'],
        ['game', 'kaptis'],
        ['duration', duration.toString()],
        ['p', winnerPubkey, '', 'winner'],
        ['p', loserPubkey, '', 'loser'],
      ],
      createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );

    return await _publishEvent(event);
  }

  /// Subscribe to game session events for a specific room code
  Stream<Nip01Event> subscribeToGameSession(String sessionId) {
    final controller = StreamController<Nip01Event>.broadcast();

    _ensureConnected().then((_) {
      final filter = Filter(
        kinds: [NostrEventKinds.gameSession],
        dTags: ['kaptis-$sessionId'],
      );

      _ndk!.requests.subscription(filter: filter).stream.listen((event) {
        controller.add(event);
      });
    });

    return controller.stream;
  }

  /// Subscribe to game moves for a specific session
  Stream<Nip01Event> subscribeToGameMoves(String sessionId, String hostPubkey) {
    final controller = StreamController<Nip01Event>.broadcast();

    _ensureConnected().then((_) {
      final aTag = '38743:$hostPubkey:kaptis-$sessionId';

      final filter = Filter(kinds: [NostrEventKinds.gameAction], aTags: [aTag]);

      _ndk!.requests.subscription(filter: filter).stream.listen((event) {
        controller.add(event);
      });
    });

    return controller.stream;
  }

  /// Get user metadata (profile)
  Future<Metadata?> getUserMetadata(String pubkey) async {
    await _ensureConnected();
    try {
      return await _ndk!.metadata.loadMetadata(pubkey);
    } catch (e) {
      return null;
    }
  }

  /// Find a game session by room code
  // TODO: Gérer le cas où plusieurs parties ont le même code (afficher la liste avec les créateurs)
  Future<Nip01Event?> findGameSession(String sessionId) async {
    await _ensureConnected();

    final filter = Filter(
      kinds: [NostrEventKinds.gameSession],
      dTags: ['kaptis-$sessionId'],
      limit: 1,
    );

    final response = _ndk!.requests.query(filter: filter);
    final events = await response.future;

    if (events.isNotEmpty) {
      return events.first;
    }
    return null;
  }

  /// Internal: Publish an event
  Future<Nip01Event?> _publishEvent(Nip01Event event) async {
    try {
      final response = _ndk!.broadcast.broadcast(nostrEvent: event);
      await response.broadcastDoneFuture;
      return response.publishEvent;
    } catch (e) {
      return null;
    }
  }

  /// Internal: Ensure connection
  Future<void> _ensureConnected() async {
    if (!_isConnected || _ndk == null) {
      await connect();
    }
  }
}
