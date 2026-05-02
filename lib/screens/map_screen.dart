import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tracking Map"),
        actions: [
          IconButton(
            icon: Icon(Icons.layers),
            onPressed: () {},
          )
        ],
      ),
      body: Stack(
        children: [

          // 🔹 Fake Map Background
          Container(
            color: Colors.grey[300],
            child: Center(
              child: Text("Map View (Google Maps later)"),
            ),
          ),

          // 🔴 Danger Zone (circle simulation)
          Positioned(
            top: 150,
            left: 100,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // 📍 Current Location Marker
          Positioned(
            top: 200,
            left: 160,
            child: Icon(
              Icons.location_pin,
              size: 40,
              color: Colors.blue,
            ),
          ),

          // 🟢 Safety Status Card
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.security, color: Colors.green),
                    SizedBox(width: 10),
                    Text("Status: Safe"),
                  ],
                ),
              ),
            ),
          ),

          // 🎯 Recenter Button
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {},
              child: Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }``
}