import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/global.dart';
import 'native_fall_bridge.dart';
import 'advanced_fall_detection_service.dart';

import 'background_service.dart';
import 'notification_service.dart';
import 'geofence_service.dart';
import 'service_health_monitor.dart';
import 'battery_optimization_service.dart';

import '../providers/location_provider.dart';
import '../providers/zone_provider.dart';
import '../providers/system_status_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/settings_provider.dart';

import 'permission_service.dart';
import 'system_status_service.dart';

class StartupManager {
  static const String setupCompleteKey = 'app_setup_complete';

  static bool _started = false;
  static DateTime? _lastResumeAt;
  static Future<void>? _resumeInFlight;

  static Future<bool> isSetupComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(setupCompleteKey) ?? false;
  }

  static Future<void> markSetupComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(setupCompleteKey, true);
  }

  /// Starts the app initialization. Safe to call multiple times.
  static Future<void> startAppInitialization(
    BuildContext context, {
    bool requestPermissions = true,
  }) async {
    if (_started) {
      await onAppResumed(context);
      return;
    }
    _started = true;

    final widgetContext = context;
    final location = widgetContext.read<LocationProvider>();
    final zone = widgetContext.read<ZoneProvider>();
    final status = widgetContext.read<SystemStatusProvider>();
    final settings = widgetContext.read<SettingsProvider>();
    final notification = widgetContext.read<NotificationProvider>();

    location.connectSystemStatus(status);
    settings.setSystemStatusProvider(status);

    zone.triggerInitialLoad(
      context: widgetContext,
      locationProvider: location,
      statusProvider: status,
    );

    if (requestPermissions) {
      await PermissionService.requestAllPermissions();
    }

    await NotificationService.initialize();
    await initializeService();
    await startBackgroundService();

    await Permission.activityRecognition.request();
    await _ensureFallDetection();

    final statusContext = navigatorKey.currentContext;
    if (statusContext != null) {
      // ignore: use_build_context_synchronously
      await SystemStatusService.initializeAllStatus(statusContext);
    }

    GeofenceService.startMonitoring(
      locationProvider: location,
      zoneProvider: zone,
      notificationProvider: notification,
    );

    await location.restoreFromBackground();
    await location.resumeIfNeeded();

    unawaited(
      Future.microtask(() async {
        final rootContext = navigatorKey.currentContext;
        if (rootContext != null) {
          // ignore: use_build_context_synchronously
          ServiceHealthMonitor.start(rootContext);
        }
      }),
    );

    unawaited(
      Future.microtask(() async {
        final batteryContext = navigatorKey.currentContext;
        if (batteryContext != null) {
          unawaited(
            BatteryOptimizationService.checkAndShowOptimizationDialog(
              batteryContext,
            ),
          );
        }
      }),
    );

    unawaited(
      Future.microtask(() async {
        await notification.loadNotifications();
      }),
    );

    await markSetupComplete();
  }

  static Future<void> _ensureFallDetection() async {
    try {
      final granted = await Permission.activityRecognition.isGranted;
      if (!granted) {
        debugPrint(
          'Skipping fall bridge init: activity recognition not granted',
        );
        return;
      }

      await NativeFallBridge.ensureRunning();

      final fallContext = navigatorKey.currentContext;
      if (fallContext != null) {
        // ignore: use_build_context_synchronously
        await AdvancedFallDetectionService.initialize(fallContext);
      }
    } catch (e, st) {
      debugPrint('Native fall init failed: $e\n$st');
    }
  }

  /// Lightweight resume when the UI returns after being swiped away.
  static Future<void> onAppResumed(BuildContext context) async {
    final now = DateTime.now();
    if (_lastResumeAt != null &&
        now.difference(_lastResumeAt!) < const Duration(seconds: 2)) {
      return;
    }
    _lastResumeAt = now;

    _resumeInFlight ??= _handleAppResumed(context);
    try {
      await _resumeInFlight;
    } finally {
      _resumeInFlight = null;
    }
  }

  static Future<void> _handleAppResumed(BuildContext context) async {
    final location = context.read<LocationProvider>();
    final status = context.read<SystemStatusProvider>();

    await status.syncFromBackground();
    await location.onUiEngineReattached();

    final bgRunning = await FlutterBackgroundService().isRunning();
    if (!bgRunning) {
      await NotificationService.initialize();
      await initializeService();
      await startBackgroundService();
    }

    await _ensureFallDetection();
    await status.syncFromBackground();
  }
}
