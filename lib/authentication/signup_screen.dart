import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'package:physio_track/authentication/signin_screen.dart';
import 'package:physio_track/constant/ImageConstant.dart';
import 'package:physio_track/reusable_widget/reusable_widget.dart';

import '../constant/ColorConstant.dart';
import '../constant/TextConstant.dart';
import '../profile/model/user_model.dart';
import '../profile/service/user_service.dart';
import '../translations/locale_keys.g.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  UserService _userService = UserService();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();
  bool _validateUsernameInput = false;
  bool _validateEmailInput = false;
  bool _validatePasswordInput = false;
  bool _isObscure = true;

  void toggleObscure() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  Future<void> _createUserWithEmailAndPassword() async {
    try {
      final username = _usernameController.text;
      final email = _emailTextController.text;
      final password = _passwordTextController.text;
      UserModel user;
      // Sign in with email and password
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email,
            password: password,
          )
          .then((value) => {
                user = UserModel(
                  id: 0,
                  username: username,
                  email: email,
                  role: "patient",
                  createTime: Timestamp.now(),
                  isTakenTest: false,
                  address: '',
                  phone: '',
                  profileImageUrl: '',
                  level: 1,
                  totalExp: 0,
                  progressToNextLevel: 0.0,
                  sharedJournal: false,
                  gender: '',
                ),
                _userService.addNewUserToFirestore(user, value.user!.uid),
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          LocaleKeys.New_account_created_successfully.tr())),
                ),
                print("New account created successfully"),
                Navigator.pop(context),
              });
    } on FirebaseAuthException catch (e) {
      String message;

      if (e.code == 'email-already-in-use') {
        message = LocaleKeys.Email_Ady_Use.tr();
      } else if (e.code == 'weak-password') {
        message = LocaleKeys.Password_Too_Weak.tr();
      } else if (e.code == 'invalid-email') {
        message = LocaleKeys.Invalid_Email_Address.tr();
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
        Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(ImageConstant.SIGNUP_PIC),
                alignment: Alignment.center,
                fit: BoxFit.fitWidth),
          ),
        ),
        Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).size.height * 0.45, 20, 0),
                child: Column(
                  children: [
                    reusableTextField(
                        LocaleKeys.Username.tr(),
                        LocaleKeys.Please_Insert_Username.tr(),
                        Icons.person_outline,
                        false,
                        _usernameController,
                        _validateUsernameInput,
                        _isObscure,
                        toggleObscure),
                    SizedBox(
                      height: 10,
                    ),
                    reusableTextField(
                        LocaleKeys.Enter_Email.tr(),
                        LocaleKeys.Please_Insert_Valid_Email.tr(),
                        Icons.mail_outline,
                        false,
                        _emailTextController,
                        _validateEmailInput,
                        _isObscure,
                        toggleObscure),
                    SizedBox(
                      height: 10,
                    ),
                    reusableTextField(
                        LocaleKeys.Enter_Password.tr(),
                        LocaleKeys.Please_Insert_Password.tr(),
                        Icons.lock_outline,
                        true,
                        _passwordTextController,
                        _validatePasswordInput,
                        _isObscure,
                        toggleObscure),
                  ],
                ),
              ),
            )),
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
              LocaleKeys.Sign_Up.tr(),
              ColorConstant.BLUE_BUTTON_TEXT,
              ColorConstant.BLUE_BUTTON_UNPRESSED,
              ColorConstant.BLUE_BUTTON_PRESSED,
              () {
                setState(() {
                  _usernameController.text.isEmpty
                      ? _validateUsernameInput = true
                      : _validateUsernameInput = false;
                  _emailTextController.text.isEmpty ||
                          !_emailTextController.text.contains("@")
                      ? _validateEmailInput = true
                      : _validateEmailInput = false;
                  _passwordTextController.text.isEmpty
                      ? _validatePasswordInput = true
                      : _validatePasswordInput = false;
                });
                if (_validateUsernameInput == false &&
                    _validateEmailInput == false &&
                    _validatePasswordInput == false) {
                  _createUserWithEmailAndPassword();
                }
              },
            ),
          ),
        )
      ]),
    );
  }
}
