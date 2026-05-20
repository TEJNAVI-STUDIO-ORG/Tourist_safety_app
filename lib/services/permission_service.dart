import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<void> requestAllPermissions() async {
    // =========================
    // LOCATION SERVICE ENABLE
    // =========================

    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    }

    // =========================
    // FOREGROUND LOCATION
    // =========================

    await Permission.location.request();

    // =========================
    // BACKGROUND LOCATION
    // =========================

    if (await Permission.location.isGranted) {
      await Permission.locationAlways.request();
    }

    // =========================
    // OTHER PERMISSIONS
    // =========================

    await [
      Permission.sms,
      Permission.phone,
      Permission.notification,
      Permission.activityRecognition,
    ].request();
  }

  static Future<bool> checkLocationPermission() async {
    return await Permission.location.isGranted;
  }

  static Future<bool> checkSmsPermission() async {
    return await Permission.sms.isGranted;
  }
}