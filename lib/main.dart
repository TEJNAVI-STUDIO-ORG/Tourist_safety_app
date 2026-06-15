import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'core/themes/app_theme.dart';

import 'services/notification_service.dart';
import 'services/permission_service.dart';
import 'services/advanced_fall_detection_service.dart';
import 'services/native_fall_bridge.dart';
import 'services/geofence_service.dart';
import 'services/background_service.dart';
import 'services/system_status_service.dart';
import 'services/service_health_monitor.dart';
import 'services/battery_optimization_service.dart';

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

  await PermissionService.requestAllPermissions();

  // Initialize notifications early
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
      // 2. Load core providers
      final location = context.read<LocationProvider>();
      final zone = context.read<ZoneProvider>();
      final status = context.read<SystemStatusProvider>();
      final settings = context.read<SettingsProvider>();
      final notification = context.read<NotificationProvider>();

      // 3. Connect providers
      location.connectSystemStatus(status);
      settings.setSystemStatusProvider(status);

      // 4. Initial load sequence
      zone.triggerInitialLoad(
        context: context,
        locationProvider: location,
        statusProvider: status,
      );

      await initializeService();
      ServiceHealthMonitor.start(context);
      
      // 5. App Permissions & Services
      await Permission.activityRecognition.request();
      await SystemStatusService.initializeAllStatus(context);
      
      GeofenceService.startMonitoring(
        locationProvider: location,
        zoneProvider: zone,
        notificationProvider: notification,
      );

      unawaited(location.startLiveTracking());
      unawaited(BatteryOptimizationService.checkAndShowOptimizationDialog(context));

      // 6. Fall Detection
      await NativeFallBridge.initialize();
      AdvancedFallDetectionService.initialize(context);
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
