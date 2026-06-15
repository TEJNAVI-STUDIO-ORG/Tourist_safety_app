import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/zone_provider.dart';
import 'advanced_fall_detection_service.dart';
import 'battery_optimization_service.dart';
import '../providers/system_status_provider.dart';
import '../providers/settings_provider.dart';
import 'geofence_service.dart';

class ServiceHealthReport {
  final bool gpsEnabled;
  final bool locationPermission;
  final bool backgroundPermission;
  final bool smsPermission;
  final bool notificationPermission;
  final bool backgroundServiceRunning;
  final bool batteryOptimizationDisabled;
  final DateTime timestamp;

  ServiceHealthReport({
    required this.gpsEnabled,
    required this.locationPermission,
    required this.backgroundPermission,
    required this.smsPermission,
    required this.notificationPermission,
    required this.backgroundServiceRunning,
    required this.batteryOptimizationDisabled,
    required this.timestamp,
  });

  bool get isHealthy =>
      gpsEnabled &&
      locationPermission &&
      backgroundPermission &&
      smsPermission &&
      notificationPermission &&
      backgroundServiceRunning &&
      batteryOptimizationDisabled;
}

class ServiceHealthMonitor {
  static Timer? _watchdogTimer;

  static void start(BuildContext context) {
    _watchdogTimer?.cancel();
    // Verify on start
    performFullVerification(context);
    
    // Periodic check every 5 minutes
    _watchdogTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      await performFullVerification(context);
    });
  }

  static Future<ServiceHealthReport> performFullVerification(BuildContext context) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final status = Provider.of<SystemStatusProvider>(context, listen: false);

    // Skip verification if privacy mode is on
    if (settings.privateMode) {
      return ServiceHealthReport(
        gpsEnabled: false,
        locationPermission: false,
        backgroundPermission: false,
        smsPermission: false,
        notificationPermission: false,
        backgroundServiceRunning: false,
        batteryOptimizationDisabled: false,
        timestamp: DateTime.now(),
      );
    }

    // 1. GPS Check
    bool gpsEnabled = await Geolocator.isLocationServiceEnabled();
    
    // 2. Permissions Check
    bool locPerm = await Permission.location.isGranted;
    bool bgLocPerm = await Permission.locationAlways.isGranted;
    bool smsPerm = await Permission.sms.isGranted;
    bool notifPerm = await Permission.notification.isGranted;

    // 3. BG Service Check
    final service = FlutterBackgroundService();
    bool bgRunning = await service.isRunning();

    // 4. Battery Optimization Check
    bool batteryOptimized = await BatteryOptimizationService.isOptimized();

    final report = ServiceHealthReport(
      gpsEnabled: gpsEnabled,
      locationPermission: locPerm,
      backgroundPermission: bgLocPerm,
      smsPermission: smsPerm,
      notificationPermission: notifPerm,
      backgroundServiceRunning: bgRunning,
      batteryOptimizationDisabled: !batteryOptimized,
      timestamp: DateTime.now(),
    );

    // AUTO REPAIR
    if (!bgRunning && !settings.privateMode) {
      await service.startService();
    }

    // Update Providers
    status.updateBackgroundService(
      active: bgRunning,
      status: bgRunning ? "Healthy" : "Dead (Restarting...)",
    );

    return report;
  }

  static Future<void> checkAndRepair(BuildContext context) async {
    final report = await performFullVerification(context);
    
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final location = Provider.of<LocationProvider>(context, listen: false);
    final status = Provider.of<SystemStatusProvider>(context, listen: false);

    if (settings.privateMode) return;

    // 1. REPAIR BACKGROUND SERVICE
    if (!report.backgroundServiceRunning) {
      debugPrint("Repairing Background Service...");
      await FlutterBackgroundService().startService();
    }

    // 2. REPAIR GPS / LOCATION
    if (!report.gpsEnabled || !report.locationPermission || status.latitude == null) {
      debugPrint("Repairing Location Services...");
      await location.startLiveTracking();
    } else if (DateTime.now().difference(status.lastGpsUpdate ?? DateTime(2000)).inMinutes > 2) {
      // Force refresh if stalled
      debugPrint("GPS stalled - requesting fresh lock...");
      await location.getCurrentLocation();
    }

    // 3. REPAIR FALL DETECTION
    if (settings.fallDetection && (!status.fallDetectionActive || status.sensorStatus != 'active')) {
      debugPrint("Repairing Fall Detection...");
      AdvancedFallDetectionService.startDetection();
    }

    // 4. REPAIR OVERPASS / ZONES
    if (status.totalZones == 0 || (status.lastOverpassRefresh != null && DateTime.now().difference(status.lastOverpassRefresh!).inMinutes > 10)) {
       debugPrint("Repairing Zone Engine...");
       if (status.latitude != null && status.longitude != null) {
         await location.refreshZones(context);
       }
    }

    // 5. REPAIR GEOFENCING
    if (settings.geofenceAlerts && !status.geofenceActive) {
      debugPrint("Repairing Geofencing...");
      final zones = Provider.of<ZoneProvider>(context, listen: false);
      final notifications = Provider.of<NotificationProvider>(context, listen: false);
      GeofenceService.startMonitoring(
        locationProvider: location,
        zoneProvider: zones,
        notificationProvider: notifications,
      );
    }
    
    // Final verification
    await performFullVerification(context);
  }

  static void stop() {
    _watchdogTimer?.cancel();
  }
}
