import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:physio_track/authentication/signup_screen.dart';
import 'package:physio_track/profile/screen/change_language_screen.dart';
import 'package:physio_track/provider/user_state.dart';
import 'package:physio_track/reusable_widget/reusable_widget.dart';
import 'package:physio_track/screening_test/screen/test_start_screen.dart';
import 'package:physio_track/user_sceen/admin/admin_home_page.dart';
import 'package:physio_track/user_sceen/physio/physio_home_page.dart';
import 'package:provider/provider.dart';

import '../constant/ColorConstant.dart';
import '../constant/ImageConstant.dart';
import '../profile/model/user_model.dart';
import '../profile/service/user_service.dart';
import '../translations/locale_keys.g.dart';
import '../user_sceen/patient/patient_home_page.dart';
import 'forget_password_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  UserService _userService = UserService();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();
  bool _validateEmailInput = false;
  bool _validatePasswordInput = false;
  bool _isObscure = true;
  bool _isLoading = false;

  void toggleObscure() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  loginWithEmailPassword(String email, String password) async {
    try {
      setState(() {
        _isLoading = true;
      });
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

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

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            titlePadding:
                EdgeInsets.fromLTRB(16, 0, 16, 0), 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(LocaleKeys.Error.tr()),
                IconButton(
                  icon: Icon(Icons.close, color: ColorConstant.RED_BUTTON_TEXT),
                  onPressed: () {
                    Navigator.of(context).pop(); 
                  },
                ),
              ],
            ),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                message,
                textAlign: TextAlign.center,
              ),
            ),
            actions: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        backgroundColor: ColorConstant.BLUE_BUTTON_UNPRESSED,
                      ),
                      child: Text(LocaleKeys.OK.tr(),
                          style:
                              TextStyle(color: ColorConstant.BLUE_BUTTON_TEXT)),
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );

      setState(() {});
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  loginWithGoogle() async {
    try {
      final GoogleSignInAccount? gUser = await _googleSignIn.signIn();

      if (gUser != null) {
        final GoogleSignInAuthentication gAuth = await gUser.authentication;

        AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken,
          idToken: gAuth.idToken,
        );

        final userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        UserState userState = Provider.of<UserState>(context, listen: false);
        userState.setUserCredentials(credential);

        if (userCredential.additionalUserInfo?.isNewUser == true) {
          String displayName = userCredential.user?.displayName ?? "-";
          String email = userCredential.user?.email ?? "-";
          String uid = FirebaseAuth.instance.currentUser!.uid;
          UserModel userModel = UserModel(
            id: 0,
            username: displayName,
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
          );

          await _userService.addNewUserToFirestore(userModel, uid);
        }

         checkUserRoleAndRedirect(context);
      } else {
        print("Google Sign-In canceled");
      }
    } catch (e) {
      String message = LocaleKeys.An_Error_Occurred.tr();
      print(message);
      print(e.toString());

    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void checkUserRoleAndRedirect(BuildContext context) async {
    String? uid = _auth.currentUser?.uid;

    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userSnapshot.exists) {
      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

      if (userData != null) {
        String? role = userData['role'];
        bool? isTakenTest = userData['isTakenTest'];

        if (role != null) {
          if (role == 'patient') {
            print(role);
            if (isTakenTest == true) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => PatientHomePage()));
            } else {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => TestStartScreen()));
            }
          } else if (role == 'admin') {
            print(role);
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => AdminHomePage()));
          } else if (role == 'physio') {
            print(role);
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => PhysioHomePage()));
          } else {
            print("Handle null role value");
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  contentPadding: EdgeInsets.zero, 
                  titlePadding:
                      EdgeInsets.fromLTRB(16, 0, 16, 0), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(LocaleKeys.Error.tr()),
                      IconButton(
                        icon: Icon(Icons.close,
                            color: ColorConstant.RED_BUTTON_TEXT),
                        onPressed: () {
                          Navigator.of(context).pop(); 
                        },
                      ),
                    ],
                  ),
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      LocaleKeys.Handle_null_role_value.tr(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  actions: [
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              backgroundColor:
                                  ColorConstant.BLUE_BUTTON_UNPRESSED,
                            ),
                            child: Text(LocaleKeys.OK.tr(),
                                style: TextStyle(
                                    color: ColorConstant.BLUE_BUTTON_TEXT)),
                            onPressed: () async {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          }
        } else {
          print("Handle null user data");
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                contentPadding: EdgeInsets.zero, 
                titlePadding:
                    EdgeInsets.fromLTRB(16, 0, 16, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(LocaleKeys.Error.tr()),
                    IconButton(
                      icon: Icon(Icons.close,
                          color: ColorConstant.RED_BUTTON_TEXT),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    LocaleKeys.Handle_null_user_data.tr(),
                    textAlign: TextAlign.center,
                  ),
                ),
                actions: [
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            backgroundColor:
                                ColorConstant.BLUE_BUTTON_UNPRESSED,
                          ),
                          child: Text(LocaleKeys.OK.tr(),
                              style: TextStyle(
                                  color: ColorConstant.BLUE_BUTTON_TEXT)),
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        }
      } else {
        print("User document does not exist, handle as needed");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              contentPadding: EdgeInsets.zero, 
              titlePadding:
                  EdgeInsets.fromLTRB(16, 0, 16, 0), 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(LocaleKeys.Error.tr()),
                  IconButton(
                    icon:
                        Icon(Icons.close, color: ColorConstant.RED_BUTTON_TEXT),
                    onPressed: () {
                      Navigator.of(context).pop(); 
                    },
                  ),
                ],
              ),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  LocaleKeys.User_document_not_exist.tr(),
                  textAlign: TextAlign.center,
                ),
              ),
              actions: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          backgroundColor: ColorConstant.BLUE_BUTTON_UNPRESSED,
                        ),
                        child: Text(LocaleKeys.OK.tr(),
                            style: TextStyle(
                                color: ColorConstant.BLUE_BUTTON_TEXT)),
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      }
    } else {
      signOutGoogle();
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
          Column(
            children: [
              SizedBox(height: 33),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.33,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(ImageConstant.LOGIN_PIC),
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                    Container(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          0,
                          20,
                          0,
                        ),
                        child: Column(
                          children: [
                            logoWidget(ImageConstant.LOGO),
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
                              if (!_isLoading) {
                                setState(() {
                                  _emailTextController.text.isEmpty ||
                                          !_emailTextController.text
                                              .contains("@")
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
                                  UserState userState = Provider.of<UserState>(
                                      context,
                                      listen: false);
                                  userState.setUserEmailPassword(
                                    _emailTextController.text,
                                    _passwordTextController.text,
                                  );
                                }
                              }
                            }),
                            signInGmailButton(context, () async {
                              loginWithGoogle();
                            }),
                            signUpOption(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChangeLanguageScreen()));
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
