import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'package:physio_track/reusable_widget/reusable_widget.dart';

import '../../authentication/change_password_screen.dart';
import '../../authentication/service/auth_manager.dart';
import '../../authentication/signin_screen.dart';
import '../../constant/ColorConstant.dart';
import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../../notification/screen/notification_list_screen.dart';
import '../../notification/service/notification_service.dart';
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationListScreen(),
                    ),
                  );
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
                  'Profile',
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
            ListView(
              // padding: EdgeInsets.all(16.0),
              children: [
                SizedBox(height: 50),
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
                            backgroundImage:
                                profileImageUrl == null || profileImageUrl == ''
                                    ? AssetImage(ImageConstant.DEFAULT_USER)
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
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (userData['role'] == 'patient')
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
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Level ${userData['level']}',
                                          style: TextStyle(
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 2.0),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                          child: LinearPercentIndicator(
                                            animation: true,
                                            lineHeight: 10.0,
                                            animationDuration: 2000,
                                            percent:
                                                userData['progressToNextLevel'],
                                            barRadius: Radius.circular(10.0),
                                            progressColor: Colors.yellow,
                                            padding: EdgeInsets.zero,
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
                infoCard(Icons.phone_outlined,
                    userData['phone'] != '' ? userData['phone'] : 'N/A'),
                SizedBox(height: 10),
                infoCard(Icons.email_outlined,
                    userData['email'] != '' ? userData['email'] : 'N/A'),
                SizedBox(height: 10),
                infoCard(Icons.pin_drop_outlined,
                    userData['address'] != '' ? userData['address'] : 'N/A'),
                SizedBox(height: 5),
                changePassword(),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: customButton(
                      context,
                      'Edit Profile',
                      ColorConstant.YELLOW_BUTTON_TEXT,
                      ColorConstant.YELLOW_BUTTON_UNPRESSED,
                      ColorConstant.YELLOW_BUTTON_PRESSED, () {
                    _navigateToEditProfileScreen(context);
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: customButton(
                      context,
                      'Change Language',
                      ColorConstant.BLUE_BUTTON_TEXT,
                      ColorConstant.BLUE_BUTTON_UNPRESSED,
                      ColorConstant.BLUE_BUTTON_PRESSED, () {
                    // navigate to change language page
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: customButton(
                      context,
                      'Log Out',
                      ColorConstant.RED_BUTTON_TEXT,
                      ColorConstant.RED_BUTTON_UNPRESSED,
                      ColorConstant.RED_BUTTON_PRESSED, () {
                    signOut();
                  }),
                ),
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationListScreen(),
                    ),
                  );
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
                  'Profile',
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
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChangePasswordScreen()));
            },
            child: const Text(
              "Change Password",
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
