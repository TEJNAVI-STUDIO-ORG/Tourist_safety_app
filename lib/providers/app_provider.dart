import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  bool isTracking = true;
  int navigationIndex = 0;
  bool blinkAddContactButton = false;

  void toggleTracking() {
    isTracking = !isTracking;
    notifyListeners();
  }

  void updateNavigationIndex(int index) {
    navigationIndex = index;
    notifyListeners();
  }

  void triggerAddContactBlink() {
    blinkAddContactButton = true;
    notifyListeners();
  }

  void disableAddContactBlink() {
    blinkAddContactButton = false;
    notifyListeners();
  }
}