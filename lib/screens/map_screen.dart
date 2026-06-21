// ignore_for_file: unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';

import 'package:provider/provider.dart';

import '../providers/location_provider.dart';
import '../providers/system_status_provider.dart';
import '../providers/zone_provider.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final locationProvider = Provider.of<LocationProvider>(
        context,
        listen: false,
      );

      final zoneProvider = Provider.of<ZoneProvider>(context, listen: false);

      final statusProvider = Provider.of<SystemStatusProvider>(
        context,
        listen: false,
      );

      await zoneProvider.triggerInitialLoad(
        context: context,
        locationProvider: locationProvider,
        statusProvider: statusProvider,
      );
    });
  }

  String formatTime(DateTime? time) {
    if (time == null) {
      return "--";
    }

    final hour24 = time.hour;
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;

    return "${hour12.toString().padLeft(2, '0')}:"
        "${time.minute.toString().padLeft(2, '0')}:"
        "${time.second.toString().padLeft(2, '0')} $period";
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final zoneProvider = Provider.of<ZoneProvider>(context);
    final statusProvider = Provider.of<SystemStatusProvider>(context);

    final mapCenter = locationProvider.mapCenter;

    if (mapCenter == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tracking Map')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Acquiring your location...'),
            ],
          ),
        ),
      );
    }

    final currentLocation = mapCenter;

    if (firstMapMove) {
      firstMapMove = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        mapController.move(currentLocation, 15);
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Tracking Map")),

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
          // 📍 BOTTOM TRANSLUCENT STATUS BAR
          // =========================
          Positioned(
            bottom: 17,
            left: 20,
            right: 90, // Increased to accommodate larger button
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Safety Dot
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: statusProvider.insideDangerZone ? Colors.red : Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (statusProvider.insideDangerZone ? Colors.red : Colors.green).withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Zone Info
                  Text(
                    "Zones: ${zoneProvider.zones.length}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const Spacer(),

                  // Refreshing State
                  if (zoneProvider.isLoadingZones)
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Refreshing...",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // =========================
          // 🎯 RECENTER BUTTON
          // =========================
          Positioned(
            bottom: 15, // Slightly lower to center-align with the bar
            right: 15,
            child: FloatingActionButton(
              heroTag: "btn_map_recenter",
              shape: const CircleBorder(),
              backgroundColor: Colors.white.withOpacity(0.9),
              foregroundColor: Colors.blueAccent,
              onPressed: () {
                mapController.move(currentLocation, 15);
              },
              child: const Icon(Icons.my_location),
            ),
          ),

          // =========================
          // GPS LOADING OVERLAY
          // =========================
          if (locationProvider.isLoading && locationProvider.latitude == null)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
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
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
