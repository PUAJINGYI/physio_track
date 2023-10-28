import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:physio_track/constant/ColorConstant.dart';
import 'package:physio_track/reusable_widget/reusable_widget.dart';

import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';

class ChangeLanguageScreen extends StatefulWidget {
  const ChangeLanguageScreen({super.key});

  @override
  State<ChangeLanguageScreen> createState() => _ChangeLanguageScreenState();
}

class _ChangeLanguageScreenState extends State<ChangeLanguageScreen> {
  int selectedLanguage = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 290,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Card(
                          elevation: 5,
                          child: Row(
                            children: [
                              Image.asset(
                                ImageConstant.GB,
                                width: 90.0,
                                height: 90.0,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                'English',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: Transform.scale(
                                  scale: 1.5,
                                  child: Radio<int>(
                                    value: 1,
                                    groupValue: selectedLanguage,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedLanguage = value!;
                                      });
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Card(
                          elevation: 5,
                          child: Row(
                            children: [
                              Image.asset(
                                ImageConstant.MALAYSIA,
                                width: 90.0,
                                height: 90.0,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                'Bahasa Malaysia',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: Transform.scale(
                                  scale: 1.5,
                                  child: Radio<int>(
                                    value: 2,
                                    groupValue: selectedLanguage,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedLanguage = value!;
                                      });
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Card(
                          elevation: 5,
                          child: Row(
                            children: [
                              Image.asset(
                                ImageConstant.CHINA,
                                width: 90.0,
                                height: 90.0,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                '简体中文',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: Transform.scale(
                                  scale: 1.5,
                                  child: Radio<int>(
                                    value: 3,
                                    groupValue: selectedLanguage,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedLanguage = value!;
                                      });
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ])),
        Positioned(
          top: 25,
          left: 0,
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: 35.0,
            ),
            onPressed: () {
              Navigator.pop(context, true);
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
              'Language',
              style: TextStyle(
                fontSize: TextConstant.TITLE_FONT_SIZE,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Positioned(
          top: 70,
          right: 0,
          left: 0,
          child: Image.asset(
            ImageConstant.LANGUAGE,
            width: 200.0,
            height: 200.0,
          ),
        ),
        Positioned(
            bottom: 20,
            right: 0,
            left: 0,
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: customButton(
                    context,
                    'Change',
                    ColorConstant.BLUE_BUTTON_TEXT,
                    ColorConstant.BLUE_BUTTON_UNPRESSED,
                    ColorConstant.BLUE_BUTTON_PRESSED,
                    () async {
                      print(selectedLanguage);
                    }))),
      ],
    ));
  }
}