import 'package:flutter/material.dart';

class SystemStatusProvider extends ChangeNotifier {
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

  DateTime? lastOverpassRefresh;

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

  // =========================
  // FALL DETECTION
  // =========================

  bool fallDetectionActive = false;

  String fallDetectionStatus = "Inactive";

  DateTime? lastFallCheck;

  // =========================
  // NOTIFICATIONS
  // =========================

  bool notificationActive = false;

  String notificationStatus = "Inactive";

  // =========================
  // BACKGROUND SERVICE
  // =========================

  bool backgroundServiceActive = false;

  String backgroundServiceStatus = "Stopped";

  // =========================
  // SOS
  // =========================

  bool sosReady = false;



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
  }) {
    gpsActive = active;

    gpsStatus = status;

    latitude = lat;

    longitude = lng;

    accuracy = gpsAccuracy;

    gpsspeed = speed;

    lastGpsUpdate = DateTime.now();

    notifyListeners();
  }

  void updateOverpass({required bool active, required String status}) {
    overpassActive = active;

    overpassStatus = status;

    lastOverpassRefresh = DateTime.now();

    notifyListeners();
  }

  void updateGeofence({
    required bool active,
    required String status,
    bool? insideZone,
  }) {
    geofenceActive = active;

    geofenceStatus = status;

    insideDangerZone = insideZone ?? false;

    lastGeofenceCheck = DateTime.now();

    notifyListeners();
  }

  void updateFallDetection({required bool active, required String status}) {
    fallDetectionActive = active;

    fallDetectionStatus = status;

    lastFallCheck = DateTime.now();

    notifyListeners();
  }

  void updateNotifications({required bool active, required String status}) {
    notificationActive = active;

    notificationStatus = status;

    notifyListeners();
  }

  void updateBackgroundService({required bool active, required String status}) {
    backgroundServiceActive = active;

    backgroundServiceStatus = status;

    notifyListeners();
  }

  void updateZoneCount({required int total, required int nearby}) {
    totalZones = total;

    nearbyZones = nearby;

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
