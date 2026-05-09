import 'package:flutter/services.dart';

class SmsService {

  static const platform =
      MethodChannel('sms_channel');

  static Future<void> sendSOS({

    required List<String> recipients,

    required String message,

  }) async {

    try {

      await platform.invokeMethod(
        'sendSMS',

        {
          'numbers': recipients,
          'message': message,
        },
      );

    } catch (e) {

      print("SMS Error: $e");
    }
  }
}