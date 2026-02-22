import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_player.dart';
import '../models/game_state.dart';
import '../models/nexus_skin.dart';

class PreferencesService {
  static const _nexusSkinKey = 'nexus_skin';
  static const _nexusColorKey = 'nexus_color';
  static const _boardSizeKey = 'board_size';
  static const _vsAIKey = 'vs_ai';
  static const _difficultyKey = 'difficulty';
  static const _gameModeKey = 'game_mode';
  static const _winConditionKey = 'win_condition';
  static const _startingPlayerKey = 'starting_player';

  static NexusSkin _nexusSkin = NexusSkin.core;
  static NexusColor _nexusColor = NexusColor.gold;
  static int _boardSize = 5;
  static bool _vsAI = true;
  static AIDifficulty _difficulty = AIDifficulty.normal;
  static GameMode _gameMode = GameMode.square;
  static WinCondition _winCondition = WinCondition.ownCamp;
  static Player _startingPlayer = Player.player1;

  static NexusSkin get nexusSkin => _nexusSkin;
  static NexusColor get nexusColor => _nexusColor;
  static int get boardSize => _boardSize;
  static bool get vsAI => _vsAI;
  static AIDifficulty get difficulty => _difficulty;
  static GameMode get gameMode => _gameMode;
  static WinCondition get winCondition => _winCondition;
  static Player get startingPlayer => _startingPlayer;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final skinIndex = prefs.getInt(_nexusSkinKey) ?? NexusSkin.core.index;
    final colorIndex = prefs.getInt(_nexusColorKey) ?? 0;
    _nexusSkin =
        NexusSkin.values[skinIndex.clamp(0, NexusSkin.values.length - 1)];
    _nexusColor =
        NexusColor.values[colorIndex.clamp(0, NexusColor.values.length - 1)];

    _boardSize = prefs.getInt(_boardSizeKey) ?? 5;
    _vsAI = prefs.getBool(_vsAIKey) ?? true;
    final difficultyIndex =
        prefs.getInt(_difficultyKey) ?? AIDifficulty.normal.index;
    _difficulty = AIDifficulty
        .values[difficultyIndex.clamp(0, AIDifficulty.values.length - 1)];
    final gameModeIndex = prefs.getInt(_gameModeKey) ?? GameMode.square.index;
    _gameMode =
        GameMode.values[gameModeIndex.clamp(0, GameMode.values.length - 1)];
    final winConditionIndex =
        prefs.getInt(_winConditionKey) ?? WinCondition.ownCamp.index;
    _winCondition = WinCondition
        .values[winConditionIndex.clamp(0, WinCondition.values.length - 1)];
    final startingPlayerIndex =
        prefs.getInt(_startingPlayerKey) ?? Player.player1.index;
    _startingPlayer =
        Player.values[startingPlayerIndex.clamp(0, Player.values.length - 1)];
  }

  static Future<void> setNexusSkin(NexusSkin skin) async {
    _nexusSkin = skin;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_nexusSkinKey, skin.index);
  }

  static Future<void> setNexusColor(NexusColor color) async {
    _nexusColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_nexusColorKey, color.index);
  }

  static Future<void> setBoardSize(int size) async {
    _boardSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_boardSizeKey, size);
  }

  static Future<void> setVsAI(bool value) async {
    _vsAI = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vsAIKey, value);
  }

  static Future<void> setDifficulty(AIDifficulty difficulty) async {
    _difficulty = difficulty;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_difficultyKey, difficulty.index);
  }

  static Future<void> setGameMode(GameMode mode) async {
    _gameMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_gameModeKey, mode.index);
  }

  static Future<void> setWinCondition(WinCondition condition) async {
    _winCondition = condition;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_winConditionKey, condition.index);
  }

  static Future<void> setStartingPlayer(Player player) async {
    _startingPlayer = player;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_startingPlayerKey, player.index);
  }
}
