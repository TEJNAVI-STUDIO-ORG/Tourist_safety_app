import 'dart:math';

import 'package:flutter/material.dart';

import 'package:latlong2/latlong.dart';

import '../models/zone_model.dart';

class ZoneEngineService {
  static List<ZoneModel> generateZones(List<dynamic> elements) {
    List<ZoneModel> zones = [];

    for (var element in elements) {
      final tags = element['tags'] ?? {};

      String type = 'unknown';

      Color color = Colors.green;

      int risk = 1;

      double radius = 100;

      String severity = 'safe';

      // =========================
      // CLIFF
      // =========================

      if (tags['natural'] == 'cliff') {
        type = 'cliff';

        color = Colors.red;

        risk = 10;

        radius = 180;

        severity = 'danger';
      }
      // =========================
      // FOREST
      // =========================
      else if (tags['landuse'] == 'forest') {
        type = 'forest';

        color = Colors.orange;

        risk = 7;

        radius = 140;

        severity = 'warning';
      }
      // =========================
      // WATER
      // =========================
      else if (tags['natural'] == 'water') {
        type = 'water';

        color = Colors.yellow;

        risk = 5;

        radius = 120;

        severity = 'caution';
      }
      // =========================
      // MOUNTAIN
      // =========================
      else if (tags['natural'] == 'peak') {
        type = 'mountain';

        color = Colors.orange;

        risk = 8;

        radius = 180;

        severity = 'warning';
      }
      // =========================
      // MILITARY
      // =========================
      else if (tags.containsKey('military')) {
        type = 'restricted';

        color = Colors.red.shade900;

        risk = 10;

        radius = 220;

        severity = 'danger';
      }
      // =========================
      // Amenity
      // =========================
      else if (tags['amenity'] == 'hospital') {
        type = 'safe_zone';

        color = Colors.green;

        risk = 1;

        radius = 70;

        severity = 'safe';
      } else if (tags['amenity'] == 'police') {
        type = 'police';

        color = Colors.green;

        risk = 1;

        radius = 60;

        severity = 'safe';
      } else if (tags['amenity'] == 'fire_station') {
        type = 'fire_station';

        color = Colors.green;

        risk = 1;

        radius = 60;

        severity = 'safe';
      } else if (tags.containsKey('tourism')) {
        type = 'tourist_zone';

        color = Colors.green;

        risk = 1;

        radius = 70;

        severity = 'safe';
      }
      // =========================
      // HAZARD
      // =========================
      else if (tags.containsKey('hazard')) {
        type = 'hazard';

        color = Colors.red;

        risk = 9;

        radius = 180;

        severity = 'danger';
      }
      // =========================
      // FALLBACK FOR NAMED ENTITIES
      // =========================
      else if (tags.containsKey('name')) {
        type = tags['amenity'] ?? tags['natural'] ?? tags['landuse'] ?? tags['tourism'] ?? 'poi';
        
        color = Colors.blue.withOpacity(0.5);
        risk = 3;
        radius = 80;
        severity = 'caution';
      }
      // =========================
      // SKIP UNKNOWN
      // =========================
      else {
        continue;
      }

      double? lat = element['lat'] ?? element['center']?['lat'];

      double? lng = element['lon'] ?? element['center']?['lon'];

      if (lat == null || lng == null) {
        continue;
      }

      final center = LatLng(lat, lng);

      // =========================
      // DUPLICATE FILTER
      // =========================

      bool tooClose = false;

      for (var existingZone in zones) {
        final distance = _calculateDistanceMeters(center, existingZone.center);

        if (distance < 10) {
          tooClose = true;

          break;
        }
      }

      if (tooClose) {
        continue;
      }

      zones.add(
        ZoneModel(
          id: element['id'].toString(),

          type: type,

          name: (tags['name'] ?? type).toString().toUpperCase(),

          center: center,

          radius: radius,

          color: color,

          riskScore: risk,

          severity: severity,
        ),
      );
    }

    print("Generated Zones: ${zones.length}");

    return zones;
  }

  // =========================
  // DISTANCE CALCULATION
  // =========================

  static double _calculateDistanceMeters(LatLng start, LatLng end) {
    const double earthRadius = 6371000;

    final dLat = _degToRad(end.latitude - start.latitude);

    final dLng = _degToRad(end.longitude - start.longitude);

    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degToRad(start.latitude)) *
            cos(_degToRad(end.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _degToRad(double deg) {
    return deg * 0.017453292519943295;
  }
}
