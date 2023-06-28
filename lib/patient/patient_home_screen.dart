import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:physio_track/patient/patient_navbar.dart';
import 'package:physio_track/physio/physio_home_screen.dart';
import 'package:physio_track/profile/screen/profile_screen.dart';
import '../admin/admin_home_screeen.dart';
import '../authentication/signin_screen.dart';
import '../reusable_widget/reusable_widget.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
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
            top: 100,
            left: 25,
            child: Text('Welcome, User',
                style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold)),
          ),
          Positioned(
            top: 135,
            left: 60,
            child: Text('Start your today\'s progress',
                style: TextStyle(fontSize: 17.0)),
          ),
          Column(
            children: [
              SizedBox(
                height: 200,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Exercises',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 14.0), // Adjust the padding as needed
                child: Row(
                  children: [
                    exerciseCard(
                        context,
                        'assets/images/progress-bar.png',
                        'assets/images/pt.png',
                        'PT',
                        '8.00 AM - 1.30 PM',
                        () {}),
                    SizedBox(width: 10.0), // Add spacing between cards
                    exerciseCard(
                        context,
                        'assets/images/progress-bar.png',
                        'assets/images/ot.png',
                        'OT',
                        '8.00 AM - 1.30 PM',
                        () {}),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 14.0), // Adjust the padding as needed
                child: Row(
                  children: [
                    customHalfSizeCard(context, 'assets/images/progress.png',
                        'Progress', Color.fromARGB(255, 255, 205, 210), () {}),
                    SizedBox(width: 10.0), // Add spacing between cards
                    customHalfSizeCard(
                        context,
                        'assets/images/journal-image.png',
                        'Journal',
                        Color.fromARGB(255, 200, 230, 201),
                        () {}),
                  ],
                ),
              ),
              SizedBox(height: 5.0),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 14.0), // Adjust the padding as needed
                child: Row(
                  children: [
                    customHalfSizeCard(
                        context,
                        'assets/images/schedule.png',
                        'Appointment',
                        Color.fromARGB(255, 255, 224, 178),
                        () {}),
                    SizedBox(width: 10.0), // Add spacing between cards
                    customHalfSizeCard(context, 'assets/images/user.png',
                        'User Profile', Color.fromARGB(255, 225, 190, 231), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfileScreen(), // Replace NextPage with your desired page
                        ),
                      );
                    }),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
