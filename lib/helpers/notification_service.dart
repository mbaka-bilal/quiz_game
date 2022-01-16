import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    /* initialize the notification settings
    */

    // initialize notifications for android

    final AndroidInitializationSettings _initializationSettingsAndroid =
        AndroidInitializationSettings("notification_icon");

    final InitializationSettings _initializationSettings =
        InitializationSettings(android: _initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(_initializationSettings);

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails("reminder", "reminder");

    const NotificationDetails platformChannelsSpecifics =
        NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
        1,
        "Notification",
        "More world class Questions are yet to be solved!!",
        tz.TZDateTime.now(tz.UTC).add(const Duration(hours: 5)),
        platformChannelsSpecifics,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true);
  }

  Future<void> cancelAllNotifications() async {
    if (await _flutterLocalNotificationsPlugin.pendingNotificationRequests() !=
        null) {
      await _flutterLocalNotificationsPlugin.cancelAll();
    }
  }
}
