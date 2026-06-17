import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms of Service"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "TouriSafe Terms of Service",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Last Updated: June 12, 2026",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            _buildSection(
              "1. Acceptance of Terms",
              "By downloading or using TouriSafe, these terms will automatically apply to you. You should ensure that you read them carefully before using the app. We are offering you this app to use for your own personal use without cost, but you are not allowed to send it on to anyone else, and you're not allowed to copy, or modify the app, any part of the app, or our trademarks in any way.",
            ),
            _buildSection(
              "2. Service Limitations",
              "TouriSafe is intended as a safety aid and supplement to official emergency services. It is NOT a replacement for professional emergency response (911/112/etc.). We do not guarantee that the app will operate in areas with no cellular data or GPS signal. The effectiveness of SOS alerts depends on your mobile carrier's SMS delivery capabilities.",
            ),
            _buildSection(
              "3. User Responsibilities",
              "As a user of TouriSafe, you are responsible for:\n\n"
              "• Ensuring your device remains sufficiently charged.\n"
              "• Granting the necessary location, SMS, and sensor permissions.\n"
              "• Maintaining accurate emergency contact information.\n"
              "• Using the SOS feature only in genuine emergency situations.",
            ),
            _buildSection(
              "4. Limitation of Liability",
              "To the maximum extent permitted by law, TouriSafe and its developers shall not be liable for any personal injury, property damage, or loss of life resulting from the use or inability to use the application, including failures in notification delivery, GPS inaccuracies, or hardware malfunctions.",
            ),
            _buildSection(
              "5. Changes to the Service",
              "We reserve the right to make changes to the app or to charge for its services, at any time and for any reason. We will never charge you for the app or its services without making it very clear to you exactly what you're paying for.",
            ),
            const SizedBox(height: 40),
            const Center(
              child: Column(
                children: [
                  Text(
                    "For questions or support, contact:",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    "tejnavi.studio@gmail.com",
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
