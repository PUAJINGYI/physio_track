import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
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
import 'package:physio_track/profile/screen/change_language_screen.dart';
import 'package:physio_track/reusable_widget/reusable_widget.dart';
import 'package:physio_track/screening_test/screen/test_start_screen.dart';

import '../admin/admin_home_screen.dart';
import '../constant/ColorConstant.dart';
import '../constant/ImageConstant.dart';
import '../translations/locale_keys.g.dart';
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
      String message = LocaleKeys.An_Error_Occurred.tr();

      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          message = LocaleKeys.No_user_found_with_this_email.tr();
        } else if (e.code == 'wrong-password') {
          message = LocaleKeys.Invalid_password.tr();
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
      String message = LocaleKeys.An_Error_Occurred.tr();
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
              SnackBar(content: Text(LocaleKeys.Handle_null_role_value.tr())),
            );
          }
        } else {
          // Handle null user data
          print("Handle null user data");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(LocaleKeys.Handle_null_user_data.tr())),
          );
        }
      } else {
        // User document does not exist, handle as needed
        print("User document does not exist, handle as needed");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocaleKeys.User_document_not_exist.tr())),
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
                      LocaleKeys.Enter_Email.tr(),
                      LocaleKeys.Please_Insert_Valid_Email.tr(),
                      Icons.email_outlined,
                      false,
                      _emailTextController,
                      _validateEmailInput,
                      _isObscure,
                      toggleObscure,
                    ),
                    SizedBox(height: 20),
                    reusableTextField(
                      LocaleKeys.Enter_Password.tr(),
                      LocaleKeys.Please_Insert_Password.tr(),
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
                        LocaleKeys.Login.tr(),
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
          Positioned(
            top: 25,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                color: Colors.black,
                icon: Icon(Icons.language_outlined),
                iconSize: 35,
                onPressed: () {
                  Navigator.push(context,
                MaterialPageRoute(builder: (context) => ChangeLanguageScreen()));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(LocaleKeys.Do_not_have_account.tr(),
            style: TextStyle(color: Colors.black)),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SignUpScreen()));
          },
          child: Text(
            LocaleKeys.Sign_Up.tr(),
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
            child: Text(
              LocaleKeys.Forget_Password.tr(),
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
