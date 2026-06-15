import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/system_status_provider.dart';
import '../services/service_health_monitor.dart';

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

  String formatDuration(DateTime? startTime) {
    if (startTime == null) return "0m";
    final diff = DateTime.now().difference(startTime);
    if (diff.inDays > 0) return "${diff.inDays}d ${diff.inHours % 24}h";
    if (diff.inHours > 0) return "${diff.inHours}h ${diff.inMinutes % 60}m";
    return "${diff.inMinutes}m ${diff.inSeconds % 60}s";
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
              // HEALTH REPORT
              // =========================
              if (status.lastHealthReport != null)
                buildTile(
                  title: "System Health Report",
                  value: "Overall: ${status.lastHealthReport!.isHealthy ? "HEALTHY" : "ISSUES DETECTED"}\n\n"
                      "GPS HW: ${status.lastHealthReport!.gpsEnabled ? "OK" : "OFF"}\n"
                      "Location Perm: ${status.lastHealthReport!.locationPermission ? "OK" : "MISSING"}\n"
                      "Background Perm: ${status.lastHealthReport!.backgroundPermission ? "OK" : "MISSING"}\n"
                      "SMS Perm: ${status.lastHealthReport!.smsPermission ? "OK" : "MISSING"}\n"
                      "Notification Perm: ${status.lastHealthReport!.notificationPermission ? "OK" : "MISSING"}\n"
                      "Background Service: ${status.lastHealthReport!.backgroundServiceRunning ? "RUNNING" : "DEAD"}\n"
                      "Battery Optimization: ${status.lastHealthReport!.batteryOptimizationDisabled ? "DISABLED" : "ENABLED (FIX)"}\n"
                      "Last Check: ${formatTime(status.lastHealthReport!.timestamp)}",
                  icon: status.lastHealthReport!.isHealthy ? Icons.health_and_safety : Icons.error_outline,
                  active: status.lastHealthReport!.isHealthy,
                ),

              if (status.lastHealthReport != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Show loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => const Center(
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 15),
                                  Text("Repairing Services..."),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );

                      try {
                        await ServiceHealthMonitor.checkAndRepair(context);
                      } finally {
                        if (context.mounted) Navigator.pop(context);
                      }
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Repair sequence completed. Checking health..."),
                            backgroundColor: Colors.blueAccent,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.build_circle),
                    label: const Text("SMART REPAIR & RESTART"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

              const SizedBox(height: 10),

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
                      "\nNearby Zones: ${status.nearbyZones}"
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

                active: (status.totalZones > 0 || status.geofenceActive) && !status.geofenceStatus.contains("Privacy Mode"),
              ),

              // =========================
              // FALL DETECTION
              // =========================

              buildTile(
                title: "Fall Detection",

                value:
                    "${status.fallDetectionStatus}\n\n"
                    "Monitoring State: ${status.fallDetectionActive ? "ACTIVE" : "DISABLED"}\n"
                    "Sensor Status: ${status.sensorStatus.toUpperCase()}\n"
                    "Last Fall Event: ${status.lastFallEvent}\n"
                    "Last Sensor Update: ${formatTime(status.lastFallCheck)}",

                icon: Icons.warning_amber_rounded,

                active: status.fallDetectionActive && status.sensorStatus == 'active',
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
                    "Service Uptime: ${formatDuration(status.serviceUptime)}\n"
                    "Last Pulse (Heartbeat): ${formatTime(status.lastPulse)}\n"
                    "Last Active: ${formatTime(status.lastActiveTimestamp)}\n"
                    "Foreground Tracking: ${status.backgroundServiceActive ? "RUNNING" : "STOPPED"}\n"
                    "Last BG Scan: ${formatTime(status.lastBackgroundCheck)}",

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
