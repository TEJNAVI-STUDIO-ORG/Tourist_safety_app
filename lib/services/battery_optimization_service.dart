import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/material.dart';
import '../core/global.dart';

class BatteryOptimizationService {
  static Future<bool> isOptimized() async {
    try {
      final bool? isBatteryOptimizationDisabled =
          await DisableBatteryOptimization.isBatteryOptimizationDisabled;
      return !(isBatteryOptimizationDisabled ?? false);
    } catch (e) {
      debugPrint("Error checking battery optimization: $e");
      return false;
    }
  }

  static Future<void> checkAndShowOptimizationDialog(BuildContext context) async {
    // Wait for navigator to be ready and MaterialApp to be fully initialized
    await Future.delayed(const Duration(seconds: 2));
    
    final bool optimized = await isOptimized();
    final navContext = navigatorKey.currentContext;
    
    if (optimized && navContext != null && navContext.mounted) {
      try {
        showDialog(
          context: navContext,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Safety Protection Alert"),
            content: const Text(
              "To ensure your safety tracking and fall detection stay active 24/7, "
              "please disable battery optimization for TouriSafe. "
              "Otherwise, Android may stop your protection silently.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("LATER"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text("FIX NOW"),
              ),
            ],
          ),
        );
      } catch (e) {
        debugPrint("Error showing optimization dialog: $e");
      }
    }
  }

  static Future<void> openOptimizationSettings() async {
    await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
  }
}
