import 'package:shared_preferences/shared_preferences.dart';

class ZoneCacheService {
  static const String zonesKey = "cached_zones";

  // =========================
  // SAVE ZONES
  // =========================
  static Future<void> saveZones(String jsonData) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(zonesKey, jsonData);
  }

  // =========================
  // LOAD ZONES
  // =========================
  static Future<String?> loadZones() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(zonesKey);
  }

  // =========================
  // CLEAR CACHE
  // =========================
  static Future<void> clearZones() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(zonesKey);
  }
}