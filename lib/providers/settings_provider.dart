import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contact_model.dart';

class ContactModel {

  final String name;
  final String phone;

  ContactModel({
    required this.name,
    required this.phone,
  });

  Map<String, dynamic> toJson() {

    return {
      "name": name,
      "phone": phone,
    };
  }

  factory ContactModel.fromJson(
      Map<String, dynamic> json) {

    return ContactModel(
      name: json["name"],
      phone: json["phone"],
    );
  }
}

class SettingsProvider
    extends ChangeNotifier {

  bool darkMode = true;

  bool geofenceAlerts = true;

  bool smsAlerts = true;
  
  bool pushNotifications = true;

  List<ContactModel> contacts = [];

  SettingsProvider() {

    loadSettings();
  }


  // 🌙 DARK MODE
  void toggleDarkMode() {

    darkMode = !darkMode;

    saveSettings();

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

    notifyListeners();
  }


  // 🔔 PUSH
  void togglePushNotifications() {

    pushNotifications =
        !pushNotifications;

    saveSettings();

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

    notifyListeners();
  }

  void removeContact(
    int index,
  ) {

    contacts.removeAt(index);

    saveSettings();

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

    contacts.clear();

    saveSettings();

    notifyListeners();
  }
}