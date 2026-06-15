import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

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
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  static const AndroidNotificationChannel trackingChannel =
      AndroidNotificationChannel(
    'guardian_tracking',
    'Guardian Tracking',
    description: 'Background safety tracking heartbeat',
    importance: Importance.low,
    playSound: false,
    enableVibration: false,
    showBadge: false,
  );

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.actionId == 'safe_action' || response.actionId == 'leave_action') {
          FlutterBackgroundService().invoke('stop_emergency');
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_alertChannel);

    await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(trackingChannel);
  }

  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse response) {
    if (response.actionId == 'safe_action' || response.actionId == 'leave_action') {
      FlutterBackgroundService().invoke('stop_emergency');
    }
  }

  /// Shows a heads-up notification in the system shade.
  /// [notificationId] defaults from time so consecutive alerts all appear.
  static Future<void> showNotification({
    required String title,
    required String body,
    int? notificationId,
    List<AndroidNotificationAction>? actions,
    bool fullScreen = false,
  }) async {
    final int id = notificationId ??
        (DateTime.now().millisecondsSinceEpoch % 2147483647);

    // SOS Pattern: wait 0, vibrate 500, wait 200, vibrate 500, wait 200, vibrate 500, wait 200, vibrate 1000...
    final Int64List vibrationPattern = Int64List.fromList([0, 500, 200, 500, 200, 500, 200, 1000, 200, 1000, 200, 1000, 200, 500, 200, 500, 200, 500]);

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'guardian_channel',
      'Guardian Alerts',
      channelDescription:
          'Zone alerts, fall detection, and safety messages',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      enableVibration: true,
      vibrationPattern: vibrationPattern,
      playSound: true,
      actions: actions,
      fullScreenIntent: fullScreen,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
    );

    final NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      details,
    );
  }
}
