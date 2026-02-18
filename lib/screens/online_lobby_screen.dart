import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../main.dart' show deepLinkService;
import '../models/game_state.dart';
import '../services/multiplayer_service.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import 'multiplayer_game_screen.dart';

enum LobbyMode { create, join }

class OnlineLobbyScreen extends StatefulWidget {
  final LobbyMode mode;
  final String? initialCode;

  const OnlineLobbyScreen({super.key, required this.mode, this.initialCode});

  @override
  State<OnlineLobbyScreen> createState() => _OnlineLobbyScreenState();
}

class _OnlineLobbyScreenState extends State<OnlineLobbyScreen> {
  final MultiplayerService _multiplayerService = MultiplayerService();
  final TextEditingController _codeController = TextEditingController();

  // Config options (host only)
  int _boardSize = 5;
  GameMode _gameMode = GameMode.square;
  WinCondition _winCondition = WinCondition.ownCamp;
  Player _startingPlayer = Player.player1;

  bool _isLoading = false;
  bool _copied = false;
  String? _error;
  String? _pendingCode; // Code généré localement avant connexion
  bool _isCreatingRoom = false; // En cours de création
  bool _configChangedDuringCreation = false; // Config modifiée pendant création

  StreamSubscription<void>? _gameStartSubscription;

  AppColors get _theme => context.colors;
  bool get _isHost => widget.mode == LobbyMode.create;
  bool get _hasGuest => _multiplayerService.currentRoom?.guestPubkey != null;
  String? get _displayCode =>
      _multiplayerService.currentRoom?.code ?? _pendingCode;

  @override
  void initState() {
    super.initState();
    _multiplayerService.addListener(_onServiceUpdate);

    // Listen for game start (guest only)
    _gameStartSubscription = _multiplayerService.onGameStarted.listen((_) {
      _navigateToGame();
    });

    if (_isHost) {
      _createRoom();
    } else if (widget.initialCode != null) {
      // Auto-fill and auto-join when opened via deep link
      _codeController.text = widget.initialCode!;
      WidgetsBinding.instance.addPostFrameCallback((_) => _joinRoom());
    }
  }

  @override
  void dispose() {
    _multiplayerService.removeListener(_onServiceUpdate);
    _gameStartSubscription?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _onServiceUpdate() {
    // Sync config from room for guest (quand l'host modifie)
    final room = _multiplayerService.currentRoom;
    if (!_isHost && room != null) {
      _boardSize = room.boardSize;
      _gameMode = room.gameMode;
      _winCondition = room.winCondition;
      _startingPlayer = room.startingPlayer;
    }
    setState(() {});
  }

  Future<void> _createRoom() async {
    // Génère le code immédiatement (pas de chargement visible)
    _pendingCode = _generateRoomCode();
    _isCreatingRoom = true;
    _configChangedDuringCreation = false;
    setState(() {});

    // Connexion Nostr en arrière-plan
    await _multiplayerService.createRoomWithCode(
      code: _pendingCode!,
      boardSize: _boardSize,
      gameMode: _gameMode,
      winCondition: _winCondition,
      hostPlayer: Player.player1,
      startingPlayer: _startingPlayer,
    );

    _isCreatingRoom = false;
    _pendingCode = null;

    // Si la config a changé pendant la création, on re-sync
    if (_configChangedDuringCreation &&
        _multiplayerService.currentRoom != null) {
      _configChangedDuringCreation = false;
      await _updateConfig();
    }

    setState(() {
      _error = _multiplayerService.error;
    });
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  Future<void> _joinRoom() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = 'Entrez un code');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final room = await _multiplayerService.joinRoom(code);

    setState(() {
      _isLoading = false;
      _error = _multiplayerService.error;
    });

    if (room != null) {
      // Update local config from room
      _boardSize = room.boardSize;
      _gameMode = room.gameMode;
      _winCondition = room.winCondition;
      _startingPlayer = room.startingPlayer;
    }
  }

  Future<void> _updateConfig() async {
    if (!_isHost) return;

    // Si la room est en cours de création, on note juste que la config a changé
    if (_isCreatingRoom) {
      _configChangedDuringCreation = true;
      return;
    }

    // Si la room n'existe pas encore, rien à faire
    if (_multiplayerService.currentRoom == null) return;

    // Republier l'événement addressable (remplace l'ancien)
    await _multiplayerService.updateRoomConfig(
      boardSize: _boardSize,
      gameMode: _gameMode,
      winCondition: _winCondition,
      startingPlayer: _startingPlayer,
    );
  }

  void _startGame() {
    if (!_hasGuest) return;

    // Initialize game state
    final room = _multiplayerService.currentRoom!;
    final gameState = room.createInitialGameState(room.startingPlayer);
    _multiplayerService.updateGameState(gameState);

    // Notify guest that game is starting
    _multiplayerService.publishGameStart();

    _navigateToGame();
  }

  void _navigateToGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MultiplayerGameScreen(multiplayerService: _multiplayerService),
      ),
    );
  }

  void _copyCode() {
    final code = _displayCode;
    if (code != null) {
      Clipboard.setData(ClipboardData(text: code));
      setState(() => _copied = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _copied = false);
      });
    }
  }

  void _shareLink(String code) {
    final link = deepLinkService.generateShareLink(code);
    SharePlus.instance.share(
      ShareParams(text: 'Rejoins ma partie Kaptis!\n$link'),
    );
  }

  Future<void> _cancel() async {
    await _multiplayerService.leaveRoom();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLarge = Responsive.isLargeScreen(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) await _cancel();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isHost ? 'Créer une partie' : 'Rejoindre',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isLarge ? 24 : 20,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _cancel,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: Responsive.screenPadding(context),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Responsive.contentMaxWidth(context),
                ),
                child: _isHost
                    ? _buildHostView(isLarge)
                    : _buildGuestView(isLarge),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHostView(bool isLarge) {
    final code = _displayCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Code display
        if (code != null) _buildCodeCard(isLarge, code),
        SizedBox(height: isLarge ? 32 : 24),

        // Config section
        _buildConfigSection(isLarge),
        SizedBox(height: isLarge ? 32 : 24),

        // Players section
        _buildPlayersSection(isLarge),
        SizedBox(height: isLarge ? 32 : 24),

        // Start button
        _buildStartButton(isLarge),

        // Error
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(
            _error!,
            style: TextStyle(color: Colors.red, fontSize: isLarge ? 16 : 14),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildGuestView(bool isLarge) {
    final room = _multiplayerService.currentRoom;

    // If not yet joined, show code input
    if (room == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCodeInput(isLarge),
          SizedBox(height: isLarge ? 24 : 16),
          _buildJoinButton(isLarge),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Colors.red, fontSize: isLarge ? 16 : 14),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      );
    }

    // Already joined, show lobby
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCodeCard(isLarge, room.code),
        SizedBox(height: isLarge ? 32 : 24),
        _buildConfigSection(isLarge, readOnly: true),
        SizedBox(height: isLarge ? 32 : 24),
        _buildPlayersSection(isLarge),
        SizedBox(height: isLarge ? 32 : 24),
        _buildWaitingForHost(isLarge),
      ],
    );
  }

  Widget _buildCodeCard(bool isLarge, String code) {
    return Container(
      padding: EdgeInsets.all(isLarge ? 32 : 24),
      decoration: BoxDecoration(
        color: _theme.cardBackground,
        borderRadius: BorderRadius.circular(isLarge ? 20 : 16),
        border: Border.all(color: _theme.accentColor, width: 2),
      ),
      child: Column(
        children: [
          Text(
            'Code de la partie',
            style: TextStyle(
              fontSize: isLarge ? 16 : 14,
              color: _theme.secondaryText,
            ),
          ),
          SizedBox(height: isLarge ? 16 : 12),
          Text(
            code,
            style: TextStyle(
              fontSize: isLarge ? 48 : 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
              color: _theme.accentColor,
            ),
          ),
          SizedBox(height: isLarge ? 16 : 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _copyCode,
                icon: Icon(
                  _copied ? Icons.check : Icons.copy,
                  size: isLarge ? 20 : 18,
                ),
                label: Text(
                  'Copier',
                  style: TextStyle(fontSize: isLarge ? 16 : 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _theme.accentColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isLarge ? 24 : 16,
                    vertical: isLarge ? 12 : 10,
                  ),
                ),
              ),
              SizedBox(width: isLarge ? 12 : 8),
              ElevatedButton.icon(
                onPressed: () => _shareLink(code),
                icon: Icon(Icons.share, size: isLarge ? 20 : 18),
                label: Text(
                  'Partager',
                  style: TextStyle(fontSize: isLarge ? 16 : 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _theme.accentColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isLarge ? 24 : 16,
                    vertical: isLarge ? 12 : 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCodeInput(bool isLarge) {
    return Container(
      padding: EdgeInsets.all(isLarge ? 32 : 24),
      decoration: BoxDecoration(
        color: _theme.cardBackground,
        borderRadius: BorderRadius.circular(isLarge ? 20 : 16),
        border: Border.all(color: _theme.cardBorder),
      ),
      child: Column(
        children: [
          Text(
            'Entrez le code',
            style: TextStyle(
              fontSize: isLarge ? 18 : 16,
              fontWeight: FontWeight.w500,
              color: _theme.primaryText,
            ),
          ),
          SizedBox(height: isLarge ? 24 : 16),
          TextField(
            controller: _codeController,
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.characters,
            style: TextStyle(
              fontSize: isLarge ? 32 : 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
            decoration: InputDecoration(
              hintText: 'ABC123',
              hintStyle: TextStyle(
                color: _theme.tertiaryText,
                letterSpacing: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: isLarge ? 20 : 16,
              ),
            ),
            maxLength: 6,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              UpperCaseTextFormatter(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfigSection(bool isLarge, {bool readOnly = false}) {
    return Container(
      padding: EdgeInsets.all(isLarge ? 24 : 16),
      decoration: BoxDecoration(
        color: _theme.cardBackground,
        borderRadius: BorderRadius.circular(isLarge ? 16 : 12),
        border: Border.all(color: _theme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuration',
            style: TextStyle(
              fontSize: isLarge ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: _theme.primaryText,
            ),
          ),
          SizedBox(height: isLarge ? 20 : 16),

          // Board size
          _buildConfigRow(
            isLarge,
            'Plateau',
            readOnly
                ? Text(
                    _gameMode == GameMode.hexagonal
                        ? 'Hexagonal'
                        : '${_boardSize}x$_boardSize',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: _theme.primaryText,
                    ),
                  )
                : _buildStyledDropdown<String>(
                    value: _gameMode == GameMode.hexagonal
                        ? 'hex'
                        : '${_boardSize}x$_boardSize',
                    isLarge: isLarge,
                    items: const [
                      DropdownMenuItem(value: '5x5', child: Text('5x5')),
                      DropdownMenuItem(value: '7x7', child: Text('7x7')),
                      DropdownMenuItem(value: 'hex', child: Text('Hexagonal')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        if (value == 'hex') {
                          _gameMode = GameMode.hexagonal;
                        } else {
                          _gameMode = GameMode.square;
                          _boardSize = value == '7x7' ? 7 : 5;
                        }
                      });
                      _updateConfig();
                    },
                  ),
          ),

          SizedBox(height: isLarge ? 12 : 8),

          // Win condition
          _buildConfigRow(
            isLarge,
            'Victoire',
            readOnly
                ? Text(
                    _winCondition == WinCondition.ownCamp
                        ? 'Son camp'
                        : 'Camp adverse',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: _theme.primaryText,
                    ),
                  )
                : _buildStyledDropdown<WinCondition>(
                    value: _winCondition,
                    isLarge: isLarge,
                    items: const [
                      DropdownMenuItem(
                        value: WinCondition.ownCamp,
                        child: Text('Son camp'),
                      ),
                      DropdownMenuItem(
                        value: WinCondition.opponentCamp,
                        child: Text('Camp adverse'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _winCondition = value);
                        _updateConfig();
                      }
                    },
                  ),
          ),

          SizedBox(height: isLarge ? 12 : 8),

          // Starting player
          _buildConfigRow(
            isLarge,
            'Commence',
            readOnly
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _startingPlayer == Player.player1
                              ? _theme.player1Color
                              : _theme.player2Color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _startingPlayer == Player.player1 ? 'Bleu' : 'Rouge',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: _theme.primaryText,
                        ),
                      ),
                    ],
                  )
                : _buildStyledDropdown<Player>(
                    value: _startingPlayer,
                    isLarge: isLarge,
                    items: [
                      DropdownMenuItem(
                        value: Player.player1,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _theme.player1Color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('Bleu'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: Player.player2,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _theme.player2Color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('Rouge'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _startingPlayer = value);
                        _updateConfig();
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigRow(bool isLarge, String label, Widget value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isLarge ? 16 : 14,
            color: _theme.secondaryText,
          ),
        ),
        value,
      ],
    );
  }

  Widget _buildStyledDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required bool isLarge,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 12 : 10,
        vertical: isLarge ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: _theme.cardBackground,
        borderRadius: BorderRadius.circular(isLarge ? 12 : 10),
        border: Border.all(color: _theme.cardBorder),
      ),
      child: DropdownButton<T>(
        value: value,
        underline: const SizedBox(),
        isDense: true,
        borderRadius: BorderRadius.circular(12),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: _theme.secondaryText,
          size: isLarge ? 20 : 18,
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildPlayersSection(bool isLarge) {
    return Container(
      padding: EdgeInsets.all(isLarge ? 24 : 16),
      decoration: BoxDecoration(
        color: _theme.cardBackground,
        borderRadius: BorderRadius.circular(isLarge ? 16 : 12),
        border: Border.all(color: _theme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Joueurs',
            style: TextStyle(
              fontSize: isLarge ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: _theme.primaryText,
            ),
          ),
          SizedBox(height: isLarge ? 16 : 12),

          // Host
          _buildPlayerRow(
            isLarge: isLarge,
            profile: _isHost
                ? _multiplayerService.localProfile
                : _multiplayerService.hostProfile,
            label: _isHost ? 'Vous (host)' : 'Host',
            connected: true,
            color: _theme.player1Color,
          ),

          SizedBox(height: isLarge ? 12 : 8),

          // Guest
          _buildPlayerRow(
            isLarge: isLarge,
            profile: _hasGuest
                ? (_isHost
                      ? _multiplayerService.guestProfile
                      : _multiplayerService.localProfile)
                : null,
            label: _hasGuest
                ? (_isHost ? 'Adversaire' : 'Vous')
                : 'En attente...',
            connected: _hasGuest,
            color: _hasGuest ? _theme.player2Color : _theme.tertiaryText,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerRow({
    required bool isLarge,
    required PlayerProfile? profile,
    required String label,
    required bool connected,
    required Color color,
  }) {
    final avatarSize = isLarge ? 40.0 : 32.0;

    return Row(
      children: [
        // Avatar ou indicateur
        if (profile?.picture != null)
          ClipOval(
            child: Image.network(
              profile!.picture!,
              width: avatarSize,
              height: avatarSize,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) =>
                  _buildDefaultAvatar(avatarSize, color, connected),
            ),
          )
        else
          _buildDefaultAvatar(avatarSize, color, connected),

        SizedBox(width: isLarge ? 12 : 8),

        // Nom et label
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile?.displayName ?? label,
                style: TextStyle(
                  fontSize: isLarge ? 16 : 14,
                  fontWeight: connected ? FontWeight.w500 : FontWeight.normal,
                  color: connected ? _theme.primaryText : _theme.tertiaryText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (profile != null)
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isLarge ? 12 : 10,
                    color: _theme.tertiaryText,
                  ),
                ),
            ],
          ),
        ),

        // Indicateur de connexion
        Container(
          width: isLarge ? 10 : 8,
          height: isLarge ? 10 : 8,
          decoration: BoxDecoration(
            color: connected ? color : Colors.transparent,
            border: Border.all(color: color, width: 2),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar(double size, Color color, bool connected) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: connected ? color.withAlpha(50) : _theme.cardBorder,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: size * 0.6,
        color: connected ? color : _theme.tertiaryText,
      ),
    );
  }

  Widget _buildStartButton(bool isLarge) {
    return ElevatedButton(
      onPressed: _hasGuest ? _startGame : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _theme.accentColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: _theme.cardBorder,
        disabledForegroundColor: _theme.tertiaryText,
        padding: EdgeInsets.symmetric(vertical: isLarge ? 20 : 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isLarge ? 16 : 12),
        ),
      ),
      child: Text(
        _hasGuest ? 'Lancer la partie' : 'En attente d\'un adversaire...',
        style: TextStyle(
          fontSize: isLarge ? 18 : 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildJoinButton(bool isLarge) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _joinRoom,
      style: ElevatedButton.styleFrom(
        backgroundColor: _theme.accentColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: isLarge ? 20 : 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isLarge ? 16 : 12),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              'Rejoindre',
              style: TextStyle(
                fontSize: isLarge ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget _buildWaitingForHost(bool isLarge) {
    return Container(
      padding: EdgeInsets.all(isLarge ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(25),
        borderRadius: BorderRadius.circular(isLarge ? 16 : 12),
        border: Border.all(color: Colors.orange.withAlpha(100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: isLarge ? 20 : 16,
            height: isLarge ? 20 : 16,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.orange,
            ),
          ),
          SizedBox(width: isLarge ? 12 : 8),
          Text(
            'En attente du lancement par le host...',
            style: TextStyle(
              fontSize: isLarge ? 16 : 14,
              color: Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
