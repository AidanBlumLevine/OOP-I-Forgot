import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Notifications {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  Notifications(this.flutterLocalNotificationsPlugin);

  Future<void> initNotifications() async {
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: (String payload) async {
      if (payload != null) {
        print('notification payload: ' + payload);
      }
    });
  }

  Future<void> notify(int id, String title, String body, String payload, tz.TZDateTime at) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        at,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'channel id',
            'course work channel',
            '^^^^^^^^^^^^^^^^^',
            importance: Importance.max,
            priority: Priority.max,
            // showWhen: false,
          ),
        ),
        payload: payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> notifyScheduled(int id, String title, String body, String payload, DateTime time, int day) async {
    DateTime now = DateTime.now();
    DateTime nextMatchingDayOfWeekAndTime = DateTime(now.year + 1, now.month, now.day, time.hour, time.minute);
    while (nextMatchingDayOfWeekAndTime.weekday != day) {
      nextMatchingDayOfWeekAndTime = nextMatchingDayOfWeekAndTime.add(const Duration(days: 1));
    }
    await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(nextMatchingDayOfWeekAndTime, tz.getLocation('US/Eastern')),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'channel id',
            'course work channel',
            '^^^^^^^^^^^^^^^^^',
            importance: Importance.max,
            priority: Priority.max,
            // showWhen: false,
          ),
        ),
        payload: payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
  }
}
