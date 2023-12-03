import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:physio_track/constant/ColorConstant.dart';
import 'package:physio_track/reusable_widget/reusable_widget.dart';

import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../../translations/locale_keys.g.dart';

class ChangeLanguageScreen extends StatefulWidget {
  const ChangeLanguageScreen({super.key});

  @override
  State<ChangeLanguageScreen> createState() => _ChangeLanguageScreenState();
}

class _ChangeLanguageScreenState extends State<ChangeLanguageScreen> {
  int selectedLanguage = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Locale currentLocale = EasyLocalization.of(context)!.locale;
    if (currentLocale == Locale('en')) {
      selectedLanguage = 1;
    } else if (currentLocale == Locale('ms')) {
      selectedLanguage = 2;
    } else if (currentLocale == Locale('zh')) {
      selectedLanguage = 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return Future.value(true);
      },
      child: Scaffold(
          body: Stack(
        children: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 265,
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedLanguage = 1;
                                  });
                                },
                                child: Padding(
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
                                              padding: const EdgeInsets.fromLTRB(
                                                  0, 0, 10, 0),
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
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedLanguage = 2;
                                  });
                                },
                                child: Padding(
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
                                              padding: const EdgeInsets.fromLTRB(
                                                  0, 0, 10, 0),
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
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedLanguage = 3;
                                  });
                                },
                                child: Padding(
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
                                              padding: const EdgeInsets.fromLTRB(
                                                  0, 0, 10, 0),
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
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
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
                LocaleKeys.Language.tr(),
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
                      LocaleKeys.Change.tr(),
                      ColorConstant.BLUE_BUTTON_TEXT,
                      ColorConstant.BLUE_BUTTON_UNPRESSED,
                      ColorConstant.BLUE_BUTTON_PRESSED, () async {
                    if (selectedLanguage == 1) {
                      //await context.setLocale(Locale('en'));
                      await EasyLocalization.of(context)!
                          .setLocale(Locale('en'));
                    } else if (selectedLanguage == 2) {
                      //await context.setLocale(Locale('my'));
                      await EasyLocalization.of(context)!
                          .setLocale(Locale('ms'));
                    } else if (selectedLanguage == 3) {
                      //await context.setLocale(Locale('zh'));
                      await EasyLocalization.of(context)!
                          .setLocale(Locale('zh'));
                    }
                  }))),
        ],
      )),
    );
  }
}
