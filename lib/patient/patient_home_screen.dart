import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:physio_track/achievement/screen/progress_screen.dart';
import 'package:physio_track/appointment/screen/appointment_patient_screen.dart';
import 'package:physio_track/journal/screen/view_journal_list_screen.dart';
import 'package:physio_track/physio/physio_home_screen.dart';
import 'package:physio_track/profile/screen/profile_screen.dart';
import 'package:physio_track/pt_library/screen/pt_daily_list_screen.dart';
import '../admin/admin_home_screen.dart';
import '../authentication/signin_screen.dart';
import '../constant/ImageConstant.dart';
import '../constant/TextConstant.dart';
import '../ot_library/model/ot_activity_model.dart';
import '../ot_library/screen/ot_daily_list_screen.dart';
import '../ot_library/service/user_ot_list_service.dart';
import '../pt_library/model/pt_activity_model.dart';
import '../pt_library/service/user_pt_list_service.dart';
import '../reusable_widget/reusable_widget.dart';
import '../translations/locale_keys.g.dart';
import '../user_management/service/user_management_service.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key, required UniqueKey uniqueKey});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  late double ptProgress = 0.0;
  late double otProgress = 0.0;
  String uId = FirebaseAuth.instance.currentUser!.uid;
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  UserManagementService userManagementService = UserManagementService();
  UserPTListService userPTListService = UserPTListService();
  UserOTListService userOTListService = UserOTListService();
  String username = '';

  @override
  void initState() {
    super.initState();
    // updateUserOTPTList();
    // _fetchPTProgress();
    // _fetchOTProgress();
    updateProgress();
  }

  Future<void> updateProgress() async {
    await _fetchPTProgress();
    await _fetchOTProgress();
  }

  Future<void> updateUserOTPTList() async {
    username = await userManagementService.getUsernameByUid(uId, true);
    DocumentReference userRef = usersCollection.doc(uId);
    await userPTListService.suggestPTActivityList(userRef, uId);
    await userOTListService.suggestOTActivityList(userRef, uId);
  }

  Future<void> _fetchPTProgress() async {
    DateTime currentDate = DateTime.now();
    DateTime currentDateWithoutTime =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    final CollectionReference ptCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection('pt_activities');

    QuerySnapshot ptSnapshot = await ptCollection.get();
    PTActivity? ptActivity;
    try {
      ptActivity = ptSnapshot.docs
          .map((doc) => PTActivity.fromSnapshot(doc))
          .firstWhere((ptActivity) {
        Timestamp ptActivityTimestamp = ptActivity.date;
        DateTime ptActivityDate = ptActivityTimestamp.toDate();
        // Compare the dates
        return ptActivityDate.year == currentDateWithoutTime.year &&
            ptActivityDate.month == currentDateWithoutTime.month &&
            ptActivityDate.day == currentDateWithoutTime.day;
      });
    } catch (e) {
      print(e);
    }

    if (ptActivity != null) {
      QuerySnapshot ptActivitiesSnapshot =
          await ptCollection.where('id', isEqualTo: ptActivity.id).get();

      if (ptActivitiesSnapshot.docs.isNotEmpty) {
        ptProgress = ptActivity.progress;
        //setState(() {});
      }
    }
  }

  Future<void> _fetchOTProgress() async {
    DateTime currentDate = DateTime.now();
    DateTime currentDateWithoutTime =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    final CollectionReference otCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection('ot_activities');

    QuerySnapshot otSnapshot = await otCollection.get();
    OTActivity? otActivity;
    try {
      otActivity = otSnapshot.docs
          .map((doc) => OTActivity.fromSnapshot(doc))
          .firstWhere((otActivity) {
        Timestamp otActivityTimestamp = otActivity.date;
        DateTime otActivityDate = otActivityTimestamp.toDate();
        // Compare the dates
        return otActivityDate.year == currentDateWithoutTime.year &&
            otActivityDate.month == currentDateWithoutTime.month &&
            otActivityDate.day == currentDateWithoutTime.day;
      });
    } catch (e) {
      print(e);
    }
    if (otActivity != null) {
      QuerySnapshot otActivitiesSnapshot =
          await otCollection.where('id', isEqualTo: otActivity.id).get();

      if (otActivitiesSnapshot.docs.isNotEmpty) {
        otProgress = otActivity.progress;
        //setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: updateUserOTPTList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for data, you can return a loading indicator or any placeholder.
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16), // Adjust the spacing as needed
                  Text(LocaleKeys.Fetching_Data.tr()),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            // Handle errors if any.
            return Center(
                child: Text('${LocaleKeys.Error.tr()}: ${snapshot.error}'));
          } else {
            // Return your main content when the data is ready.
            return Stack(
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: 180,
                    ),
                    Expanded(
                      child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: 1,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      LocaleKeys.Exercises.tr(),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          14.0), // Adjust the padding as needed
                                  child: Row(
                                    children: [
                                      exerciseCard(
                                          context,
                                          ptProgress,
                                          ImageConstant.PT,
                                          LocaleKeys.PT.tr(), () async {
                                        final needUpdate = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PTDailyListScreen(uid: uId),
                                          ),
                                        );
                    
                                        if (needUpdate != null && needUpdate) {
                                          setState(() {
                                            updateProgress();
                                          });
                                        }
                                      }),
                                      SizedBox(
                                          width:
                                              10.0), // Add spacing between cards
                                      exerciseCard(
                                          context,
                                          otProgress,
                                          ImageConstant.OT,
                                          LocaleKeys.OT.tr(), () async {
                                        final needUpdate = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                OTDailyListScreen(uid: uId),
                                          ),
                                        );
                    
                                        if (needUpdate != null && needUpdate) {
                                          setState(() {
                                            updateProgress();
                                          });
                                        }
                                      }),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      LocaleKeys.Features.tr(),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          14.0), // Adjust the padding as needed
                                  child: Row(
                                    children: [
                                      customHalfSizeCard(
                                          context,
                                          ImageConstant.PROGRESS,
                                          LocaleKeys.Progress.tr(),
                                          Color.fromARGB(255, 255, 205, 210), () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProgressScreen(
                                                    uniqueKey: UniqueKey(),
                                                  )),
                                        );
                                      }),
                                      SizedBox(
                                          width:
                                              10.0), // Add spacing between cards
                                      customHalfSizeCard(
                                          context,
                                          ImageConstant.JOURNAL_IMAGE,
                                          LocaleKeys.Journal.tr(),
                                          Color.fromARGB(255, 200, 230, 201), () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ViewJournalListScreen()),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          14.0), // Adjust the padding as needed
                                  child: Row(
                                    children: [
                                      customHalfSizeCard(
                                          context,
                                          ImageConstant.SCHEDULE,
                                          LocaleKeys.Appointment.tr(),
                                          Color.fromARGB(255, 255, 224, 178), () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AppointmentPatientScreen()),
                                        );
                                      }),
                                      SizedBox(
                                          width:
                                              10.0), // Add spacing between cards
                                      customHalfSizeCard(
                                          context,
                                          ImageConstant.USER,
                                          LocaleKeys.User_Profile.tr(),
                                          Color.fromARGB(255, 225, 190, 231), () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProfileScreen(), // Replace NextPage with your desired page
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                    )
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
                  top: 100,
                  left: 25,
                  child: Text('${LocaleKeys.welcome.tr()} ${username}',
                      style: TextStyle(
                          fontSize: 25.0, fontWeight: FontWeight.bold)),
                ),
                Positioned(
                  top: 135,
                  left: 60,
                  child: Text(LocaleKeys.Start_today_progress.tr(),
                      style: TextStyle(fontSize: 17.0)),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
