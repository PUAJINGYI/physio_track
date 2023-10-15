import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:physio_track/screening_test/screen/test_part_1_screen.dart';
import 'package:physio_track/screening_test/screen/test_physiotherapist_request_screen.dart';

import '../../constant/ColorConstant.dart';
import '../../constant/ImageConstant.dart';
import '../../reusable_widget/reusable_widget.dart';

class TestStartScreen extends StatefulWidget {
  const TestStartScreen({super.key});

  @override
  State<TestStartScreen> createState() => _TestStartScreenState();
}

class _TestStartScreenState extends State<TestStartScreen> {
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
                image: AssetImage(ImageConstant.TEST_START),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 250, 0, 0),
              child: Icon(Icons.error,
                  size: 80, color: Color.fromARGB(255, 43, 222, 253)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(90, 10, 90, 10),
              child: Text(
                'The user is needed to complete the screening test to continue action',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, height: 1.2, fontWeight: FontWeight.bold),
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
                      'Start Quiz',
                      ColorConstant.BLUE_BUTTON_TEXT,
                      ColorConstant.BLUE_BUTTON_UNPRESSED,
                      ColorConstant.BLUE_BUTTON_PRESSED, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TestPhysiotherapistRequestScreen(),
                      ),
                    );
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
