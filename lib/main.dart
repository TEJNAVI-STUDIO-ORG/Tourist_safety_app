import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/themes/app_theme.dart';

import 'screens/welcome_screen.dart';
import 'screens/main_navigation.dart';
import 'services/startup_manager.dart';

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

  final locationProvider = LocationProvider();
  await locationProvider.restoreFromBackground();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider.value(value: locationProvider),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
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

class _TouristSafeAppState extends State<TouristSafeApp>
    with WidgetsBindingObserver {
  bool _consentLoaded = false;
  bool _hasConsent = false;
  bool _setupComplete = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        unawaited(StartupManager.onAppResumed(context));
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // UI geolocator will detach when the activity is destroyed; background
      // service keeps updating last_lat/last_lng in SharedPreferences.
      final context = navigatorKey.currentContext;
      if (context != null) {
        unawaited(context.read<LocationProvider>().restoreFromBackground());
      }
    }
  }

  void _handleLoadingComplete(bool consent, bool setupComplete) {
    if (!mounted) return;

    setState(() {
      _consentLoaded = true;
      _hasConsent = consent;
      _setupComplete = setupComplete;
    });
  }

  Future<void> _acceptConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('consentAccepted', true);
    if (!mounted) return;

    setState(() {
      _hasConsent = true;
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
      routes: {
        '/privacy': (_) => const PrivacyPolicyScreen(),
        '/terms': (_) => const TermsScreen(),
      },
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: !_consentLoaded
            ? LoadingScreen(
                key: const ValueKey('loading'),
                onFinished: _handleLoadingComplete,
              )
            : !_hasConsent
            ? ConsentScreen(
                key: const ValueKey('consent'),
                onAccept: _acceptConsent,
                onExit: () {
                  SystemNavigator.pop();
                },
              )
            : _setupComplete
            ? const MainNavigation(key: ValueKey('main'))
            : const WelcomeScreen(key: ValueKey('welcome')),
      ),
    );
  }
}
