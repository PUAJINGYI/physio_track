import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

import '../../constant/ColorConstant.dart';
import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../../patient/patient_home_page.dart';
import '../../reusable_widget/reusable_widget.dart';
import '../../translations/locale_keys.g.dart';

class PTDailyFinishedScreen extends StatefulWidget {
  @override
  _PTDailyFinishedScreenState createState() => _PTDailyFinishedScreenState();
}

class _PTDailyFinishedScreenState extends State<PTDailyFinishedScreen> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 10));
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Add the ConfettiWidget here
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _controller,
              emissionFrequency: 0.01,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              gravity: 0.2,
              numberOfParticles: 30,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(ImageConstant.BALLOON),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 220, 0, 0),
                child: Text(
                  LocaleKeys.Congratulations.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    height: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(90, 10, 90, 10),
                child: Text(
                  LocaleKeys.You_completed_physiotherapy_actiivities_today.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.2,
                  ),
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
                  20,
                  MediaQuery.of(context).size.height * 0.39,
                  20,
                  0,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 360,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
              bottom: TextConstant.CUSTOM_BUTTON_BOTTOM,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    TextConstant.CUSTOM_BUTTON_SIDE_PADDING,
                    TextConstant.CUSTOM_BUTTON_TB_PADDING,
                    TextConstant.CUSTOM_BUTTON_SIDE_PADDING,
                    TextConstant.CUSTOM_BUTTON_TB_PADDING),
                child: customButton(
                    context,
                    LocaleKeys.Done.tr(),
                    ColorConstant.BLUE_BUTTON_TEXT,
                    ColorConstant.BLUE_BUTTON_UNPRESSED,
                    ColorConstant.BLUE_BUTTON_PRESSED, () {
                  Navigator.pop(context, true);
                  Navigator.pop(context, true);
                }),
              )),
        ],
      ),
    );
  }
}
