import 'package:shared_preferences/shared_preferences.dart';
import '../models/nexus_skin.dart';

class PreferencesService {
  static const _nexusSkinKey = 'nexus_skin';
  static const _nexusColorKey = 'nexus_color';

  static NexusSkin _nexusSkin = NexusSkin.core;
  static NexusColor _nexusColor = NexusColor.gold;

  static NexusSkin get nexusSkin => _nexusSkin;
  static NexusColor get nexusColor => _nexusColor;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final skinIndex = prefs.getInt(_nexusSkinKey) ?? NexusSkin.core.index;
    final colorIndex = prefs.getInt(_nexusColorKey) ?? 0;
    _nexusSkin =
        NexusSkin.values[skinIndex.clamp(0, NexusSkin.values.length - 1)];
    _nexusColor =
        NexusColor.values[colorIndex.clamp(0, NexusColor.values.length - 1)];
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
}
