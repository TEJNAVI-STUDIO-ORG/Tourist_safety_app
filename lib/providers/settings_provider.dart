import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contact_model.dart';
import '../services/sos_service.dart';
import '../providers/system_status_provider.dart';

class SettingsProvider extends ChangeNotifier {

  bool darkMode = true;

  bool geofenceAlerts = true;

  bool smsAlerts = true;

  bool privateMode = false;
  
  bool pushNotifications = true;

  bool fallDetection = true;

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

    notifyListeners();
  }

  // 🩹 FALL DETECTION
  void toggleFallDetection() {

    fallDetection =
        !fallDetection;

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

    // CONTACTS
    List<String> contactList =
        contacts.map((contact) {

      return jsonEncode(
        contact.toJson(),
      );

    }).toList();

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
            ?? true;

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
    "🚨 EMERGENCY SOS!\n\n"
    "I need help immediately.\n\n"
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

    darkMode = true;

    geofenceAlerts = true;

    smsAlerts = true;

    pushNotifications = true;

    fallDetection = true;

    contacts.clear();

    saveSettings();

    notifyListeners();
  }
}