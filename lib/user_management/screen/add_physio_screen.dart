import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../../constant/ColorConstant.dart';
import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../../profile/model/user_model.dart';
import '../../profile/service/user_service.dart';
import '../../reusable_widget/reusable_widget.dart';
import '../../translations/locale_keys.g.dart';

class AddPhysioScreen extends StatefulWidget {
  const AddPhysioScreen({super.key});

  @override
  State<AddPhysioScreen> createState() => _AddPhysioScreenState();
}

class _AddPhysioScreenState extends State<AddPhysioScreen> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();
  bool _validateUsernameInput = false;
  bool _validateEmailInput = false;
  bool _validatePasswordInput = false;
  bool _isObscure = true;
  UserService _userService = UserService();

  void toggleObscure() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  Future<void> _createPhysioAccWithEmailAndPassword() async {
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
          .then((value) async => {
                user = UserModel(
                  id: 0,
                  username: username,
                  email: email,
                  role: "physio",
                  createTime: Timestamp.now(),
                  isTakenTest: false,
                  address: '',
                  phone: '',
                  profileImageUrl: '',
                  level: 0,
                  totalExp: 0,
                  progressToNextLevel: 0.0,
                  sharedJournal: false,
                ),
                await _userService.addNewUserToFirestore(user, value.user!.uid),
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text("New phsyio account created successfully")),
                ),
                print("New physio account created successfully"),
                Navigator.pop(context, true),
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
        body: Stack(
      children: [
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
                        LocaleKeys.Enter_username.tr(),
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
                    SizedBox(
                      height: 100,
                    ),
                    customButton(
                        context,
                        LocaleKeys.Add.tr(),
                        ColorConstant.BLUE_BUTTON_TEXT,
                        ColorConstant.BLUE_BUTTON_UNPRESSED,
                        ColorConstant.BLUE_BUTTON_PRESSED, () async {
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
                        await _createPhysioAccWithEmailAndPassword();
                      }
                    })
                  ],
                ),
              ),
            )),
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
              LocaleKeys.New_Physio.tr(),
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
            ImageConstant.PHYSIO,
            width: 200.0,
            height: 200.0,
          ),
        ),
      ],
    ));
  }
}
