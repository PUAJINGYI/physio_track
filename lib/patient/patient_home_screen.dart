import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:physio_track/achievement/screen/progress_screen.dart';
import 'package:physio_track/appointment/screen/appointment_patient_screeen.dart';
import 'package:physio_track/journal/screen/view_journal_list_screen.dart';
import 'package:physio_track/physio/physio_home_screen.dart';
import 'package:physio_track/profile/screen/profile_screen.dart';
import 'package:physio_track/pt_library/screen/pt_daily_list_screen.dart';
import '../admin/admin_home_screeen.dart';
import '../authentication/signin_screen.dart';
import '../constant/ImageConstant.dart';
import '../constant/TextConstant.dart';
import '../ot_library/model/ot_activity_model.dart';
import '../ot_library/screen/ot_daily_list_screen.dart';
import '../ot_library/service/user_ot_list_service.dart';
import '../pt_library/model/pt_activity_model.dart';
import '../pt_library/service/user_pt_list_service.dart';
import '../reusable_widget/reusable_widget.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  late double ptProgress = 0.0;
  late double otProgress = 0.0;
  String uId = FirebaseAuth.instance.currentUser!.uid;
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  UserPTListService userPTListService = UserPTListService();
  UserOTListService userOTListService = UserOTListService();

  @override
  void initState() {
    super.initState();
    updateUserOTPTList();
    _fetchPTProgress();
    _fetchOTProgress();
  }

  Future<void> updateUserOTPTList() async {
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
    PTActivity ptActivity = ptSnapshot.docs
        .map((doc) => PTActivity.fromSnapshot(doc))
        .firstWhere((ptActivity) {
      Timestamp ptActivityTimestamp = ptActivity.date;
      DateTime ptActivityDate = ptActivityTimestamp.toDate();
      // Compare the dates
      return ptActivityDate.year == currentDateWithoutTime.year &&
          ptActivityDate.month == currentDateWithoutTime.month &&
          ptActivityDate.day == currentDateWithoutTime.day;
    });

    QuerySnapshot ptActivitiesSnapshot =
        await ptCollection.where('id', isEqualTo: ptActivity.id).get();

    if (ptActivitiesSnapshot.docs.isNotEmpty) {
      ptProgress = ptActivity.progress;
      setState(() {});
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
    OTActivity otActivity = otSnapshot.docs
        .map((doc) => OTActivity.fromSnapshot(doc))
        .firstWhere((otActivity) {
      Timestamp otActivityTimestamp = otActivity.date;
      DateTime otActivityDate = otActivityTimestamp.toDate();
      // Compare the dates
      return otActivityDate.year == currentDateWithoutTime.year &&
          otActivityDate.month == currentDateWithoutTime.month &&
          otActivityDate.day == currentDateWithoutTime.day;
    });

    QuerySnapshot otActivitiesSnapshot =
        await otCollection.where('id', isEqualTo: otActivity.id).get();

    if (otActivitiesSnapshot.docs.isNotEmpty) {
      otProgress = otActivity.progress;
      setState(() {});
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
                  Text('Fetching Data...'),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            // Handle errors if any.
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Return your main content when the data is ready.
            return Stack(
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: 200,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Exercises',
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
                          horizontal: 14.0), // Adjust the padding as needed
                      child: Row(
                        children: [
                          exerciseCard(context, ptProgress, ImageConstant.PT,
                              'PT', '8.00 AM - 1.30 PM', () async {
                            final needUpdate = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PTDailyListScreen(uid: uId),
                              ),
                            );

                            if (needUpdate != null && needUpdate) {
                              setState(() {
                                _fetchPTProgress();
                              });
                            }
                          }),
                          SizedBox(width: 10.0), // Add spacing between cards
                          exerciseCard(context, otProgress, ImageConstant.OT,
                              'OT', '8.00 AM - 1.30 PM', () async {
                            final needUpdate = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    OTDailyListScreen(uid: uId),
                              ),
                            );

                            if (needUpdate != null && needUpdate) {
                              setState(() {
                                _fetchOTProgress();
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
                          'Features',
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
                          horizontal: 14.0), // Adjust the padding as needed
                      child: Row(
                        children: [
                          customHalfSizeCard(
                              context,
                              ImageConstant.PROGRESS,
                              'Progress',
                              Color.fromARGB(255, 255, 205, 210), () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProgressScreen()),
                            );
                          }),
                          SizedBox(width: 10.0), // Add spacing between cards
                          customHalfSizeCard(
                              context,
                              ImageConstant.JOURNAL_IMAGE,
                              'Journal',
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
                          horizontal: 14.0), // Adjust the padding as needed
                      child: Row(
                        children: [
                          customHalfSizeCard(
                              context,
                              ImageConstant.SCHEDULE,
                              'Appointment',
                              Color.fromARGB(255, 255, 224, 178), () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AppointmentPatientScreen()),
                            );
                          }),
                          SizedBox(width: 10.0), // Add spacing between cards
                          customHalfSizeCard(
                              context,
                              ImageConstant.USER,
                              'User Profile',
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
                      'Home',
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
                  child: Text('Welcome, User',
                      style: TextStyle(
                          fontSize: 25.0, fontWeight: FontWeight.bold)),
                ),
                Positioned(
                  top: 135,
                  left: 60,
                  child: Text('Start your today\'s progress',
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
