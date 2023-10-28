import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:physio_track/appointment/screen/admin/appointment_admin_nav_page.dart';
import 'package:physio_track/reusable_widget/reusable_widget.dart';
import 'package:physio_track/screening_test/screen/admin/question_list_nav_page.dart';
import 'package:physio_track/user_management/screen/navigation_page.dart';

import '../authentication/signin_screen.dart';
import '../constant/ImageConstant.dart';
import '../constant/TextConstant.dart';
import '../user_management/service/user_management_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  UserManagementService userManagementService = UserManagementService();
  String uid = FirebaseAuth.instance.currentUser!.uid;
  String username = "";

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchAdminUsername() async {
    username = await userManagementService.getUsernameByUid(uid, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: FutureBuilder<void>(
                future: fetchAdminUsername(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Return a loading indicator or placeholder while data is loading.
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    // Handle the error.
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return Stack(
                      children: [
                        Column(
                          children: [
                            Expanded(
                                child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: 1,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Column(
                                        children: [
                                          SizedBox(
                                            height: 210,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 8, 20, 8),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Appointment Managment',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 0, 20, 0),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        AppointmentAdminNavPage(),
                                                  ),
                                                );
                                              },
                                              child: Card(
                                                color: Colors.blue.shade100,
                                                elevation: 5.0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                  child: Container(
                                                    height:
                                                        150.0, // Adjust the height as needed
                                                    width: double.infinity,
                                                    child: Image.asset(
                                                      ImageConstant.APPOINTMENT,
                                                      // fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 8, 20, 8),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Screening Test',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 0, 20, 0),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        QuestionListNavPage(),
                                                  ),
                                                );
                                              },
                                              child: Card(
                                                color: Colors.blue.shade100,
                                                elevation: 5.0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                  child: Container(
                                                    height:
                                                        150.0, // Adjust the height as needed
                                                    width: double.infinity,
                                                    child: Image.asset(
                                                      ImageConstant
                                                          .SCREENING_TEST_ADMIN,
                                                      // fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 8, 20, 8),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'User Management',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 0, 20, 0),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        UserManagementPage(),
                                                  ),
                                                );
                                              },
                                              child: Card(
                                                color: Colors.blue.shade100,
                                                elevation: 5.0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                  child: Container(
                                                    height:
                                                        150.0, // Adjust the height as needed
                                                    width: double.infinity,
                                                    child: Image.asset(
                                                      ImageConstant
                                                          .ACCOUNT_MANAGE,
                                                      // fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      );
                                    })),
                          ],
                        ),
                        Positioned(
                          top: 25,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: kToolbarHeight,
                            alignment: Alignment.center,
                            child: Text(
                              'Home',
                              style: TextStyle(
                                fontSize: TextConstant.TITLE_FONT_SIZE,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 50,
                          right: -10,
                          child: Image.asset(
                            ImageConstant.ADMIN_HOME,
                            width: 211.0,
                            height: 169.0,
                          ),
                        ),
                        Positioned(
                          top: 125,
                          left: 25,
                          child: Container(
                            width: 200,
                            child: AutoSizeText(
                              'Welcome, ${username}',
                              style: TextStyle(
                                  fontSize: 25.0, fontWeight: FontWeight.bold),
                              maxLines: 1,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 160,
                          left: 40,
                          child: Text('Start your administration task',
                              style: TextStyle(fontSize: 13.0)),
                        ),
                      ],
                    );
                  }
                })));
  }
}
