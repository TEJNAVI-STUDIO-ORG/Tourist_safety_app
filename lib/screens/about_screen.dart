import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About TouriSafe"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                Icons.shield,
                size: 100,
                color: Color.lerp(Theme.of(context).colorScheme.primary, Colors.black, 0.1),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                "TouriSafe",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                "Version 2.40.23",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              "Our Mission",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "TouriSafe is your intelligent companion for secure exploration. Engineered for travelers, trekkers, and global explorers, our mission is to ensure that safety never stands in the way of adventure.\n\n"
              "By combining cutting-edge geospatial intelligence with reliable emergency protocols, TouriSafe provides a 360-degree safety net that works even when you're off the beaten path.",
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Core Safety Ecosystem",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(Icons.gps_fixed, "Precision Location Tracking"),
            _buildFeatureItem(Icons.notification_important, "Instant SOS Emergency Routing"),
            _buildFeatureItem(Icons.security, "Geofencing & Hazard Detection"),
            _buildFeatureItem(Icons.people, "Trusted Contact Management"),
            _buildFeatureItem(Icons.sync_problem, "Smart Fall & Crash Detection"),
            const SizedBox(height: 40),
            const Center(
              child: Column(
                children: [
                  Text(
                    "Designed & Developed by Aditya Vispute",
                    style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "aditya.vispute@gmail.com",
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "© 2026 TouriSafe. All rights reserved.",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
