import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../providers/location_provider.dart';
import '../providers/system_status_provider.dart';
import '../providers/settings_provider.dart';

import '../screens/system_status_screen.dart';
import '../screens/emergency_screen.dart';
import 'notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final MapController mapController = MapController();

  int batteryLevel = 0;

  @override
  void initState() {
    super.initState();

    loadBattery();
  }

  Future<void> loadBattery() async {
    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);

    final currentLocation = LatLng(
      locationProvider.latitude ?? 18.5204,
      locationProvider.longitude ?? 73.8567,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("TouriSafe"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Live Map",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Your current location and nearby safety zones",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // =========================
                // LIVE MAP
                // =========================
                Container(
                  height: 250,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),

                  clipBehavior: Clip.hardEdge,

                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                          initialCenter: currentLocation,
                          initialZoom: 15,
                        ),

                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                            userAgentPackageName:
                                'com.example.tourist_safety_app',
                          ),

                          MarkerLayer(
                            markers: [
                              Marker(
                                point: currentLocation,

                                width: 40,
                                height: 40,

                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // RE-CENTER BUTTON
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: FloatingActionButton.small(
                          heroTag: "btn_dashboard_recenter",
                          shape: const CircleBorder(),
                          onPressed: () {
                            mapController.move(currentLocation, 15);
                          },
                          child: const Icon(Icons.my_location),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // =========================
                // PRIVATE MODE
                // =========================
                Consumer<SettingsProvider>(
                  builder: (context, settings, _) {
                    return SwitchListTile(
                      title: const Text("Private Mode"),
                      subtitle: const Text("Disable live tracking"),
                      value: settings.privateMode,
                      onChanged: (value) {
                        settings.togglePrivateMode();
                      },
                    );
                  },
                ),

                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "System Monitor",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Real-time status of your safety subsystems",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // =========================
                // MAIN STATUS
                // =========================
                Card(
                  child: ListTile(
                    leading: Icon(
                      locationProvider.trackingEnabled
                          ? Icons.shield
                          : Icons.shield_outlined,
                      color: locationProvider.trackingEnabled
                          ? Colors.green
                          : Colors.red,
                    ),

                    title: const Text("Status"),

                    subtitle: Text(
                      locationProvider.trackingEnabled
                          ? "Live Tracking Active"
                          : "Tracking Disabled",
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // =========================
                // LIVE SYSTEM CARDS
                // =========================
                Consumer<SystemStatusProvider>(
                  builder: (context, status, _) {
                    return Column(
                      children: [
                        _buildSystemTile(
                          title: "GPS",
                          subtitle: status.gpsStatus,
                          active: status.gpsActive,
                          icon: Icons.gps_fixed,
                        ),

                        _buildSystemTile(
                          title: "Geofence",
                          subtitle: status.geofenceStatus,
                          active: status.geofenceActive,
                          icon: Icons.shield,
                        ),

                        _buildSystemTile(
                          title: "Fall Detect",
                          subtitle: status.fallDetectionStatus,
                          active: status.fallDetectionActive,
                          icon: Icons.warning_amber_rounded,
                        ),

                        _buildSystemTile(
                          title: "Background",
                          subtitle: status.backgroundServiceStatus,
                          active: status.backgroundServiceActive,
                          icon: Icons.sync,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),

                // =========================
                // SYSTEM MONITOR BUTTON
                // =========================
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SystemStatusScreen(),
                        ),
                      );
                    },

                    icon: const Icon(Icons.analytics),

                    label: const Text("Open System Monitor"),
                  ),
                ),

                const SizedBox(height: 20),

                // =========================
                // SOS BUTTON
                // =========================
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmergencyScreen(),
                        ),
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),

                    child: const Text(
                      "SOS",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),

          // =========================
          // GPS LOADING OVERLAY
          // =========================
          if (locationProvider.isLoading && locationProvider.latitude == null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,

              child: Container(
                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(14),
                ),

                child: const Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,

                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(width: 12),

                    Text(
                      "Locating GPS...",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _zoneRow(String title, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(title),

          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }
}

Widget _buildSystemTile({
  required String title,
  required String subtitle,
  required bool active,
  required IconData icon,
}) {
  return Card(
    margin: const EdgeInsets.only(bottom: 8),

    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: active
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),

        child: Icon(icon, color: active ? Colors.green : Colors.grey),
      ),

      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

      subtitle: Text(subtitle),

      trailing: Container(
        width: 12,
        height: 12,

        decoration: BoxDecoration(
          color: active ? Colors.green : Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    ),
  );
}
