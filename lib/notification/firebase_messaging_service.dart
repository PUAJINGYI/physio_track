import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> configureFirebaseMessaging() async {
    // Initialize Firebase Messaging
    await _firebaseMessaging.requestPermission();
    
    // Configure Firebase Messaging
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle incoming FCM messages here
    });

    // Configure Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
   
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  // Function to display a local notification
  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
     AndroidNotificationChannel channel = AndroidNotificationChannel(
      'hello',
      'hello',
      importance: Importance.max,
      showBadge: true,
    );

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString(),
      channelDescription: 'channel description',
      importance: Importance.max,
      icon: "app_icon",
      priority: Priority.high,
      ticker: 'ticker',
      enableVibration: true,
      //visibility: NotificationVisibility.public,
    );
     NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title, // Title of your notification
      body, // Body of your notification
      platformChannelSpecifics,
    );
  }
}