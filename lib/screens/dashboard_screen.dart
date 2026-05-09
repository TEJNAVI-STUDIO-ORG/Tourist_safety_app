import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:provider/provider.dart';

import '../providers/location_provider.dart';

class DashboardScreen
    extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final locationProvider =
        Provider.of<LocationProvider>(
          context,
        );

    // ⏳ WAIT FOR REAL LOCATION
    if (locationProvider.latitude == null ||
        locationProvider.longitude == null) {

      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    final currentLocation = LatLng(
      locationProvider.latitude!,
      locationProvider.longitude!,
    );

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "TouristSafe",
        ),

        actions: [

          IconButton(
            icon: const Icon(
              Icons.notifications,
            ),
            onPressed: () {},
          ),
        ],
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(16),

        child: Column(
          children: [

            // 🟢 STATUS CARD
            Card(

              child: ListTile(

                leading: const Icon(
                  Icons.shield,
                  color: Colors.green,
                ),

                title: const Text(
                  "Status",
                ),

                subtitle: const Text(
                  "Live Tracking Active",
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 🔒 PRIVATE MODE
            SwitchListTile(

              title:
                  const Text(
                "Private Mode",
              ),

              value: false,

              onChanged: (value) {},
            ),

            const SizedBox(height: 10),

            // 🔋 BATTERY
            Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const Text("Battery"),

                const SizedBox(height: 8),

                LinearProgressIndicator(
                  value: 0.7,
                ),

                const SizedBox(height: 5),

                const Text("70%"),
              ],
            ),

            const SizedBox(height: 20),

            // 🗺️ LIVE MAP PREVIEW
            Container(

              height: 220,

              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(16),
              ),

              clipBehavior:
                  Clip.hardEdge,

              child: FlutterMap(

                options: MapOptions(

                  initialCenter:
                      currentLocation,

                  initialZoom: 15,
                ),

                children: [

                  // 🌍 MAP
                  TileLayer(

                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                    userAgentPackageName:
                        'com.example.tourist_safety_app',
                  ),

                  // 📍 LIVE MARKER
                  MarkerLayer(

                    markers: [

                      Marker(

                        point:
                            currentLocation,

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

            // 🚨 SOS BUTTON
            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                onPressed: () {},

                style:
                    ElevatedButton.styleFrom(

                  backgroundColor:
                      Colors.red,

                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 18,
                  ),
                ),

                child: const Text(

                  "SOS",

                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 📍 LIVE COORDINATES
            Card(

              child: ListTile(

                leading: const Icon(
                  Icons.location_on,
                ),

                title: const Text(
                  "Current Location",
                ),

                subtitle: Text(

                  "Lat: "
                  "${locationProvider.latitude!.toStringAsFixed(5)}\n"

                  "Lng: "
                  "${locationProvider.longitude!.toStringAsFixed(5)}",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}