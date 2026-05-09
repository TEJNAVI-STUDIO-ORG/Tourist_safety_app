import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {

  bool isTracking = true;

  void toggleTracking() {
    isTracking = !isTracking;
    notifyListeners();
  }
}