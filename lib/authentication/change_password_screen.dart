import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../constant/ColorConstant.dart';
import '../constant/ImageConstant.dart';
import '../constant/TextConstant.dart';
import '../profile/screen/profile_screen.dart';
import '../reusable_widget/reusable_widget.dart';
import '../translations/locale_keys.g.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _confirmPasswordTextController =
      TextEditingController();
  TextEditingController _newPasswordTextController = TextEditingController();

  bool _validatePasswordInput = false;
  bool _validateConfirmPasswordInput = false;
  bool _validateNewPasswordInput = false;
  bool _isObscure = true;
  bool _isObscure2 = true;
  bool _isObscure3 = true;

  String uid = FirebaseAuth.instance.currentUser!.uid;

  void toggleObscure() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  void toggleObscure2() {
    setState(() {
      _isObscure2 = !_isObscure2;
    });
  }

  void toggleObscure3() {
    setState(() {
      _isObscure3 = !_isObscure3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(ImageConstant.RESET_PASSWORD_PIC),
              alignment: Alignment.center,
            ),
          ),
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
                      height: 80,
                    ),
                    reusableTextField(
                        LocaleKeys.Enter_Existing_Password.tr(),
                        LocaleKeys.Please_insert_existing_password.tr(),
                        Icons.lock_outline,
                        true,
                        _passwordTextController,
                        _validatePasswordInput,
                        _isObscure,
                        toggleObscure),
                    SizedBox(
                      height: 10,
                    ),
                    reusableTextField(
                        LocaleKeys.Enter_Confirmed_Password.tr(),
                        LocaleKeys.Please_insert_confirmed_password.tr(),
                        Icons.lock_outline,
                        true,
                        _confirmPasswordTextController,
                        _validateConfirmPasswordInput,
                        _isObscure2,
                        toggleObscure2),
                    SizedBox(
                      height: 10,
                    ),
                    reusableTextField(
                        LocaleKeys.Enter_New_Password.tr(),
                        LocaleKeys.Please_insert_new_password.tr(),
                        Icons.lock_outline,
                        true,
                        _newPasswordTextController,
                        _validateNewPasswordInput,
                        _isObscure3,
                        toggleObscure3),
                    SizedBox(
                      height: 100,
                    ),
                    customButton(
                        context,
                        LocaleKeys.Reset_Password.tr(),
                        ColorConstant.BLUE_BUTTON_TEXT,
                        ColorConstant.BLUE_BUTTON_UNPRESSED,
                        ColorConstant.BLUE_BUTTON_PRESSED, () {
                      setState(() {
                        _passwordTextController.text.isEmpty
                            ? _validatePasswordInput = true
                            : _validatePasswordInput = false;
                        _confirmPasswordTextController.text.isEmpty
                            ? _validateConfirmPasswordInput = true
                            : _validateConfirmPasswordInput = false;
                        _newPasswordTextController.text.isEmpty
                            ? _validateNewPasswordInput = true
                            : _validateNewPasswordInput = false;
                      });
                      if (_validatePasswordInput == false &&
                          _validateConfirmPasswordInput == false &&
                          _validateNewPasswordInput == false) {
                        changePassword(
                            _passwordTextController.text,
                            _confirmPasswordTextController.text,
                            _newPasswordTextController.text);
                      }
                    }),
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
              LocaleKeys.Change_Password.tr(),
              style: TextStyle(
                fontSize: TextConstant.TITLE_FONT_SIZE,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ]),
    );
  }

  void changePassword(
      String oldPassword, String confirmedPassword, String newPassword) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (oldPassword == confirmedPassword && user != null) {
        // Re-authenticate the user by verifying their current password
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: oldPassword,
        );

        await user.reauthenticateWithCredential(credential);

        // Change the password
        await user.updatePassword(newPassword);

        // Show success message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocaleKeys.Password_updated_successfully.tr())),
        );
        Navigator.pop(context);
      } else {
        // Show error message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  LocaleKeys.Both_Password_Must_Same.tr())), // Replace with the actual user name
        );
      }
    } catch (e) {
      // Show error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(LocaleKeys.Wrong_password.tr())),
      );
    }
  }
}
