import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:physio_track/admin/admin_home_page.dart';
import 'package:physio_track/authentication/forget_password_screen.dart';
import 'package:physio_track/authentication/redirect_screen.dart';
import 'package:physio_track/authentication/signin_screen.dart';
import 'package:physio_track/authentication/signup_screen.dart';
import 'package:physio_track/journal/screen/add_journal_screen.dart';
import 'package:physio_track/journal/screen/view_journal_list_screen.dart';
import 'package:physio_track/patient/patient_home_page.dart';
import 'package:physio_track/patient/patient_home_screen.dart';
import 'package:physio_track/patient/patient_navbar.dart';
import 'package:physio_track/physio/physio_home_page.dart';
import 'package:physio_track/physio/physio_home_screen.dart';
import 'package:physio_track/profile/screen/edit_profile_screen.dart';
import 'package:physio_track/screening_test/screen/add_question_screen.dart';
import 'package:physio_track/screening_test/screen/admin/question_list_nav_page.dart';
import 'package:physio_track/screening_test/screen/test_end_screen.dart';
import 'package:physio_track/screening_test/screen/test_start_screen.dart';
import 'package:physio_track/screening_test/screen/test_physiotherapist_request_screen.dart';
import 'authentication/change_password_screen.dart';
import 'authentication/service/auth_manager.dart';
import 'authentication/splash_screen.dart';
import 'journal/screen/add_journal_ori_screen.dart';
import 'ot_library/screen/ot_library_detail_screen.dart';
import 'ot_library/screen/ot_library_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final AuthManager authManager = AuthManager();
  runApp(MyApp(authManager));
}

class MyApp extends StatelessWidget {
  final AuthManager authManager;
  const MyApp(this.authManager, {Key? key}) : super(key: key);

@override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: 
       OTLibraryDetailScreen(recordId: 1),
       //AddQuestionScreen(),
      // SplashScreen(
      //   onFinish: () {
      //     if (authManager.isLoggedIn) {
      //       Navigator.of(context).pushReplacement(
      //         MaterialPageRoute(builder: (_) => RedirectScreen()),
      //       );
      //     } else {
      //       Navigator.of(context).pushReplacement(
      //         MaterialPageRoute(builder: (_) => SignInScreen()),
      //       );
      //     }
      //   },
      // ),
    );
  }
}

