import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Privacy Policy for TouriSafe",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Effective Date: June 12, 2026",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            _buildSection(
              "1. Information We Collect",
              "TouriSafe is designed to provide real-time safety services. To achieve this, we collect:\n\n"
              "• Precise Location Data: We collect your location in the background to monitor geofences and hazards, and to share your position with contacts during an SOS event.\n"
              "• Contact Information: Emergency contacts you provide are stored locally and used exclusively for emergency routing.\n"
              "• Sensor Data: Accelerometer and gyroscope data are processed to detect sudden falls or impacts.",
            ),
            _buildSection(
              "2. How We Use Data",
              "Your data is used solely for safety functionalities, including:\n\n"
              "• Triggering alerts when entering high-risk zones.\n"
              "• Automated SOS message dispatching.\n"
              "• Monitoring device health for background reliability.",
            ),
            _buildSection(
              "3. Data Sharing & Third Parties",
              "TouriSafe does not sell or lease your personal data. Location data is shared only with your designated emergency contacts and relevant emergency services when you trigger an SOS. We use OpenStreetMap (Overpass API) for hazard data, but no personal identifiers are sent to these services.",
            ),
            _buildSection(
              "4. Data Security",
              "Safety-critical data like emergency contacts is encrypted and stored locally on your device. We implement industry-standard protocols to protect any data transmitted during an emergency.",
            ),
            _buildSection(
              "5. Your Consent",
              "By using TouriSafe, you explicitly consent to the background collection of location data for safety monitoring. You can revoke these permissions at any time via device settings, though this will disable core safety features.",
            ),
            const SizedBox(height: 20),
            const Center(
              child: Column(
                children: [
                  Text(
                    "For privacy inquiries, please contact:",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    "tejnavi.studio@gmail.com",
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }
}
