import 'package:flutter/material.dart';

class AdminNavBar extends StatelessWidget {
  final List<Widget> pages;
  final int currentIndex;
  final ValueChanged<int> onTabChanged;


  AdminNavBar({required this.pages, required this.currentIndex, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTabChanged,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      iconSize: 25,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
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
          icon: Icon(Icons.account_circle_outlined),
          label: 'Manage Account',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: 'Settings',
        ),
      ],
    );
  }
}