import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class SmsService {
  static const _channel = MethodChannel('sms_channel');

  // ─────────────────────────────────────────────────────────────────────────
  // SILENT SEND — no SMS app opens, messages are delivered automatically.
  // Requires SEND_SMS permission (already declared in AndroidManifest).
  // ─────────────────────────────────────────────────────────────────────────

  /// Send SOS to all [recipients] silently via native SmsManager.
  /// Falls back to opening the SMS app if the native channel fails
  /// (e.g. on iOS or a device without telephony).
  static Future<bool> sendSOS({
    required List<String> recipients,
    required String message,
  }) async {
    try {
      await _channel.invokeMethod<String>('sendSMS', {
        'numbers': recipients,
        'message': message,
      });
      return true;
    } on PlatformException {
      // Fallback: open SMS app so user can send manually
      await openSMS(phone: recipients.first, message: message);
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // OPEN SMS APP (fallback / single contact)
  // ─────────────────────────────────────────────────────────────────────────

  static Future<void> openSMS({
    required String phone,
    required String message,
  }) async {
    final uri = Uri(
      scheme: 'sms',
      path: phone,
      queryParameters: {'body': message},
    );
    await launchUrl(uri);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // OPEN CALL APP
  // ─────────────────────────────────────────────────────────────────────────

  static Future<void> makeCall(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    await launchUrl(uri);
  }
}