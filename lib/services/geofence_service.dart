import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/zone_model.dart';
import '../models/notification_model.dart';

import '../providers/location_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/zone_provider.dart';

import 'notification_service.dart';

class GeofenceService {
  static final Distance _distance = Distance();

  static Timer? _timer;

  static List<String> activeZones = [];

  static void startMonitoring({
    required LocationProvider locationProvider,
    required ZoneProvider zoneProvider,
    required NotificationProvider notificationProvider,
  }) {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) async {
        await _checkZones(
          locationProvider,
          zoneProvider,
          notificationProvider,
        );
      },
    );
  }

  static void stopMonitoring() {
    _timer?.cancel();
  }

  static Future<void> _checkZones(
    LocationProvider locationProvider,
    ZoneProvider zoneProvider,
    NotificationProvider notificationProvider,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('geofenceAlerts') ?? true)) return;
    if (!(prefs.getBool('pushNotifications') ?? true)) return;

    final lat = locationProvider.latitude;
    final lng = locationProvider.longitude;

    if (lat == null || lng == null) {
      return;
    }

    // Update system status (monitoring)
    locationProvider.systemStatusProvider?.updateGeofence(
      active: true,
      status: "Monitoring ${zoneProvider.zones.length} Zones",
    );

    final userLocation = LatLng(lat, lng);
    bool anyInside = false;
    int nearbyCount = 0;
    String? lastEvent;

    for (final ZoneModel zone in zoneProvider.zones) {
      final distance = _distance.as(
        LengthUnit.Meter,
        userLocation,
        zone.center,
      );

      final inside = distance <= zone.radius;

      if (inside) {
        anyInside = true;
      }

      // mark nearby if within radius + 100m buffer
      if (distance <= zone.radius + 100) {
        nearbyCount++;
      }

      final alreadyInside = activeZones.contains(zone.id);

      if (inside && !alreadyInside) {
        activeZones.add(zone.id);

        final id = DateTime.now().millisecondsSinceEpoch.toString();
        final title = 'Entered ${zone.name}';
        final body = 'You entered a ${zone.severity} zone.';

        await notificationProvider.addNotification(
          AppNotification(
            id: id,
            title: title,
            body: body,
            type: 'zone_enter',
            time: DateTime.now(),
            severity: zone.severity,
            isRead: false,
          ),
        );

        await NotificationService.showNotification(
          title: title,
          body: body,
          notificationId: int.parse(id) % 2147483647,
        );

        lastEvent = title;

        if (zone.severity == 'danger') {
          debugPrint('DANGER ZONE ALERT');
        }
      } else if (!inside && alreadyInside) {
        activeZones.remove(zone.id);

        final id = DateTime.now().millisecondsSinceEpoch.toString();
        final title = 'Exited ${zone.name}';
        final body = 'You left the zone safely.';

        await notificationProvider.addNotification(
          AppNotification(
            id: id,
            title: title,
            body: body,
            type: 'zone_exit',
            time: DateTime.now(),
            severity: zone.severity,
            isRead: false,
          ),
        );

        await NotificationService.showNotification(
          title: title,
          body: body,
          notificationId: int.parse(id) % 2147483647,
        );

        lastEvent = title;
      }
    }

    // Persist active zone ids and last event for background visibility
    try {
      await prefs.setStringList('bg_active_zone_ids', activeZones);
      await prefs.setInt('active_zone_count', activeZones.length);
      if (lastEvent != null) {
        await prefs.setString('last_zone_event', lastEvent);
      }
    } catch (_) {}

    // Update system status provider counts and last event
    locationProvider.systemStatusProvider?.updateZoneCount(
      total: zoneProvider.zones.length,
      nearby: nearbyCount,
    );

    locationProvider.systemStatusProvider?.setEnteredZones(activeZones.length);

    // Update geofence inside state and last event
    locationProvider.systemStatusProvider?.updateGeofence(
      active: zoneProvider.zones.isNotEmpty,
      status: "Monitoring ${zoneProvider.zones.length} Zones",
      insideZone: anyInside,
    );

    if (lastEvent != null) {
      locationProvider.systemStatusProvider?.updateLastZoneEvent(lastEvent);
    }
  }
}
