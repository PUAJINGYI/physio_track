import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:physio_track/constant/ImageConstant.dart';
import 'package:physio_track/patient/patient_home_page.dart';
import 'package:physio_track/screening_test/service/question_service.dart';

import '../../constant/ColorConstant.dart';
import '../../reusable_widget/reusable_widget.dart';

class TestFinishScreen extends StatefulWidget {
  const TestFinishScreen({super.key});

  @override
  State<TestFinishScreen> createState() => _TestFinishScreenState();
}

class _TestFinishScreenState extends State<TestFinishScreen> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  QuestionService questionService = QuestionService();

  Future<void> finishTest() async {
    await questionService.updateTestStatus(uid);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PatientHomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(ImageConstant.TEST_FINISH),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 260, 20, 10),
              child: Text(
                'Thank you for completing the screening test !',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 25, height: 1.2, fontWeight: FontWeight.w900),
              ),
            ),
            SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
              child: Text(
                'Your response will be sent for evaluation.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.2),
              ),
            ),
          ],
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).size.height * 0.39, 20, 0),
              child: Column(
                children: [
                  SizedBox(
                    height: 400,
                  ),
                  customButton(
                      context,
                      'Go Homepage',
                      ColorConstant.BLUE_BUTTON_TEXT,
                      ColorConstant.BLUE_BUTTON_UNPRESSED,
                      ColorConstant.BLUE_BUTTON_PRESSED, () {
                    finishTest();
                  })
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
