import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/zone_model.dart';
import 'notification_service.dart';
import 'overpass_service.dart';
import 'zone_engine_service.dart';

class BackgroundServiceKeys {
  static const String zones = 'bg_zones';
  static const String activeZones = 'bg_active_zone_ids';
  static const String notifications = 'notifications';
  static const String bgRunning = 'bg_running';

  static const String nextScan = 'bg_next_scan';

  static const String totalZones = 'bg_total_zones';
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      autoStartOnBoot: true,
      isForegroundMode: true,
      notificationChannelId: 'guardian_tracking',
      initialNotificationTitle: 'Guardian Pulse',
      initialNotificationContent: 'Safety tracking active',
      foregroundServiceNotificationId: 999,
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
    iosConfiguration: IosConfiguration(),
  );
}

Future<void> syncZonesForBackground(List<ZoneModel> zones) async {
  final prefs = await SharedPreferences.getInstance();
  final encodedZones = zones
      .map(
        (zone) => jsonEncode({
          'id': zone.id,
          'name': zone.name,
          'severity': zone.severity,
          'radius': zone.radius,
          'lat': zone.center.latitude,
          'lng': zone.center.longitude,
        }),
      )
      .toList();

  await prefs.setStringList(BackgroundServiceKeys.zones, encodedZones);

  final service = FlutterBackgroundService();
  final isRunning = await service.isRunning();
  if (isRunning) {
    service.invoke('refresh_zones');
  }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  print("BACKGROUND SERVICE STARTED");

  DartPluginRegistrant.ensureInitialized();
  await NotificationService.initialize();

  final prefs = await SharedPreferences.getInstance();

  await prefs.setBool(BackgroundServiceKeys.bgRunning, true);

  await prefs.setBool(
    'fall_detection_running',
    true,
  );

  if (service is AndroidServiceInstance) {
    await service.setForegroundNotificationInfo(
      title: "Guardian Pulse",
      content: "Safety tracking active",
    );

    await service.setAsForegroundService();
  }

  service.on('refresh_zones').listen((_) async {
    await _loadZones();
  });

  await _loadZones();

  // Refresh zones every 12 mins
  Timer.periodic(const Duration(minutes: 10), (timer) async {
    await _refreshZonesFromOverpass();
  });

  // Geofence checks
  Timer.periodic(const Duration(seconds: 15), (timer) async {
    if (service is AndroidServiceInstance) {
      final isForeground = await service.isForegroundService();

      if (!isForeground) {
        await service.setForegroundNotificationInfo(
          title: "Guardian Pulse",
          content: "Safety tracking active",
        );
        print("BACKGROUND TICK");

        service.setAsForegroundService();
      }
    }

    final nextScan = DateTime.now().add(const Duration(seconds: 15));

    await prefs.setString(
      BackgroundServiceKeys.nextScan,
      nextScan.toIso8601String(),
    );

    await _runGeofenceTick();
  });
}

List<Map<String, dynamic>> _cachedZones = <Map<String, dynamic>>[];

Future<void> _refreshZonesFromOverpass() async {
  final permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    return;
  }
  if (!await Geolocator.isLocationServiceEnabled()) return;

  try {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    final elements = await OverpassService.fetchNearbyHazards(
      lat: position.latitude,
      lng: position.longitude,
      statusProvider: null, // Background service runs independently : but why??
    );
    final zones = ZoneEngineService.generateZones(elements);
    if (zones.isEmpty) return;
    await syncZonesForBackground(zones);
    await _loadZones();
  } catch (_) {}
}

Future<void> _loadZones() async {
  final prefs = await SharedPreferences.getInstance();

  final rawZones = prefs.getStringList(BackgroundServiceKeys.zones) ?? [];

  _cachedZones = rawZones
      .map((raw) => jsonDecode(raw) as Map<String, dynamic>)
      .toList();

  await prefs.setInt(BackgroundServiceKeys.totalZones, _cachedZones.length);
}

Future<void> _runGeofenceTick() async {
  if (_cachedZones.isEmpty) return;

  final prefsSettings = await SharedPreferences.getInstance();
  if (!(prefsSettings.getBool('geofenceAlerts') ?? true)) return;
  if (!(prefsSettings.getBool('pushNotifications') ?? true)) return;

  final permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    return;
  }

  final enabled = await Geolocator.isLocationServiceEnabled();
  if (!enabled) return;

  final prefs = await SharedPreferences.getInstance();
  final activeZoneIds =
      (prefs.getStringList(BackgroundServiceKeys.activeZones) ?? []).toSet();

  final position = await Geolocator.getCurrentPosition();

  await prefs.setDouble(
    'last_speed',
    position.speed,
  );

  await prefs.setDouble(
    'last_accuracy',
    position.accuracy,
  );

  await prefs.setString(
    'last_location_update',
    DateTime.now().toIso8601String(),
  );

  final now = DateTime.now();

  for (final zone in _cachedZones) {
    final zoneId = zone['id'].toString();
    final zoneName = zone['name'].toString();
    final severity = zone['severity'].toString();
    final radius = (zone['radius'] as num).toDouble();
    final lat = (zone['lat'] as num).toDouble();
    final lng = (zone['lng'] as num).toDouble();

    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      lat,
      lng,
    );
    final isInside = distance <= radius;
    final wasInside = activeZoneIds.contains(zoneId);

    if (isInside && !wasInside) {
      activeZoneIds.add(zoneId);
      await _emitZoneNotification(
        title: 'Entered $zoneName',
        body: 'You entered a $severity zone.',
        type: 'zone_enter',
        severity: severity,
        now: now,
      );
    } else if (!isInside && wasInside) {
      activeZoneIds.remove(zoneId);
      await _emitZoneNotification(
        title: 'Exited $zoneName',
        body: 'You left the zone safely.',
        type: 'zone_exit',
        severity: severity,
        now: now,
      );
    }
  }

  await prefs.setStringList(
    BackgroundServiceKeys.activeZones,
    activeZoneIds.toList(),
  );

  await prefs.setInt(
    'active_zone_count',
    activeZoneIds.length,
  );
}

Future<void> _emitZoneNotification({
  required String title,
  required String body,
  required String type,
  required String severity,
  required DateTime now,
}) async {
  final nid = now.millisecondsSinceEpoch % 2147483647;
  await NotificationService.showNotification(
    title: title,
    body: body,
    notificationId: nid,
  );

  final prefs = await SharedPreferences.getInstance();
  final existing =
      prefs.getStringList(BackgroundServiceKeys.notifications) ?? [];
  final payload = jsonEncode({
    'id': now.millisecondsSinceEpoch.toString(),
    'title': title,
    'body': body,
    'time': now.toIso8601String(),
    'type': type,
    'severity': severity,
    'isRead': false,
  });
  existing.add(payload);
  await prefs.setStringList(BackgroundServiceKeys.notifications, existing);
}
