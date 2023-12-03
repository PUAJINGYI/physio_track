import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:physio_track/authentication/signin_screen.dart';

import '../constant/ColorConstant.dart';
import '../constant/ImageConstant.dart';
import '../constant/TextConstant.dart';
import '../reusable_widget/reusable_widget.dart';
import '../translations/locale_keys.g.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  TextEditingController _emailTextController = TextEditingController();
  bool _validateEmailInput = false;
  bool _isObscure = true;

  void toggleObscure() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  Future<void> _sendPasswordResetEmail() async {
    try {
      final email = _emailTextController.text;

      // Sign in with email and password
      final userCredential = await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.Email_Sent_Successfully.tr())),
      );
      print("Email Sent Successfully");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SignInScreen()));
    } on FirebaseAuthException catch (e) {
      String message;

      if (e.code == 'user-not-found') {
        message = LocaleKeys.No_user_found_with_this_email.tr();
      } else {
        message = LocaleKeys.An_Error_Occurred.tr();
      }

      // Show Snackbar with error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      // Refresh the page
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        Column(
          children: [
            SizedBox(
              height: 70,
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(ImageConstant.RESET_PASSWORD_PIC),
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 100,
                            ),
                            reusableTextField(
                                LocaleKeys.Enter_Registered_Email.tr(),
                                LocaleKeys.Please_Insert_Valid_Email.tr(),
                                Icons.email_outlined,
                                false,
                                _emailTextController,
                                _validateEmailInput,
                                _isObscure,
                                toggleObscure),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: 25,
          left: 0,
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: 35.0,
            ),
            onPressed: () {
              Navigator.pop(context);
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
              LocaleKeys.Forget_Password.tr(),
              style: TextStyle(
                fontSize: TextConstant.TITLE_FONT_SIZE,
                fontWeight: FontWeight.bold,
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
              LocaleKeys.Reset_Password.tr(),
              ColorConstant.BLUE_BUTTON_TEXT,
              ColorConstant.BLUE_BUTTON_UNPRESSED,
              ColorConstant.BLUE_BUTTON_PRESSED,
              () {
                setState(() {
                  _emailTextController.text.isEmpty ||
                          !_emailTextController.text.contains("@")
                      ? _validateEmailInput = true
                      : _validateEmailInput = false;
                });
                if (_validateEmailInput == false) {
                  _sendPasswordResetEmail();
                }
              },
            ),
          ),
        )
      ]),
    );
  }
}
