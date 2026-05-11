import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../providers/system_status_provider.dart';
import '../providers/location_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/zone_provider.dart';
import '../services/geofence_service.dart';
import '../services/advanced_fall_detection_service.dart';

import 'about_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final systemStatusProvider = Provider.of<SystemStatusProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // 🌙 DARK MODE
            Card(
              child: SwitchListTile(
                title: const Text("Dark Mode"),

                subtitle: const Text("Enable dark theme"),

                value: settingsProvider.darkMode,

                onChanged: (value) {
                  settingsProvider.toggleDarkMode();
                },
              ),
            ),

            const SizedBox(height: 20),

            // 📞 CONTACTS TITLE
            const Text(
              "Emergency Contacts",

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // 📞 CONTACT LIST
            ...settingsProvider.contacts.map((contact) {
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),

                  title: Text(contact.name),

                  subtitle: Text(contact.phone),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      // ✏️ EDIT
                      IconButton(
                        icon: const Icon(Icons.edit),

                        onPressed: () {
                          showContactDialog(
                            context,

                            settingsProvider,

                            isEditing: true,

                            index: settingsProvider.contacts.indexOf(contact),

                            existingName: contact.name,

                            existingPhone: contact.phone,
                          );
                        },
                      ),

                      // 🗑 DELETE
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),

                        onPressed: () {
                          settingsProvider.removeContact(
                            settingsProvider.contacts.indexOf(contact),
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
                showContactDialog(context, settingsProvider);
              },

              icon: const Icon(Icons.add),

              label: const Text("Add Contact"),
            ),

            const SizedBox(height: 25),

            // 🔔 ALERT SETTINGS
            const Text(
              "Alert Preferences",

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Card(
              child: Column(
                children: [
                  // 📍 GEOFENCE
                  SwitchListTile(
                    title: const Text("Geofence Alerts"),

                    subtitle: const Text(
                      "Triggers alerts when leaving safe zones",
                    ),

                    value: settingsProvider.geofenceAlerts,

                    onChanged: (value) {
                      settingsProvider.toggleGeofenceAlerts();
                      
                      // Actually start/stop geofence service
                      if (value) {
                        // Start geofence monitoring
                        final locationProvider = Provider.of<LocationProvider>(context, listen: false);
                        final zoneProvider = Provider.of<ZoneProvider>(context, listen: false);
                        final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
                        
                        GeofenceService.startMonitoring(
                          locationProvider: locationProvider,
                          zoneProvider: zoneProvider,
                          notificationProvider: notificationProvider,
                        );
                      } else {
                        // Stop geofence monitoring
                        GeofenceService.stopMonitoring();
                      }
                      
                      // Update system status
                      systemStatusProvider.updateGeofence(
                        active: value,
                        status: value ? "Geofence Alerts Active" : "Geofence Alerts Disabled",
                      );
                    },
                  ),

                  // 💬 SMS
                  SwitchListTile(
                    title: const Text("SMS Emergency Alerts"),

                    subtitle: const Text("Send emergency SMS to contacts"),

                    value: settingsProvider.smsAlerts,

                    onChanged: (value) {
                      settingsProvider.toggleSmsAlerts();
                      
                      // SMS alerts are part of notification system
                      // The actual SMS sending is handled when SOS is triggered
                      // Update system status to reflect SMS alert preference
                      final notificationActive = settingsProvider.pushNotifications || value;
                      systemStatusProvider.updateNotifications(
                        active: notificationActive,
                        status: notificationActive 
                            ? "Notifications Active (SMS+Push)" 
                            : "Notifications Disabled",
                      );
                    },
                  ),

                  // 🔔 PUSH
                  SwitchListTile(
                    title: const Text("Push Notifications"),

                    subtitle: const Text("Receive safety alerts and warnings"),

                    value: settingsProvider.pushNotifications,

                    onChanged: (value) {
                      settingsProvider.togglePushNotifications();
                      
                      // Push notifications are handled by NotificationService
                      // Update system status to reflect combined notification state
                      final notificationActive = settingsProvider.smsAlerts || value;
                      systemStatusProvider.updateNotifications(
                        active: notificationActive,
                        status: notificationActive 
                            ? "Notifications Active (SMS+Push)" 
                            : "Notifications Disabled",
                      );
                    },
                  ),

                  // 🚶 FALL DETECTION
                  SwitchListTile(
                    title: const Text("Fall Detection"),

                    subtitle: const Text("Detect sudden falls during travel"),

                    value: settingsProvider.fallDetection,

                    onChanged: (value) {
                      settingsProvider.toggleFallDetection();
                      
                      // Actually start/stop fall detection service
                      if (value) {
                        // Start fall detection
                        AdvancedFallDetectionService.startDetection();
                      } else {
                        // Stop fall detection
                        AdvancedFallDetectionService.stopDetection();
                      }
                      
                      // Update system status
                      systemStatusProvider.updateFallDetection(
                        active: value,
                        status: value ? "Fall Detection Active" : "Fall Detection Disabled",
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ℹ️ ABOUT
            Card(
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.info),

                    title: Text("TouristSafe"),

                    subtitle: Text("Version 1.0.0"),
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(Icons.privacy_tip),

                    title: const Text("Privacy Policy"),

                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.description),

                    title: const Text("Terms of Service"),

                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsScreen(),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.android),

                    title: const Text("About App"),

                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 🔄 RESET BUTTON
            SizedBox(
              width: double.infinity,

              child: OutlinedButton(
                onPressed: () {
                  settingsProvider.resetSettings();
                },

                child: const Text("Reset Settings"),
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
  final nameController = TextEditingController(text: existingName);

  final phoneController = TextEditingController(text: existingPhone);

  showDialog(
    context: context,

    builder: (context) {
      return AlertDialog(
        title: Text(isEditing ? "Edit Contact" : "Add Contact"),

        content: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            // 👤 NAME
            TextField(
              controller: nameController,

              decoration: const InputDecoration(labelText: "Name"),
            ),

            const SizedBox(height: 15),

            // 📞 PHONE
            TextField(
              controller: phoneController,

              keyboardType: TextInputType.phone,

              decoration: const InputDecoration(labelText: "Phone Number"),
            ),
          ],
        ),

        actions: [
          // ❌ CANCEL
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },

            child: const Text("Cancel"),
          ),

          // 💾 SAVE
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();

              final phone = phoneController.text.trim();

              if (name.isEmpty || phone.isEmpty) {
                return;
              }

              if (isEditing) {
                settingsProvider.editContact(index!, name, phone);
              } else {
                settingsProvider.addContact(name, phone);
              }

              Navigator.pop(context);
            },

            child: const Text("Save"),
          ),
        ],
      );
    },
  );
}
