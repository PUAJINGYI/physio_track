import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:physio_track/profile/screen/change_language_screen.dart';

import 'package:physio_track/reusable_widget/reusable_widget.dart';

import '../../authentication/change_password_screen.dart';
import '../../authentication/service/auth_manager.dart';
import '../../authentication/signin_screen.dart';
import '../../constant/ColorConstant.dart';
import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../../notification/screen/notification_list_screen.dart';
import '../../notification/service/notification_service.dart';
import '../../translations/locale_keys.g.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  late Map<String, dynamic> userData = {};
  String? profileImageUrl;
  AuthManager _authManager = AuthManager();
  NotificationService notificationService = NotificationService();
  bool hasUnreadNotifications = false;

  @override
  void initState() {
    super.initState();
    checkUnreadNotifications();
    getUserData();
  }

  Future<void> checkUnreadNotifications() async {
    final notifications = await notificationService.fetchNotificationList(uid);
    final unreadNotifications =
        notifications.where((notification) => !notification.isRead).toList();
    setState(() {
      hasUnreadNotifications = unreadNotifications.isNotEmpty;
    });
  }

  Future<void> getUserData() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    DocumentSnapshot userSnapshot = await userRef.get();

    Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>;
    if (userData == null) {
      print("empty");
    } else {
      setState(() {
        this.userData = userData;
        profileImageUrl =
            userData['profileImageUrl']; // Assign the profile image URL
      });
    }
  }

  void signOut() {
    FirebaseAuth.instance.signOut().then((value) {
      GoogleSignIn().signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signed out")),
      );
      print("Signed out");
      _authManager.logout();
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return SignInScreen();
          },
        ),
        (_) => false,
      );
    });
  }

  void showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
    Function onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          titlePadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 18)),
              IconButton(
                icon: Icon(Icons.close, color: ColorConstant.RED_BUTTON_TEXT),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              message,
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: ColorConstant.BLUE_BUTTON_UNPRESSED,
                    ),
                    child: Text(LocaleKeys.Yes.tr(),
                        style:
                            TextStyle(color: ColorConstant.BLUE_BUTTON_TEXT)),
                    onPressed: () async {
                      onConfirm();
                      //Navigator.pop(context);
                    },
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: ColorConstant.RED_BUTTON_UNPRESSED,
                    ),
                    child: Text(LocaleKeys.No.tr(),
                        style: TextStyle(color: ColorConstant.RED_BUTTON_TEXT)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToEditProfileScreen(BuildContext context) async {
    final needUpdate = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(),
      ),
    );

    if (needUpdate != null && needUpdate) {
      setState(() {
        getUserData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userData.isEmpty) {
      return Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 25,
              right: 0,
              child: IconButton(
                icon: Stack(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      size: 35.0,
                    ),
                    if (hasUnreadNotifications)
                      Positioned(
                        right: 5,
                        top: 5,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () async {
                  final needUpdate = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationListScreen(),
                    ),
                  );
                  if (needUpdate != null && needUpdate) {
                    setState(() {
                      getUserData();
                      checkUnreadNotifications();
                    });
                  }
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
                  LocaleKeys.Profile.tr(),
                  style: TextStyle(
                    fontSize: TextConstant.TITLE_FONT_SIZE,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 70),
                Expanded(
                    child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: 1,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.only(top: 20, left: 20),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 75,
                                          backgroundImage: profileImageUrl ==
                                                      null ||
                                                  profileImageUrl == ''
                                              ? AssetImage(
                                                  ImageConstant.DEFAULT_USER)
                                              : NetworkImage(profileImageUrl!)
                                                  as ImageProvider<Object>?,
                                          backgroundColor: Colors.grey,
                                        ),
                                        SizedBox(width: 10),
                                        // Expanded(
                                        //   child: Padding(
                                        //     padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                        //     child: AutoSizeText(
                                        //       userData['username'] != ''
                                        //           ? userData['username']
                                        //           : 'N/A',
                                        //       style: TextStyle(
                                        //         fontSize: 20,
                                        //         fontWeight: FontWeight.bold,
                                        //       ),
                                        //       minFontSize: 12,
                                        //       maxFontSize: 20,
                                        //       maxLines: 1,
                                        //       overflow: TextOverflow.ellipsis,
                                        //     ),
                                        //   ),
                                        // ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 0, 10, 0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                AutoSizeText(
                                                  userData['username'],
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  minFontSize: 12,
                                                  maxFontSize: 20,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                if (userData['role'] ==
                                                    'patient')
                                                  // AutoSizeText(
                                                  //   'Level: ${userData['level']}',
                                                  //   style: TextStyle(
                                                  //     fontSize:
                                                  //         16, // Adjust the font size as needed
                                                  //   ),
                                                  //   maxLines: 1,
                                                  //   overflow: TextOverflow.ellipsis,
                                                  // ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        '${LocaleKeys.Level.tr()} ${userData['level']}',
                                                        style: TextStyle(
                                                          fontSize: 13.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(height: 2.0),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                0, 0, 20, 0),
                                                        child:
                                                            LinearPercentIndicator(
                                                          animation: true,
                                                          lineHeight: 10.0,
                                                          animationDuration:
                                                              2000,
                                                          percent: userData[
                                                                      'progressToNextLevel']
                                                                  .toDouble() ??
                                                              0.0,
                                                          barRadius:
                                                              Radius.circular(
                                                                  10.0),
                                                          progressColor:
                                                              Colors.yellow,
                                                          padding:
                                                              EdgeInsets.zero,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              infoCard(
                                  Icons.phone_outlined,
                                  userData['phone'] != ''
                                      ? userData['phone']
                                      : 'N/A'),
                              SizedBox(height: 10),
                              infoCard(
                                  Icons.email_outlined,
                                  userData['email'] != ''
                                      ? userData['email']
                                      : 'N/A'),
                              SizedBox(height: 10),
                              infoCard(
                                  Icons.pin_drop_outlined,
                                  userData['address'] != ''
                                      ? userData['address']
                                      : 'N/A'),
                              SizedBox(height: 5),
                              changePassword(),
                              SizedBox(height: 20),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                child: customButton(
                                    context,
                                    LocaleKeys.Edit_Profile.tr(),
                                    ColorConstant.YELLOW_BUTTON_TEXT,
                                    ColorConstant.YELLOW_BUTTON_UNPRESSED,
                                    ColorConstant.YELLOW_BUTTON_PRESSED, () {
                                  _navigateToEditProfileScreen(context);
                                }),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                child: customButton(
                                    context,
                                    LocaleKeys.Change_Language.tr(),
                                    ColorConstant.BLUE_BUTTON_TEXT,
                                    ColorConstant.BLUE_BUTTON_UNPRESSED,
                                    ColorConstant.BLUE_BUTTON_PRESSED,
                                    () async {
                                  final needUpdate = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChangeLanguageScreen(),
                                    ),
                                  );
                                  if (needUpdate != null && needUpdate) {
                                    setState(() {
                                      getUserData();
                                    });
                                  }
                                }),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                child: customButton(
                                    context,
                                    LocaleKeys.Log_Out.tr(),
                                    ColorConstant.RED_BUTTON_TEXT,
                                    ColorConstant.RED_BUTTON_UNPRESSED,
                                    ColorConstant.RED_BUTTON_PRESSED, () {
                                  showConfirmationDialog(
                                      context,
                                      LocaleKeys.Log_Out.tr(),
                                      LocaleKeys.Are_you_sure_to_sign_out.tr(),
                                      () {
                                    signOut();
                                  });
                                }),
                              )
                            ],
                          );
                        }))
              ],
            ),
            Positioned(
              top: 25,
              right: 0,
              child: IconButton(
                icon: Stack(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      size: 35.0,
                    ),
                    if (hasUnreadNotifications)
                      Positioned(
                        right: 5,
                        top: 5,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () async {
                  final needUpdate = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationListScreen(),
                    ),
                  );

                  if (needUpdate != null && needUpdate) {
                    setState(() {
                      getUserData();
                      checkUnreadNotifications();
                    });
                  }
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
                  LocaleKeys.Profile.tr(),
                  style: TextStyle(
                    fontSize: TextConstant.TITLE_FONT_SIZE,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Padding changePassword() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(35, 0, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () async {
              final needUpdate = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChangePasswordScreen()));
              if (needUpdate != null && needUpdate) {
                setState(() {
                  getUserData();
                });
              }
            },
            child: Text(
              LocaleKeys.Change_Password.tr(),
              style: TextStyle(
                color: Colors.black,
              ),
              textAlign: TextAlign.end,
            ),
          )
        ],
      ),
    );
  }
}
