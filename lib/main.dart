import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'core/themes/app_theme.dart';

import 'services/notification_service.dart';
import 'services/permission_service.dart';
import 'services/advanced_fall_detection_service.dart';
import 'services/native_fall_bridge.dart';
import 'services/geofence_service.dart';
import 'services/background_service.dart';
import 'services/overpass_service.dart';
import 'services/zone_engine_service.dart';
import 'services/system_status_service.dart';

import 'providers/notification_provider.dart';
import 'providers/app_provider.dart';
import 'providers/location_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/zone_provider.dart';
import 'providers/system_status_provider.dart';

import 'screens/loading_screen.dart';

import './core/global.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Never block the first frame on plugin init (can hang on some OEMs).
  unawaited(
    NotificationService.initialize().catchError((Object e, StackTrace st) {
      debugPrint('NotificationService.initialize failed: $e\n$st');
    }),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),

        ChangeNotifierProvider(create: (_) => LocationProvider()),

        ChangeNotifierProvider(create: (_) => SettingsProvider()),

        ChangeNotifierProvider(
          create: (_) => NotificationProvider()..loadNotifications(),
        ),

        ChangeNotifierProvider(create: (_) => SystemStatusProvider()),

        ChangeNotifierProvider(create: (_) => ZoneProvider()),
      ],

      child: const TouristSafeApp(),
    ),
  );
}

class TouristSafeApp extends StatefulWidget {
  const TouristSafeApp({super.key});

  @override
  State<TouristSafeApp> createState() => _TouristSafeAppState();
}

class _TouristSafeAppState extends State<TouristSafeApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // =========================
      // PERMISSIONS
      // =========================

      await Permission.activityRecognition.request();

      await PermissionService.requestAllPermissions();

      await initializeService();

      if (!mounted) return;

      // =========================
      // INITIAL STATUS CHECK
      // =========================
      
      // Initialize all system statuses based on current settings
      SystemStatusService.initializeAllStatus(context);

      // =========================
      // LOCATION
      // =========================

      final locationProvider = Provider.of<LocationProvider>(
        context,
        listen: false,
      );

      final systemStatusProvider = Provider.of<SystemStatusProvider>(
        context,
        listen: false,
      );

      final settingsProvider = Provider.of<SettingsProvider>(
        context,
        listen: false,
      );

      locationProvider.connectSystemStatus(systemStatusProvider);
      settingsProvider.setSystemStatusProvider(systemStatusProvider);

      final zoneProvider = Provider.of<ZoneProvider>(context, listen: false);
      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );

      await locationProvider.requestPermissions();

      GeofenceService.startMonitoring(
        locationProvider: locationProvider,

        zoneProvider: zoneProvider,

        notificationProvider: notificationProvider,
      );

      await locationProvider.startLiveTracking();

      // First GPS fix can arrive after the stream starts — Overpass needs coordinates.
      try {
        if (locationProvider.latitude == null ||
            locationProvider.longitude == null) {
          await locationProvider.getCurrentLocation().timeout(
            const Duration(seconds: 45),
          );
        }
      } catch (_) {
        // Still proceed; map / later ticks can populate location.
      }

      if (locationProvider.latitude != null &&
          locationProvider.longitude != null) {
        final elements = await OverpassService.fetchNearbyHazards(
          lat: locationProvider.latitude!,
          lng: locationProvider.longitude!,
          statusProvider: systemStatusProvider,
        );
        final zones = ZoneEngineService.generateZones(elements);
        zoneProvider.setZones(zones);
        SystemStatusService.updateZoneStatus(
          context,
        );
        await syncZonesForBackground(zones);
      }

      if (!mounted) return;

      // =========================
      // FALL DETECTION
      // =========================

      await FlutterBackgroundService().startService();

      SystemStatusService
          .updateBackgroundService(
        context,
        active: true,
      );
      await NativeFallBridge.initialize();
      AdvancedFallDetectionService.initialize(context);

      SystemStatusService
          .updateFallDetection(
        context,
        active: true,
      );

      // Start the native foreground service (survives app kill + reboot).
      // It also kicks off the Dart-side accelerometer listener as a fallback.
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      darkTheme: AppTheme.darkTheme,

      themeMode: settingsProvider.darkMode ? ThemeMode.dark : ThemeMode.light,

      home: const LoadingScreen(),
    );
  }
}
