import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'system_status_provider.dart';

import '../services/system_status_service.dart';

import '../core/global.dart';

class LocationProvider extends ChangeNotifier {
  double? latitude;
  double? longitude;

  double speed = 0;
  double accuracy = 0;

  bool isLoading = false;

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
      return;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      systemStatusProvider?.updateGps(active: false, status: "GPS Disabled");

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

        return;
    }

    isLoading = true;

    notifyListeners();

    SystemStatusService.updateLocationStatus(
      navigatorKey.currentContext!,
    );

    positionStream?.cancel();

    positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,

            distanceFilter: 3,
          ),
        ).listen((Position position) {
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

          isLoading = false;

          notifyListeners();
        });
  }

  // conect method to system status provider for GPS updates
  void connectSystemStatus(SystemStatusProvider provider) {
    systemStatusProvider = provider;
  }

  // 📍 GET CURRENT LOCATION
  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    );

    latitude = position.latitude;

    longitude = position.longitude;

    speed = position.speed;

    accuracy = position.accuracy;

    notifyListeners();
  }

  // 🛑 STOP TRACKING
  Future<void> stopTracking() async {
    trackingEnabled = false;

    await positionStream?.cancel();
    systemStatusProvider?.updateGps(
      active: false,
      status: "Tracking Stopped",
    );

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
