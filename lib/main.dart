import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'core/themes/app_theme.dart';

import 'providers/app_provider.dart';
import 'providers/location_provider.dart';
import 'providers/settings_provider.dart';

import 'screens/dashboard_screen.dart';
import 'screens/map_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/settings_screen.dart';

void main() {

  runApp(

    MultiProvider(

      providers: [

        ChangeNotifierProvider(
          create: (_) => AppProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => LocationProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => SettingsProvider(),
        ),
      ],

      child: const TouristSafeApp(),
    ),
  );
}

class TouristSafeApp
    extends StatefulWidget {

  const TouristSafeApp({
    super.key,
  });

  @override
  State<TouristSafeApp>
      createState() =>
          _TouristSafeAppState();
}

class _TouristSafeAppState
    extends State<TouristSafeApp> {

  @override
  void initState() {

    super.initState();

    Future.microtask(() {

      Provider.of<LocationProvider>(
        context,
        listen: false,
      ).startLiveTracking();
    });
  }

  @override
  Widget build(BuildContext context) {

    final settingsProvider =
        Provider.of<SettingsProvider>(
          context,
        );

    return MaterialApp(

      debugShowCheckedModeBanner:
          false,

      theme: AppTheme.lightTheme,

      darkTheme: AppTheme.darkTheme,

      themeMode:
          settingsProvider.darkMode
              ? ThemeMode.dark
              : ThemeMode.light,

      home: const MainNavigation(),
    );
  }
}

class MainNavigation
    extends StatefulWidget {

  const MainNavigation({
    super.key,
  });

  @override
  State<MainNavigation>
      createState() =>
          _MainNavigationState();
}

class _MainNavigationState
    extends State<MainNavigation> {

  int currentIndex = 0;

  late final List<Widget> screens;

  @override
  void initState() {

    super.initState();

    screens = [

      DashboardScreen(),

      const MapScreen(),

      const EmergencyScreen(),

      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: screens[currentIndex],

      bottomNavigationBar:
          BottomNavigationBar(

        currentIndex: currentIndex,

        onTap: (index) {

          setState(() {
            currentIndex = index;
          });
        },

        type:
            BottomNavigationBarType.fixed,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Dashboard",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Tracking",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: "Emergency",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}