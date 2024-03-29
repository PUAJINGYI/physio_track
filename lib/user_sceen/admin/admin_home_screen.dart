import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:physio_track/appointment/screen/admin/appointment_admin_nav_page.dart';
import 'package:physio_track/screening_test/screen/admin/question_list_nav_page.dart';
import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../../translations/locale_keys.g.dart';
import '../../user_management/service/user_management_service.dart';
import 'admin_activity_management_screen.dart';

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
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return Stack(
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              height: 230,
                            ),
                            Expanded(
                                child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: 1,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 8, 20, 8),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                LocaleKeys
                                                        .Appointment_Management
                                                    .tr(),
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
                                                    height: 150.0,
                                                    width: double.infinity,
                                                    child: Image.asset(
                                                      ImageConstant.APPOINTMENT,
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
                                                LocaleKeys.Screening_Test.tr(),
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
                                                    height: 150.0,
                                                    width: double.infinity,
                                                    child: Image.asset(
                                                      ImageConstant
                                                          .SCREENING_TEST_ADMIN,
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
                                                LocaleKeys.Activity_Management
                                                    .tr(),
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
                                                        AdminActivityManagementScreen(),
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
                                                    height: 150.0,
                                                    width: double.infinity,
                                                    child: Image.asset(
                                                      ImageConstant.PHYSIO_HOME,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
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
                              LocaleKeys.Home.tr(),
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
                              '${LocaleKeys.welcome.tr()} ${username}',
                              style: TextStyle(
                                  fontSize: 25.0, fontWeight: FontWeight.bold),
                              maxLines: 1,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 160,
                          left: 40,
                          child: Text(LocaleKeys.Start_your_admin_task.tr(),
                              style: TextStyle(fontSize: 13.0)),
                        ),
                      ],
                    );
                  }
                })));
  }
}
