import 'package:flutter/material.dart';
import 'package:physio_track/achievement/screen/progress_screen.dart';
import 'package:physio_track/journal/screen/view_journal_list_screen.dart';
import 'package:physio_track/patient/patient_home_screen.dart';

import '../appointment/screen/appointment_patient_screeen.dart';
import '../profile/screen/profile_screen.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({Key? key}) : super(key: key);

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage>
    with TickerProviderStateMixin {
  PageController? _pageController;
  int _currentIndex = 0;

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
    _pageController = PageController(initialPage: 0, keepPage: true);
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
      body: PageView(
        controller: _pageController,
        children: _page,
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
