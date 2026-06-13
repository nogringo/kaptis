import 'package:audioplayers/audioplayers.dart';
import 'preferences_service.dart';

/// Plays short sound effects for game actions (pawn / nexus moves).
///
/// Uses dedicated low-latency [AudioPlayer]s so a sound can be retriggered
/// rapidly without cutting off into a long media pipeline. Respects the
/// [PreferencesService.soundEnabled] setting.
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  static final _pawnSource = AssetSource('sounds/pawn_move.wav');
  static final _nexusSource = AssetSource('sounds/nexus_move.wav');

  final AudioPlayer _pawnPlayer = AudioPlayer();
  final AudioPlayer _nexusPlayer = AudioPlayer();
  bool _initialized = false;

  /// Configures the players for short sound-effect playback. Safe to call once
  /// at startup; failures are swallowed so audio never blocks the game.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await _pawnPlayer.setReleaseMode(ReleaseMode.stop);
      await _nexusPlayer.setReleaseMode(ReleaseMode.stop);
      await _pawnPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _nexusPlayer.setPlayerMode(PlayerMode.lowLatency);
      // Pre-load the sources so the first move plays without delay.
      await _pawnPlayer.setSource(_pawnSource);
      await _nexusPlayer.setSource(_nexusSource);
    } catch (_) {
      // Ignore: audio is non-essential.
    }
  }

  Future<void> playPawnMove() => _play(_pawnPlayer, _pawnSource);

  Future<void> playNexusMove() => _play(_nexusPlayer, _nexusSource);

  Future<void> _play(AudioPlayer player, AssetSource source) async {
    if (!PreferencesService.soundEnabled) return;
    try {
      await player.stop();
      await player.play(source);
    } catch (_) {
      // Ignore playback errors (e.g. unsupported platform).
    }
  }
}
