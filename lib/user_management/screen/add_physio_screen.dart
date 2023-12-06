import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:physio_track/provider/user_state.dart';
import 'package:provider/provider.dart';

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
  TextEditingController _genderController = TextEditingController();
  bool _validateUsernameInput = false;
  bool _validateEmailInput = false;
  bool _validatePasswordInput = false;
  bool _validateGender = false;
  String _selectedGender = '';
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
      final gender = _genderController.text;
      UserModel user;
      // Sign in with email and password
      await FirebaseAuth.instance
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
                  gender: gender,
                ),
                await _userService.addNewUserToFirestore(user, value.user!.uid),
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text("New phsyio account created successfully")),
                ),
                print("New physio account created successfully"),
                Navigator.pop(context, true),
              });
      await FirebaseAuth.instance.signOut();

      UserState userState = Provider.of<UserState>(context, listen: false);
      if (userState.userEmail != '' && userState.userPassword != '') {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: userState.userEmail, password: userState.userPassword);
      } else {
        await FirebaseAuth.instance
            .signInWithCredential(userState.userCredential);
      }
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

  Future<void> _showGenderPicker(BuildContext context) async {
    String selectedGender = '';

    // Show the bottom sheet dialog
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext builder) {
        return GestureDetector(
          onTap: () {
            // Do nothing when tapped inside the dialog
          },
          child: Container(
            height: MediaQuery.of(context).copyWith().size.height / 4,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          LocaleKeys.Select_Gender.tr(),
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () {
                          Navigator.of(context)
                              .pop(); // Close the bottom s5heet
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          LocaleKeys.Male.tr(),
                          textAlign: TextAlign.center,
                        ),
                        onTap: () {
                          setState(() {
                            selectedGender = 'Male';
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                      ListTile(
                        title: Text(
                          LocaleKeys.Female.tr(),
                          textAlign: TextAlign.center,
                        ),
                        onTap: () {
                          setState(() {
                            selectedGender = 'Female';
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    _genderController.text = selectedGender;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 70,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      Image.asset(
                        ImageConstant.PHYSIO,
                        width: 300.0,
                      ),
                      SizedBox(
                        height: 50,
                      ),
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
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          _showGenderPicker(context);
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            controller: _genderController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.male_outlined,
                                color: Colors.black,
                              ),
                              labelText: LocaleKeys.Select_Gender.tr(),
                              errorText: _validateGender
                                  ? LocaleKeys.Please_Select_Gender.tr()
                                  : null,
                              labelStyle: TextStyle(
                                  color: Colors.black.withOpacity(0.5)),
                              filled: true,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              fillColor: Colors.white,
                              border: UnderlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 100,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            0,
                            TextConstant.CUSTOM_BUTTON_TB_PADDING,
                            0,
                            TextConstant.CUSTOM_BUTTON_TB_PADDING),
                        child: customButton(
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
                            _genderController.text.isEmpty
                                ? _validateGender = true
                                : _validateGender = false;
                          });
                          if (_validateUsernameInput == false &&
                              _validateEmailInput == false &&
                              _validatePasswordInput == false &&
                              _validateGender == false) {
                            await _createPhysioAccWithEmailAndPassword();
                          }
                        }),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 45,
              ),
            ],
          ),
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
      ],
    ));
  }
}
