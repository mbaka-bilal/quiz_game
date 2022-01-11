import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  Future<void> init() async {
    /* initialize the notification settings
    */

    final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // initialize notifications for android

    final AndroidInitializationSettings _initializationSettingsAndroid =
        AndroidInitializationSettings("letter_w");

    final InitializationSettings _initializationSettings =
        InitializationSettings(android: _initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(_initializationSettings);

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails("reminder", "reminder");

    const NotificationDetails platformChannelsSpecifics =
        NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
        1,
        "We are waiting",
        "More world class Questions are yet to be solved!!",
        platformChannelsSpecifics);
  }
}
