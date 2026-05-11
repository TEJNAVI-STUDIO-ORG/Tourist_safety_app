import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';
import 'package:vibration/vibration.dart';

import 'notification_service.dart';

// NOTE: This class is superseded by AdvancedFallDetectionService and
// NativeFallBridge. Kept only for reference; not used anywhere.
class FallDetectionService {
  static void startListening() {
    accelerometerEventStream().listen((event) async {
      final double acceleration = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      if (acceleration > 25) {
        await NotificationService.showNotification(
          title: 'Fall Detected',
          body: 'Possible fall detected!',
        );

        final bool? hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator == true) {
          Vibration.vibrate(duration: 1000);
        }
      }
    });
  }
}