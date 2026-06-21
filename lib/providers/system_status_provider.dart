import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/service_health_monitor.dart';

class SystemStatusProvider extends ChangeNotifier {
  ServiceHealthReport? lastHealthReport;

  void updateHealthReport(ServiceHealthReport report) {
    lastHealthReport = report;
    notifyListeners();
  }

  // =========================
  // GPS
  // =========================

  bool gpsActive = false;
  String gpsStatus = "Initializing...";
  DateTime? lastGpsUpdate;
  double? latitude;
  double? longitude;
  double? accuracy;
  double? gpsspeed;

  // =========================
  // OVERPASS / API
  // =========================

  bool overpassActive = false;
  String overpassStatus = "Waiting...";
  String lastApiCall = "None";
  String lastSuccessfulEndpoint = "None";
  DateTime? lastOverpassRefresh;
  String overpassSuggestion = "No hazard suggestions yet";
  int retryCount = 0;

  // =========================
  // GEOFENCING
  // =========================

  bool geofenceActive = false;
  String geofenceStatus = "Inactive";
  String lastZoneEvent = "None";
  DateTime? lastGeofenceCheck;
  bool insideDangerZone = false;

  // =========================
  // ZONES
  // =========================

  int totalZones = 0;
  int nearbyZones = 0;
  int enteredZones = 0;
  DateTime? nextZoneScan;
  String zoneSource = "Unknown";
  String locationName = "Unknown Location";

  // =========================
  // FALL DETECTION
  // =========================

  bool fallDetectionActive = false;
  String fallDetectionStatus = "Inactive";
  DateTime? lastFallCheck;
  String lastFallEvent = "No recent fall events";
  String sensorStatus = "Unknown";
  DateTime? lastActiveTimestamp;

  // =========================
  // NOTIFICATIONS
  // =========================

  bool notificationActive = false;
  String notificationStatus = "Inactive";

  bool sosMessageTemplateValid = false;
  int sosContactCount = 0;

  // =========================
  // BACKGROUND SERVICE
  // =========================

  bool backgroundServiceActive = false;
  String backgroundServiceStatus = "Stopped";
  DateTime? lastPulse;
  DateTime? lastBackgroundCheck;
  DateTime? serviceUptime;

  // =========================
  // SOS
  // =========================

  bool sosReady = false;

  // =========================
  // CACHE KEYS
  // =========================
  static const String keyLastLat = 'status_last_lat';
  static const String keyLastLng = 'status_last_lng';
  static const String keyLastApiStatus = 'status_last_api_msg';
  static const String keyLastApiTime = 'status_last_api_time';
  static const String keyLastApiSuggestion = 'status_last_api_suggestion';
  static const String keyLocationName = 'status_location_name';
  static const String keyLastFallEvent = 'status_last_fall_event';
  static const String keyLastPulse = 'bg_last_heartbeat';
  static const String keyLastBgCheck = 'bg_last_check';
  static const String keyServiceUptime = 'bg_service_uptime';
  static const String keySensorStatus = 'fall_sensor_status';
  static const String keyInsideDangerZone = 'status_inside_danger_zone';

  // =========================
  // INITIALIZATION
  // =========================
  
  Future<void> syncFromBackground() async {
    final prefs = await SharedPreferences.getInstance();

    final pulseStr = prefs.getString(keyLastPulse);
    if (pulseStr != null) {
      lastPulse = DateTime.tryParse(pulseStr);
      lastActiveTimestamp = lastPulse;
    }

    final bgCheckStr = prefs.getString(keyLastBgCheck);
    if (bgCheckStr != null) {
      lastBackgroundCheck = DateTime.tryParse(bgCheckStr);
    }

    final uptimeStr = prefs.getString(keyServiceUptime);
    if (uptimeStr != null) {
      serviceUptime = DateTime.tryParse(uptimeStr);
    }

    final savedSensorStatus = prefs.getString(keySensorStatus);
    if (savedSensorStatus != null && savedSensorStatus.isNotEmpty) {
      sensorStatus = savedSensorStatus;
    }

    final bgRunning = prefs.getBool('bg_running') ?? false;
    backgroundServiceActive = bgRunning;
    if (bgRunning) {
      backgroundServiceStatus = 'Foreground Service Running';
    }

    final bgTotalZones = prefs.getInt('bg_total_zones');
    if (bgTotalZones != null) {
      totalZones = bgTotalZones;
    }

    final activeInside = prefs.getInt('active_zone_count');
    if (activeInside != null) {
      enteredZones = activeInside;
    }

    final nextScanStr = prefs.getString('bg_next_scan');
    if (nextScanStr != null) {
      nextZoneScan = DateTime.tryParse(nextScanStr);
    }

    final lastFallSensor = prefs.getString('last_fall_sensor_update');
    if (lastFallSensor != null) {
      lastFallCheck = DateTime.tryParse(lastFallSensor);
    }

    final fallRunning = prefs.getBool('fall_detection_running');
    if (fallRunning != null) {
      fallDetectionActive = fallRunning;
    }

    final savedFallEvent = prefs.getString(keyLastFallEvent);
    if (savedFallEvent != null) {
      lastFallEvent = savedFallEvent;
    }

    final zoneEvent = prefs.getString('last_zone_event');
    if (zoneEvent != null) {
      lastZoneEvent = zoneEvent;
      lastGeofenceCheck = DateTime.now();
    }

    final lastLocationUpdate = prefs.getString('last_location_update');
    if (lastLocationUpdate != null) {
      final parsed = DateTime.tryParse(lastLocationUpdate);
      if (parsed != null &&
          DateTime.now().difference(parsed) < const Duration(minutes: 5)) {
        geofenceActive = true;
        geofenceStatus = 'Background monitoring active';
      }
    }

    notifyListeners();
  }

  void updateSensorStatus(String status) async {
    sensorStatus = status;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keySensorStatus, status);
    notifyListeners();
  }

  Future<void> loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    
    final savedLat = prefs.getDouble(keyLastLat);
    final savedLng = prefs.getDouble(keyLastLng);
    if (savedLat != null && savedLng != null) {
      latitude = savedLat;
      longitude = savedLng;
      gpsStatus = "Using Cached Location";
    }

    final savedStatus = prefs.getString(keyLastApiStatus);
    if (savedStatus != null) {
      overpassStatus = savedStatus;
    }
    
    final apiTimeStr = prefs.getString(keyLastApiTime);
    if (apiTimeStr != null) {
      lastOverpassRefresh = DateTime.parse(apiTimeStr);
      overpassActive = true;
    }

    final pulseStr = prefs.getString(keyLastPulse);
    if (pulseStr != null) {
      lastPulse = DateTime.tryParse(pulseStr);
      lastActiveTimestamp = lastPulse;
    }

    final bgCheckStr = prefs.getString(keyLastBgCheck);
    if (bgCheckStr != null) {
      lastBackgroundCheck = DateTime.tryParse(bgCheckStr);
    }

    final uptimeStr = prefs.getString(keyServiceUptime);
    if (uptimeStr != null) {
      serviceUptime = DateTime.tryParse(uptimeStr);
    }

    final savedSensorStatus = prefs.getString(keySensorStatus);
    if (savedSensorStatus != null) {
      sensorStatus = savedSensorStatus;
    }

    final savedFallEvent = prefs.getString(keyLastFallEvent);
    if (savedFallEvent != null) {
      lastFallEvent = savedFallEvent;
    }

    final savedSuggestion = prefs.getString(keyLastApiSuggestion);
    if (savedSuggestion != null) {
      overpassSuggestion = savedSuggestion;
    }

    final savedLocationName = prefs.getString(keyLocationName);
    if (savedLocationName != null) {
      locationName = savedLocationName;
    }

    insideDangerZone = prefs.getBool(keyInsideDangerZone) ?? false;

    // Load background-service counts if present
    final bgTotalZones = prefs.getInt('bg_total_zones');
    if (bgTotalZones != null) {
      totalZones = bgTotalZones;
    }

    final activeInside = prefs.getInt('active_zone_count') ?? 0;
    enteredZones = activeInside;

    if (totalZones > 0 && zoneSource == "Unknown") {
      zoneSource = 'Cache Only';
    }
    
    // Load next scheduled background scan
    final nextScanStr = prefs.getString('bg_next_scan');
    if (nextScanStr != null) {
      nextZoneScan = DateTime.tryParse(nextScanStr);
    }

    // Load last fall sensor timestamp saved by fall detection service
    final lastFallSensor = prefs.getString('last_fall_sensor_update');
    if (lastFallSensor != null) {
      lastFallCheck = DateTime.tryParse(lastFallSensor);
    }
    
    notifyListeners();
  }

  // =========================
  // UPDATE METHODS
  // =========================

  void updateGps({
    required bool active,
    required String status,
    double? lat,
    double? lng,
    double? gpsAccuracy,
    double? speed,
  }) async {
    gpsActive = active;
    gpsStatus = status;
    latitude = lat;
    longitude = lng;
    accuracy = gpsAccuracy;
    gpsspeed = speed;
    lastGpsUpdate = DateTime.now();

    if (lat != null && lng != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(keyLastLat, lat);
      await prefs.setDouble(keyLastLng, lng);
    }

    notifyListeners();
  }

  void updateOverpass({required bool active, required String status, String? suggestion}) async {
    overpassActive = active;
    overpassStatus = status;
    if (suggestion != null) {
      overpassSuggestion = suggestion;
    }
    lastOverpassRefresh = DateTime.now();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLastApiStatus, status);
    await prefs.setString(keyLastApiTime, lastOverpassRefresh!.toIso8601String());
    if (suggestion != null) {
      await prefs.setString(keyLastApiSuggestion, suggestion);
    }

    notifyListeners();
  }

  void updateGeofence({
    required bool active,
    required String status,
    bool? insideZone,
  }) async {
    geofenceActive = active;
    geofenceStatus = status;
    insideDangerZone = insideZone ?? false;
    lastGeofenceCheck = DateTime.now();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyInsideDangerZone, insideDangerZone);

    notifyListeners();
  }

  void updateFallDetection({required bool active, required String status}) {
    fallDetectionActive = active;
    fallDetectionStatus = status;
    lastFallCheck = DateTime.now();
    notifyListeners();
  }

  void updateLocationName(String name) async {
    locationName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLocationName, name);
    notifyListeners();
  }

  void updateNotifications({required bool active, required String status}) {
    notificationActive = active;
    notificationStatus = status;
    notifyListeners();
  }

  void updateSosDetails({
    required bool ready,
    required int contactCount,
    required bool messageValid,
  }) {
    sosReady = ready;
    sosContactCount = contactCount;
    sosMessageTemplateValid = messageValid;
    notifyListeners();
  }

  void updateLastFallEvent(String event) async {
    lastFallEvent = event;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLastFallEvent, event);

    notifyListeners();
  }

  void updateBackgroundService({required bool active, required String status}) {
    backgroundServiceActive = active;
    backgroundServiceStatus = status;
    notifyListeners();
  }

  void updateZoneCount({required int total, required int nearby, String source = 'Live Memory'}) {
    totalZones = total;
    nearbyZones = nearby;
    zoneSource = source;
    notifyListeners();
  }

  void updateLastZoneEvent(String event) {
    lastZoneEvent = event;
    notifyListeners();
  }

  void incrementEnteredZones() {
    enteredZones++;
    notifyListeners();
  }

  void setEnteredZones(int count) {
    enteredZones = count;
    notifyListeners();
  }

  void incrementRetry() {
    retryCount++;
    notifyListeners();
  }

  void resetRetry() {
    retryCount = 0;
    notifyListeners();
  }

  void updateSOS(bool ready) {
    sosReady = ready;
    notifyListeners();
  }

  void setGpsActive(bool value) {
    gpsActive = value;
    notifyListeners();
  }

  void setGeofenceActive(bool value) {
    geofenceActive = value;
    notifyListeners();
  }

  void setBackgroundServiceActive(bool value) {
    backgroundServiceActive = value;
    notifyListeners();
  }

  void setNotificationServiceActive(bool value) {
    notificationActive = value;
    notifyListeners();
  }

  void setFallDetectionActive(bool value) {
    fallDetectionActive = value;
    notifyListeners();
  }

  void setActiveZones(int count) {
    nearbyZones = count;
    notifyListeners();
  }

  void updateAccuracy(double value) {
    accuracy = value;
    notifyListeners();
  }

  void updateSpeed(double value) {
    gpsspeed = value;
    notifyListeners();
  }

  void updateLastLocation(DateTime time) {
    lastGpsUpdate = time;
    notifyListeners();
  }

  void updateNextZoneScan(DateTime time) {
    nextZoneScan = time;
    notifyListeners();
  }
}
