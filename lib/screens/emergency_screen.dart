import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../providers/location_provider.dart';
import '../providers/settings_provider.dart';

import '../services/sms_service.dart';

class EmergencyScreen extends StatelessWidget {

  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final settingsProvider =
        Provider.of<SettingsProvider>(context);

    final contacts =
        settingsProvider.contacts;

    return Scaffold(

      appBar: AppBar(
        title: const Text("Emergency"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          children: [

            // 🚨 SOS BUTTON
            Center(
              child: ElevatedButton(

                onPressed: () async {

                  final locationProvider =
                      Provider.of<LocationProvider>(
                        context,
                        listen: false,
                      );

                  await locationProvider
                      .getCurrentLocation();

                  final phoneNumbers =
                      contacts
                          .map(
                            (contact) =>
                                contact.phone,
                          )
                          .toList();

                  await Permission.sms.request();

                  await SmsService.sendSOS(

                    recipients: phoneNumbers,

                    message:
                        "🚨 EMERGENCY SOS!\n\n"
                        "I need help immediately.\n\n"
                        "Live Location:\n"
                        "Latitude: ${locationProvider.latitude}\n"
                        "Longitude: ${locationProvider.longitude}",
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(60),
                ),

                child: const Text(
                  "SOS",

                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 📞 CONTACT TITLE
            const Align(
              alignment: Alignment.centerLeft,

              child: Text(
                "Emergency Contacts",

                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 📋 CONTACT LIST
            Expanded(

              child: contacts.isEmpty

                  ? const Center(
                      child: Text(
                        "No contacts added yet",
                      ),
                    )

                  : ListView.builder(

                      itemCount: contacts.length,

                      itemBuilder: (context, index) {

                        final contact =
                            contacts[index];

                        return Card(

                          child: ListTile(

                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),

                            title: Text(
                              contact.name,
                            ),

                            subtitle: Text(
                              contact.phone,
                            ),

                            trailing: Row(
                              mainAxisSize:
                                  MainAxisSize.min,

                              children: [

                                // 📞 CALL
                                IconButton(

                                  icon: const Icon(
                                    Icons.call,
                                    color: Colors.green,
                                  ),

                                  onPressed: () {},
                                ),

                                // 💬 SMS
                                IconButton(

                                  icon: const Icon(
                                    Icons.message,
                                    color: Colors.blue,
                                  ),

                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 10),

            // 📨 ALERT PREVIEW
            Container(

              width: double.infinity,

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius:
                    BorderRadius.circular(12),
              ),

              child: const Text(

                "SOS Alert Preview:\n"
                "I need help. My live location will be shared.",

                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}