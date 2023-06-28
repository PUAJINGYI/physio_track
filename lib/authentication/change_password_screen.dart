import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../profile/screen/profile_screen.dart';
import '../reusable_widget/reusable_widget.dart';

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
          right: 0,
          child: IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              size: 35.0,
            ),
            onPressed: () {
              // Perform your desired action here
              // For example, show notifications
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
              'Reset Password',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/reset-password-pic.png'),
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
                        "Enter Existing Password",
                        "Please insert your existing password",
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
                        "Enter Confirmed Password",
                        "Please insert your confirmed password",
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
                        "Enter New Password",
                        "Please insert your new password",
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
                        'Reset Password',
                        Colors.white,
                        Color.fromARGB(255, 43, 222, 253),
                        Color.fromARGB(255, 66, 157, 173), () {
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
          SnackBar(content: Text('Password updated successfully')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
      } else {
        // Show error message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Both existing password and confirmation password must be the same!')),
        );
      }
    } catch (e) {
      // Show error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wrong password provided for the current user.')),
      );
    }
  }

}
