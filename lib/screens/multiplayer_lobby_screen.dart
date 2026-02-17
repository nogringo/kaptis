import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../services/key_service.dart';
import '../services/multiplayer_service.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import 'waiting_room_screen.dart';
import 'multiplayer_game_screen.dart';

class MultiplayerLobbyScreen extends StatefulWidget {
  const MultiplayerLobbyScreen({super.key});

  @override
  State<MultiplayerLobbyScreen> createState() => _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends State<MultiplayerLobbyScreen> {
  final _codeController = TextEditingController();
  final _multiplayerService = MultiplayerService();

  int _boardSize = 5;
  GameMode _gameMode = GameMode.square;
  WinCondition _winCondition = WinCondition.ownCamp;
  Player _hostPlayer = Player.player1;

  bool _isCreating = false;
  bool _isJoining = false;
  String? _error;
  String? _npub;

  AppColors get _theme => context.colors;

  @override
  void initState() {
    super.initState();
    _loadNpub();
  }

  Future<void> _loadNpub() async {
    final npub = await KeyService.getNpub();
    if (mounted) {
      setState(() => _npub = npub);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    setState(() {
      _isCreating = true;
      _error = null;
    });

    final room = await _multiplayerService.createRoom(
      boardSize: _boardSize,
      gameMode: _gameMode,
      winCondition: _winCondition,
      hostPlayer: _hostPlayer,
    );

    if (!mounted) return;

    setState(() => _isCreating = false);

    if (room != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              WaitingRoomScreen(multiplayerService: _multiplayerService),
        ),
      );
    } else {
      setState(
        () => _error = _multiplayerService.error ?? 'Erreur de connexion',
      );
    }
  }

  Future<void> _joinRoom() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty || code.length != 6) {
      setState(() => _error = 'Code invalide (6 caracteres)');
      return;
    }

    setState(() {
      _isJoining = true;
      _error = null;
    });

    final room = await _multiplayerService.joinRoom(code);

    if (!mounted) return;

    setState(() => _isJoining = false);

    if (room != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MultiplayerGameScreen(multiplayerService: _multiplayerService),
        ),
      );
    } else {
      setState(
        () => _error = _multiplayerService.error ?? 'Partie introuvable',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLarge = Responsive.isLargeScreen(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Multijoueur',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isLarge ? 24 : 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: Responsive.screenPadding(context),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Responsive.contentMaxWidth(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCreateSection(isLarge),
                  SizedBox(height: isLarge ? 48 : 32),
                  _buildDivider(isLarge),
                  SizedBox(height: isLarge ? 48 : 32),
                  _buildJoinSection(isLarge),
                  SizedBox(height: isLarge ? 48 : 32),
                  _buildInfoSection(isLarge),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateSection(bool isLarge) {
    return Container(
      padding: EdgeInsets.all(isLarge ? 32 : 24),
      decoration: BoxDecoration(
        color: _theme.cardBackground,
        borderRadius: BorderRadius.circular(isLarge ? 24 : 20),
        border: Border.all(color: _theme.cardBorder, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.add_circle_outline_rounded,
                size: isLarge ? 32 : 28,
                color: _theme.accentColor,
              ),
              SizedBox(width: isLarge ? 16 : 12),
              Text(
                'Creer une partie',
                style: TextStyle(
                  fontSize: isLarge ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: _theme.primaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: isLarge ? 32 : 24),
          _buildSectionTitle('Type de plateau', isLarge),
          SizedBox(height: isLarge ? 16 : 12),
          _buildBoardTypeSelector(isLarge),
          if (_gameMode == GameMode.square) ...[
            SizedBox(height: isLarge ? 24 : 16),
            _buildSectionTitle('Taille du plateau', isLarge),
            SizedBox(height: isLarge ? 16 : 12),
            _buildSizeSelector(isLarge),
          ],
          SizedBox(height: isLarge ? 24 : 16),
          _buildSectionTitle('Condition de victoire', isLarge),
          SizedBox(height: isLarge ? 16 : 12),
          _buildWinConditionSelector(isLarge),
          SizedBox(height: isLarge ? 24 : 16),
          _buildSectionTitle('Votre couleur', isLarge),
          SizedBox(height: isLarge ? 16 : 12),
          _buildHostPlayerSelector(isLarge),
          SizedBox(height: isLarge ? 32 : 24),
          SizedBox(
            width: double.infinity,
            height: isLarge ? 60 : 52,
            child: ElevatedButton(
              onPressed: _isCreating ? null : _createRoom,
              style: ElevatedButton.styleFrom(
                backgroundColor: _theme.accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isLarge ? 16 : 12),
                ),
              ),
              child: _isCreating
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'CREER',
                      style: TextStyle(
                        fontSize: isLarge ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinSection(bool isLarge) {
    return Container(
      padding: EdgeInsets.all(isLarge ? 32 : 24),
      decoration: BoxDecoration(
        color: _theme.cardBackground,
        borderRadius: BorderRadius.circular(isLarge ? 24 : 20),
        border: Border.all(color: _theme.cardBorder, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.login_rounded,
                size: isLarge ? 32 : 28,
                color: _theme.accentColor,
              ),
              SizedBox(width: isLarge ? 16 : 12),
              Text(
                'Rejoindre une partie',
                style: TextStyle(
                  fontSize: isLarge ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: _theme.primaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: isLarge ? 24 : 16),
          TextField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            maxLength: 6,
            style: TextStyle(
              fontSize: isLarge ? 24 : 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
              color: _theme.primaryText,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'CODE',
              hintStyle: TextStyle(
                color: _theme.tertiaryText,
                letterSpacing: 8,
              ),
              counterText: '',
              filled: true,
              fillColor: _theme.secondaryBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isLarge ? 16 : 12),
                borderSide: BorderSide(color: _theme.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isLarge ? 16 : 12),
                borderSide: BorderSide(color: _theme.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isLarge ? 16 : 12),
                borderSide: BorderSide(color: _theme.accentColor, width: 2),
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              UpperCaseTextFormatter(),
            ],
          ),
          if (_error != null) ...[
            SizedBox(height: isLarge ? 16 : 12),
            Text(
              _error!,
              style: TextStyle(color: Colors.red, fontSize: isLarge ? 14 : 12),
              textAlign: TextAlign.center,
            ),
          ],
          SizedBox(height: isLarge ? 24 : 16),
          SizedBox(
            width: double.infinity,
            height: isLarge ? 60 : 52,
            child: ElevatedButton(
              onPressed: _isJoining ? null : _joinRoom,
              style: ElevatedButton.styleFrom(
                backgroundColor: _theme.primaryButtonBackground,
                foregroundColor: _theme.primaryButtonForeground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isLarge ? 16 : 12),
                ),
              ),
              child: _isJoining
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _theme.primaryButtonForeground,
                      ),
                    )
                  : Text(
                      'REJOINDRE',
                      style: TextStyle(
                        fontSize: isLarge ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(bool isLarge) {
    return Container(
      padding: EdgeInsets.all(isLarge ? 24 : 16),
      decoration: BoxDecoration(
        color: _theme.cardBackground.withAlpha(128),
        borderRadius: BorderRadius.circular(isLarge ? 16 : 12),
        border: Border.all(color: _theme.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: isLarge ? 20 : 18,
                color: _theme.tertiaryText,
              ),
              SizedBox(width: 8),
              Text(
                'Votre identite Nostr',
                style: TextStyle(
                  fontSize: isLarge ? 14 : 12,
                  color: _theme.tertiaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            _npub ?? 'Chargement...',
            style: TextStyle(
              fontSize: isLarge ? 12 : 10,
              color: _theme.secondaryText,
              fontFamily: 'monospace',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isLarge) {
    return Row(
      children: [
        Expanded(child: Divider(color: _theme.cardBorder)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isLarge ? 24 : 16),
          child: Text(
            'OU',
            style: TextStyle(
              color: _theme.tertiaryText,
              fontSize: isLarge ? 16 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(child: Divider(color: _theme.cardBorder)),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isLarge) {
    return Text(
      title,
      style: TextStyle(
        fontSize: isLarge ? 16 : 14,
        fontWeight: FontWeight.w600,
        color: _theme.secondaryText,
      ),
    );
  }

  Widget _buildBoardTypeSelector(bool isLarge) {
    return Row(
      children: [
        Expanded(
          child: _buildOptionChip(
            label: 'Carre',
            icon: Icons.grid_4x4_rounded,
            isSelected: _gameMode == GameMode.square,
            onTap: () => setState(() => _gameMode = GameMode.square),
            isLarge: isLarge,
          ),
        ),
        SizedBox(width: isLarge ? 16 : 12),
        Expanded(
          child: _buildOptionChip(
            label: 'Hexagonal',
            icon: Icons.hexagon_rounded,
            isSelected: _gameMode == GameMode.hexagonal,
            onTap: () => setState(() => _gameMode = GameMode.hexagonal),
            isLarge: isLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSelector(bool isLarge) {
    return Row(
      children: [
        Expanded(
          child: _buildOptionChip(
            label: '5 x 5',
            isSelected: _boardSize == 5,
            onTap: () => setState(() => _boardSize = 5),
            isLarge: isLarge,
          ),
        ),
        SizedBox(width: isLarge ? 16 : 12),
        Expanded(
          child: _buildOptionChip(
            label: '7 x 7',
            isSelected: _boardSize == 7,
            onTap: () => setState(() => _boardSize = 7),
            isLarge: isLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildWinConditionSelector(bool isLarge) {
    return Row(
      children: [
        Expanded(
          child: _buildOptionChip(
            label: 'Son camp',
            icon: Icons.home_rounded,
            isSelected: _winCondition == WinCondition.ownCamp,
            onTap: () => setState(() => _winCondition = WinCondition.ownCamp),
            isLarge: isLarge,
          ),
        ),
        SizedBox(width: isLarge ? 16 : 12),
        Expanded(
          child: _buildOptionChip(
            label: 'Camp adverse',
            icon: Icons.flag_rounded,
            isSelected: _winCondition == WinCondition.opponentCamp,
            onTap: () =>
                setState(() => _winCondition = WinCondition.opponentCamp),
            isLarge: isLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildHostPlayerSelector(bool isLarge) {
    return Row(
      children: [
        Expanded(
          child: _buildColorChip(
            label: 'Bleus',
            color: _theme.player1Color,
            isSelected: _hostPlayer == Player.player1,
            onTap: () => setState(() => _hostPlayer = Player.player1),
            isLarge: isLarge,
          ),
        ),
        SizedBox(width: isLarge ? 16 : 12),
        Expanded(
          child: _buildColorChip(
            label: 'Rouges',
            color: _theme.player2Color,
            isSelected: _hostPlayer == Player.player2,
            onTap: () => setState(() => _hostPlayer = Player.player2),
            isLarge: isLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionChip({
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isLarge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isLarge ? 16 : 12,
            vertical: isLarge ? 14 : 10,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? _theme.accentColor.withAlpha(25)
                : _theme.secondaryBackground,
            borderRadius: BorderRadius.circular(isLarge ? 12 : 10),
            border: Border.all(
              color: isSelected ? _theme.accentColor : _theme.cardBorder,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: isLarge ? 20 : 18,
                  color: isSelected ? _theme.accentColor : _theme.tertiaryText,
                ),
                SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: isLarge ? 15 : 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? _theme.accentColor : _theme.primaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorChip({
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isLarge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isLarge ? 16 : 12,
            vertical: isLarge ? 14 : 10,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withAlpha(25)
                : _theme.secondaryBackground,
            borderRadius: BorderRadius.circular(isLarge ? 12 : 10),
            border: Border.all(
              color: isSelected ? color : _theme.cardBorder,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isLarge ? 20 : 16,
                height: isLarge ? 20 : 16,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: isLarge ? 15 : 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : _theme.primaryText,
                ),
              ),
            ],
          ),
        ),
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
