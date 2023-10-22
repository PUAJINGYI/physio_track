import 'package:flutter/material.dart';
import 'package:physio_track/appointment/screen/admin/appointment_admin_nav_page.dart';
import 'package:physio_track/screening_test/screen/admin/question_list_nav_page.dart';

import '../profile/screen/profile_screen.dart';
import '../user_management/screen/navigation_page.dart';
import 'admin_activity_management_screen.dart';
import 'admin_home_screeen.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage>
    with TickerProviderStateMixin {
  PageController? _pageController;
  int _currentIndex = 0;

  List<Widget> _page = [
    AdminHomeScreen(),
    AppointmentAdminNavPage(),
    QuestionListNavPage(),
    UserManagementPage(),
    AdminActivityManagementScreen(),
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
        onPageChanged: (int page) {
          setState(() {
            _currentIndex = page;
          });
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
        icon: Icon(Icons.schedule_outlined),
        label: 'Appointment',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.rate_review_outlined),
        label: 'Screening Test',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        label: 'Manage Account',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.directions_run_outlined),
        label: 'Settings',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings_outlined),
        label: 'Settings',
      ),
    ];
  }
}
