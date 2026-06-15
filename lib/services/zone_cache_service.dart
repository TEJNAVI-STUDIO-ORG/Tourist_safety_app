import 'package:shared_preferences/shared_preferences.dart';

class ZoneCacheService {
  static const String zonesKey = "cached_zones";
  static const String lastLatKey = "cached_zones_lat";
  static const String lastLngKey = "cached_zones_lng";

  // =========================
  // SAVE ZONES
  // =========================
  static Future<void> saveZones(String jsonData, {double? lat, double? lng}) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(zonesKey, jsonData);
    if (lat != null && lng != null) {
      await prefs.setDouble(lastLatKey, lat);
      await prefs.setDouble(lastLngKey, lng);
    }
  }

  // =========================
  // LOAD ZONES
  // =========================
  static Future<String?> loadZones() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(zonesKey);
  }

  // =========================
  // GET LAST CACHED LOCATION
  // =========================
  static Future<Map<String, double>?> getLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(lastLatKey);
    final lng = prefs.getDouble(lastLngKey);

    if (lat != null && lng != null) {
      return {'lat': lat, 'lng': lng};
    }
    return null;
  }

  // =========================
  // CLEAR CACHE
  // =========================
  static Future<void> clearZones() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(zonesKey);
    await prefs.remove(lastLatKey);
    await prefs.remove(lastLngKey);
  }
}
