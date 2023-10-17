import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:physio_track/achievement/screen/physio/patient_list_by_phiso_screen.dart';
import 'package:physio_track/appointment/screen/physio/appointment_schedule_screen.dart';
import 'package:physio_track/physio/physio_home_screen.dart';
import 'package:physio_track/physio/physio_navbar.dart';

import '../profile/screen/profile_screen.dart';

class PhysioHomePage extends StatefulWidget {
  const PhysioHomePage({Key? key}) : super(key: key);

  @override
  State<PhysioHomePage> createState() => _PhysioHomePageState();
}

class _PhysioHomePageState extends State<PhysioHomePage> with TickerProviderStateMixin{
  PageController? _pageController;
  int _currentIndex = 0;

  List<Widget> _page = [
    PhysioHomeScreen(),
    AppointmentScheduleScreen(),
    PatientListByPhysioScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, keepPage: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        currentIndex: _currentIndex,
        items: _navBarItems(),
        onTap: (value) {
          setState(() {
            _currentIndex = value;
            _pageController?.jumpToPage(value);
          });
        },
      ),
      body: PageView(
        controller: _pageController,
        children: _page,
      ),
    );
  }

  List<BottomNavigationBarItem> _navBarItems() {
    return [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month_outlined),
        label: 'Appointment',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.healing_outlined),
        label: 'Patients',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings_outlined),
        label: 'Settings',
      ),
    ];
  }
}
