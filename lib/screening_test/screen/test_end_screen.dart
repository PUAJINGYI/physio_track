import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:physio_track/constant/ImageConstant.dart';
import 'package:physio_track/patient/patient_home_page.dart';
import 'package:physio_track/screening_test/service/question_service.dart';

import '../../constant/ColorConstant.dart';
import '../../reusable_widget/reusable_widget.dart';
import '../../translations/locale_keys.g.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder(
            future: finishTest(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // The future has completed, navigate to PatientHomePage
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientHomePage(),
                    ),
                  );
                });
              }

              return Stack(children: [
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
                        LocaleKeys.Thank_you_for_completing_screening_test.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 25,
                            height: 1.2,
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                    SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                      child: Text(
                        LocaleKeys.Your_response_will_sent_evaluation.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, height: 1.2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(50, 0, 50, 10),
                      child: Text(
                        LocaleKeys.It_may_take_some_minutes.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, height: 1.2),
                      ),
                    ),
                    SizedBox(height: 10),
                    Center(child: CircularProgressIndicator()),
                  ],
                ),
              ]);
            }));
  }
}
