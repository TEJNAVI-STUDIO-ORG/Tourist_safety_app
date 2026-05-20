import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tourist_safety_app/providers/notification_provider.dart';

import '../services/background_service.dart';
import '../services/geofence_service.dart';
import '../services/overpass_service.dart';
import '../services/zone_engine_service.dart';
import 'system_status_provider.dart';

import '../services/system_status_service.dart';

import '../core/global.dart';
import 'zone_provider.dart';

class LocationProvider extends ChangeNotifier {
  double? latitude;
  double? longitude;

  double speed = 0;
  double accuracy = 0;

  bool isLoading = false;
  DateTime? lastZoneRefresh;
  bool trackingEnabled = true;

  StreamSubscription<Position>? positionStream;
  SystemStatusProvider? systemStatusProvider;

  // 🔐 REQUEST ALL PERMISSIONS
  Future<void> requestPermissions() async {
    await Permission.location.request();
    await Permission.locationAlways.request();

    await Permission.sms.request();

    await Permission.phone.request();
  }

  // 🚀 START LIVE TRACKING
  Future<void> startLiveTracking() async {
    if (!trackingEnabled) {
      isLoading = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      systemStatusProvider?.updateGps(active: false, status: "GPS Disabled");

      isLoading = false;
      notifyListeners();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      systemStatusProvider?.updateGps(
        active: false,
        status: "Permission Denied",
      );

      isLoading = false;
      notifyListeners();
      return;
    }

    isLoading = true;

    notifyListeners();

    SystemStatusService.updateLocationStatus(
      navigatorKey.currentContext!,
    );

    // 🔥 FORCE IMMEDIATE LOCATION FETCH
    try {
      await getCurrentLocation().timeout(
        const Duration(seconds: 10),
      );
    } catch (e) {
      debugPrint("Initial GPS lock failed: $e");
    }

    positionStream?.cancel();

    positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 2,
          ),
        ).listen(
          (Position position) {
            latitude = position.latitude;
            longitude = position.longitude;

            speed = position.speed;
            accuracy = position.accuracy;

            systemStatusProvider?.updateGps(
              active: true,
              status: "GPS Tracking Active",
              lat: latitude,
              lng: longitude,
              gpsAccuracy: accuracy,
              speed: speed,
            );

            debugPrint(
            "LIVE GPS: ${position.latitude}, ${position.longitude}",
            );

            isLoading = false;

            notifyListeners();
          },

          onError: (e) {
            isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<void> refreshZones(BuildContext context) async {
    if (latitude == null || longitude == null) {
      return;
    }

    final zoneProvider =
     Provider.of<ZoneProvider>(context, listen: false);

    final statusProvider = Provider.of<SystemStatusProvider>(
      context,
      listen: false,
    );

    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    final elements = await OverpassService.fetchNearbyHazards(
      lat: latitude!,
      lng: longitude!,
      statusProvider: statusProvider,
    );

    final zones = ZoneEngineService.generateZones(elements);

    zoneProvider.setZones(zones);

    await syncZonesForBackground(zones);

    GeofenceService.startMonitoring(
      locationProvider: this,
      zoneProvider: zoneProvider,
      notificationProvider: notificationProvider,
    );
  }

  // conect method to system status provider for GPS updates
  void connectSystemStatus(SystemStatusProvider provider) {
    systemStatusProvider = provider;
  }

  // 📍 GET CURRENT LOCATION
  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.bestForNavigation),
    );

    latitude = position.latitude;

    longitude = position.longitude;

    speed = position.speed;

    accuracy = position.accuracy;

    debugPrint(
      "INITIAL GPS: ${position.latitude}, ${position.longitude}",
    );

    isLoading = false; 

    notifyListeners();
  }

  // 🛑 STOP TRACKING
  Future<void> stopTracking() async {
    trackingEnabled = false;

    await positionStream?.cancel();
    systemStatusProvider?.updateGps(active: false, status: "Tracking Stopped");

    notifyListeners();
  }

  // ▶️ ENABLE TRACKING
  Future<void> enableTracking() async {
    trackingEnabled = true;

    notifyListeners();

    await startLiveTracking();
  }

  Future<void> resumeTracking() async {
    trackingEnabled = true;

    notifyListeners();

    await startLiveTracking();
  }
}
