// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// import 'noti.dart';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// class HomePage extends StatefulWidget {
  
//   final Noti noti;
//   const HomePage({required this.noti});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   @override
//   void initState() {
//     super.initState();
//     Noti.initialize(flutterLocalNotificationsPlugin);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//           gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [Color(0xFF3ac3cb), Color(0xFFf85187)])),
//       child: Scaffold(
//           backgroundColor: Colors.transparent,
//           appBar: AppBar(
//             backgroundColor: Colors.blue.withOpacity(0.5),
//           ),
//           body: Center(
//             child: Container(
//               decoration: BoxDecoration(
//                   color: Colors.white, borderRadius: BorderRadius.circular(20)),
//               width: 200,
//               height: 80,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Noti.showBigTextNotification(
//                       title: "New message title",
//                       body: "Your long body",
//                       routeName: '/details',
//                       fln: flutterLocalNotificationsPlugin);
//                 },
//                 child: Text("click"),
//               ),
//             ),
//           )),
//     );
//   }
// }
