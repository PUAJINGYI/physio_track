import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:physio_track/admin/admin_home_page.dart';
import 'package:physio_track/authentication/signup_screen.dart';
import 'package:physio_track/patient/patient_home_screen.dart';
import 'package:physio_track/physio/physio_home_page.dart';
import 'package:physio_track/physio/physio_home_screen.dart';
import 'package:physio_track/reusable_widget/reusable_widget.dart';
import 'package:physio_track/screening_test/screen/test_start_screen.dart';

import '../admin/admin_home_screeen.dart';
import '../constant/ColorConstant.dart';
import '../constant/ImageConstant.dart';
import 'service/auth_manager.dart';
import '../patient/patient_home_page.dart';
import 'forget_password_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();
  bool _validateEmailInput = false;
  bool _validatePasswordInput = false;
  bool _isObscure = true;
  AuthManager _authManager = AuthManager();

  void toggleObscure() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  loginWithEmailPassword(String email, String password) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _authManager.login();
      checkUserRoleAndRedirect(context);
    } catch (e) {
      String message = 'An error occurred. Please try again later.';

      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          message = 'No user found with this email.';
        } else if (e.code == 'wrong-password') {
          message = 'Invalid password.';
        }
      }

      // Show Snackbar with error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      // Refresh the page
      setState(() {});
    }
  }

  loginWithGoogle() async {
    try {
      final GoogleSignInAccount? gUser = await _googleSignIn.signIn();

      if (gUser != null) {
        final GoogleSignInAuthentication gAuth = await gUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken,
          idToken: gAuth.idToken,
        );

        final userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        _authManager.login();
        checkUserRoleAndRedirect(context);
      } else {
        // Handle when the Google Sign In window is closed without logging in
        print("Google Sign In canceled");
      }
    } catch (e) {
      // Handle any other errors that may occur
      String message = 'An error occurred. Please try again later.';
      print(message);
      print(e.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      setState(() {});
    }
  }

  void checkUserRoleAndRedirect(BuildContext context) async {
    // Get the current user's ID
    String? uid = _auth.currentUser?.uid;

    // Retrieve the user document from Firestore
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userSnapshot.exists) {
      // User document exists
      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

      if (userData != null) {
        // Retrieve the role from the user data
        String? role = userData['role'];
        bool? isTakenTest = userData['isTakenTest'];

        if (role != null) {
          // Redirect based on user role
          if (role == 'patient') {
            // Redirect to patient home page
            print(role);
            if (isTakenTest == true) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => PatientHomePage()));
            } else {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => TestStartScreen()));
            }
          } else if (role == 'admin') {
            // Redirect to admin home page
            print(role);
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => AdminHomePage()));
          } else if (role == 'physio') {
            // Redirect to admin home page
            print(role);
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => PhysioHomePage()));
          } else {
            // Handle null role value
            print("Handle null role value");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Handle null role value")),
            );
          }
        } else {
          // Handle null user data
          print("Handle null user data");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Handle null user data")),
          );
        }
      } else {
        // User document does not exist, handle as needed
        print("User document does not exist, handle as needed");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("User document does not exist, handle as needed")),
        );
      }
    } else {
      print("User does not exist");
    }
  }

  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(ImageConstant.LOGIN_PIC),
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
                    20,
                    MediaQuery.of(context).size.height * 0.39,
                    20,
                    0,
                  ),
                  child: Column(
                    children: [
                      logoWidget(ImageConstant.LOGO),
                      SizedBox(height: 10),
                      reusableTextField(
                        "Enter Email",
                        "Please insert valid email",
                        Icons.email_outlined,
                        false,
                        _emailTextController,
                        _validateEmailInput,
                        _isObscure,
                        toggleObscure,
                      ),
                      SizedBox(height: 20),
                      reusableTextField(
                        "Enter Password",
                        "Please insert password",
                        Icons.lock_outline,
                        true,
                        _passwordTextController,
                        _validatePasswordInput,
                        _isObscure,
                        toggleObscure,
                      ),
                      SizedBox(height: 5),
                      forgetPassword(),
                      SizedBox(height: 10),
                      customButton(
                          context,
                          'Login',
                          ColorConstant.BLUE_BUTTON_TEXT,
                          ColorConstant.BLUE_BUTTON_UNPRESSED,
                          ColorConstant.BLUE_BUTTON_PRESSED, () {
                        setState(() {
                          _emailTextController.text.isEmpty ||
                                  !_emailTextController.text.contains("@")
                              ? _validateEmailInput = true
                              : _validateEmailInput = false;
                          _passwordTextController.text.isEmpty
                              ? _validatePasswordInput = true
                              : _validatePasswordInput = false;
                        });
                        if (_validateEmailInput == false &&
                            _validatePasswordInput == false) {
                          loginWithEmailPassword(
                            _emailTextController.text,
                            _passwordTextController.text,
                          );
                        }
                      }),
                      signInGmailButton(context, () async {
                        // await signOutGoogle();
                        loginWithGoogle();
                      }),
                      signUpOption(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar:
            null // Hide the persistent_bottom_nav_bar on the sign-in page
        );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have account?",
            style: TextStyle(color: Colors.black)),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SignUpScreen()));
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(
                color: Color.fromARGB(255, 66, 157, 173),
                fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Padding forgetPassword() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ForgetPasswordScreen()));
            },
            child: const Text(
              "Forget Password?",
              style: TextStyle(
                color: Colors.red,
              ),
              textAlign: TextAlign.end,
            ),
          )
        ],
      ),
    );
  }
}
