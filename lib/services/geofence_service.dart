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
      const Duration(seconds: 5),
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

    final userLocation = LatLng(lat, lng);

    for (final ZoneModel zone in zoneProvider.zones) {
      final distance = _distance.as(
        LengthUnit.Meter,
        userLocation,
        zone.center,
      );

      final inside = distance <= zone.radius;

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
      }
    }
  }
}
