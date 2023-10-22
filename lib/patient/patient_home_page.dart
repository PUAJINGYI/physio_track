import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:physio_track/achievement/screen/progress_screen.dart';
import 'package:physio_track/journal/screen/view_journal_list_screen.dart';
import 'package:physio_track/patient/patient_home_screen.dart';

import '../appointment/screen/appointment_patient_screeen.dart';
import '../ot_library/service/user_ot_list_service.dart';
import '../profile/screen/profile_screen.dart';
import '../pt_library/service/user_pt_list_service.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({Key? key}) : super(key: key);

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage>
    with TickerProviderStateMixin {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  PageController? _pageController;
  int _currentIndex = 0;
  UserPTListService userPTListService = UserPTListService();
  UserOTListService userOTListService = UserOTListService();

  List<Widget> _page = [
    PatientHomeScreen(),
    ProgressScreen(),
    ViewJournalListScreen(),
    AppointmentPatientScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    //updateUserOTPTList();
    _pageController = PageController(initialPage: 0, keepPage: true);
  }

  Future<void> updateUserOTPTList() async {
    DocumentReference userRef = usersCollection.doc(userId);
    await userPTListService.suggestPTActivityList(userRef, userId);
    await userOTListService.suggestOTActivityList(userRef, userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        currentIndex: _currentIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: _navBarItems(),
        onTap: (value) {
          setState(() {
            _currentIndex = value;
            _pageController?.jumpToPage(value);
          });
        },
      ),
      body: FutureBuilder(
        future: updateUserOTPTList(), // Call your method here.
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // You can return a loading indicator or a placeholder widget here.
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
            return Text('Error: ${snapshot.error}');
          } else {
            // Once the future is completed, you can build your PageView.
            return PageView(
              controller: _pageController,
              children: _page,
              onPageChanged: (int page) {
                setState(() {
                  _currentIndex = page;
                });
              },
            );
          }
        },
      ),
    );
  }

  List<BottomNavigationBarItem> _navBarItems() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        label: "Home",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.pie_chart_outline),
        label: 'Progress',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.book_outlined),
        label: 'Journal',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month_outlined),
        label: 'Appointment',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings_outlined),
        label: 'Settings',
      ),
    ];
  }
}
