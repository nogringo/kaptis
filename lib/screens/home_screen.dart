import 'package:flutter/material.dart';
import 'setup_screen.dart';
import 'rules_screen.dart';
import 'nexus_selection_screen.dart';
import 'online_lobby_screen.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppColors get _theme => context.colors;

  bool get _isLarge => Responsive.isLargeScreen(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: Responsive.screenPadding(context),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Responsive.contentMaxWidth(context),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTitle(),
                  SizedBox(height: _isLarge ? 20 : 16),
                  _buildSubtitle(),
                  SizedBox(height: _isLarge ? 16 : 12),
                  _buildTagline(),
                  SizedBox(height: _isLarge ? 60 : 48),
                  _buildButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return ShaderMask(
      shaderCallback: (bounds) =>
          LinearGradient(colors: _theme.titleGradient).createShader(bounds),
      child: Text(
        "Kaptis",
        style: TextStyle(
          fontSize: _isLarge ? 72 : 56,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: _isLarge ? 6 : 4,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      AppLocalizations.of(context)!.homeSubtitle,
      style: TextStyle(
        fontSize: _isLarge ? 20 : 16,
        color: _theme.secondaryText,
        letterSpacing: _isLarge ? 2 : 1,
      ),
    );
  }

  Widget _buildTagline() {
    return Text(
      AppLocalizations.of(context)!.homeTagline,
      style: TextStyle(
        fontSize: _isLarge ? 24 : 18,
        fontWeight: FontWeight.w600,
        color: _theme.accentColor,
        letterSpacing: _isLarge ? 1.5 : 1,
      ),
    );
  }

  Widget _buildButtons() {
    final buttonWidth = _isLarge ? 280.0 : 220.0;
    final buttonHeight = _isLarge ? 64.0 : 56.0;
    final secondaryHeight = _isLarge ? 56.0 : 50.0;

    if (_isLarge) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPlayButton(buttonWidth, buttonHeight),
              const SizedBox(width: 24),
              _buildMultiplayerButton(buttonWidth, buttonHeight),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildRulesButton(buttonWidth, secondaryHeight),
              const SizedBox(width: 24),
              _buildCustomizeButton(buttonWidth, secondaryHeight),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildPlayButton(buttonWidth, buttonHeight),
        const SizedBox(height: 20),
        _buildMultiplayerButton(buttonWidth, buttonHeight),
        const SizedBox(height: 20),
        _buildRulesButton(buttonWidth, secondaryHeight),
        const SizedBox(height: 20),
        _buildCustomizeButton(buttonWidth, secondaryHeight),
      ],
    );
  }

  Widget _buildPlayButton(double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SetupScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _theme.primaryButtonBackground,
          foregroundColor: _theme.primaryButtonForeground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height / 2),
          ),
          elevation: 8,
          shadowColor: _theme.accentShadow,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow_rounded, size: height * 0.5),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.homePlayLocal,
                style: TextStyle(
                  fontSize: height * 0.32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMultiplayerButton(double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: () => _showMultiplayerOptions(),
        style: ElevatedButton.styleFrom(
          backgroundColor: _theme.accentColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height / 2),
          ),
          elevation: 8,
          shadowColor: _theme.accentShadow,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.public_rounded, size: height * 0.5),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.homePlayOnline,
                style: TextStyle(
                  fontSize: height * 0.32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMultiplayerOptions() {
    if (_isLarge) {
      _showMultiplayerDialog();
    } else {
      _showMultiplayerBottomSheet();
    }
  }

  void _showMultiplayerDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.multiplayer,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _theme.primaryText,
                  ),
                ),
                const SizedBox(height: 32),
                _buildOptionButton(
                  icon: Icons.add_circle_outline,
                  label: AppLocalizations.of(context)!.createGame,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const OnlineLobbyScreen(mode: LobbyMode.create),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildOptionButton(
                  icon: Icons.login_rounded,
                  label: AppLocalizations.of(context)!.joinGame,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const OnlineLobbyScreen(mode: LobbyMode.join),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMultiplayerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.multiplayer,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _theme.primaryText,
              ),
            ),
            const SizedBox(height: 24),
            _buildOptionButton(
              icon: Icons.add_circle_outline,
              label: AppLocalizations.of(context)!.createGame,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const OnlineLobbyScreen(mode: LobbyMode.create),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildOptionButton(
              icon: Icons.login_rounded,
              label: AppLocalizations.of(context)!.joinGame,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const OnlineLobbyScreen(mode: LobbyMode.join),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: _theme.primaryText,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: _theme.cardBorder),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesButton(double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RulesScreen()),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: _theme.outlineButtonForeground,
          side: BorderSide(color: _theme.outlineButtonBorder, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_rounded, size: height * 0.45),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.homeRulesButton,
              style: TextStyle(
                fontSize: height * 0.3,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomizeButton(double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NexusSelectionScreen(),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: _theme.outlineButtonForeground,
          side: BorderSide(color: _theme.outlineButtonBorder, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: height * 0.45),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.homeNexusButton,
              style: TextStyle(
                fontSize: height * 0.3,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
