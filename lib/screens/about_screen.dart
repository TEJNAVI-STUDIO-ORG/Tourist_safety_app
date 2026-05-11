import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {

  const AboutScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "About TouristSafe",
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Center(

              child: Icon(
                Icons.shield,
                size: 90,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 20),

            const Center(

              child: Text(

                "TouristSafe",

                style: TextStyle(
                  fontSize: 28,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Center(

              child: Text(
                "Version 1.0.0",
              ),
            ),

            const SizedBox(height: 30),

            const Text(

              "About App",

              style: TextStyle(

                fontSize: 22,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(

              "TouristSafe is a smart tourist safety "
              "application designed especially for "
              "travelers, trekkers, and explorers.\n\n"

              "The app provides:\n\n"

              "• Live GPS Tracking\n"
              "• Emergency SOS Alerts\n"
              "• Real-Time Location Sharing\n"
              "• Emergency Contact Management\n"
              "• Geofence Danger Alerts\n"
              "• Safety Notifications\n"
              "• Smart Tourist Protection System\n\n"

              "This app is built to improve tourist "
              "safety in remote and risky areas.",

              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
