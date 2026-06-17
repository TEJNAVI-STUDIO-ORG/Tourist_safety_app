import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
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

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _flashController;
  late Animation<Color?> _flashColorAnimation;
  bool _flashRequested = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _flashColorAnimation =
        ColorTween(
          begin: const Color.fromARGB(255, 233, 220, 255),
          end: const Color.fromARGB(255, 149, 103, 228).withOpacity(0.55),
        ).animate(
          CurvedAnimation(parent: _flashController, curve: Curves.easeInOut),
        );
  }

  void _startFlash(AppProvider appProvider) {
    if (!mounted) return;
    _flashController.forward().then((_) {
      _flashController.reverse();
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      appProvider.disableAddContactBlink();
      _flashRequested = false;
    });
  }

  @override
  void dispose() {
    _flashController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final systemStatusProvider = Provider.of<SystemStatusProvider>(context);

    if (appProvider.blinkAddContactButton && !_flashRequested) {
      _flashRequested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startFlash(appProvider);
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),

      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // 📞 CONTACTS TITLE
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Emergency Contacts",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Manage people who will be notified in case of an emergency.",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
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
            Align(
              alignment: Alignment.centerLeft,
              child: AnimatedBuilder(
                animation: _flashController,
                builder: (context, child) {
                  return ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(160, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      backgroundColor: _flashRequested
                          ? _flashColorAnimation.value
                          : const Color.fromARGB(255, 233, 220, 255),
                    ),
                    onPressed: () {
                      showContactDialog(context, settingsProvider);
                    },
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text("Add Contact"),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            // 🔔 ALERT SETTINGS
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Alert Preferences",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Configure how and when the app should monitor your safety.",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
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
                        final locationProvider = Provider.of<LocationProvider>(
                          context,
                          listen: false,
                        );
                        final zoneProvider = Provider.of<ZoneProvider>(
                          context,
                          listen: false,
                        );
                        final notificationProvider =
                            Provider.of<NotificationProvider>(
                              context,
                              listen: false,
                            );

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
                        status: value
                            ? "Geofence Alerts Active"
                            : "Geofence Alerts Disabled",
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
                      final notificationActive =
                          settingsProvider.pushNotifications || value;
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
                      final notificationActive =
                          settingsProvider.smsAlerts || value;
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
                        status: value
                            ? "Fall Detection Active"
                            : "Fall Detection Disabled",
                      );
                    },
                  ),

                  // 🧪 TEST ZONE
                  SwitchListTile(
                    title: const Text("Show Test Danger Zone"),
                    subtitle: const Text(
                      "Display a virtual danger zone near you for testing",
                    ),
                    value: settingsProvider.showTestZone,
                    onChanged: (value) {
                      settingsProvider.toggleShowTestZone();

                      // Refresh zones to reflect change
                      final locationProvider = Provider.of<LocationProvider>(
                        context,
                        listen: false,
                      );
                      final zoneProvider = Provider.of<ZoneProvider>(
                        context,
                        listen: false,
                      );

                      if (locationProvider.latitude != null &&
                          locationProvider.longitude != null) {
                        zoneProvider.refreshZones(
                          lat: locationProvider.latitude!,
                          lng: locationProvider.longitude!,
                          statusProvider: systemStatusProvider,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Appearance",

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

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

            const SizedBox(height: 25),

            // ℹ️ ABOUT
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.shield,
                      color: Color.lerp(
                        Theme.of(context).colorScheme.primary,
                        Colors.black,
                        0.1,
                      ),
                    ),

                    title: const Text("TouriSafe"),

                    subtitle: const Text("Version 2.40.23"),
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: Icon(
                      Icons.policy_outlined,
                      color: Color.lerp(
                        Theme.of(context).colorScheme.primary,
                        Colors.black,
                        0.1,
                      ),
                    ),

                    title: const Text("Privacy Policy"),

                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),

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
                    leading: Icon(
                      Icons.gavel_outlined,
                      color: Color.lerp(
                        Theme.of(context).colorScheme.primary,
                        Colors.black,
                        0.1,
                      ),
                    ),

                    title: const Text("Terms of Service"),

                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),

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
                    leading: Icon(
                      Icons.info_outline,
                      color: Color.lerp(
                        Theme.of(context).colorScheme.primary,
                        Colors.black,
                        0.1,
                      ),
                    ),

                    title: const Text("About TouriSafe"),

                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),

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
