import 'package:flutter/material.dart';

import '../models/zone_model.dart';

class ZoneProvider extends ChangeNotifier {
  List<ZoneModel> zones = [];

  void setZones(List<ZoneModel> newZones) {
    zones = newZones;

    notifyListeners();
  }

  void clearZones() {
    zones.clear();

    notifyListeners();
  }
}