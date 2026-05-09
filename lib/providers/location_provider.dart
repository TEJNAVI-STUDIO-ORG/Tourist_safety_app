import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider extends ChangeNotifier {

  double? latitude;
  double? longitude;

  bool isLoading = false;

  StreamSubscription<Position>?
      positionStream;

  // 🚀 START LIVE TRACKING
  Future<void> startLiveTracking() async {

    bool serviceEnabled =
        await Geolocator
            .isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission ==
        LocationPermission.denied) {

      permission =
          await Geolocator
              .requestPermission();
    }

    if (permission ==
            LocationPermission.deniedForever ||
        permission ==
            LocationPermission.denied) {

      return;
    }

    isLoading = true;
    notifyListeners();

    positionStream =
        Geolocator.getPositionStream(

      locationSettings:
          const LocationSettings(

        accuracy:
            LocationAccuracy.high,

        distanceFilter: 5,
      ),
    ).listen(

      (Position position) {

        latitude =
            position.latitude;

        longitude =
            position.longitude;

        isLoading = false;

        notifyListeners();
      },
    );
  }

  // 📍 GET CURRENT LOCATION ONCE
  Future<void> getCurrentLocation() async {

    Position position =
        await Geolocator.getCurrentPosition(
      locationSettings:
          const LocationSettings(
        accuracy:
            LocationAccuracy.high,
      ),
    );

    latitude = position.latitude;
    longitude = position.longitude;

    notifyListeners();
  }

  // 🛑 STOP TRACKING
  void stopTracking() {

    positionStream?.cancel();
  }
}