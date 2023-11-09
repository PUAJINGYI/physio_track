import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:physio_track/notification/screen/notification_details_screen.dart';
import 'package:physio_track/notification/service/notification_service.dart';
import 'package:physio_track/translations/locale_keys.g.dart';

import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../model/notification_model.dart';
import '../widget/shimmering_message_widget.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  NotificationService notificationService = NotificationService();
  late Future<List<Notifications>> notificationList;
  final dateFormat = DateFormat('dd/MM/yyyy');
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    notificationList = loadUserNotification();
  }

  Future<List<Notifications>> loadUserNotification() async {
    return await notificationService.fetchNotificationList(uid);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 240,
                ),
                Expanded(
                  child: RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: () async {
                      setState(() {
                        notificationList = loadUserNotification();
                      });
                    },
                    child: FutureBuilder<List<Notifications>>(
                      future: notificationList,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        if (snapshot.hasData && snapshot.data!.isEmpty) {
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
                          // Handle the case where you have notifications to display
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final notification = snapshot.data![index];
                              final isRead = notification.isRead;
                              final titleColor =
                                  isRead ? Colors.grey : Colors.black;
    
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                child: Card(
                                  color: Color.fromRGBO(241, 243, 250, 1),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ListTile(
                                          title:
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
                                                    color: titleColor,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                          subtitle: Text(
                                            dateFormat.format(notification.date),
                                            style: TextStyle(color: titleColor),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 10, 0),
                                        child: Container(
                                          width: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                          ),
                                          child: IconButton(
                                            icon: Icon(Icons.arrow_forward),
                                            color: Colors.blue,
                                            onPressed: () async {
                                              final needUpdate =
                                                  await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      NotificationDetailsScreen(
                                                          notificationId:
                                                              notification.id),
                                                ),
                                              );
                                              if (needUpdate != null &&
                                                  needUpdate) {
                                                _refreshIndicatorKey.currentState
                                                    ?.show();
                                                loadUserNotification();
                                              }
                                              await notificationService
                                                  .updateNotificationStatus(
                                                      uid, notification.id);
                                              _refreshIndicatorKey.currentState
                                                  ?.show();
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                ),
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
                width: 271.0,
                height: 190.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
