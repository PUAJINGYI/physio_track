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
  int _currentIndex = 0;
  List<Widget>? _page;
  List<BottomNavigationBarItem>? _navBarItems;
  BottomNavigationBar? bottomNavBar;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _updateTabs();
      print('hello $_currentIndex');
    });
  }

  _updateTabs() {
    _page = [
      PatientHomeScreen(uniqueKey: UniqueKey()),
      ProgressScreen(uniqueKey: UniqueKey()),
      const ViewJournalListScreen(),
      const AppointmentPatientScreen(),
      const ProfileScreen(),
    ];

    _navBarItems = const [
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

    bottomNavBar = BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.black,
      currentIndex: _currentIndex,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: _navBarItems!,
      onTap: _onItemTapped,
    );

  }

  @override
  void initState() {
    _updateTabs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomNavBar,
      body: _page![_currentIndex],
    );
  }
}
