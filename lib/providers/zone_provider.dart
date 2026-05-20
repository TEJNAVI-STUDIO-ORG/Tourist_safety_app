import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/zone_model.dart';

import '../services/background_service.dart';
import '../services/overpass_service.dart';
import '../services/zone_cache_service.dart';
import '../services/zone_engine_service.dart';

import 'location_provider.dart';
import 'system_status_provider.dart';

class ZoneProvider extends ChangeNotifier {
  List<ZoneModel> zones = [];

  bool zonesLoaded = false;

  bool _loadingTriggered = false;

  bool isLoadingZones = false;

  // =========================
  // SET ZONES
  // =========================

  void setZones(List<ZoneModel> newZones) {
    zones = newZones;

    zonesLoaded = true;

    notifyListeners();
  }

  // =========================
  // CLEAR ZONES
  // =========================

  Future<void> clearZones() async {
    zones.clear();

    zonesLoaded = false;

    await ZoneCacheService.clearZones();

    notifyListeners();
  }

  // =========================
  // LOAD CACHED ZONES
  // =========================

  Future<void> loadCachedZones() async {
    try {
      final cachedData = await ZoneCacheService.loadZones();

      if (cachedData == null) {
        debugPrint("No cached zones found");

        return;
      }

      final List decoded = jsonDecode(cachedData);

      zones = decoded.map((e) => ZoneModel.fromJson(e)).toList();

      zonesLoaded = true;

      debugPrint("Loaded Cached Zones: ${zones.length}");

      notifyListeners();
    } catch (e) {
      debugPrint("Cache Load Error: $e");
    }
  }

  // =========================
  // SAVE ZONES TO CACHE
  // =========================

  Future<void> saveZonesToCache(List<ZoneModel> zonesToSave) async {
    try {
      final jsonData = jsonEncode(
        zonesToSave.map((zone) => zone.toJson()).toList(),
      );

      await ZoneCacheService.saveZones(jsonData);

      debugPrint("Zones Cached Successfully");
    } catch (e) {
      debugPrint("Cache Save Error: $e");
    }
  }

  // =========================
  // LOAD ZONES FROM API
  // =========================

  Future<void> loadZones({
    required double lat,
    required double lng,
    required SystemStatusProvider statusProvider,
  }) async {
    if (isLoadingZones) {
      return;
    }

    isLoadingZones = true;

    notifyListeners();

    try {
      final elements = await OverpassService.fetchNearbyHazards(
        lat: lat,
        lng: lng,
        statusProvider: statusProvider,
      );

      final generatedZones = ZoneEngineService.generateZones(elements);

      // =========================
      // TEST ZONE
      // =========================

      generatedZones.add(
        ZoneModel(
          id: 'test_zone',

          type: 'danger_test',

          name: 'TEST DANGER ZONE',

          center: LatLng(lat + 0.00002, lng),

          radius: 2.22,

          color: Colors.red,

          riskScore: 10,

          severity: 'danger',
        ),
      );
      
      setZones(generatedZones);

      zonesLoaded = true;

      // SAVE CACHE
      await saveZonesToCache(generatedZones);

      // BACKGROUND GEOFENCE
      await syncZonesForBackground(generatedZones);

      debugPrint("Generated Zones: ${generatedZones.length}");
    } catch (e) {
      debugPrint("Zone Loading Error: $e");
    }

    isLoadingZones = false;

    notifyListeners();
  }

  // =========================
  // INITIAL LOAD
  // =========================

  Future<void> triggerInitialLoad({
    required BuildContext context,
    required LocationProvider locationProvider,
    required SystemStatusProvider statusProvider,
  }) async {
    if (_loadingTriggered) return;

    _loadingTriggered = true;

    // =========================
    // LOAD CACHED ZONES FIRST
    // =========================

    await loadCachedZones();

    // =========================
    // REFRESH ONLY IF GPS READY
    // =========================

    if (locationProvider.latitude == null ||
        locationProvider.longitude == null) {
      return;
    }

    refreshZones(
      lat: locationProvider.latitude!,
      lng: locationProvider.longitude!,
      statusProvider: statusProvider,
    );
  }

  // =========================
  // FORCE REFRESH
  // =========================

  Future<void> refreshZones({
    required double lat,
    required double lng,
    required SystemStatusProvider statusProvider,
  }) async {
    await loadZones(lat: lat, lng: lng, statusProvider: statusProvider);
  }
}
