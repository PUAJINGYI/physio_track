// import 'package:flutter/material.dart';

// class PhysioNavBar extends StatelessWidget {
//   final int currentIndex;
//   final ValueChanged<int> onTabChanged;

//   const PhysioNavBar({
//     required this.currentIndex,
//     required this.onTabChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: currentIndex,
//       onTap: onTabChanged,
//       selectedItemColor: Colors.blue,
//       unselectedItemColor: Colors.grey,
//       showSelectedLabels: false,
//       showUnselectedLabels: false,
//       type: BottomNavigationBarType.fixed,
//       iconSize: 25,
//       items: [
//         BottomNavigationBarItem(
//           icon: Icon(Icons.home_outlined),
//           label: 'Home',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.calendar_month_outlined),
//           label: 'Appointment',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.healing_outlined),
//           label: 'Screening Test',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.settings_outlined),
//           label: 'Settings',
//         ),
//       ],
//     );
//   }
// }