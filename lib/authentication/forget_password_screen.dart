import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:physio_track/authentication/signin_screen.dart';

import '../reusable_widget/reusable_widget.dart';

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
        SnackBar(content: Text("Email Sent Successfully")),
      );
      print("Email Sent Successfully");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SignInScreen()));
    } on FirebaseAuthException catch (e) {
      String message;

      if (e.code == 'user-not-found') {
        message = 'No user found with this email.';
      } else {
        message = 'An error occurred. Please try again later.';
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
                      height: 200,
                    ),
                    reusableTextField(
                        "Enter Registered Email",
                        "Please insert valid email",
                        Icons.email_outlined,
                        false,
                        _emailTextController,
                        _validateEmailInput,
                        _isObscure,
                        toggleObscure),
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
                        _emailTextController.text.isEmpty ||
                                !_emailTextController.text.contains("@")
                            ? _validateEmailInput = true
                            : _validateEmailInput = false;
                      });
                      if (_validateEmailInput == false) {
                        _sendPasswordResetEmail();
                      }
                    })
                  ],
                ),
              ),
            )),
      ]),
    );
  }
}
