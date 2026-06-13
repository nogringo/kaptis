import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/preferences_service.dart';
import '../services/sound_service.dart';

/// Icon button that toggles the global sound-effects preference.
///
/// Self-contained: it rebuilds its own icon on tap, so parent screens don't
/// need to call setState just to refresh it. The underlying preference is
/// global, so all instances stay in sync the next time they rebuild.
class SoundToggleButton extends StatefulWidget {
  /// Optional icon size; falls back to the ambient [IconTheme] when null.
  final double? size;

  /// Optional icon color; falls back to the ambient [IconTheme] when null.
  final Color? color;

  const SoundToggleButton({super.key, this.size, this.color});

  @override
  State<SoundToggleButton> createState() => _SoundToggleButtonState();
}

class _SoundToggleButtonState extends State<SoundToggleButton> {
  @override
  Widget build(BuildContext context) {
    final enabled = PreferencesService.soundEnabled;
    return IconButton(
      icon: Icon(
        enabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
        size: widget.size,
        color: widget.color,
      ),
      tooltip: enabled
          ? AppLocalizations.of(context)!.soundOn
          : AppLocalizations.of(context)!.soundOff,
      onPressed: () {
        final newValue = !PreferencesService.soundEnabled;
        PreferencesService.setSoundEnabled(newValue);
        // Give immediate audible feedback when turning sound back on.
        if (newValue) SoundService.instance.playPawnMove();
        setState(() {});
      },
    );
  }
}
