import 'dart:async';
import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:physio_track/achievement/screen/achievement_list_screen.dart';
import 'package:physio_track/user_sceen/admin/admin_home_page.dart';
import 'package:physio_track/authentication/forget_password_screen.dart';
import 'package:physio_track/authentication/redirect_screen.dart';
import 'package:physio_track/authentication/signin_screen.dart';
import 'package:physio_track/authentication/signup_screen.dart';
import 'package:physio_track/journal/screen/add_journal_screen.dart';
import 'package:physio_track/journal/screen/view_journal_list_screen.dart';
import 'package:physio_track/user_sceen/patient/patient_home_page.dart';
import 'package:physio_track/user_sceen/patient/patient_home_screen.dart';
import 'package:physio_track/user_sceen/physio/physio_home_page.dart';
import 'package:physio_track/user_sceen/physio/physio_home_screen.dart';
import 'package:physio_track/profile/screen/change_language_screen.dart';
import 'package:physio_track/profile/screen/edit_profile_screen.dart';
import 'package:physio_track/provider/user_state.dart';
import 'package:physio_track/pt_library/screen/add_pt_activity_library_screen.dart';
import 'package:physio_track/pt_library/screen/pt_daily_finished_screen.dart';
import 'package:physio_track/pt_library/screen/pt_daily_list_screen.dart';
import 'package:physio_track/pt_library/screen/pt_library_detail_screen.dart';
import 'package:physio_track/pt_library/screen/pt_library_detail_screen.dart';
import 'package:physio_track/pt_library/screen/pt_library_list_screen.dart';
import 'package:physio_track/screening_test/screen/add_question_screen.dart';
import 'package:physio_track/screening_test/screen/admin/daily_question_list_screen.dart';
import 'package:physio_track/screening_test/screen/admin/general_question_list_screen.dart';
import 'package:physio_track/screening_test/screen/admin/question_list_nav_page.dart';
import 'package:physio_track/screening_test/screen/test_end_screen.dart';
import 'package:physio_track/screening_test/screen/test_part_1_screen.dart';
import 'package:physio_track/screening_test/screen/test_part_2_screen.dart';
import 'package:physio_track/screening_test/screen/test_start_screen.dart';
import 'package:physio_track/screening_test/screen/test_physiotherapist_request_screen.dart';
import 'package:physio_track/screening_test/service/question_service.dart';
import 'package:physio_track/translations/codegen_loader.g.dart';
import 'package:physio_track/treatment/screen/create_treatment_report_screen.dart';
import 'package:physio_track/user_management/screen/add_physio_screen.dart';
import 'package:workmanager/workmanager.dart';
import 'achievement/screen/add_achievement_screen.dart';
import 'achievement/screen/bar_chart_sample1.dart';
import 'achievement/screen/physio/patient_list_by_physio_screen.dart';
import 'achievement/screen/progress_screen.dart';
import 'achievement/screen/weekly_analysis_screen.dart';
import 'user_sceen/admin/admin_activity_management_screen.dart';
import 'appointment/screen/admin/appointment_admin_nav_page.dart';
import 'appointment/screen/appointment_history_screen.dart';
import 'appointment/screen/appointment_patient_screen.dart';
import 'appointment/screen/appointment_booking_screen.dart';
import 'appointment/screen/physio/appointment_history_physio_screen.dart';
import 'appointment/screen/physio/appointment_schedule_screen.dart';
import 'authentication/change_password_screen.dart';
import 'authentication/service/auth_manager.dart';
import 'authentication/splash_screen.dart';
import 'leave/screen/leave_apply_screen.dart';
import 'leave/screen/leave_list_screen.dart';
import 'notification/model/received_notification_model.dart';
import 'notification/screen/notification_list_screen.dart';
import 'ot_library/screen/edit_ot_activity_library.dart';
import 'ot_library/screen/ot_daily_list_screen.dart';
import 'ot_library/screen/ot_library_detail_screen.dart';
import 'ot_library/screen/ot_library_list_screen.dart';
import 'ot_library/screen/ot_library_list_screen.dart';
import 'ot_library/screen/add_ot_activity_library_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();
int id = 0;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_example');

const String urlLaunchActionId = 'id_1';

const String navigationActionId = 'id_3';

const String darwinNotificationCategoryText = 'textCategory';

const String darwinNotificationCategoryPlain = 'plainCategory';

String? selectedNotificationPayload;
final GlobalKey<NavigatorState> NavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  await _configureLocalTimeZone();

  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        !kIsWeb && Platform.isLinux
            ? null
            : await flutterLocalNotificationsPlugin
                .getNotificationAppLaunchDetails();
    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ms'), Locale('zh')],
        fallbackLocale: const Locale('en'),
        assetLoader: const CodegenLoader(),
        path: 'assets/translations',
        child: ChangeNotifierProvider(
          create: (context) =>
              UserState(), 
          child: MyApp(),
        ),
      ),
    );
  });
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

Future<void> _configureLocalTimeZone() async {
  if (kIsWeb || Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Singapore'));
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigatorKey,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      title: 'PhysioTrack',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:
          SplashScreen(
        onFinish: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => RedirectScreen()),
          );
        },
      ),
    );
  }
}
