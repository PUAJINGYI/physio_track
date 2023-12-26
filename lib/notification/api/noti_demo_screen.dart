// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter/src/widgets/placeholder.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:physio_track/notification/api/second_page.dart';
// import 'package:physio_track/notification/api/third_page.dart';

// import '../home_screen.dart';
// import 'notification_api.dart';

// class NotiDemoScreen extends StatefulWidget {
//   const NotiDemoScreen({super.key});

//   @override
//   State<NotiDemoScreen> createState() => _NotiDemoScreenState();
// }

// class _NotiDemoScreenState extends State<NotiDemoScreen> {
//   bool _notificationsEnabled = false;
//   final StreamController<ReceivedNotification>
//       didReceiveLocalNotificationStream =
//       StreamController<ReceivedNotification>.broadcast();

//   final StreamController<String?> selectNotificationStream =
//       StreamController<String?>.broadcast();

//   // static MethodChannel platform =
//   //     MethodChannel('dexterx.dev/flutter_local_notifications_example');

//   // static String portName = 'notification_send_port';
//   @override
//   void initState() {
//     super.initState();
//     _isAndroidPermissionGranted();
//     _requestPermissions();
//     // _configureDidReceiveLocalNotificationSubject();
//     //_configureSelectNotificationSubject();
//     NotificationApi.init();
//     listenNotifications();
//   }

//   @override
//   void dispose() {
//     didReceiveLocalNotificationStream.close();
//     selectNotificationStream.close();
//     super.dispose();
//   }

//   Future<void> _isAndroidPermissionGranted() async {
//     if (Platform.isAndroid) {
//       final bool granted = await flutterLocalNotificationsPlugin
//               .resolvePlatformSpecificImplementation<
//                   AndroidFlutterLocalNotificationsPlugin>()
//               ?.areNotificationsEnabled() ??
//           false;

//       setState(() {
//         _notificationsEnabled = granted;
//       });
//     }
//   }

//   Future<void> _requestPermissions() async {
//     if (Platform.isIOS || Platform.isMacOS) {
//       await flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//               IOSFlutterLocalNotificationsPlugin>()
//           ?.requestPermissions(
//             alert: true,
//             badge: true,
//             sound: true,
//           );
//       await flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//               MacOSFlutterLocalNotificationsPlugin>()
//           ?.requestPermissions(
//             alert: true,
//             badge: true,
//             sound: true,
//           );
//     } else if (Platform.isAndroid) {
//       final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
//           flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin>();

//       final bool? grantedNotificationPermission =
//           await androidImplementation?.requestNotificationsPermission();
//       setState(() {
//         _notificationsEnabled = grantedNotificationPermission ?? false;
//       });
//     }
//   }

//   // void _configureDidReceiveLocalNotificationSubject() {
//   //   didReceiveLocalNotificationStream.stream
//   //       .listen((ReceivedNotification receivedNotification) async {
//   //     await showDialog(
//   //       context: context,
//   //       builder: (BuildContext context) => CupertinoAlertDialog(
//   //         title: receivedNotification.title != null
//   //             ? Text(receivedNotification.title!)
//   //             : null,
//   //         content: receivedNotification.body != null
//   //             ? Text(receivedNotification.body!)
//   //             : null,
//   //         actions: <Widget>[
//   //           CupertinoDialogAction(
//   //             isDefaultAction: true,
//   //             onPressed: () async {
//   //               Navigator.of(context, rootNavigator: true).pop();
//   //               await Navigator.of(context).push(
//   //                 MaterialPageRoute<void>(
//   //                   builder: (BuildContext context) =>
//   //                       SecondPage(payload: receivedNotification.payload),
//   //                 ),
//   //               );
//   //             },
//   //             child: const Text('Ok'),
//   //           )
//   //         ],
//   //       ),
//   //     );
//   //   });
//   // }

//   // void _configureSelectNotificationSubject() {
//   //   selectNotificationStream.stream.listen((String? payload) async {
//   //     if (payload == null)
//   //       return;
//   //     else if (payload == 'pua.abs') {
//   //       await Navigator.push(
//   //         context,
//   //         MaterialPageRoute(
//   //           builder: (context) => SecondPage(payload: payload),
//   //         ),
//   //       );
//   //     } else if (payload == 'pua.abs2')
//   //       await Navigator.of(context).push(MaterialPageRoute<void>(
//   //         builder: (BuildContext context) => SecondPage(payload: payload),
//   //       ));
//   //   });
//   // }

//   void listenNotifications() =>
//       NotificationApi.onNotifications.stream.listen(onClickedNotification);

//   void onClickedNotification(String? payload) {
//     if (payload == 'pua.abs')
//       Navigator.of(context).push(MaterialPageRoute(
//           builder: (context) => SecondPage(payload: payload)));
//     else if (payload == 'pua.abs2') {
//       Navigator.of(context).push(
//           MaterialPageRoute(builder: (context) => ThirdPage(payload: payload)));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('Notification Demo'),
//         ),
//         body: Column(
//           children: [
//             TextButton(
//                 onPressed: () {
//                   NotificationApi.showNotification(
//                       title: "Normal Noti",
//                       body: "normal noti testing",
//                       payload: 'pua.abs');
//                 },
//                 child: Text("Simple Notification")),
//             TextButton(
//                 onPressed: () {
//                   NotificationApi.showScheduledNotification(
//                       id: 100,
//                       title: "Schedule Noti",
//                       body: "schedule noti testing",
//                       payload: 'pua.abs',
//                       scheduledDate: DateTime(2023, 12, 24, 4, 10, 0, 0, 0));

//                   final snackbar = SnackBar(
//                       content: Text(
//                         'Scheduled in 12 Seconds!',
//                         style: TextStyle(fontSize: 24),
//                       ),
//                       backgroundColor: Colors.green);
//                   ScaffoldMessenger.of(context)
//                     ..removeCurrentSnackBar()
//                     ..showSnackBar(snackbar);
//                 },
//                 child: Text("Scheduled Notificationm 410")),
//             TextButton(
//                 onPressed: () {
//                   NotificationApi.periodicallyPushNoti(
//                     id: 1,
//                     title: "Schedule Periodic Noti for every minute",
//                     body: "schedule noti every minute testing",
//                     payload: 'pua.abs',
//                     interval: RepeatInterval.everyMinute,
//                   );
//                 },
//                 child: Text("Every every minute Notification")),
//             TextButton(
//                 onPressed: () {
//                   NotificationApi.periodicallyPushNoti(
//                     id: 2,
//                     title: "Schedule Periodic Noti for every hour",
//                     body: "schedule noti every hour testing",
//                     payload: 'pua.abs2',
//                     interval: RepeatInterval.everyMinute,
//                   );
//                 },
//                 child: Text("Every hour Notification")),
//             TextButton(onPressed: () {}, child: Text("Remove Notification")),
//             TextButton(
//                 onPressed: () {
//                   NotificationApi.cancelNoti(id: 1);
//                 },
//                 child: Text("Cancel Notification Id 1")),
//             TextButton(
//                 onPressed: () {
//                   NotificationApi.cancelNoti(id: 2);
//                 },
//                 child: Text("Cancel Notification Id 2")),
//           ],
//         ));
//   }
// }

// class ReceivedNotification {
//   ReceivedNotification({
//     required this.id,
//     required this.title,
//     required this.body,
//     required this.payload,
//   });

//   final int id;
//   final String? title;
//   final String? body;
//   final String? payload;
// }
