import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/location_provider.dart';
import '../providers/settings_provider.dart';

import '../services/sms_service.dart';

class EmergencyScreen
    extends StatefulWidget {

  const EmergencyScreen({
    super.key,
  });

  @override
  State<EmergencyScreen>
      createState() =>
          _EmergencyScreenState();
}

class _EmergencyScreenState
    extends State<EmergencyScreen> {

  late TextEditingController
      messageController;

  @override
  void initState() {

    super.initState();

    final settingsProvider =
        Provider.of<SettingsProvider>(

      context,
      listen: false,
    );

    messageController =
        TextEditingController(

      text:
          settingsProvider
              .sosMessageTemplate,
    );
  }

  @override
  void dispose() {

    messageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final settingsProvider =
        Provider.of<SettingsProvider>(
      context,
    );

    final locationProvider =
        Provider.of<LocationProvider>(
      context,
    );

    final contacts =
        settingsProvider.contacts;

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Emergency",
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          children: [

            // 🚨 BIG SOS
            Center(

              child: ElevatedButton(

                onPressed: () async {

                  await locationProvider
                      .getCurrentLocation();

                  final phoneNumbers =
                      contacts
                          .map(
                            (contact) =>
                                contact.phone,
                          )
                          .toList();

                  final locationText =
                      "Google Maps: "
                      "https://maps.google.com/?q="
                      "${locationProvider.latitude},${locationProvider.longitude}";

                      "Latitude: "
                      "${locationProvider.latitude}\n"

                      "Longitude: "
                      "${locationProvider.longitude}";


                  final finalMessage =

                      messageController.text
                          .replaceAll(
                    "{location}",
                    locationText,
                  );

                  await SmsService.sendSOS(

                    recipients:
                        phoneNumbers,

                    message:
                        finalMessage,
                  );
                },

                style:
                    ElevatedButton.styleFrom(

                  backgroundColor:
                      Colors.red,

                  shape:
                      const CircleBorder(),

                  padding:
                      const EdgeInsets.all(
                    60,
                  ),
                ),

                child: const Text(

                  "SOS",

                  style: TextStyle(

                    fontSize: 28,

                    color: Colors.white,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 📞 CONTACTS
            const Align(

              alignment:
                  Alignment.centerLeft,

              child: Text(

                "Emergency Contacts",

                style: TextStyle(

                  fontSize: 20,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            contacts.isEmpty

                ? const Padding(

                    padding:
                        EdgeInsets.all(20),

                    child: Text(
                      "No contacts added",
                    ),
                  )

                : ListView.builder(

                    shrinkWrap: true,

                    physics:
                        const NeverScrollableScrollPhysics(),

                    itemCount:
                        contacts.length,

                    itemBuilder:
                        (context, index) {

                      final contact =
                          contacts[index];

                      return Card(

                        child: ListTile(

                          leading:
                              const CircleAvatar(

                            child: Icon(
                              Icons.person,
                            ),
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

                                icon:
                                    const Icon(

                                  Icons.call,

                                  color:
                                      Colors.green,
                                ),

                                onPressed:
                                    () async {

                                  await SmsService
                                      .makeCall(
                                    contact.phone,
                                  );
                                },
                              ),

                              // 💬 SMS
                              IconButton(

                                icon:
                                    const Icon(

                                  Icons.message,

                                  color:
                                      Colors.blue,
                                ),

                                onPressed:
                                    () async {

                                  await SmsService
                                      .openSMS(

                                    phone:
                                        contact.phone,

                                    message:
                                        "Hey, I may need help.",
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

            const SizedBox(height: 25),

            // 📨 TEMPLATE TITLE
            const Align(

              alignment:
                  Alignment.centerLeft,

              child: Text(

                "SOS Message Template",

                style: TextStyle(

                  fontSize: 20,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 📝 TEMPLATE FIELD
            TextField(

              controller:
                  messageController,

              maxLines: 8,

              decoration:
                  InputDecoration(

                hintText:
                    "Write SOS message...",

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // 💾 SAVE TEMPLATE
            SizedBox(

              width: double.infinity,

              child: ElevatedButton.icon(

                onPressed: () {

                  Provider.of<SettingsProvider>(

                    context,
                    listen: false,

                  ).saveSOSTemplate(

                    messageController.text,
                  );

                  ScaffoldMessenger.of(context)
                      .showSnackBar(

                    const SnackBar(

                      content: Text(
                        "SOS template saved",
                      ),
                    ),
                  );
                },

                icon: const Icon(
                  Icons.save,
                ),

                label: const Text(
                  "Save Template",
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 📍 LOCATION TOKEN INFO
            Container(

              width: double.infinity,

              padding:
                  const EdgeInsets.all(
                16,
              ),

              decoration: BoxDecoration(

                color:
                    Theme.of(context)
                        .cardColor,

                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),

              child: const Text(

                "Use:\n\n"
                "{location}\n\n"
                "inside message to automatically insert live coordinates.",

                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
