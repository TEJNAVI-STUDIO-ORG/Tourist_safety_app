import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:provider/provider.dart';

import '../providers/location_provider.dart';

class MapScreen extends StatefulWidget {

  const MapScreen({super.key});

  @override
  State<MapScreen> createState() =>
      _MapScreenState();
}

class _MapScreenState
    extends State<MapScreen> {

  final MapController mapController =
      MapController();

  @override
  Widget build(BuildContext context) {

    final locationProvider =
            Provider.of<LocationProvider>(
              context,
            );

        if (locationProvider.latitude == null ||
        locationProvider.longitude == null) {

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentLocation = LatLng(
      locationProvider.latitude!,
      locationProvider.longitude!,
    );

    // 🚀 AUTO RECENTER
    WidgetsBinding.instance
        .addPostFrameCallback((_) {

      mapController.move(
        currentLocation,
        15,
      );
    });

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Tracking Map",
        ),
      ),

      body: Stack(
        children: [

          // 🗺️ MAP
          FlutterMap(

            mapController:
                mapController,

            options: MapOptions(
              initialCenter:
                  currentLocation,

              initialZoom: 15,
            ),

            children: [

              // 🌍 TILE LAYER
              TileLayer(

                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                userAgentPackageName:
                    'com.example.tourist_safety_app',
              ),

              // 📍 LIVE LOCATION MARKER
              MarkerLayer(

                markers: [

                  Marker(

                    point:
                        currentLocation,

                    width: 80,
                    height: 80,

                    child: const Icon(
                      Icons.location_pin,
                      size: 40,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),

              // 🔴 DANGER ZONE
              CircleLayer(

                circles: [

                  CircleMarker(

                    point:
                        LatLng(
                          18.5250,
                          73.8600,
                        ),

                    radius: 80,

                    color:
                        Colors.red
                            .withOpacity(0.3),

                    borderColor:
                        Colors.red,

                    borderStrokeWidth: 2,
                  ),
                ],
              ),
            ],
          ),

          // 📍 LIVE STATUS CARD
          Positioned(

            bottom: 100,
            left: 20,
            right: 20,

            child: Card(

              child: Padding(

                padding:
                    const EdgeInsets.all(12),

                child: Row(
                  children: [

                    const Icon(
                      Icons.security,
                      color: Colors.green,
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Expanded(

                      child: Text(

                        "Lat: "
                        "${locationProvider.latitude!.toStringAsFixed(5)}\n"

                        "Lng: "
                        "${locationProvider.longitude!.toStringAsFixed(5)}",

                        style:
                            const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 🎯 RECENTER BUTTON
          Positioned(

            bottom: 30,
            right: 20,

            child:
                FloatingActionButton(

              onPressed: () {

                mapController.move(
                  currentLocation,
                  15,
                );
              },

              child: const Icon(
                Icons.my_location,
              ),
            ),
          ),
        ],
      ),
    );
  }
}