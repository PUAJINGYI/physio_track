// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: "Main Navigator");

// late String routeToGo = '/';
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// String? payload;
// String? initialRoute;

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print("_firebaseMessagingBackgroundHandler Clicked!");
//   routeToGo = '/second';
//   print(message.notification!.body);
//   flutterLocalNotificationsPlugin.show(
//     message.notification.hashCode,
//     message.notification?.title,
//     message.notification?.body,
//     NotificationDetails(
//       android: AndroidNotificationDetails(
//         channel.id,
//         channel.name,
//       ),
//     ),
//   );
// }

// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//   'high_importance_channel',
//   'High Importance Notifications',
//   importance: Importance.high,
// );

// Future<void> selectNotification(String? payload) async {
//   if (payload != null) {
//     debugPrint('notification payload: $payload');
//     initialRoute = '/second';
//     navigatorKey.currentState?.pushNamed('/second');
//   }
// }

// Future<void> main2() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();

//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);

//   var initialzationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
//   var initializationSettings = InitializationSettings(android: initialzationSettingsAndroid);
//   flutterLocalNotificationsPlugin.initialize(initializationSettings);

//   final NotificationAppLaunchDetails? notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
//   payload = notificationAppLaunchDetails!.payload;

//   if (payload != null) {
//     routeToGo = '/second';
//   }

//   await flutterLocalNotificationsPlugin.initialize(
//     initializationSettings,
//     onDidReceiveNotificationResponse: selectNotification,
//   );

//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
//     print(message.notification!.body != null);
//     if (message.notification!.body != null) {
//       navigatorKey.currentState?.pushNamed('/second');
//     }
//   });

//   runApp(MyApp(initialRoute: routeToGo));
// }

// class MyApp extends StatefulWidget {
//   const MyApp({Key? key, required this.initialRoute}) : super(key: key);

//   final String? initialRoute;

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   late String token;

//   getToken() async {
//     token = (await FirebaseMessaging.instance.getToken())!;
//     print(token);
//   }

//   @override
//   void initState() {
//     super.initState();
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print("onMessage Clicked!");
//       print(message.notification!.body);
//       RemoteNotification? notification = message.notification;
//       AndroidNotification? android = message.notification?.android;
//       if (notification != null && android != null) {
//         flutterLocalNotificationsPlugin.show(
//           notification.hashCode,
//           notification.title,
//           notification.body,
//           NotificationDetails(
//             android: AndroidNotificationDetails(
//               channel.id,
//               channel.name,
//               icon: android.smallIcon,
//             ),
//           ),
//         );
//       }
//     });
//     getToken();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       navigatorKey: navigatorKey,
//       theme: ThemeData(primaryColor: Colors.blue),
//       initialRoute: widget.initialRoute ?? '/',
//       onGenerateRoute: (RouteSettings settings) {
//         switch (settings.name) {
//           case '/':
//             return MaterialPageRoute(
//               builder: (_) => const MyHomePage(title: 'Home Page'),
//             );
//           case '/second':
//             return MaterialPageRoute(
//               builder: (_) => const SecondPage(),
//             );
//           default:
//             return _errorRoute();
//         }
//       },
//     );
//   }

//   static Route<dynamic> _errorRoute() {
//     return MaterialPageRoute(
//       builder: (_) {
//         return Scaffold(
//           body: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Stack(
//                   children: [
//                     Align(
//                       child: Container(
//                         width: 150,
//                         height: 150,
//                         child: Icon(
//                           Icons.delete_forever,
//                           size: 48,
//                         ),
//                       ),
//                       alignment: Alignment.center,
//                     ),
//                     Align(
//                       alignment: Alignment.center,
//                       child: SizedBox(
//                         width: 150,
//                         height: 150,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 4,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 20,),
//                 Text('Page Not Found'),
//                 SizedBox(height: 10,),
//                 Text(
//                   'Press back button on your phone',
//                   style: TextStyle(color: Color(0xff39399d), fontSize: 28),
//                 ),
//                 SizedBox(height: 20,),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop();
//                     return;
//                   },
//                   style: ButtonStyle(
//                     backgroundColor: MaterialStateProperty.all(Colors.orange),
//                   ),
//                   child: const Text('Back to home'),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class SecondPage extends StatelessWidget {
//   const SecondPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Second Page'),
//       ),
//       body: Center(
//         child: Text("Second page"),
//       ),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               CustomPaint(
//                 child: Container(
//                   width: 400,
//                   height: 410,
//                   color: Colors.black,
//                 ),
//                 foregroundPainter: LinePainter(),
//               )
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

// class LinePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     print(size);
//     var paint = Paint()
//       ..color = Colors.teal
//       ..strokeWidth = 1;
//     var str = 'm      ';
//     var path = Path();
//     path.moveTo(0, 57.804239);
//     path.lineTo(51.121936, 5.963);
//     path.lineTo(0.612, 0.103);
//     path.lineTo(1.137, 5.741);
//     path.lineTo(0.517, 0.184);
//     path.lineTo(2.214, 0.437);
//     path.lineTo(5.067, 8.586);
//     path.lineTo(-0.727, 3.214);
//     path.lineTo(-0.311, 0.82);
//     path.lineTo(-8.509, 0);
//     path.close();
//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }
