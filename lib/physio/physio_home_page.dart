import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:physio_track/physio/physio_home_screen.dart';
import 'package:physio_track/physio/physio_navbar.dart';

import '../profile/screen/profile_screen.dart';

class PhysioHomePage extends StatefulWidget {
  const PhysioHomePage({Key? key}) : super(key: key);

  @override
  State<PhysioHomePage> createState() => _PhysioHomePageState();
}

class _PhysioHomePageState extends State<PhysioHomePage> {
  PersistentTabController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: [
          PhysioHomeScreen(),
          Placeholder(),
          Placeholder(),
          ProfileScreen(),
        ],
        items: _navBarItems(),
        confineInSafeArea: true,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        hideNavigationBarWhenKeyboardShows: true,
        decoration: NavBarDecoration(
          colorBehindNavBar: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        popAllScreensOnTapOfSelectedTab: true,
        navBarStyle: NavBarStyle.style12,
        onItemSelected: (int index) {
          setState(() {
            _controller?.index = index;
          });
        },
      ),
    );
  }

  List<PersistentBottomNavBarItem> _navBarItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home_outlined),
        title: 'Home',
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.calendar_month_outlined),
        title: 'Appointment',
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.healing_outlined),
        title: 'Screening Test',
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.settings_outlined),
        title: 'Settings',
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }
}