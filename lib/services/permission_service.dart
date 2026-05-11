import 'package:permission_handler/permission_handler.dart';

class PermissionService {

  static Future<void> requestAllPermissions() async {

    // Foreground location first
    await Permission.location.request();

    // Background location after foreground granted
    if (await Permission.location.isGranted) {
      await Permission.locationAlways.request();
    }

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