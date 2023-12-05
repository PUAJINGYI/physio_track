import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/intl.dart';
import 'package:physio_track/constant/ColorConstant.dart';
import 'package:physio_track/reusable_widget/reusable_widget.dart';

import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../../translations/locale_keys.g.dart';
import '../model/notification_model.dart';
import '../service/notification_service.dart';
import '../widget/shimmering_message_widget.dart';
import '../widget/shimmering_text_list_widget.dart';

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
                        return Center(
                            child: Text(
                                '${LocaleKeys.Error.tr()}: ${snapshot.error}'));
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
                              Text(LocaleKeys.No_Record_Found.tr(),
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
                                      FutureBuilder(
                                        future:
                                            notificationService.translateText(
                                                notification.title, context),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<String> snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return ShimmeringMessageWidget(); // or any loading indicator
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          } else {
                                            String title = snapshot.data!;
                                            return Text(
                                              title,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18.0),
                                              textAlign: TextAlign.center,
                                            );
                                          }
                                        },
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Text(
                                          dateFormat.format(notification.date)),
                                      SizedBox(
                                        height: 50.0,
                                      ),
                                      FutureBuilder(
                                        future:
                                            notificationService.translateText(
                                                notification.message, context),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<String> snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return ShimmeringTextListWidget(
                                                width: 300,
                                                numOfLines:
                                                    4); // or any loading indicator
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          } else {
                                            String title = snapshot.data!;
                                            return Text(
                                              title,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15.0),
                                              textAlign: TextAlign.justify,
                                            );
                                          }
                                        },
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
              padding: const EdgeInsets.fromLTRB(
                  TextConstant.CUSTOM_BUTTON_SIDE_PADDING,
                  TextConstant.CUSTOM_BUTTON_TB_PADDING,
                  TextConstant.CUSTOM_BUTTON_SIDE_PADDING,
                  TextConstant.CUSTOM_BUTTON_TB_PADDING),
              child: customButton(
                  context,
                  LocaleKeys.Back.tr(),
                  ColorConstant.BLUE_BUTTON_TEXT,
                  ColorConstant.BLUE_BUTTON_UNPRESSED,
                  ColorConstant.BLUE_BUTTON_PRESSED, () {
                Navigator.pop(context, true);
              }),
            ),
            SizedBox(
              height: 45.0,)
          ],
        ),
        Positioned(
          top: 25,
          left: 0,
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: 35.0,
            ),
            onPressed: () {
              Navigator.pop(context, true);
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
              LocaleKeys.Notifications.tr(),
              style: TextStyle(
                fontSize: TextConstant.TITLE_FONT_SIZE,
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
            width: 190.0,
            height: 170.0,
          ),
        ),
      ],
    ));
  }
}
