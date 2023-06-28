import 'package:flutter/material.dart';
import 'package:physio_track/screening_test/screen/admin/question_list_nav_page.dart';

import '../profile/screen/profile_screen.dart';
import '../user_management/screen/navigation_page.dart';
import 'admin_home_screeen.dart';
import 'admin_navbar.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _currentIndex = 0;

  List<Widget> _pages = [
    AdminHomeScreen(),
    Placeholder(),
    QuestionListNavPage(),
    UserManagementPage(),
    ProfileScreen(),
  ];

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: AdminNavBar(
        pages: _pages,
        currentIndex: _currentIndex,
        onTabChanged: _onTabChanged,
      ),
    );
  }
}
