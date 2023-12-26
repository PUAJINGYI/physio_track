// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';

// import 'package:app_settings/app_settings.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:physio_track/notification/notification_message_screen.dart';

// import '../screening_test/service/question_service.dart';

// class NotificationServices {
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   void requestNotificationPermission() async {
//     NotificationSettings settings = await messaging.requestPermission(
//         alert: true,
//         announcement: true,
//         badge: true,
//         carPlay: true,
//         criticalAlert: true,
//         provisional: true,
//         sound: true);

//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('user granted permission');
//     } else if (settings.authorizationStatus ==
//         AuthorizationStatus.provisional) {
//       print('user granted provisional permission');
//     } else {
//       AppSettings.openNotificationSettings();
//       print('user denied permission');
//     }
//   }

//   void initLocalNotifications(
//       BuildContext context, RemoteMessage message) async {
//     var androidInitializationSettings =
//         const AndroidInitializationSettings('app_icon');
//     var initializationSetting =
//         InitializationSettings(android: androidInitializationSettings);

//     // await _flutterLocalNotificationsPlugin.initialize(initializationSetting,
//     //     onDidReceiveNotificationResponse: (payload) {
//     //   handleMessage(context, message);
//     // });
//   }

//   void firebaseInit(BuildContext context) {
//     FirebaseMessaging.onMessage.listen((message) {
//       RemoteNotification? notification = message.notification;
//       AndroidNotification? android = message.notification!.android;

//       if (kDebugMode) {
//         print("notifications title:${notification!.title}");
//         print("notifications body:${notification.body}");
//         print('count:${android!.count}');
//         print('data:${message.data.toString()}');
//       }

//       if (Platform.isAndroid) {
//         initLocalNotifications(context, message);
//         showNotification(message);
//       }
//     });
//   }

//   Future<void> showNotification(RemoteMessage message) async {
//     AndroidNotificationChannel channel = AndroidNotificationChannel(
//       message.notification!.android!.channelId.toString(),
//       message.notification!.android!.channelId.toString(),
//       description: message.notification!.android!.channelId.toString(),
//       importance: Importance.max,
//       showBadge: true,
//     );

//     AndroidNotificationDetails androidNotificationDetails =
//         AndroidNotificationDetails(
//       channel.id.toString(),
//       channel.name.toString(),
//       channelDescription: 'channel description',
//       importance: Importance.max,
//       icon: "app_icon",
//       priority: Priority.high,
//       ticker: 'ticker',
//       enableVibration: true,
//       //visibility: NotificationVisibility.public,
//     );

//     // const DarwinNotificationDetails darwinNotificationDetails =
//     //     DarwinNotificationDetails(
//     //         presentAlert: true, presentBadge: true, presentSound: true);

//     NotificationDetails notificationDetails =
//         NotificationDetails(android: androidNotificationDetails);
//     print(message.notification!.title.toString());
//     if (message.notification!.title.toString() == 'bgtask' &&
//         message.data['type'] == 'bg') {
//       // await _performBackgroundTask();
//     }

//     Future.delayed(Duration.zero, () {
//       _flutterLocalNotificationsPlugin.show(
//         0,
//         message.notification!.title.toString(),
//         message.notification!.body.toString(),
//         notificationDetails,
//       );
//     });
//   }

//   // Future<void> _performBackgroundTask() async {
//   //   // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//   //   //     FlutterLocalNotificationsPlugin();
//   //   // final NotificationServices notificationServices = NotificationServices();
//   //   WidgetsFlutterBinding.ensureInitialized();
//   //   await Firebase.initializeApp();
//   //   print('_performBackgroundTask');

//   //   // empty list be get!!!
//   //   QuestionService questionService = QuestionService();
//   //   QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
//   //       .collection('users')
//   //       .where('role', isEqualTo: 'patient')
//   //       .where('isTakenTest', isEqualTo: true)
//   //       .get();

//   //   for (QueryDocumentSnapshot userDoc in usersSnapshot.docs) {
//   //     String userId = userDoc.id;
//   //     print("useerid: ${userId}");
//   //     DocumentReference userRef =
//   //         FirebaseFirestore.instance.collection('users').doc(userId);

//   //     QuerySnapshot otLibrariesSnapshot = await userRef
//   //         .collection('ot_activities')
//   //         .orderBy('date', descending: true)
//   //         .limit(1)
//   //         .get();
//   //     print("below is otLibrariesSnapshot");
//   //     print(otLibrariesSnapshot);
//   //     if (otLibrariesSnapshot.docs.isNotEmpty) {
//   //       // today date + 1 day
//   //       DateTime currentDate = DateTime.now();
//   //       DateTime currentDateWithoutTime =
//   //           DateTime(currentDate.year, currentDate.month, currentDate.day);
//   //       DateTime todayPlusOneDay =
//   //           currentDateWithoutTime.add(Duration(days: 1));
//   //       print(todayPlusOneDay.toString());
//   //       // latest library date
//   //       DocumentSnapshot latestLibrarySnapshot = otLibrariesSnapshot.docs[0];
//   //       Timestamp latestLibraryTimestamp = latestLibrarySnapshot.get('date');
//   //       DateTime latestLibraryDate = DateTime(
//   //         latestLibraryTimestamp.toDate().year,
//   //         latestLibraryTimestamp.toDate().month,
//   //         latestLibraryTimestamp.toDate().day,
//   //       );
//   //       print(latestLibraryDate.toString());
//   //       if (todayPlusOneDay.isAfter(latestLibraryDate)) {
//   //         print('same day');
//   //         questionService.updateTestStatus(userId);
//   //         print('finish update test status');
//   //         // notificationServices.showTaskNotification(
//   //         //     title: "Occupational Therapy Activities",
//   //         //     body: 'New Weekly activity list be refreshed !',
//   //         //     fln: flutterLocalNotificationsPlugin);
//   //       }
//   //       print('not same day');
//   //     } else {
//   //       questionService.updateTestStatus(userId);
//   //       // notificationServices.showTaskNotification(
//   //       //     title: "Occupational Therapy Activities",
//   //       //     body: 'New Weekly activity list be refreshed !',
//   //       //     fln: flutterLocalNotificationsPlugin);
//   //     }
//   //     print("otLibrariesSnapshot is empty");
//   //   }
//   //   // notificationServices.showTaskNotification(
//   //   //     title: "Testing Background Auto Triggger Task",
//   //   //     body: 'Testing 1234',
//   //   //     fln: flutterLocalNotificationsPlugin);
//   // }

//   Future<void> showTaskNotification(
//       {int id = 0,
//       required String title,
//       required String body,
//       required FlutterLocalNotificationsPlugin fln}) async {
//     AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       '1',
//       'background task',
//       channelDescription: 'channel description',
//       playSound: true,
//       importance: Importance.max,
//       priority: Priority.high,
//       icon: "app_icon",
//     );

//     var not = NotificationDetails(android: androidPlatformChannelSpecifics);
//     await fln.show(id, title, body, not);
//   }

//   Future<String> getDeviceToken() async {
//     String? token = await messaging.getToken();
//     return token!;
//   }

//   void isTokenRefresh() async {
//     messaging.onTokenRefresh.listen((event) {
//       event.toString();
//       if (kDebugMode) {
//         print('refresh');
//       }
//     });
//   }

//   Future<void> setupInteractMessage(BuildContext context) async {
//     // when app is terminated
//     RemoteMessage? initialMessage =
//         await FirebaseMessaging.instance.getInitialMessage();

//     if (initialMessage != null) {
//       print('initial message = null');
//       handleMessage(context, initialMessage);
//       print('enter handle 1');
//     }

//     //when app ins background
//     FirebaseMessaging.onMessageOpenedApp.listen((event) {
//       handleMessage(context, event);
//       print('enter handle 2');
//     });
//   }

//   void handleMessage(BuildContext context, RemoteMessage message) {
//     print('enter handle message');
//     try {
//       if (message.data['type'] == 'msg' && context != null) {
//         print('Handling message in the foreground or when app is active');

//         // Navigator.push(
//         //   context,
//         //   MaterialPageRoute(
//         //     builder: (context) => MessageScreen(
//         //       id: message.data['id'],
//         //     ),
//         //   ),        );
//       } else {
//         print('Handling message when app is in the background or terminated');
//         // Handle the notification differently or store it for later processing.
//         // For example, you can use a global variable or a state management solution.
//       }

//       if (message.data['type'] == 'bg') {
//         //  _performBackgroundTask();
//       }
//     } catch (e, stackTrace) {
//       print('Exception: $e');
//       print('Stack Trace: $stackTrace');
//     }
//   }

//   Future forgroundMessage() async {
//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//   }
// }
