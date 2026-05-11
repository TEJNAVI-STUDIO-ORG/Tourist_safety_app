import 'package:url_launcher/url_launcher.dart';

class LauncherService {

  // 📞 CALL
  static Future<void> makeCall(
    String phone,
  ) async {

    final Uri url =
        Uri.parse("tel:$phone");

    await launchUrl(url);
  }

  // 💬 SMS
  static Future<void> sendSms(
    String phone,
    String message,
  ) async {

    final Uri url = Uri.parse(
      "sms:$phone?body=$message",
    );

    await launchUrl(url);
  }
}