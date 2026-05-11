import 'package:flutter/material.dart';

class PrivacyPolicyScreen
    extends StatelessWidget {

  const PrivacyPolicyScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Privacy Policy",
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(20),

        child: const Text(

          "Privacy Policy\n\n"

          "TouristSafe collects location "
          "data only to provide live tracking, "
          "SOS alerts, and geofencing safety "
          "features.\n\n"

          "Your emergency contacts are stored "
          "locally on your device.\n\n"

          "We do not sell or share your "
          "personal data with third parties.\n\n"

          "Location access is used only "
          "for tourist safety features.\n\n"

          "SMS permissions are used only "
          "for emergency SOS functionality.\n\n"

          "By using TouristSafe, you agree "
          "to this privacy policy.",

          style: TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
