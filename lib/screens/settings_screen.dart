import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {

  const SettingsScreen({
    super.key,
  });

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {

    final settingsProvider =
        Provider.of<SettingsProvider>(
      context,
    );

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Settings",
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // 🌙 DARK MODE
            Card(

              child: SwitchListTile(

                title: const Text(
                  "Dark Mode",
                ),

                subtitle: const Text(
                  "Enable dark theme",
                ),

                value:
                    settingsProvider.darkMode,

                onChanged: (value) {

                  settingsProvider
                      .toggleDarkMode();
                },
              ),
            ),

            const SizedBox(height: 20),

            // 📞 CONTACTS TITLE
            const Text(

              "Emergency Contacts",

              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // 📞 CONTACT LIST
            ...settingsProvider.contacts
                .map((contact) {

              return Card(

                child: ListTile(

                  leading: const CircleAvatar(
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

                      // ✏️ EDIT
                      IconButton(

                        icon: const Icon(
                          Icons.edit,
                        ),

                        onPressed: () {

                          showContactDialog(

                            context,

                            settingsProvider,

                            isEditing: true,

                            index:
                                settingsProvider
                                    .contacts
                                    .indexOf(
                                        contact),

                            existingName:
                                contact.name,

                            existingPhone:
                                contact.phone,
                          );
                        },
                      ),

                      // 🗑 DELETE
                      IconButton(

                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),

                        onPressed: () {

                          settingsProvider
                              .removeContact(

                            settingsProvider
                                .contacts
                                .indexOf(
                                    contact),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 10),

            // ➕ ADD CONTACT
            ElevatedButton.icon(

              onPressed: () {

                showContactDialog(
                  context,
                  settingsProvider,
                );
              },

              icon: const Icon(
                Icons.add,
              ),

              label: const Text(
                "Add Contact",
              ),
            ),

            const SizedBox(height: 25),

            // 🔔 ALERT SETTINGS
            const Text(

              "Alert Preferences",

              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(

              child: Column(

                children: [

                  // 📍 GEOFENCE
                  SwitchListTile(

                    title: const Text(
                      "Geofence Alerts",
                    ),

                    value: settingsProvider
                        .geofenceAlerts,

                    onChanged: (value) {

                      settingsProvider
                          .toggleGeofenceAlerts();
                    },
                  ),

                  // 💬 SMS ALERTS
                  SwitchListTile(

                    title: const Text(
                      "SMS Alerts",
                    ),

                    value: settingsProvider
                        .smsAlerts,

                    onChanged: (value) {

                      settingsProvider
                          .toggleSmsAlerts();
                    },
                  ),

                  // 🔔 PUSH NOTIFICATIONS
                  SwitchListTile(

                    title: const Text(
                      "Push Notifications",
                    ),

                    value: settingsProvider
                        .pushNotifications,

                    onChanged: (value) {

                      settingsProvider
                          .togglePushNotifications();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 📡 APP STATUS
            Card(

              child: ListTile(

                leading: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),

                title: const Text(
                  "App Status",
                ),

                subtitle: const Text(
                  "Online and tracking active",
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ℹ️ ABOUT
            Card(

              child: const ListTile(

                leading: Icon(
                  Icons.info,
                ),

                title: Text(
                  "About App",
                ),

                subtitle: Text(
                  "TouristSafe v1.0\n"
                  "Smart Tourist Safety System",
                ),
              ),
            ),

            const SizedBox(height: 25),

            // 🔄 RESET BUTTON
            SizedBox(

              width: double.infinity,

              child: OutlinedButton(

                onPressed: () {

                  settingsProvider
                      .resetSettings();
                },

                child: const Text(
                  "Reset Settings",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🚀 CONTACT DIALOG
void showContactDialog(

  BuildContext context,

  SettingsProvider settingsProvider, {

  bool isEditing = false,

  int? index,

  String existingName = "",

  String existingPhone = "",
}) {

  final nameController =
      TextEditingController(
    text: existingName,
  );

  final phoneController =
      TextEditingController(
    text: existingPhone,
  );

  showDialog(

    context: context,

    builder: (context) {

      return AlertDialog(

        title: Text(

          isEditing
              ? "Edit Contact"
              : "Add Contact",
        ),

        content: Column(

          mainAxisSize:
              MainAxisSize.min,

          children: [

            // 👤 NAME
            TextField(

              controller:
                  nameController,

              decoration:
                  const InputDecoration(
                labelText: "Name",
              ),
            ),

            const SizedBox(height: 15),

            // 📞 PHONE
            TextField(

              controller:
                  phoneController,

              keyboardType:
                  TextInputType.phone,

              decoration:
                  const InputDecoration(
                labelText:
                    "Phone Number",
              ),
            ),
          ],
        ),

        actions: [

          // ❌ CANCEL
          TextButton(

            onPressed: () {

              Navigator.pop(
                context,
              );
            },

            child: const Text(
              "Cancel",
            ),
          ),

          // 💾 SAVE
          ElevatedButton(

            onPressed: () {

              final name =
                  nameController.text
                      .trim();

              final phone =
                  phoneController.text
                      .trim();

              if (name.isEmpty ||
                  phone.isEmpty) {

                return;
              }

              if (isEditing) {

                settingsProvider
                    .editContact(
                  index!,
                  name,
                  phone,
                );

              } else {

                settingsProvider
                    .addContact(
                  name,
                  phone,
                );
              }

              Navigator.pop(
                context,
              );
            },

            child: const Text(
              "Save",
            ),
          ),
        ],
      );
    },
  );
}