import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'background_service.dart';

class ServiceHealthMonitor {
  static Timer? _watchdogTimer;

  static void start(BuildContext context) {
    _watchdogTimer?.cancel();
    // Wait 30 seconds before starting the first check, then every 2 minutes
    Future.delayed(const Duration(seconds: 30), () {
      _watchdogTimer = Timer.periodic(const Duration(minutes: 2), (timer) async {
        await checkAndRepair(context);
      });
    });
  }

  static Future<void> checkAndRepair(BuildContext context) async {
    final service = FlutterBackgroundService();
    bool isRunning = await service.isRunning();
    
    final prefs = await SharedPreferences.getInstance();
    final lastHeartbeatStr = prefs.getString(BackgroundServiceKeys.lastHeartbeat);
    
    bool isStale = true;
    if (lastHeartbeatStr != null) {
      final lastHeartbeat = DateTime.parse(lastHeartbeatStr);
      final diff = DateTime.now().difference(lastHeartbeat).inMinutes;
      if (diff < 5) {
        isStale = false;
      }
    }

    if (!isRunning || isStale) {
      debugPrint("Service Health Monitor: Service is dead or stale. Restarting...");
      await service.startService();
    }
  }

  static void stop() {
    _watchdogTimer?.cancel();
  }
}
