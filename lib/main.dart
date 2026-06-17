import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/themes/app_theme.dart';

import 'screens/welcome_screen.dart';
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

import 'screens/consent_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/terms_screen.dart';

import './core/global.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  bool _consentLoaded = false;
  bool _hasConsent = false;
  bool _initializationStarted = false;

  @override
  void initState() {
    super.initState();
  }

  void _handleLoadingComplete(bool consent) {
    if (!mounted) return;

    setState(() {
      _consentLoaded = true;
      _hasConsent = consent;
    });

    if (consent) {
      _startAppInitialization();
    }
  }

  Future<void> _acceptConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('consentAccepted', true);
    if (!mounted) return;

    setState(() {
      _hasConsent = true;
    });

    _startAppInitialization();
  }

  Future<void> _startAppInitialization() async {
    if (_initializationStarted) return;
    _initializationStarted = true;

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

    await PermissionService.requestAllPermissions();
    unawaited(
      NotificationService.initialize().catchError((Object e, StackTrace st) {
        debugPrint('NotificationService.initialize failed: $e\n$st');
      }),
    );

    await initializeService();
    final rootContext = navigatorKey.currentContext;
    if (rootContext != null) {
      // ignore: use_build_context_synchronously
      ServiceHealthMonitor.start(rootContext);
    }

    await Permission.activityRecognition.request();
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

    unawaited(location.startLiveTracking());

    if (navigatorKey.currentContext != null) {
      final batteryContext = navigatorKey.currentContext!;
      unawaited(
        BatteryOptimizationService.checkAndShowOptimizationDialog(
      // ignore: use_build_context_synchronously
          batteryContext,
        ),
      );

      await NativeFallBridge.initialize();
      // ignore: use_build_context_synchronously
      AdvancedFallDetectionService.initialize(batteryContext);
    }
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
      routes: {
        '/privacy': (_) => const PrivacyPolicyScreen(),
        '/terms': (_) => const TermsScreen(),
      },
      home: !_consentLoaded
          ? LoadingScreen(onFinished: _handleLoadingComplete)
          : _hasConsent
          ? const WelcomeScreen()
          : ConsentScreen(
              onAccept: _acceptConsent,
              onExit: () {
                SystemNavigator.pop();
              },
            ),
    );
  }
}
