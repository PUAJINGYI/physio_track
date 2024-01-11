import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:physio_track/authentication/signin_screen.dart';
import 'package:physio_track/screening_test/screen/test_start_screen.dart';

import '../user_sceen/admin/admin_home_page.dart';
import '../constant/ColorConstant.dart';
import '../user_sceen/patient/patient_home_page.dart';
import '../user_sceen/physio/physio_home_page.dart';
import '../translations/locale_keys.g.dart';

class RedirectScreen extends StatefulWidget {
  const RedirectScreen({super.key});

  @override
  _RedirectScreenState createState() => _RedirectScreenState();
}

class _RedirectScreenState extends State<RedirectScreen> {
  @override
  void initState() {
    super.initState();
    checkUserRoleAndRedirect();
  }

  void checkUserRoleAndRedirect() async {
    String? uid = FirebaseAuth.instance.currentUser!.uid;

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
            if (isTakenTest == false) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => TestStartScreen()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PatientHomePage()),
              );
            }
          } else if (role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminHomePage()),
            );
          } else if (role == 'physio') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => PhysioHomePage()),
            );
          } else {
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SignInScreen()),
          );
        }
      } else {
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
      print("User does not exist");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => SignInScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
