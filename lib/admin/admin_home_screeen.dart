import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:physio_track/reusable_widget/reusable_widget.dart';
import 'package:physio_track/user_management/screen/navigation_page.dart';

import '../authentication/signin_screen.dart';
import '../constant/ImageConstant.dart';
import '../constant/TextConstant.dart';

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
        Column(
          children: [
            SizedBox(
              height: 250,
            ),
            customClickableCard(
                'Appointment Management',
                AssetImage(ImageConstant.APPOINTMENT),
                () => {
                      print('press'),
                      //action
                    }),
            SizedBox(
              height: 10,
            ),
            customClickableCard(
                'Screening Test',
                AssetImage(ImageConstant.SCREENING_TEST),
                () => {
                      print('press'),
                      //action
                    }),
            SizedBox(
              height: 10,
            ),
            customClickableCard(
                'User Management',
                AssetImage(ImageConstant.ACCOUNT_MANAGE),
                () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserManagementPage())),
                    }),
          ],
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
                fontSize: TextConstant.TITLE_FONT_SIZE,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Positioned(
          top: 50,
          right: -10,
          child: Image.asset(
            ImageConstant.ADMIN_HOME,
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
      ],
    ));
  }
}
