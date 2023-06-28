import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:physio_track/screening_test/screen/test_start_screen.dart';

import '../admin/admin_home_page.dart';
import '../patient/patient_home_page.dart';
import '../physio/physio_home_page.dart';

class RedirectScreen extends StatefulWidget {
  const RedirectScreen({super.key});

  @override
  _RedirectScreenState createState() => _RedirectScreenState();
}

class _RedirectScreenState extends State<RedirectScreen> {
  @override
  void initState() {
    super.initState();
    checkUserRoleAndRedirect();
  }

  void checkUserRoleAndRedirect() async {
    // Get the current user's ID
    String? uid = FirebaseAuth.instance.currentUser!.uid;

    // Retrieve the user document from Firestore
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userSnapshot.exists) {
      // User document exists
      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

      if (userData != null) {
        // Retrieve the role from the user data
        String? role = userData['role'];
        bool? isTakenTest = userData['isTakenTest'];
        if (role != null) {
          // Redirect based on user role
          if (role == 'patient') {
            // Redirect to patient home page
            if (isTakenTest == false) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => TestStartScreen()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PatientHomePage()),
              );
            }
          } else if (role == 'admin') {
            // Redirect to admin home page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminHomePage()),
            );
          } else if (role == 'physio') {
            // Redirect to admin home page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => PhysioHomePage()),
            );
          } else {
            // Handle null role value
            print("Handle null role value");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Handle null role value")),
            );
          }
        } else {
          // Handle null user data
          print("Handle null user data");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Handle null user data")),
          );
        }
      } else {
        // User document does not exist, handle as needed
        print("User document does not exist, handle as needed");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("User document does not exist, handle as needed")),
        );
      }
    } else {
      print("User does not exist");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}