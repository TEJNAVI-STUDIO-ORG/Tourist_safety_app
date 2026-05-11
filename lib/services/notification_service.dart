import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Local notification IDs must be unique so alerts do not overwrite each other.
class NotificationService {
  static final FlutterLocalNotificationsPlugin
      flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _alertChannel =
      AndroidNotificationChannel(
    'guardian_channel',
    'Guardian Alerts',
    description: 'Zone alerts, fall detection, and safety messages',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  static const AndroidNotificationChannel trackingChannel =
      AndroidNotificationChannel(
    'guardian_tracking',
    'Guardian Tracking',
    description: 'Background safety tracking',
    importance: Importance.low,

  
  );

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(settings);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_alertChannel);

    await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(trackingChannel);
  }

  /// Shows a heads-up notification in the system shade.
  /// [notificationId] defaults from time so consecutive alerts all appear.
  static Future<void> showNotification({
    required String title,
    required String body,
    int? notificationId,
  }) async {
    final int id = notificationId ??
        (DateTime.now().millisecondsSinceEpoch % 2147483647);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'guardian_channel',
      'Guardian Alerts',
      channelDescription:
          'Zone alerts, fall detection, and safety messages',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      details,
    );
  }
}