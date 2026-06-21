import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'dart:async';

import '../providers/system_status_provider.dart';
import '../core/global.dart';
import '../providers/location_provider.dart';
import '../providers/zone_provider.dart';
import '../providers/settings_provider.dart';
import '../services/sos_service.dart';

class SystemStatusService {
  static Timer? _liveSyncTimer;

  /// Polls SharedPreferences written by the background isolate and refreshes UI.
  static void startLiveSync(BuildContext context) {
    _liveSyncTimer?.cancel();

    final provider = Provider.of<SystemStatusProvider>(context, listen: false);
    unawaited(provider.syncFromBackground());

    _liveSyncTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final ctx = navigatorKey.currentContext;
      if (ctx == null) return;
      Provider.of<SystemStatusProvider>(ctx, listen: false).syncFromBackground();
    });
  }

  static void stopLiveSync() {
    _liveSyncTimer?.cancel();
    _liveSyncTimer = null;
  }

  // =========================
  // INITIAL STATUS CHECK
  // =========================

  static Future<void> initializeAllStatus(BuildContext context) async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final systemProvider = Provider.of<SystemStatusProvider>(context, listen: false);
    
    // Load cached location and Overpass status first
    await systemProvider.loadCache();
    await systemProvider.syncFromBackground();
    
    if (settingsProvider.privateMode) {
      systemProvider.updateGps(active: false, status: "Disabled by Privacy Mode");
      systemProvider.updateGeofence(active: false, status: "Disabled by Privacy Mode");
      systemProvider.updateFallDetection(active: false, status: "Disabled by Privacy Mode");
      systemProvider.updateNotifications(active: false, status: "Disabled by Privacy Mode");
      systemProvider.updateBackgroundService(active: false, status: "Disabled by Privacy Mode");
      systemProvider.updateOverpass(active: false, status: "Disabled by Privacy Mode");
      return;
    }
    
    // Initialize notification services based on settings
    systemProvider.updateNotifications(
      active: settingsProvider.pushNotifications || settingsProvider.smsAlerts,
      status: settingsProvider.pushNotifications || settingsProvider.smsAlerts 
          ? "Notifications Active" 
          : "Notifications Disabled",
    );
    
    // Initialize geofence alerts
    systemProvider.updateGeofence(
      active: settingsProvider.geofenceAlerts,
      status: settingsProvider.geofenceAlerts 
          ? "Geofence Alerts Active" 
          : "Geofence Alerts Disabled",
    );
    
    // Initialize fall detection
    systemProvider.updateFallDetection(
      active: settingsProvider.fallDetection,
      status: settingsProvider.fallDetection 
          ? "Fall Detection Active" 
          : "Fall Detection Disabled",
    );
    
    // Initialize SOS system
    SosService.checkAndUpdateSosStatus(
      statusProvider: systemProvider,
      settingsProvider: settingsProvider,
    );
    
    // Initialize background service status
    final isRunning = await FlutterBackgroundService().isRunning();
    updateBackgroundService(context, active: isRunning);

    startLiveSync(context);
  }

  // =========================
  // LOCATION STATUS
  // =========================

  static void updateLocationStatus(
    BuildContext context,
  ) {
    final locationProvider =
        Provider.of<LocationProvider>(
      context,
      listen: false,
    );

    final systemProvider =
        Provider.of<SystemStatusProvider>(
      context,
      listen: false,
    );

    final hasLocation =
        locationProvider.latitude !=
                null &&
            locationProvider.longitude !=
                null;

    systemProvider.updateGps(
      active: hasLocation,
      status: hasLocation
          ? "GPS Active"
          : "GPS Offline",
      lat: locationProvider.latitude,
      lng: locationProvider.longitude,
      gpsAccuracy:
          locationProvider.accuracy,
      speed: locationProvider.speed,
    );

    systemProvider.updateAccuracy(
      locationProvider.accuracy,
    );

    systemProvider.updateSpeed(
      locationProvider.speed,
    );

    systemProvider.updateLastLocation(
      DateTime.now(),
    );
  }

  // =========================
  // ZONE STATUS
  // =========================

  static void updateZoneStatus(
    BuildContext context,
  ) {
    final zoneProvider =
        Provider.of<ZoneProvider>(
      context,
      listen: false,
    );

    final locationProvider =
        Provider.of<LocationProvider>(
      context,
      listen: false,
    );

    final systemProvider =
        Provider.of<SystemStatusProvider>(
      context,
      listen: false,
    );

    final totalZones =
        zoneProvider.zones.length;

    final userLat =
        locationProvider.latitude;

    final userLng =
        locationProvider.longitude;

    int nearbyZones = 0;

    if (userLat != null &&
        userLng != null) {

      nearbyZones =
          zoneProvider.zones.where((zone) {

        final distance =
            Geolocator.distanceBetween(
          userLat,
          userLng,
          zone.center.latitude,
          zone.center.longitude,
        );

        return distance <= 500;
      }).length;
    }

    systemProvider.updateZoneCount(
      total: totalZones,
      nearby: nearbyZones,
    );

    systemProvider.setActiveZones(
      nearbyZones,
    );

    systemProvider.updateGeofence(
      active: totalZones > 0,
      status: totalZones > 0
          ? "Monitoring Zones"
          : "No Zones Loaded",
      insideZone: nearbyZones > 0,
    );

    systemProvider.updateNextZoneScan(
      DateTime.now().add(
        const Duration(minutes: 5),
      ),
    );
  }

  // =========================
  // BACKGROUND SERVICE
  // =========================

  static void updateBackgroundService(
    BuildContext context, {
    required bool active,
  }) {
    final systemProvider =
        Provider.of<SystemStatusProvider>(
      context,
      listen: false,
    );

    systemProvider.updateBackgroundService(
      active: active,
      status: active
          ? "Foreground Service Running"
          : "Background Service Stopped",
    );
  }

  // =========================
  // FALL DETECTION
  // =========================

  static void updateFallDetection(
    BuildContext context, {
    required bool active,
  }) {
    final systemProvider =
        Provider.of<SystemStatusProvider>(
      context,
      listen: false,
    );

    systemProvider.updateFallDetection(
      active: active,
      status: active
          ? "Fall Detection Active"
          : "Fall Detection Disabled",
    );
  }

  // =========================
  // NOTIFICATIONS
  // =========================

  static void updateNotificationStatus(
    BuildContext context, {
    required bool active,
  }) {
    final systemProvider =
        Provider.of<SystemStatusProvider>(
      context,
      listen: false,
    );

    systemProvider.updateNotifications(
      active: active,
      status: active
          ? "Notifications Active"
          : "Notifications Disabled",
    );
  }

  // =========================
  // OVERPASS STATUS
  // =========================

  static void updateOverpassStatus(
    BuildContext context, {
    required bool active,
    required String status,
  }) {
    final systemProvider =
        Provider.of<SystemStatusProvider>(
      context,
      listen: false,
    );

    systemProvider.updateOverpass(
      active: active,
      status: status,
    );
  }

  // =========================
  // LAST ZONE EVENT
  // =========================

  static void updateZoneEvent(
    BuildContext context, {
    required String event,
  }) {
    final systemProvider =
        Provider.of<SystemStatusProvider>(
      context,
      listen: false,
    );

    systemProvider.updateLastZoneEvent(
      event,
    );
  }
}