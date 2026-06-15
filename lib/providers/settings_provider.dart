import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contact_model.dart';
import '../services/sos_service.dart';
import '../services/geofence_service.dart';
import '../services/advanced_fall_detection_service.dart';
import '../services/system_status_service.dart';
import '../providers/system_status_provider.dart';
import '../providers/location_provider.dart';
import '../providers/zone_provider.dart';
import '../providers/notification_provider.dart';
import '../core/global.dart';

class SettingsProvider extends ChangeNotifier {

  bool darkMode = false;

  bool geofenceAlerts = true;

  bool smsAlerts = true;

  bool privateMode = false;
  
  bool pushNotifications = true;

  bool fallDetection = true;

  bool showTestZone = false;

  List<ContactModel> contacts = [];

  String sosMessageTemplate =
    "🚨 EMERGENCY SOS!\n\n"
    "I need help immediately.\n\n"
    "My live location:\n"
    "{location}";

  // Reference to system status provider for updates
  SystemStatusProvider? systemStatusProvider;

  SettingsProvider() {

    loadSettings();
  }

  void setSystemStatusProvider(SystemStatusProvider provider) {
    systemStatusProvider = provider;
    // Check SOS status when provider is set
    _updateSosStatus();
  }

  void _updateSosStatus() {
    if (systemStatusProvider != null) {
      SosService.checkAndUpdateSosStatus(
        statusProvider: systemStatusProvider!,
        settingsProvider: this,
      );
    }
  }

  void _updateNotificationStatus() {
    if (systemStatusProvider != null) {
      final bool pushEnabled = pushNotifications || smsAlerts;
      final String pushState = pushEnabled ? 'ACTIVE' : 'DISABLED';
      systemStatusProvider!.updateNotifications(
        active: pushEnabled,
        status: 'Push Alerts: $pushState | SOS: ${systemStatusProvider!.sosReady ? 'READY' : 'NOT READY'}',
      );
    }
  }

  // 🌙 DARK MODE
  void toggleDarkMode() {

    darkMode = !darkMode;

    saveSettings();

    notifyListeners();
  }

  void updateSosTemplate(
      String message,
    ) {

      sosMessageTemplate = message;

      saveSettings();

      _updateSosStatus();

      notifyListeners();
    }

  // 📍 GEOFENCE
  void toggleGeofenceAlerts() {

    geofenceAlerts =
        !geofenceAlerts;

    saveSettings();

    notifyListeners();
  }

  // 💬 SMS
  void toggleSmsAlerts() {

    smsAlerts = !smsAlerts;

    saveSettings();

    _updateNotificationStatus();

    notifyListeners();
  }

  void togglePrivateMode() {

    privateMode = !privateMode;

    saveSettings();
    
    _handlePrivacyModeChange();

    notifyListeners();
  }

  void _handlePrivacyModeChange() {
    if (systemStatusProvider != null) {
      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        final locationProvider = Provider.of<LocationProvider>(ctx, listen: false);
        
        if (privateMode) {
          locationProvider.stopTracking();
          GeofenceService.stopMonitoring();
          AdvancedFallDetectionService.stopDetection();
          // We don't stop the background service entirely to keep the heartbeat/uptime monitoring,
          // but we can signal it to stop active tracking if needed.
          // For now, stopping the main streams is enough as per requirements.
        } else {
          locationProvider.resumeTracking();
          GeofenceService.startMonitoring(
            locationProvider: locationProvider,
            zoneProvider: Provider.of<ZoneProvider>(ctx, listen: false),
            notificationProvider: Provider.of<NotificationProvider>(ctx, listen: false),
          );
          AdvancedFallDetectionService.initialize(ctx);
        }
      }
      
      // Update all statuses immediately
      SystemStatusService.initializeAllStatus(navigatorKey.currentContext!);
    }
  }

  // 🩹 FALL DETECTION
  void toggleFallDetection() {

    fallDetection =
        !fallDetection;

    saveSettings();

    notifyListeners();
  }

  // 🧪 TEST ZONE
  void toggleShowTestZone() {
    showTestZone = !showTestZone;
    saveSettings();
    notifyListeners();
  }

  // 🔔 PUSH
  void togglePushNotifications() {

    pushNotifications =
        !pushNotifications;

    saveSettings();

    _updateNotificationStatus();

    notifyListeners();
  }

  // 📨 SAVE SOS TEMPLATE
  void saveSOSTemplate(String message) {

    sosMessageTemplate = message;

    saveSettings();

    _updateSosStatus();

    notifyListeners();
  }

    // 📞 ADD CONTACT
    void addContact(
    String name,
    String phone,
  ) {

    contacts.add(

      ContactModel(
        name: name,
        phone: phone,
      ),
    );

    saveSettings();

    _updateSosStatus();

    notifyListeners();
  }

  void removeContact(
    int index,
  ) {

    contacts.removeAt(index);

    saveSettings();

    _updateSosStatus();

    notifyListeners();
  }

  void editContact(

    int index,

    String name,

    String phone,
  ) {

    contacts[index] =
        ContactModel(
      name: name,
      phone: phone,
    );

    saveSettings();

    _updateSosStatus();

    notifyListeners();
  }

  // 💾 SAVE SETTINGS
  Future<void> saveSettings() async {

    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.setBool(
      "darkMode",
      darkMode,
    );

    await prefs.setBool(
      "geofenceAlerts",
      geofenceAlerts,
    );

    await prefs.setBool(
      "smsAlerts",
      smsAlerts,
    );

    await prefs.setBool(
      "pushNotifications",
      pushNotifications,
    );

    await prefs.setBool(
      "privateMode",
      privateMode,
    );

    await prefs.setString(
      "sosMessageTemplate",
      sosMessageTemplate,
    );

    await prefs.setBool(
      "fallDetection",
      fallDetection,
    );

    await prefs.setBool(
      "showTestZone",
      showTestZone,
    );

    // CONTACTS
    List<String> contactList =
        contacts.map((contact) {

      return jsonEncode(
        contact.toJson(),
      );

    }).toList().cast<String>();

    await prefs.setStringList(
      "contacts",
      contactList,
    );
  }

  // 📂 LOAD SETTINGS
  Future<void> loadSettings() async {

    final prefs =
        await SharedPreferences
            .getInstance();

    darkMode =
        prefs.getBool("darkMode")
            ?? false;

    geofenceAlerts =
        prefs.getBool(
          "geofenceAlerts",
        ) ??
        true;

    smsAlerts =
        prefs.getBool(
          "smsAlerts",
        ) ??
        true;

    pushNotifications =
        prefs.getBool(
          "pushNotifications",
        ) ??
        true;

    privateMode =
      prefs.getBool(
        "privateMode",
      ) ?? 
      false;

    fallDetection =
      prefs.getBool(
        "fallDetection",
      ) ?? 
      true;

    sosMessageTemplate =
    prefs.getString(
      "sosMessageTemplate",
    ) ??
    "🚨 EMERGENCY SOS!\n"
    "I need help immediately.\n"
    "My live location:\n"
    "{location}";

    // CONTACTS
    List<String>? contactList =
        prefs.getStringList(
          "contacts",
        );

    if (contactList != null) {

      contacts =
          contactList.map((contact) {

        return ContactModel.fromJson(
          jsonDecode(contact),
        );

      }).toList();
    }

    notifyListeners();
  }

  void resetSettings() {

    darkMode = false;

    geofenceAlerts = true;

    smsAlerts = true;

    pushNotifications = true;

    fallDetection = true;

    contacts.clear();

    saveSettings();

    notifyListeners();
  }
}