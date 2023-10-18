import 'package:flutter/material.dart';

import '../../../constant/ImageConstant.dart';
import '../../service/appointment_service.dart';
import 'appointment_cancel_approve_screen.dart';
import 'appointment_new_approve_screen.dart';
import 'appointment_updated_approve_screen.dart';

class AppointmentAdminNavPage extends StatefulWidget {
  const AppointmentAdminNavPage({super.key});

  @override
  State<AppointmentAdminNavPage> createState() =>
      _AppointmentAdminNavPageState();
}

class _AppointmentAdminNavPageState extends State<AppointmentAdminNavPage> {
  AppointmentService appointmentService = AppointmentService();
  void initState() {
    super.initState();
    _checkAndUpdateEvents();
    setState(() {});
  }

  Future<void> _checkAndUpdateEvents() async {
    await appointmentService.checkAndAddAppointmentFromGCalendar();
  }

  int _selectedIndex = 0;

  static List<Widget> _pages = [
    AppointmentNewApproveScreen(),
    AppointmentUpdatedApproveScreen(),
    AppointmentCancelApproveScreen(),
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
                        child: TestNavigationBarItem(
                          label: 'New',
                          isSelected: _selectedIndex == 0,
                          onTap: () => _onItemTapped(0),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: TestNavigationBarItem(
                          label: 'Update',
                          isSelected: _selectedIndex == 1,
                          onTap: () => _onItemTapped(1),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: TestNavigationBarItem(
                          label: 'Cancel',
                          isSelected: _selectedIndex == 2,
                          onTap: () => _onItemTapped(2),
                        ),
                      ),
                    ],
                  ),
                ), // Adds spacing between text and underline
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                'Appointment Management',
                style: TextStyle(
                  fontSize: 20.0,
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
              ImageConstant.APPOINTMENT,
              width: 271.0,
              height: 170.0,
            ),
          ),
        ],
      ),
    );
  }
}

class TestNavigationBarItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const TestNavigationBarItem({
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
