import 'package:shared_preferences/shared_preferences.dart';
import '../models/nexus_skin.dart';

class PreferencesService {
  static const _nexusSkinKey = 'nexus_skin';
  static const _nexusColorKey = 'nexus_color';

  static Future<NexusSkin> getNexusSkin() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_nexusSkinKey) ?? 0;
    return NexusSkin.values[index.clamp(0, NexusSkin.values.length - 1)];
  }

  static Future<void> setNexusSkin(NexusSkin skin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_nexusSkinKey, skin.index);
  }

  static Future<NexusColor> getNexusColor() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_nexusColorKey) ?? 0;
    return NexusColor.values[index.clamp(0, NexusColor.values.length - 1)];
  }

  static Future<void> setNexusColor(NexusColor color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_nexusColorKey, color.index);
  }
}
