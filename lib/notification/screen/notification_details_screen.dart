import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/intl.dart';
import 'package:physio_track/constant/ColorConstant.dart';
import 'package:physio_track/reusable_widget/reusable_widget.dart';

import '../../constant/ImageConstant.dart';
import '../model/notification_model.dart';
import '../service/notification_service.dart';

class NotificationDetailsScreen extends StatefulWidget {
  final int notificationId;
  const NotificationDetailsScreen({super.key, required this.notificationId});

  @override
  State<NotificationDetailsScreen> createState() =>
      _NotificationDetailsScreenState();
}

class _NotificationDetailsScreenState extends State<NotificationDetailsScreen> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  NotificationService notificationService = NotificationService();
  late Future<Notifications?> notification;
  final dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    notification = loadNotificationDetails();
  }

  Future<Notifications?> loadNotificationDetails() async {
    return await notificationService.fetchNotificationById(
        uid, widget.notificationId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Positioned(
          top: 25,
          left: 0,
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: 35.0,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        Positioned(
          top: 25,
          left: 0,
          right: 0,
          child: Container(
            height: kToolbarHeight,
            alignment: Alignment.center,
            child: Text(
              'Notification',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Positioned(
          top: 70,
          right: 0,
          left: 0,
          child: Image.asset(
            ImageConstant.NOTIFICATION,
            width: 271.0,
            height: 190.0,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 260,
            ),
            Expanded(
                child: FutureBuilder<Notifications?>(
                    future: notification,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (snapshot.hasData && snapshot.data == null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 100.0,
                                height: 100.0,
                                child:
                                    Image.asset(ImageConstant.DATA_NOT_FOUND),
                              ),
                              Text('No Record Found',
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      } else {
                        final notification = snapshot.data!;
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: Card(
                            color: Color.fromRGBO(241, 243, 250, 1),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        notification.title,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Text(
                                          dateFormat.format(notification.date)),
                                      SizedBox(
                                        height: 100.0,
                                      ),
                                      Text(
                                        notification.message,
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(fontSize: 15.0),
                                      ),
                                    ],
                                  ),
                                )),
                               
                              ],
                            ),
                          ),
                        );
                      }
                      return Container();
                    })),
                     Padding(
                       padding: const EdgeInsets.all(8.0),
                       child: customButton(
                                      context,
                                      'Back',
                                      ColorConstant.BLUE_BUTTON_TEXT,
                                      ColorConstant.BLUE_BUTTON_UNPRESSED,
                                      ColorConstant.BLUE_BUTTON_PRESSED, () {
                                    Navigator.pop(context);
                                  }),
                     )
          ],
        )
      ],
    ));
  }
}
