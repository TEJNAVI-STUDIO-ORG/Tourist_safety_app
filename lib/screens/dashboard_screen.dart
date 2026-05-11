import 'package:battery_plus/battery_plus.dart';

import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';

import 'package:latlong2/latlong.dart';

import 'package:provider/provider.dart';

import '../providers/location_provider.dart';
import '../providers/system_status_provider.dart';


import '../screens/system_status_screen.dart';
import '../screens/emergency_screen.dart';
import 'notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Battery battery = Battery();

  int batteryLevel = 0;

  @override
  void initState() {
    super.initState();

    loadBattery();
  }

  Future<void> loadBattery() async {
    final level = await battery.batteryLevel;

    setState(() {
      batteryLevel = level;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);

    // ⏳ WAIT FOR LOCATION
    if (locationProvider.latitude == null ||
        locationProvider.longitude == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentLocation = LatLng(
      locationProvider.latitude!,
      locationProvider.longitude!,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("TouristSafe"),

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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
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
            // =========================
            // LIVE SYSTEM CARDS (Vertical List)
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

            const SizedBox(height: 16),

            // =========================
            // PRIVATE MODE
            // =========================
            SwitchListTile(
              title: const Text("Private Mode"),

              subtitle: const Text("Disable live tracking"),

              value: !locationProvider.trackingEnabled,

              onChanged: (value) async {
                if (value) {
                  locationProvider.stopTracking();
                } else {
                  await locationProvider.resumeTracking();
                }
              },
            ),

            const SizedBox(height: 10),

            // =========================
            // BATTERY
            // =========================
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text("Battery"),

                    const SizedBox(height: 10),

                    LinearProgressIndicator(value: batteryLevel / 100),

                    const SizedBox(height: 8),

                    Text("$batteryLevel%"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // LIVE MAP
            // =========================
            Container(
              height: 220,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),

              clipBehavior: Clip.hardEdge,

              child: FlutterMap(
                options: MapOptions(
                  initialCenter: currentLocation,

                  initialZoom: 15,
                ),

                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                    userAgentPackageName: 'com.example.tourist_safety_app',
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
            ),

            const SizedBox(height: 20),

            // =========================
            // ZONE INTELLIGENCE
            // =========================
            Consumer<SystemStatusProvider>(
              builder: (context, status, _) {
                return SizedBox(
                  width: double.infinity, // 👈 THIS IS THE KEY
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Zone Intelligence",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 14),

                          _zoneRow("Total Zones", status.totalZones.toString()),
                          _zoneRow(
                            "Nearby Zones",
                            status.nearbyZones.toString(),
                          ),

                          _zoneRow(
                            "Danger Status",
                            status.insideDangerZone ? "HIGH RISK" : "SAFE",
                            valueColor: status.insideDangerZone
                                ? Colors.red
                                : Colors.green,
                          ),

                          _zoneRow(
                            "Next Scan",
                            status.nextZoneScan?.toString() ?? "--",
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // =========================
            // SOS BUTTON
            // =========================
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,

                    MaterialPageRoute(builder: (_) => const EmergencyScreen()),
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

            const SizedBox(height: 20),

            // =========================
            // LOCATION DATA
            // =========================
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on),

                title: const Text("Current Location"),

                subtitle: Text(
                  "Lat: "
                  "${locationProvider.latitude!.toStringAsFixed(5)}\n\n"
                  "Lng: "
                  "${locationProvider.longitude!.toStringAsFixed(5)}\n\n"
                  "Speed: "
                  "${locationProvider.speed.toStringAsFixed(1)} m/s\n\n"
                  "Accuracy: "
                  "${locationProvider.accuracy.toStringAsFixed(1)} m",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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

Widget _buildSystemTile({
  required String title,
  required String subtitle,
  required bool active,
  required IconData icon,
}) {
  return Card(
    margin: const EdgeInsets.only(bottom: 8), // Adds spacing between tiles
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
