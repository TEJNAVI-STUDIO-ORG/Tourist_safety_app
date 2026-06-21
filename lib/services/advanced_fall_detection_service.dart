import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../core/global.dart';

import '../models/zone_model.dart';
import '../providers/location_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/system_status_provider.dart';
import '../providers/zone_provider.dart';

import 'system_status_service.dart';
import 'notification_service.dart';

class AdvancedFallDetectionService {
  static bool _isProcessingFall = false;

  static DateTime? _freeFallTime;

  static StreamSubscription<AccelerometerEvent>? _subscription;

  static BuildContext? navigatorContext;

  static double currentMagnitude = 0;

  static DateTime? lastSensorUpdate;

  static Future<void> initialize(BuildContext context) async {
    navigatorContext = context;

    final prefs = await SharedPreferences.getInstance();

    if (!(prefs.getBool('fallDetection') ?? true)) {
      SystemStatusService.updateFallDetection(
        context,
        active: false,
      );

      return;
    }

    await WakelockPlus.enable();

    SystemStatusService.updateFallDetection(
      context,
      active: true,
    );

    _startListening(context);
  }

  /// Called by NativeFallBridge when native service detects fall
  static void triggerFallDialogFromNative() {
    if (_isProcessingFall) return;

    _isProcessingFall = true;

    // Handled by BackgroundService for unified breakthrough experience
  }

  static void _startListening(BuildContext context) {
    _subscription?.cancel();

    _subscription = accelerometerEventStream().listen((event) async {
      if (_isProcessingFall) return;

      final magnitude = sqrt(
        event.x * event.x +
            event.y * event.y +
            event.z * event.z,
      );

      currentMagnitude = magnitude;

      lastSensorUpdate = DateTime.now();

      // LIVE STATUS UPDATE
      SystemStatusService.updateFallDetection(
        context,
        active: true,
      );

      // persist last sensor update for status monitoring
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'last_fall_sensor_update',
          lastSensorUpdate!.toIso8601String(),
        );
        await prefs.setString('fall_sensor_status', 'active');
        Provider.of<SystemStatusProvider>(context, listen: false)
            .updateSensorStatus('active');
      } catch (_) {}

      if (magnitude < 2.0) {
        _freeFallTime = DateTime.now();
      }

      if (_freeFallTime != null &&
          magnitude > 25) {
        final diff =
            DateTime.now()
                .difference(_freeFallTime!)
                .inMilliseconds;

        if (diff < 1500) {
          _isProcessingFall = true;

          await _handlePossibleFall(event);
        }
      }
    });
  }

  static Future<void> _handlePossibleFall(
    AccelerometerEvent impactEvent,
  ) async {
    final initialTilt = impactEvent.z;

    await Future<void>.delayed(
      const Duration(seconds: 2),
    );

    AccelerometerEvent? newEvent;

    final completer = Completer<void>();

    late final StreamSubscription<
        AccelerometerEvent> sub;

    sub = accelerometerEventStream().listen(
      (event) {
        newEvent = event;

        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );

    await completer.future.timeout(
      const Duration(seconds: 3),
    );

    await sub.cancel();

    final tiltDifference =
        (initialTilt -
                (newEvent?.z ?? 0))
            .abs();

    if (tiltDifference < 5) {
      _reset();

      return;
    }

    bool movementDetected = false;

    final immobilitySub =
        accelerometerEventStream().listen(
      (event) {
        final magnitude = sqrt(
          event.x * event.x +
              event.y * event.y +
              event.z * event.z,
        );

        if ((magnitude - 9.8).abs() > 3) {
          movementDetected = true;
        }
      },
    );

    await Future<void>.delayed(
      const Duration(seconds: 4),
    );

    await immobilitySub.cancel();

    if (movementDetected) {
      _reset();

      return;
    }

    await NotificationService.showNotification(
      title: 'Possible Fall Detected',
      body: 'Tap to confirm safety',
      actions: [
        const AndroidNotificationAction('safe_action', "I'M SAFE", showsUserInterface: false),
      ],
    );

    await _saveNotification(
      title: 'Possible Fall Detected',
      body: 'Possible fall detected by sensors',
      type: 'fall',
    );

    await _updateFallLocationSummary();

    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 1500);
    }

    // Handled by BackgroundService for unified breakthrough experience
  }

  static Future<void> _saveNotification({
    required String title,
    required String body,
    required String type,
  }) async {
    final context =
        navigatorKey.currentContext;

    if (context == null) return;

    final provider =
        Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    await provider.addNotification(
      title: title,
      body: body,
      type: type,
      severity: 'high',
    );
  }

  static Future<void> _updateFallLocationSummary() async {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;

    final locationProvider = Provider.of<LocationProvider>(
      ctx,
      listen: false,
    );
    final zoneProvider = Provider.of<ZoneProvider>(
      ctx,
      listen: false,
    );

    String locationText = 'at current location';

    if (locationProvider.latitude != null && locationProvider.longitude != null) {
      final userLocation = LatLng(
        locationProvider.latitude!,
        locationProvider.longitude!,
      );

      final distanceCalc = Distance();
      ZoneModel? nearestZone;
      double nearestDistance = double.infinity;

      for (final zone in zoneProvider.zones) {
        final distance = distanceCalc.as(
          LengthUnit.Meter,
          userLocation,
          zone.center,
        );

        if (distance < nearestDistance) {
          nearestDistance = distance;
          nearestZone = zone;
        }
      }

      if (nearestZone != null) {
        if (nearestDistance <= nearestZone.radius) {
          locationText = 'inside ${nearestZone.name}';
        } else if (nearestDistance <= nearestZone.radius + 300) {
          locationText = 'near ${nearestZone.name}';
        } else {
          locationText = 'near ${nearestZone.name} (${nearestDistance.toStringAsFixed(0)}m)';
        }
      }
    }

    final statusProvider = Provider.of<SystemStatusProvider>(
      ctx,
      listen: false,
    );

    statusProvider.updateLastFallEvent(
      'Fall detected $locationText at ${_formatTime(DateTime.now())}',
    );
  }

  static String _formatTime(DateTime time) {
    final hour24 = time.hour;
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;

    return '${hour12.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')} $period';
  }

  static void _reset() {
    _freeFallTime = null;

    _isProcessingFall = false;
  }

  static void dispose() {
    _subscription?.cancel();
  }

  static void startDetection() {
    final ctx = navigatorKey.currentContext;
    if (ctx != null) {
      _startListening(ctx);
    }
  }

  static void stopDetection() {
    _subscription?.cancel();
    _subscription = null;
  }
}