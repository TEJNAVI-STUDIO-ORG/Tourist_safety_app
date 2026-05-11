// ignore_for_file: unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:provider/provider.dart';

import '../models/zone_model.dart';
import '../providers/location_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/system_status_provider.dart';
import '../providers/zone_provider.dart';

import '../services/geofence_service.dart';
import '../services/overpass_service.dart';
import '../services/zone_engine_service.dart';
import '../services/background_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapController = MapController();

  bool firstMapMove = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadZones();
    });
  }

  String formatTime(DateTime? time) {
    if (time == null) {
      return "--";
    }

    return
        "${time.hour.toString().padLeft(2, '0')}:"
        "${time.minute.toString().padLeft(2, '0')}:"
        "${time.second.toString().padLeft(2, '0')}";
  }

  Future<void> loadZones() async {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );

    final zoneProvider = Provider.of<ZoneProvider>(context, listen: false);

    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    if (locationProvider.latitude == null ||
        locationProvider.longitude == null) {
      return;
    }

    final systemStatusProvider = Provider.of<SystemStatusProvider>(context, listen: false);
    final elements = await OverpassService.fetchNearbyHazards(
      lat: locationProvider.latitude!,
      lng: locationProvider.longitude!,
      statusProvider: systemStatusProvider,
    );

    final zones = ZoneEngineService.generateZones(elements);

    // 🧪 TEST ZONE
    zones.add(
      ZoneModel(
        id: 'test_zone',

        type: 'danger_test',

        name: 'TEST DANGER ZONE',

        center: LatLng(
          locationProvider.latitude! + 0.00002,
          locationProvider.longitude!,
        ),

        radius: 2.22,

        color: Colors.red,

        riskScore: 10,

        severity: 'danger',
      ),
    );

    zoneProvider.setZones(zones);

    await syncZonesForBackground(zones);

    GeofenceService.startMonitoring(
      locationProvider: locationProvider,
      zoneProvider: zoneProvider,
      notificationProvider: notificationProvider,
    );
  }

  @override
Widget build(BuildContext context) {
  final locationProvider = Provider.of<LocationProvider>(context);
  final zoneProvider = Provider.of<ZoneProvider>(context);
  final statusProvider = Provider.of<SystemStatusProvider>(context);

  if (locationProvider.latitude == null ||
      locationProvider.longitude == null) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  final currentLocation = LatLng(
    locationProvider.latitude!,
    locationProvider.longitude!,
  );

  if (firstMapMove) {
    firstMapMove = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mapController.move(currentLocation, 15);
    });
  }

  return Scaffold(
    appBar: AppBar(
      title: const Text("Tracking Map"),
    ),

    body: Stack(
      children: [
        // =========================
        // 🗺️ FULL MAP (NO BLOCKING UI)
        // =========================
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: currentLocation,
            initialZoom: 15,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.tourist_safety_app',
            ),

            CircleLayer(
              circles: zoneProvider.zones.map((zone) {
                Color zoneColor;

                switch (zone.severity.toLowerCase()) {
                  case 'high':
                  case 'danger':
                    zoneColor = Colors.red;
                    break;
                  case 'medium':
                    zoneColor = Colors.orange;
                    break;
                  default:
                    zoneColor = Colors.green;
                }

                return CircleMarker(
                  point: zone.center,
                  radius: zone.radius,
                  useRadiusInMeter: true,
                  color: zoneColor.withOpacity(0.25),
                  borderStrokeWidth: 2,
                  borderColor: zoneColor,
                );
              }).toList(),
            ),

            MarkerLayer(
              markers: [
                Marker(
                  point: currentLocation,
                  width: 60,
                  height: 60,
                  child: const Icon(
                    Icons.location_pin,
                    size: 40,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),

        // =========================
        // 🔝 TOP COMPACT STATUS BAR
        // =========================
        Positioned(
          top: 10,
          left: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: statusProvider.insideDangerZone
                  ? Colors.red.withOpacity(0.85)
                  : Colors.green.withOpacity(0.85),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "GPS: ${statusProvider.gpsStatus}",
                  style: const TextStyle(color: Colors.white),
                ),

                Text(
                  "Zones: ${statusProvider.nearbyZones}",
                  style: const TextStyle(color: Colors.white),
                ),

                Text(
                  statusProvider.insideDangerZone ? "DANGER" : "SAFE",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // =========================
        // 📍 LEFT FLOATING ZONE PILL
        // =========================
        Positioned(
          top: 100,
          left: 10,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  "ZONES",
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  "${zoneProvider.zones.length}",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),

        // =========================
        // 📡 RIGHT FLOATING GPS PILL
        // =========================
        Positioned(
          top: 100,
          right: 10,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  "GPS",
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  "${locationProvider.accuracy.toStringAsFixed(0)}m",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),

        // =========================
        // 🎯 RECENTER BUTTON
        // =========================
        Positioned(
          bottom: 40,
          right: 20,
          child: FloatingActionButton(
            onPressed: () {
              mapController.move(currentLocation, 15);
            },
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    ),
  );
}
}