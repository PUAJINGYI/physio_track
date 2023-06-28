import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:physio_track/reusable_widget/reusable_widget.dart';
import 'package:physio_track/user_management/screen/navigation_page.dart';

import '../authentication/signin_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Positioned(
            top: 25,
            right: 0,
            child: IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                size: 35.0,
              ),
              onPressed: () {
                // Perform your desired action here
                // For example, show notifications
              },
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
                'Home',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Positioned(
            top: 50,
            right: -10,
            child: Image.asset(
              'assets/images/admin-home.png',
              width: 211.0,
              height: 169.0,
            ),
          ),
          Positioned(
            top: 125,
            left: 25,
            child: Text('Welcome, Admin',
                style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold)),
          ),
          Positioned(
            top: 160,
            left: 40,
            child: Text('Start your administration task',
                style: TextStyle(fontSize: 13.0)),
          ),
        Column(
          children: [
            SizedBox(
              height: 250,
            ),
            customClickableCard('Appointment Management', AssetImage('assets/images/appointment.png'), () => {
              print('press'),
              //action
            }),
            SizedBox(
              height: 10,
            ),
            customClickableCard('Screening Test', AssetImage('assets/images/screening-test.png'), () => {
              print('press'),
              //action
            }),
            SizedBox(
              height: 10,
            ),
            customClickableCard('User Management', AssetImage('assets/images/account-manage.png'), () => {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UserManagementPage())),
            }),
          ],
        )
      ],
    ));
  }
}
