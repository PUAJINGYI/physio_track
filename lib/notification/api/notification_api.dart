import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:physio_track/notification/home_screen.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

import '../../constant/ImageConstant.dart';

class NotificationApi {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();
  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();

  @pragma('vm:entry-point')
  static void notificationTapBackground(
      NotificationResponse notificationResponse) {
    // ignore: avoid_print
    print('notification(${notificationResponse.id}) action tapped: '
        '${notificationResponse.actionId} with'
        ' payload: ${notificationResponse.payload}');
    if (notificationResponse.input?.isNotEmpty ?? false) {
      // ignore: avoid_print
      print(
          'notification action tapped with input: ${notificationResponse.input}');
    }
  }

  static Future init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final settings = InitializationSettings(android: androidSettings);

    // when app is closed
    final details = await _notifications.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      final payload = details.notificationResponse!.payload;
      onNotifications.add(payload);
    }

    // await _notifications.initialize(
    //   settings,
    //   //     onMessageOpenedApp: (payload) async {
    //   //   onNotifications.add(payload);
    //   // }
    //   onDidReceiveNotificationResponse:
    //       (NotificationResponse notificationResponse) {
    //     switch (notificationResponse.notificationResponseType) {
    //       case NotificationResponseType.selectedNotification:
    //         selectNotificationStream.add(notificationResponse.payload);
    //         break;
    //       case NotificationResponseType.selectedNotificationAction:
    //         if (notificationResponse.actionId == navigationActionId) {
    //           selectNotificationStream.add(notificationResponse.payload);
    //         }
    //         break;
    //     }
    //   },
    //   onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    // );

    _notifications.initialize(settings).then((_) async {
      final details = await _notifications.getNotificationAppLaunchDetails();
      if (details != null && details.didNotificationLaunchApp) {
        onNotifications.add(details.notificationResponse!.payload);
      }
    });
  }

  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async =>
      _notifications.show(
        id,
        title,
        body,
        await _notificationDetails(),
        payload: payload,
      );

  static void showScheduledNotification({
    required int id,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduledDate,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      await _notificationDetails(),
      payload: payload,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    print("Sceduled Notification set at $scheduledDate");
  }

  static Future _notificationDetails() async {
    // final styleInformation = BigPictureStyleInformation(
    //     FilePathAndroidBitmap(
    //         "assets/images/logo.png"),
    //     largeIcon: FilePathAndroidBitmap(
    //         "assets/images/logo.png"),
    //     contentTitle: "title",
    //     summaryText: "summaryText");

    return NotificationDetails(
        android: AndroidNotificationDetails("channelId", "channelName",
            channelDescription: "channelDescription",
            importance: Importance.max,
            priority: Priority.high,
            icon: "app_icon",
            styleInformation: DefaultStyleInformation(true, true)));
  }

  static tz.TZDateTime _scheduleDaily(DateTime time) {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day,
        time.hour, time.minute, time.second);
    print('trigger time: $scheduledDate');
    final nextDay = scheduledDate.add(const Duration(days: 1));
    print('next day: $nextDay');
    return scheduledDate.isBefore(now)
        ? scheduledDate.add(const Duration(days: 1))
        : scheduledDate;
  }

  static tz.TZDateTime _scheduleEvery5Seconds() {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = now.add(const Duration(seconds: 5));
    print('Trigger time: $scheduledDate');
    return scheduledDate;
  }

  static void periodicallyPushNoti({
    required int id,
    String? title,
    String? body,
    String? payload,
    required RepeatInterval interval,
  }) async {
    await _notifications.periodicallyShow(
      id,
      title,
      body,
      interval,
      await _notificationDetails(),
      payload: payload,
      androidAllowWhileIdle: true,
    );
    print('periodic notification scheduled');
  }

  // static Future<void> _showScheduledNotification(
  //   int id,
  //   String? title,
  //   String? body,
  //   String? payload,
  // ) async {
  //   await _notifications.zonedSchedule(
  //     id,
  //     title,
  //     body,
  //     _scheduleEvery5Seconds(),
  //     await _notificationDetails(),
  //     payload: payload,
  //     androidAllowWhileIdle: true,
  //     uiLocalNotificationDateInterpretation:
  //         UILocalNotificationDateInterpretation.absoluteTime,
  //     matchDateTimeComponents: DateTimeComponents.time,
  //   );
  // }

  static void cancelNoti({required id}) async {
    await _notifications.cancel(id);
  }
}
