import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/system_status_provider.dart';

class SystemStatusScreen extends StatelessWidget {
  const SystemStatusScreen({
    super.key,
  });

  String formatTime(DateTime? time) {
    if (time == null) {
      return "Never";
    }

    final hour24 = time.hour;
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;

    return "${hour12.toString().padLeft(2, '0')}:"
        "${time.minute.toString().padLeft(2, '0')}:"
        "${time.second.toString().padLeft(2, '0')} $period";
  }

  Widget buildTile({
    required String title,
    required String value,
    required IconData icon,
    required bool active,
  }) {
    return Card(
      elevation: 2,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),

      child: ListTile(
        contentPadding: const EdgeInsets.all(16),

        leading: CircleAvatar(
          radius: 26,

          backgroundColor:
              active
                  ? Colors.green.withOpacity(0.15)
                  : Colors.red.withOpacity(0.15),

          child: Icon(
            icon,
            size: 28,

            color:
                active
                    ? Colors.green
                    : Colors.red,
          ),
        ),

        title: Text(
          title,

          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 10),

          child: Text(
            value,

            style: const TextStyle(
              height: 1.45,
            ),
          ),
        ),

        trailing: Container(
          width: 14,
          height: 14,

          decoration: BoxDecoration(
            color:
                active
                    ? Colors.green
                    : Colors.red,

            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SystemStatusProvider>(
      builder: (context, status, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "System Monitor",
            ),
          ),

          body: ListView(
            padding: const EdgeInsets.all(16),

            children: [

              // =========================
              // LIVE STATUS HEADER
              // =========================

              Container(
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),

                  gradient: LinearGradient(
                    colors:
                        status.gpsActive &&
                                status.backgroundServiceActive
                            ? [
                                Colors.green,
                                Colors.teal,
                              ]
                            : [
                                Colors.red,
                                Colors.orange,
                              ],
                  ),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "SYSTEM STATUS",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      status.gpsActive &&
                              status.backgroundServiceActive
                          ? "ALL CORE SYSTEMS ACTIVE"
                          : "SYSTEM WARNING",

                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "GPS: ${status.gpsActive ? "ONLINE" : "OFFLINE"}"
                      "\nZones Loaded: ${status.totalZones}"
                      "\nNearby Danger Zones: ${status.nearbyZones}"
                      "\nBackground Tracking: ${status.backgroundServiceActive ? "ACTIVE" : "STOPPED"}",

                      style: const TextStyle(
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // =========================
              // GPS
              // =========================

              buildTile(
                title: "GPS Status",

                value:
                    "${status.gpsStatus}\n\n"
                    "Location: ${status.locationName}\n"
                    "Latitude: ${status.latitude?.toStringAsFixed(5) ?? '--'}\n"
                    "Longitude: ${status.longitude?.toStringAsFixed(5) ?? '--'}\n"
                    "Accuracy: ${status.accuracy?.toStringAsFixed(1) ?? '--'} m\n"
                    "Speed: ${status.gpsspeed?.toStringAsFixed(1) ?? '--'} m/s\n"
                    "Last Update: ${formatTime(status.lastGpsUpdate)}",

                icon: Icons.gps_fixed,

                active: status.gpsActive,
              ),

              // =========================
              // GEOFENCE
              // =========================

              buildTile(
                title: "Geofence System",

                value:
                    "${status.geofenceStatus}\n\n"
                    "Inside Danger Zone: ${status.insideDangerZone ? "YES" : "NO"}\n"
                    "Nearby Zones: ${status.nearbyZones}\n"
                    "Last Event: ${status.lastZoneEvent}\n"
                    "Last Check: ${formatTime(status.lastGeofenceCheck)}",

                icon: Icons.shield,

                active: status.geofenceActive,
              ),

              // =========================
              // ZONES
              // =========================

              buildTile(
                title: "Zone Engine",

                value:
                    "Source: ${status.zoneSource}\n"
                    "Total Zones Loaded: ${status.totalZones}\n"
                    "Nearby Zones: ${status.nearbyZones}\n"
                    "Entered Zones: ${status.enteredZones}\n"
                    "Next Scan: ${formatTime(status.nextZoneScan)}",

                icon: Icons.map,

                active: status.totalZones > 0 || status.geofenceActive,
              ),

              // =========================
              // FALL DETECTION
              // =========================

              buildTile(
                title: "Fall Detection",

                value:
                    "${status.fallDetectionStatus}\n\n"
                    "Sensor State: ${status.fallDetectionActive ? "MONITORING" : "DISABLED"}\n"
                    "Last Fall Event: ${status.lastFallEvent}\n"
                    "Last Sensor Update: ${formatTime(status.lastFallCheck)}",

                icon: Icons.warning_amber_rounded,

                active: status.fallDetectionActive,
              ),

              // =========================
              // NOTIFICATIONS
              // =========================

              buildTile(
                title: "Notifications",

                value:
                    "${status.notificationStatus}\n\n"
                    "Push Alerts: ${status.notificationActive ? "ACTIVE" : "DISABLED"}\n"
                    "SOS Status: ${status.sosReady ? "READY" : "NOT READY"}\n"
                    "SOS Contacts: ${status.sosContactCount}\n"
                    "SOS Template: ${status.sosMessageTemplateValid ? "OK" : "Missing / Invalid"}",

                icon: Icons.notifications_active,

                active: status.notificationActive,
              ),

              // =========================
              // BACKGROUND SERVICE
              // =========================

              buildTile(
                title: "Background Service",

                value:
                    "${status.backgroundServiceStatus}\n\n"
                    "Foreground Tracking: ${status.backgroundServiceActive ? "RUNNING" : "STOPPED"}\n"
                    "Last Pulse: ${formatTime(status.lastPulse)}\n"
                    "Last BG Scan: ${formatTime(status.lastBackgroundCheck)}\n"
                    "Active Zones (bg): ${status.enteredZones}\n"
                    "Next Scan: ${formatTime(status.nextZoneScan)}",

                icon: Icons.sync,

                active: status.backgroundServiceActive,
              ),

              // =========================
              // OVERPASS API
              // =========================

              buildTile(
                title: "Overpass API",

                value:
                    "${status.overpassStatus}\n\n"
                    "Retry Count: ${status.retryCount}\n"
                    "Last Refresh: ${formatTime(status.lastOverpassRefresh)}",

                icon: Icons.cloud,

                active: status.overpassActive,
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}