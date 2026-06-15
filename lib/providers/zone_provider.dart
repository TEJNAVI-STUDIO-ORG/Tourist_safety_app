import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final Distance _distanceCalculator = const Distance();

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

  Future<void> loadCachedZones({SystemStatusProvider? statusProvider}) async {
    try {
      final cachedData = await ZoneCacheService.loadZones();

      if (cachedData == null) {
        debugPrint("No cached zones found");

        return;
      }

      final List decoded = jsonDecode(cachedData);

      zones = decoded.map((e) => ZoneModel.fromJson(e)).toList();

      zonesLoaded = true;

      // Update global status with cached counts when available
      if (statusProvider != null) {
        statusProvider.updateZoneCount(
          total: zones.length,
          nearby: statusProvider.nearbyZones,
          source: 'Cache Only',
        );
      }

      debugPrint("Loaded Cached Zones: ${zones.length}");

      notifyListeners();
    } catch (e) {
      debugPrint("Cache Load Error: $e");
    }
  }

  // =========================
  // SAVE ZONES TO CACHE
  // =========================

  Future<void> saveZonesToCache(List<ZoneModel> zonesToSave, {double? lat, double? lng}) async {
    try {
      final jsonData = jsonEncode(
        zonesToSave.map((zone) => zone.toJson()).toList(),
      );

      await ZoneCacheService.saveZones(jsonData, lat: lat, lng: lng);

      debugPrint("Zones Cached Successfully at location: $lat, $lng");
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
    bool forceRefresh = false,
  }) async {
    if (isLoadingZones) {
      return;
    }

    // =========================================================================
    // SMART FETCH LOGIC
    // =========================================================================
    // Only fetch if forced OR if user moved significantly from last cached location
    if (!forceRefresh && zones.isNotEmpty) {
      final lastLoc = await ZoneCacheService.getLastLocation();
      if (lastLoc != null) {
        final lastPoint = LatLng(lastLoc['lat']!, lastLoc['lng']!);
        final currentPoint = LatLng(lat, lng);
        final distance = _distanceCalculator.as(LengthUnit.Meter, lastPoint, currentPoint);
        
        // If user moved less than 600 meters, don't re-fetch
        if (distance < 600) {
          debugPrint("User hasn't moved enough ($distance m). Skipping API fetch.");
          statusProvider.updateZoneCount(
            total: zones.length,
            nearby: statusProvider.nearbyZones,
            source: 'Cache (Nearby)',
          );
          return;
        }
      }
    }

    isLoadingZones = true;

    notifyListeners();

    try {
      final elements = await OverpassService.fetchNearbyHazards(
        lat: lat,
        lng: lng,
        statusProvider: statusProvider,
      );

      // CRITICAL FIX: If API fails (returns empty list), do NOT clear existing zones
      if (elements.isEmpty && zones.isNotEmpty) {
        debugPrint("API returned no results/failed. Keeping existing cached zones.");
        isLoadingZones = false;
        notifyListeners();
        return;
      }

      final generatedZones = ZoneEngineService.generateZones(elements);

      // =========================
      // TEST ZONE
      // =========================
      
      final prefs = await SharedPreferences.getInstance();
      final showTest = prefs.getBool('showTestZone') ?? false;

      if (showTest) {
        generatedZones.add(
          ZoneModel(
            id: 'test_zone',
            type: 'danger_test',
            name: 'TEST DANGER ZONE',
            center: LatLng(lat + 0.0005, lng + 0.0005),
            radius: 50.0,
            color: Colors.red,
            riskScore: 10,
            severity: 'danger',
          ),
        );
      }
      
      setZones(generatedZones);

      zonesLoaded = true;

      // Keep system status in sync with freshly loaded zones
      statusProvider.updateZoneCount(
        total: generatedZones.length,
        nearby: statusProvider.nearbyZones,
        source: 'Live Memory',
      );

      // SAVE CACHE with new location
      await saveZonesToCache(generatedZones, lat: lat, lng: lng);

      // BACKGROUND GEOFENCE
      await syncZonesForBackground(generatedZones);

      debugPrint("Generated Zones: ${generatedZones.length}");
    } catch (e) {
      debugPrint("Zone Loading Error: $e");
      // Keep existing zones on error
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

    await loadCachedZones(statusProvider: statusProvider);

    // =========================
    // REFRESH ONLY IF GPS READY
    // =========================

    if (locationProvider.latitude == null ||
        locationProvider.longitude == null) {
      
      // Listen for first location
      debugPrint("Waiting for GPS lock to fetch zones...");
      
      late Function() listener;
      listener = () {
        if (locationProvider.latitude != null &&
            locationProvider.longitude != null) {
          
          locationProvider.removeListener(listener);
          
          refreshZones(
            lat: locationProvider.latitude!,
            lng: locationProvider.longitude!,
            statusProvider: statusProvider,
          );
        }
      };
      
      locationProvider.addListener(listener);
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
    bool force = false,
  }) async {
    await loadZones(
      lat: lat, 
      lng: lng, 
      statusProvider: statusProvider,
      forceRefresh: force,
    );
  }
}
