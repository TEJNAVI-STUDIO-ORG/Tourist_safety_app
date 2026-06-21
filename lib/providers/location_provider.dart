import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';
import 'package:tourist_safety_app/providers/notification_provider.dart';

import '../services/background_service.dart';
import '../services/geofence_service.dart';
import '../services/overpass_service.dart';
import '../services/zone_engine_service.dart';
import 'system_status_provider.dart';

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

  bool _starting = false;
  bool _streamAlive = false;

  static const String _lastLatKey = 'last_lat';
  static const String _lastLngKey = 'last_lng';
  static const String _lastLocationUpdateKey = 'last_location_update';

  Future<bool> _hasRecentBackgroundFix() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = DateTime.tryParse(
      prefs.getString(_lastLocationUpdateKey) ?? '',
    );
    if (lastUpdate == null) return false;
    return DateTime.now().difference(lastUpdate) <
        const Duration(minutes: 2);
  }

  Future<void> _restoreCachedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedLat = prefs.getDouble(_lastLatKey);
    final cachedLng = prefs.getDouble(_lastLngKey);
    final lastUpdateRaw = prefs.getString(_lastLocationUpdateKey);

    if (cachedLat == null || cachedLng == null) return;

    latitude = cachedLat;
    longitude = cachedLng;
    speed = prefs.getDouble('last_speed') ?? speed;
    accuracy = prefs.getDouble('last_accuracy') ?? accuracy;
    isLoading = false;

    final lastUpdate = DateTime.tryParse(lastUpdateRaw ?? '');
    final isRecent = lastUpdate != null &&
        DateTime.now().difference(lastUpdate) < const Duration(minutes: 5);

    systemStatusProvider?.updateGps(
      active: isRecent,
      status: isRecent ? 'GPS Active (background)' : 'Last known location',
      lat: latitude,
      lng: longitude,
      gpsAccuracy: accuracy,
      speed: speed,
    );
    notifyListeners();
  }

  bool get hasMapLocation => latitude != null && longitude != null;

  LatLng? get mapCenter {
    if (latitude == null || longitude == null) return null;
    return LatLng(latitude!, longitude!);
  }

  Future<void> _persistLocation(Position position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_lastLatKey, position.latitude);
    await prefs.setDouble(_lastLngKey, position.longitude);
    await prefs.setDouble('last_speed', position.speed);
    await prefs.setDouble('last_accuracy', position.accuracy);
    await prefs.setString(
      _lastLocationUpdateKey,
      DateTime.now().toIso8601String(),
    );
  }

  void _invalidateStream() {
    positionStream?.cancel();
    positionStream = null;
    _streamAlive = false;
  }

  bool get _hasActiveStream => _streamAlive && positionStream != null;

  /// Pulls the latest fix written by the background service into the UI.
  Future<void> restoreFromBackground() async {
    await _restoreCachedLocation();
  }

  /// Called when the UI engine re-attaches after the activity was destroyed.
  Future<void> onUiEngineReattached() async {
    _invalidateStream();
    await restoreFromBackground();
    await resumeIfNeeded();
  }

  /// Restores the last known fix and only opens a new stream when needed.
  Future<void> resumeIfNeeded() async {
    if (!trackingEnabled || _starting) return;

    _starting = true;
    try {
      await _restoreCachedLocation();

      if (_hasActiveStream) {
        isLoading = false;
        notifyListeners();
        return;
      }

      _invalidateStream();
      await _attachPositionStream(
        skipColdFix: await _hasRecentBackgroundFix() || latitude != null,
      );
    } finally {
      _starting = false;
    }
  }

  // 🔐 REQUEST ALL PERMISSIONS
  Future<void> requestPermissions() async {
    await Permission.location.request();
    await Permission.locationAlways.request();

    await Permission.sms.request();

    await Permission.phone.request();
  }

  // 🚀 START LIVE TRACKING
  Future<void> startLiveTracking({bool forceColdStart = true}) async {
    if (!trackingEnabled || _starting) return;

    _starting = true;
    try {
      if (!forceColdStart) {
        await _restoreCachedLocation();
        if (_hasActiveStream) {
          isLoading = false;
          notifyListeners();
          return;
        }
      }

      _invalidateStream();

      final skipColdFix = !forceColdStart &&
          (await _hasRecentBackgroundFix() || latitude != null);

      if (!skipColdFix) {
        isLoading = true;
        notifyListeners();
      }

      await _attachPositionStream(skipColdFix: skipColdFix);
    } finally {
      _starting = false;
    }
  }

  Future<bool> _ensureLocationReady() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      systemStatusProvider?.updateGps(active: false, status: 'GPS Disabled');
      isLoading = false;
      notifyListeners();
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      systemStatusProvider?.updateGps(
        active: false,
        status: 'Permission Denied',
      );
      isLoading = false;
      notifyListeners();
      return false;
    }

    return true;
  }

  Future<void> _attachPositionStream({required bool skipColdFix}) async {
    if (!await _ensureLocationReady()) return;
    if (_hasActiveStream) return;

    if (!skipColdFix) {
      try {
        await getCurrentLocation().timeout(const Duration(seconds: 10));
      } catch (e) {
        debugPrint('Initial GPS lock failed: $e');
      }
    } else {
      isLoading = false;
      notifyListeners();
    }

    positionStream = Geolocator.getPositionStream(
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

        unawaited(_persistLocation(position));

        systemStatusProvider?.updateGps(
          active: true,
          status: 'Live GPS Active',
          lat: latitude,
          lng: longitude,
          gpsAccuracy: accuracy,
          speed: speed,
        );

        debugPrint('LIVE GPS: ${position.latitude}, ${position.longitude}');

        isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _streamAlive = false;
        isLoading = false;
        notifyListeners();
      },
      onDone: () {
        _streamAlive = false;
      },
    );

    _streamAlive = true;
  }

  Future<void> refreshZones(BuildContext context) async {
    if (latitude == null || longitude == null) {
      return;
    }

    final zoneProvider = Provider.of<ZoneProvider>(context, listen: false);

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

    statusProvider.updateZoneCount(
      total: zones.length,
      nearby: statusProvider.nearbyZones,
      source: 'Live Memory',
    );

    await syncZonesForBackground(zones);

    GeofenceService.startMonitoring(
      locationProvider: this,
      zoneProvider: zoneProvider,
      notificationProvider: notificationProvider,
    );
  }

  void connectSystemStatus(SystemStatusProvider provider) {
    systemStatusProvider = provider;
  }

  Future<void> getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    );

    latitude = position.latitude;
    longitude = position.longitude;
    speed = position.speed;
    accuracy = position.accuracy;

    unawaited(_persistLocation(position));

    debugPrint('INITIAL GPS: ${position.latitude}, ${position.longitude}');

    isLoading = false;
    notifyListeners();
  }

  Future<void> stopTracking() async {
    trackingEnabled = false;

    _invalidateStream();
    systemStatusProvider?.updateGps(active: false, status: 'Tracking Stopped');

    notifyListeners();
  }

  Future<void> enableTracking() async {
    trackingEnabled = true;
    notifyListeners();
    await startLiveTracking(forceColdStart: false);
  }

  Future<void> resumeTracking() async {
    trackingEnabled = true;
    notifyListeners();
    await resumeIfNeeded();
  }
}
