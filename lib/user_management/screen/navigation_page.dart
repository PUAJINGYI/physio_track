import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:physio_track/user_management/screen/patient_list_screen.dart';
import 'package:physio_track/user_management/screen/physio_list_screen.dart';
import 'package:physio_track/user_management/service/user_management_service.dart';

import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../../profile/model/user_model.dart';

class UserManagementPage extends StatefulWidget {
  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  void initState() {
    super.initState();
    setState(() {});
  }

  int _selectedIndex = 0;

  static List<Widget> _pages = [
    PatientListScreen(),
    PhysioListScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 250),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: NavigationBarItem(
                          label: 'Patients',
                          isSelected: _selectedIndex == 0,
                          onTap: () => _onItemTapped(0),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: NavigationBarItem(
                          label: 'Physiotherapists',
                          isSelected: _selectedIndex == 1,
                          onTap: () => _onItemTapped(1),
                        ),
                      ),
                    ],
                  ),
                ), // Adds spacing between text and underline
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: _pages,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 25,
            left: 0,
            right: 0,
            child: Container(
              height: kToolbarHeight,
              alignment: Alignment.center,
              child: Text(
                'User Management',
                style: TextStyle(
                  fontSize: TextConstant.TITLE_FONT_SIZE,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 80,
            right: 0,
            left: 0,
            child: Image.asset(
              ImageConstant.ACCOUNT_MANAGE,
              width: 271.0,
              height: 170.0,
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationBarItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const NavigationBarItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? Colors.blue : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          SizedBox(height: 4), // Adds spacing between text and underline
          Container(
            height: 2,
            width: isSelected ? 150 : 0,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}
