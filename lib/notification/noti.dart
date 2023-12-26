// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class Noti {
//   static Future initialize(
//       FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
//     var androidInitialize =
//         new AndroidInitializationSettings('mipmap/ic_launcher');
//     var initializationsSettings = new InitializationSettings(
//       android: androidInitialize,
//     );
//     await flutterLocalNotificationsPlugin.initialize(initializationsSettings);
//   }

//   static Future showBigTextNotification(
//       {var id = 0,
//       required String title,
//       required String body,
//       required String routeName,
//       var payload,
//       required FlutterLocalNotificationsPlugin fln}) async {
//     AndroidNotificationDetails androidPlatformChannelSpecifics =
//         new AndroidNotificationDetails(
//       'you_can_name_it_whatever1',
//       'channel_name',
//       channelDescription:'channel_description',
//       playSound: true,
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     var not = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//     );
//     await fln.show(0, title, body, not);
//   }

//     // Handle notification taps
//   // Add a method to handle notification tap and navigate to the corresponding page.
//   static void handleNotificationTap(BuildContext context, Map<String, dynamic> payload) {
//     String? routeName = payload['routeName'];
//     if (routeName != null) {
//       Navigator.of(context).pushNamed(routeName);
//     }
//   }
// }
