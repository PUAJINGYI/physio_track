import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:physio_track/physio/physio_navbar.dart';

import '../authentication/signin_screen.dart';
import '../reusable_widget/reusable_widget.dart';

class PhysioHomeScreen extends StatefulWidget {
  const PhysioHomeScreen({super.key});

  @override
  State<PhysioHomeScreen> createState() => _PhysioHomeScreenState();
}

class _PhysioHomeScreenState extends State<PhysioHomeScreen> {
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
            top: 70,
            right: 0,
            child: Image.asset(
              'assets/images/physio-home.png',
              width: 211.0,
              height: 169.0,
            ),
          ),
          Positioned(
            top: 125,
            left: 25,
            child: Text('Welcome, Physio',
                style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold)),
          ),
          Positioned(
            top: 160,
            left: 40,
            child: Text('Start tracking your patients',
                style: TextStyle(fontSize: 13.0)),
          ),
          Column(
            children: [
              SizedBox(
                height: 250,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Next Appointment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Card(
                    elevation: 2.0,
                    child: Container(
                      color: Colors.green[100],
                      height: 100,
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal:
                                20.0), // Adjust the vertical padding as needed
                        leading: Icon(Icons.schedule, size: 50.0),
                        title: Text('3.00 PM'),
                        subtitle: Text('23 MAY 2023'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person),
                            SizedBox(width: 8.0),
                            Text('Vivian Lee'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              customClickableCard(
                  'Appointment Schedule',
                  AssetImage('assets/images/appointment.png'),
                  () => {
                        print('press'),
                        //action
                      }),
              SizedBox(
                height: 10,
              ),
              customClickableCard(
                  'Patient List',
                  AssetImage('assets/images/patient-list.png'),
                  () => {
                        print('press'),
                        //action
                      }),
            ],
          )
        ],
      ),
    );
  }
}
