import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'advanced_fall_detection_service.dart';

/// Dart bridge to the native [FallDetectionService] running in Kotlin.
///
/// Responsibilities:
///  - Start / stop the native foreground service.
///  - Receive live fall events via MethodChannel (app open).
///  - On cold-start, check SharedPreferences for a pending fall that
///    happened while the app was killed.
class NativeFallBridge {
  static const _channel = MethodChannel('fall_detection_channel');

  static bool _initialized = false;

  // ─── Public API ─────────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Start the native service
    await _channel.invokeMethod<void>('startService');

    // Handle live fall events from native while app is open
    _channel.setMethodCallHandler(_onNativeCall);

    // Check for a fall that happened while the app was killed
    await _checkPendingFall();
  }

  static Future<void> dispose() async {
    await _channel.invokeMethod<void>('stopService');
    _initialized = false;
  }

  /// Ensures the native fall-detection foreground service is running.
  static Future<void> ensureRunning() async {
    if (!_initialized) {
      await initialize();
      return;
    }

    try {
      await _channel.invokeMethod<void>('startService');
    } catch (_) {}
  }

  /// Call this when the user confirms they are safe (from the dialog).
  static Future<void> markSafe() async {
    await _channel.invokeMethod<void>('clearFall');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fall_pending', false);
  }

  // ─── Private ────────────────────────────────────────────────────────────────

  /// Handles MethodChannel calls pushed FROM native → Dart.
  static Future<dynamic> _onNativeCall(MethodCall call) async {
    if (call.method == 'fallDetected') {
      _showFallDialog();
    }
  }

  /// On app (re)open: check if a fall was detected while app was killed.
  static Future<void> _checkPendingFall() async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'checkPendingFall',
      );
      final pending = result?['pending'] as bool? ?? false;
      if (pending) _showFallDialog();
    } catch (_) {}
  }

  static void _showFallDialog() {
    // Reuse the existing dialog + countdown from AdvancedFallDetectionService
    AdvancedFallDetectionService.triggerFallDialogFromNative();
  }
}
