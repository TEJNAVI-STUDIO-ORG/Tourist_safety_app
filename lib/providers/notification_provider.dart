import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> notifications = [];

  String selectedFilter = 'all';

  List<AppNotification> get allNotifications {
    List<AppNotification> filtered = notifications;

    if (selectedFilter != 'all') {
      filtered = notifications.where((n) => n.type == selectedFilter).toList();
    }

    filtered.sort((a, b) => b.time.compareTo(a.time));

    return filtered;
  }

  Future<void> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getStringList('notifications') ?? [];

    notifications = data
        .map((e) => AppNotification.fromJson(jsonDecode(e)))
        .toList();

    notifyListeners();
  }

  Future<void> addNotification(AppNotification notification) async {
    notifications.add(notification);

    final prefs = await SharedPreferences.getInstance();

    final data = notifications.map((e) => jsonEncode(e.toJson())).toList();

    await prefs.setStringList('notifications', data);

    notifyListeners();
  }

  void setFilter(String filter) {
    selectedFilter = filter;

    notifyListeners();
  }

  void markAsRead(String id) {
    final notification = notifications.firstWhere((n) => n.id == id);

    notification.isRead = true;

    _saveNotifications();

    notifyListeners();
  }

  void deleteNotification(String id) {
    notifications.removeWhere((n) => n.id == id);

    _saveNotifications();

    notifyListeners();
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();

    final data = notifications.map((e) => jsonEncode(e.toJson())).toList();

    await prefs.setStringList('notifications', data);
  }
}
