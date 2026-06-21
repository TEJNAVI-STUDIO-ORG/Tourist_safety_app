import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/zone_model.dart';
import 'notification_service.dart';
import 'overpass_service.dart';
import 'zone_engine_service.dart';
import 'sms_service.dart';

class BackgroundServiceKeys {
  static const String zones = 'bg_zones';
  static const String activeZones = 'bg_active_zone_ids';
  static const String notifications = 'notifications';
  static const String bgRunning = 'bg_running';
  static const String lastHeartbeat = 'bg_last_heartbeat';

  static const String nextScan = 'bg_next_scan';

  static const String totalZones = 'bg_total_zones';
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      autoStartOnBoot: false,
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

/// Starts the foreground background service after channels and notification
/// permission are ready. Safe to call multiple times.
Future<void> startBackgroundService() async {
  final service = FlutterBackgroundService();
  if (await service.isRunning()) return;

  if (!await Permission.notification.isGranted) {
    return;
  }

  await service.startService();
}

Future<void> syncZonesForBackground(List<ZoneModel> zones) async {
  final prefs = await SharedPreferences.getInstance();
  final encodedZones = zones.map((zone) => jsonEncode(zone.toJson())).toList();
  await prefs.setStringList(BackgroundServiceKeys.zones, encodedZones);

  final service = FlutterBackgroundService();
  final isRunning = await service.isRunning();
  if (isRunning) {
    service.invoke('refresh_zones');
  }
}

StreamSubscription<AccelerometerEvent>? _fallSubscription;
StreamSubscription<Position>? _locationSubscription;
DateTime? _lastFallSensorUpdate;
bool _isFallProcessing = false;
DateTime? _freeFallStartTime;
bool _isEmergencyPending = false;

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  print("BACKGROUND SERVICE STARTED");

  DartPluginRegistrant.ensureInitialized();

  // Channels must exist before promoting to foreground (Android 13+).
  await NotificationService.ensureAndroidChannels();

  if (service is AndroidServiceInstance) {
    await service.setForegroundNotificationInfo(
      title: "Guardian Pulse",
      content: "Safety tracking active",
    );
    service.setAsForegroundService();
  }

  final prefs = await SharedPreferences.getInstance();

  await prefs.setBool(BackgroundServiceKeys.bgRunning, true);
  await prefs.setString(
    BackgroundServiceKeys.lastHeartbeat,
    DateTime.now().toIso8601String(),
  );
  await prefs.setString('bg_service_uptime', DateTime.now().toIso8601String());

  await prefs.setBool('fall_detection_running', true);
  await prefs.setString(
    BackgroundServiceKeys.nextScan,
    DateTime.now().add(const Duration(minutes: 5)).toIso8601String(),
  );
  await prefs.setString('bg_last_check', DateTime.now().toIso8601String());

  service.on('refresh_zones').listen((_) async {
    await _loadZones();
  });

  service.on('stop_emergency').listen((_) {
    _isFallProcessing = false;
    _freeFallStartTime = null;
    _isEmergencyPending = false;
    print("EMERGENCY HALTED BY USER ACTION");
  });

  await _loadZones();
  _startBackgroundLocationTracking();
  _startFallDetection(service);

  // Heartbeat every 1 minute
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    await prefs.setString(
      BackgroundServiceKeys.lastHeartbeat,
      DateTime.now().toIso8601String(),
    );

    // Check if fall detection needs restart
    final now = DateTime.now();
    if (_lastFallSensorUpdate == null ||
        now.difference(_lastFallSensorUpdate!).inSeconds > 30) {
      print("FALL SENSOR STALLED - RESTARTING...");
      await prefs.setString('fall_sensor_status', 'stalled');
      _startFallDetection(service);
    } else {
      await prefs.setString('fall_sensor_status', 'active');
    }
  });

  // Update foreground notification summary every 5 minutes
  Timer.periodic(const Duration(minutes: 5), (timer) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final lastLocation = prefs.getString('last_location_update');
      bool gpsActive = false;
      if (lastLocation != null) {
        final parsed = DateTime.tryParse(lastLocation);
        if (parsed != null) {
          gpsActive = DateTime.now().difference(parsed).inMinutes < 5;
        }
      }

      final totalZones = prefs.getInt(BackgroundServiceKeys.totalZones) ?? 0;
      final activeCount = prefs.getInt('active_zone_count') ?? 0;
      final fallOn = prefs.getBool('fall_detection_running') ?? false;
      final sensorStatus = prefs.getString('fall_sensor_status') ?? 'unknown';

      final safe = activeCount == 0 ? 'yes' : 'no';
      final fallStatus = fallOn ? 'on ($sensorStatus)' : 'off';

      final content =
          'gps: ${gpsActive ? 'active' : 'inactive'} | zones: $totalZones | inside: $activeCount | fall: $fallStatus | safe: $safe';

      if (service is AndroidServiceInstance) {
        await service.setForegroundNotificationInfo(
          title: "Guardian Pulse",
          content: content,
        );
      }
    } catch (_) {}
  });

  // Refresh zones every 5 mins
  Timer.periodic(const Duration(minutes: 5), (timer) async {
    await prefs.setString('bg_last_check', DateTime.now().toIso8601String());
    final nextScan = DateTime.now().add(const Duration(minutes: 5));
    await prefs.setString(
      BackgroundServiceKeys.nextScan,
      nextScan.toIso8601String(),
    );
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
        service.setAsForegroundService();
      }
    }

    await _runGeofenceTick(service);
  });
}

void _startBackgroundLocationTracking() {
  _locationSubscription?.cancel();

  _locationSubscription = Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    ),
  ).listen(
    (position) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('last_lat', position.latitude);
      await prefs.setDouble('last_lng', position.longitude);
      await prefs.setDouble('last_speed', position.speed);
      await prefs.setDouble('last_accuracy', position.accuracy);
      await prefs.setString(
        'last_location_update',
        DateTime.now().toIso8601String(),
      );
    },
    onError: (_) {
      _locationSubscription?.cancel();
      _locationSubscription = null;
      Timer(const Duration(seconds: 5), _startBackgroundLocationTracking);
    },
  );
}

void _startFallDetection(ServiceInstance service) async {
  _fallSubscription?.cancel();

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('fall_sensor_status', 'active');
  await prefs.setString(
    'last_fall_sensor_update',
    DateTime.now().toIso8601String(),
  );

  _fallSubscription = accelerometerEventStream().listen((event) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('privateMode') ?? false) {
      await prefs.setString('fall_sensor_status', 'Suspended (Privacy Mode)');
      return;
    }

    _lastFallSensorUpdate = DateTime.now();

    // Periodically save to prefs so UI can see sensor is alive
    if (_lastFallSensorUpdate!.second % 10 == 0) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'last_fall_sensor_update',
        _lastFallSensorUpdate!.toIso8601String(),
      );
      await prefs.setString('fall_sensor_status', 'active');
    }

    if (_isFallProcessing) return;

    final magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    // Basic free-fall detection
    if (magnitude < 2.0) {
      _freeFallStartTime = DateTime.now();
    }

    // Impact detection after free-fall
    if (_freeFallStartTime != null && magnitude > 25) {
      final diff = DateTime.now()
          .difference(_freeFallStartTime!)
          .inMilliseconds;

      if (diff < 1500) {
        _isFallProcessing = true;
        _handleBackgroundFall(service);
      }
    }
  });
}

Future<void> _handleBackgroundFall(ServiceInstance service) async {
  await NotificationService.showNotification(
    title: '🚨 Fall Detected!',
    body: 'We detected a possible fall. Tap to confirm you are safe.',
    fullScreen: false,
    actions: [
      const AndroidNotificationAction(
        'safe_action',
        "I'M SAFE",
        showsUserInterface: false,
      ),
    ],
  );

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    'status_last_fall_event',
    'Fall detected at ${_formatTime(DateTime.now())} (Background)',
  );

  await _triggerBackgroundSOS('possible fall', countdownSeconds: 15);

  // Keep it locked for a while to avoid multiple triggers
  await Future.delayed(const Duration(seconds: 10));
  _isFallProcessing = false;
  _freeFallStartTime = null;
}

String _formatTime(DateTime time) {
  final hour24 = time.hour;
  final period = hour24 >= 12 ? 'PM' : 'AM';
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;

  return '${hour12.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}:'
      '${time.second.toString().padLeft(2, '0')} $period';
}

List<Map<String, dynamic>> _cachedZones = <Map<String, dynamic>>[];

Future<void> _refreshZonesFromOverpass() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('privateMode') ?? false) return;

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

    // =========================================================================
    // SMART FETCH LOGIC (BACKGROUND)
    // =========================================================================
    final lastLat = prefs.getDouble('cached_zones_lat');
    final lastLng = prefs.getDouble('cached_zones_lng');

    if (lastLat != null && lastLng != null) {
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        lastLat,
        lastLng,
      );

      // If user moved less than 600 meters, skip API call
      if (distance < 600) {
        print("BG: User hasn't moved enough ($distance m). Skipping refresh.");
        return;
      }
    }

    final elements = await OverpassService.fetchNearbyHazards(
      lat: position.latitude,
      lng: position.longitude,
      statusProvider: null,
    );
    final zones = ZoneEngineService.generateZones(elements);

    if (zones.isEmpty) return;

    await syncZonesForBackground(zones);

    final jsonData = jsonEncode(zones.map((zone) => zone.toJson()).toList());
    await prefs.setString('cached_zones', jsonData);
    await prefs.setDouble('cached_zones_lat', position.latitude);
    await prefs.setDouble('cached_zones_lng', position.longitude);

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

Future<void> _runGeofenceTick(ServiceInstance service) async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('privateMode') ?? false) {
    await prefs.setString(
      'last_zone_event',
      'Monitoring Suspended (Privacy Mode)',
    );
    return;
  }

  final permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    return;
  }

  final enabled = await Geolocator.isLocationServiceEnabled();
  if (!enabled) return;

  Position position;
  try {
    position = await Geolocator.getCurrentPosition();
  } catch (_) {
    return;
  }

  await prefs.setDouble('last_lat', position.latitude);
  await prefs.setDouble('last_lng', position.longitude);
  await prefs.setDouble('last_speed', position.speed);
  await prefs.setDouble('last_accuracy', position.accuracy);
  await prefs.setString(
    'last_location_update',
    DateTime.now().toIso8601String(),
  );

  if (_cachedZones.isEmpty) return;

  if (!(prefs.getBool('geofenceAlerts') ?? true)) return;
  if (!(prefs.getBool('pushNotifications') ?? true)) return;

  final activeZoneIds =
      (prefs.getStringList(BackgroundServiceKeys.activeZones) ?? []).toSet();

  final now = DateTime.now();

  for (final zone in _cachedZones) {
    final zoneId = zone['id'].toString();
    final zoneName = zone['name'].toString();
    final severity = zone['severity'].toString();
    final radiusRaw = zone['radius'] ?? zone['raduis'];
    final latRaw = zone['lat'] ?? zone['latitude'];
    final lngRaw = zone['lng'] ?? zone['longitude'];

    if (radiusRaw == null || latRaw == null || lngRaw == null) continue;

    final radius = (radiusRaw as num).toDouble();
    final lat = (latRaw as num).toDouble();
    final lng = (lngRaw as num).toDouble();

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

      if (severity.toLowerCase() == 'danger') {
        await _triggerBackgroundSOS(
          'entered danger zone ($zoneName)',
          countdownSeconds: 30,
        );
      }
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

  await prefs.setInt('active_zone_count', activeZoneIds.length);
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
    fullScreen: false,
    actions: severity.toLowerCase() == 'danger'
        ? [
            const AndroidNotificationAction(
              'safe_action',
              "I'M SAFE",
              showsUserInterface: false,
            ),
            const AndroidNotificationAction(
              'leave_action',
              "LEAVE ZONE",
              showsUserInterface: false,
            ),
          ]
        : null,
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

Future<void> _triggerBackgroundSOS(
  String reason, {
  int countdownSeconds = 30,
}) async {
  final prefs = await SharedPreferences.getInstance();
  if (!(prefs.getBool('smsAlerts') ?? true)) return;

  _isEmergencyPending = true;

  // Wait for countdown
  await Future.delayed(Duration(seconds: countdownSeconds));

  // Check if still pending (not cancelled by user)
  if (!_isEmergencyPending) return;

  _isEmergencyPending = false;

  final contactsRaw = prefs.getStringList('contacts') ?? [];
  if (contactsRaw.isEmpty) return;

  final recipients = contactsRaw.map((c) {
    final map = jsonDecode(c) as Map<String, dynamic>;
    return map['phone'] as String;
  }).toList();

  String template =
      prefs.getString('sosMessageTemplate') ??
      "🚨 EMERGENCY SOS!\n\nI need help immediately.\n\nMy live location:\n{location}";

  try {
    final pos = await Geolocator.getCurrentPosition();
    final locationText =
        "https://maps.google.com/?q=${pos.latitude},${pos.longitude}";
    final message = template.replaceAll("{location}", locationText);

    await SmsService.sendSOS(recipients: recipients, message: message);
    await prefs.setString(
      'status_last_fall_event',
      'Background SOS triggered: $reason',
    );
  } catch (e) {
    print("Background SOS Error: $e");
  }
}
