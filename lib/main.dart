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

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_example');

// A notification action which triggers a url launch event
const String urlLaunchActionId = 'id_1';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

/// Defines a iOS/MacOS notification category for text input actions.
const String darwinNotificationCategoryText = 'textCategory';

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';

String? selectedNotificationPayload;
final GlobalKey<NavigatorState> NavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  await _configureLocalTimeZone();

  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // final AuthManager authManager = AuthManager();
  // // runApp(MyApp(authManager));
  // Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  // Workmanager().cancelByUniqueName("firstTask");
  // Workmanager().cancelByUniqueName("secondTask");
  // Workmanager().cancelByUniqueName("thirdTask");
  // Workmanager().cancelByUniqueName("updateActivityList");
  //runApp(MyApp());
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        !kIsWeb && Platform.isLinux
            ? null
            : await flutterLocalNotificationsPlugin
                .getNotificationAppLaunchDetails();
    // String initialRoute = HomePage.routeName;
    // if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    //   selectedNotificationPayload = notificationAppLaunchDetails!.notificationResponse?.payload;
    //   initialRoute = SecondPage.routeName;
    // }

    // const AndroidInitializationSettings initializationSettingsAndroid =
    //     AndroidInitializationSettings('app_icon');

    // final List<DarwinNotificationCategory> darwinNotificationCategories =
    //     <DarwinNotificationCategory>[
    //   DarwinNotificationCategory(
    //     darwinNotificationCategoryText,
    //     actions: <DarwinNotificationAction>[
    //       DarwinNotificationAction.text(
    //         'text_1',
    //         'Action 1',
    //         buttonTitle: 'Send',
    //         placeholder: 'Placeholder',
    //       ),
    //     ],
    //   ),
    //   DarwinNotificationCategory(
    //     darwinNotificationCategoryPlain,
    //     actions: <DarwinNotificationAction>[
    //       DarwinNotificationAction.plain('id_1', 'Action 1'),
    //       DarwinNotificationAction.plain(
    //         'id_2',
    //         'Action 2 (destructive)',
    //         options: <DarwinNotificationActionOption>{
    //           DarwinNotificationActionOption.destructive,
    //         },
    //       ),
    //       DarwinNotificationAction.plain(
    //         navigationActionId,
    //         'Action 3 (foreground)',
    //         options: <DarwinNotificationActionOption>{
    //           DarwinNotificationActionOption.foreground,
    //         },
    //       ),
    //       DarwinNotificationAction.plain(
    //         'id_4',
    //         'Action 4 (auth required)',
    //         options: <DarwinNotificationActionOption>{
    //           DarwinNotificationActionOption.authenticationRequired,
    //         },
    //       ),
    //     ],
    //     options: <DarwinNotificationCategoryOption>{
    //       DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
    //     },
    //   )
    // ];

    // /// Note: permissions aren't requested here just to demonstrate that can be
    // /// done later
    // final DarwinInitializationSettings initializationSettingsDarwin =
    //     DarwinInitializationSettings(
    //   requestAlertPermission: false,
    //   requestBadgePermission: false,
    //   requestSoundPermission: false,
    //   onDidReceiveLocalNotification:
    //       (int id, String? title, String? body, String? payload) async {
    //     didReceiveLocalNotificationStream.add(
    //       ReceivedNotification(
    //         id: id,
    //         title: title,
    //         body: body,
    //         payload: payload,
    //       ),
    //     );
    //   },
    //   notificationCategories: darwinNotificationCategories,
    // );
    // final LinuxInitializationSettings initializationSettingsLinux =
    //     LinuxInitializationSettings(
    //   defaultActionName: 'Open notification',
    //   defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
    // );
    // final InitializationSettings initializationSettings =
    //     InitializationSettings(
    //   android: initializationSettingsAndroid,
    //   iOS: initializationSettingsDarwin,
    //   macOS: initializationSettingsDarwin,
    //   linux: initializationSettingsLinux,
    // );
    // await flutterLocalNotificationsPlugin.initialize(
    //   initializationSettings,
    //   onDidReceiveNotificationResponse:
    //       (NotificationResponse notificationResponse) {
    //     switch (notificationResponse.notificationResponseType) {
    //       case NotificationResponseType.selectedNotification:
    //         selectNotificationStream.add(notificationResponse.payload);
    //         break;
    //       case NotificationResponseType.selectedNotificationAction:
    //         if (notificationResponse.actionId == navigationActionId) {
    //           selectNotificationStream.add(notificationResponse.payload);
    //         }
    //         break;
    //     }
    //   },
    //   onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    // );

    runApp(
      EasyLocalization(
        child: ChangeNotifierProvider(
          create: (context) =>
              UserState(), // Assuming UserState is a ChangeNotifier
          child: MyApp(),
        ),
        supportedLocales: [Locale('en'), Locale('ms'), Locale('zh')],
        fallbackLocale: Locale('en'),
        assetLoader: CodegenLoader(),
        path: 'assets/translations',
      ),
    );
  });
  //initBackgroundFetch();
  // runApp(MaterialApp(
  //   title: 'Calendar App',
  //   debugShowCheckedModeBanner: false,
  //   home: Home(),
  // ));
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
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

// void callbackDispatcher() {
//   Workmanager().executeTask((taskName, inputData) {
//     switch (taskName) {
//       case "firstTask":
//         break;
//       case "secondTask":
//         break;
//       case "thirdTask":
//         break;
//       case "updateActivityList":
//         break;
//       default:
//     }
//     return Future.value(true);
//   });
// }

class MyApp extends StatelessWidget {
  // final AuthManager authManager = AuthManager();
  // final Noti noti = Noti();
  //const MyApp(this.authManager, this.noti, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);
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
          //OTLibraryDetailScreen(recordId: 1),
          //EditOTActivityScreen(recordId: 1),
          //PTLibraryListScreen(),
          //TestPart2Screen(),
          //TestFinishScreen(),
          //AddPTActivityScreen(),
          //OTLibraryDetailScreen2(),
          //AddQuestionScreen(),
          SplashScreen(
        onFinish: () {
          // if (authManager.isLoggedIn) {
          //   Navigator.of(context).pushReplacement(
          //     MaterialPageRoute(builder: (_) => RedirectScreen()),
          //   );
          // } else {
          //   Navigator.of(context).pushReplacement(
          //     MaterialPageRoute(builder: (_) => SignInScreen()),
          //   );
          // }
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => RedirectScreen()),
          );
        },
      ),
      //  NotiDemoScreen(),
      //LeaveApplyScreen(physioId: 6,),
      //LeaveListScreen(physioId: 6),
      //ChangeLanguageScreen(),
      //AddPhysioScreen(),
      //AdminHomePage(),
      //PhysioHomePage(),
      //AdminActivityManagementScreen(),
      //NotificationListScreen(),
      //TestPart1Screen(),
      //HomePage(noti: noti,),
      //OTDailyListScreen(),
      //PTDailyFinishedScreen(),
      //PTLibraryListScreen(),
      //YoutubeAppDemo(),
      //AchievementListScreen(),
      //ProgressScreen(),
      //AppointmentPatientScreen(),
      //AppointmentHistoryScreen(),
      //AppointmentAdminNavPage(),
      //AppointmentListScreen(),
      //AppointmentBookingScreen(),
      //AppointmentHistoryPhysioScreen(),
      //CreateTreatmentReportScreen(),
      //WeeklyAnalysisScreen(),
      // AchievementAnalysisScreen(),
      // BarChartSample2(),
      //PTLibraryDetailScreen(),
      //AddAchievementScreen(),
      //AppointmentScheduleScreen(),
      //PatientListScreen(),
      //QuestionListNavPage(),
      //GeneralQuestionListScreen(),
      //DailyQuestionListScreen(),
    );
  }
}

// void initBackgroundFetch() {
//   print('Enter initBackgroundFetch');
//   BackgroundFetch.configure(
//     BackgroundFetchConfig(
//       minimumFetchInterval:
//           15, // Minimum interval between background fetches (in minutes)
//       stopOnTerminate:
//           false, // Continue background fetch even if the app is terminated
//       enableHeadless: true, // Run task in a headless state (no UI)
//       requiresBatteryNotLow: false,
//       requiresCharging: false,
//       requiresStorageNotLow: false,
//       startOnBoot: true,
//     ),
//     (taskId) async {
//       // Perform your background task here
//       //await _performBackgroundTask();
//       BackgroundFetch.finish(taskId);
//       print('Task completed');
//     },
//   );
//   BackgroundFetch.start();
// }

// Future<void> _performBackgroundTask() async {
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   final NotificationServices notificationServices = NotificationServices();
//   print('_performBackgroundTask');

//   // empty list be get!!!
//   QuestionService questionService = QuestionService();
//   QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
//       .collection('users')
//       .where('role', isEqualTo: 'patient')
//       .where('isTakenTest', isEqualTo: true)
//       .get();

//   for (QueryDocumentSnapshot userDoc in usersSnapshot.docs) {
//     String userId = userDoc.id;
//     print("useerid: ${userId}");
//     DocumentReference userRef =
//         FirebaseFirestore.instance.collection('users').doc(userId);

//     QuerySnapshot otLibrariesSnapshot = await userRef
//         .collection('ot_activities')
//         .orderBy('date', descending: true)
//         .limit(1)
//         .get();
//     print("below is otLibrariesSnapshot");
//     print(otLibrariesSnapshot);
//     if (otLibrariesSnapshot.docs.isNotEmpty) {
//       // today date + 1 day
//       DateTime currentDate = DateTime.now();
//       DateTime currentDateWithoutTime =
//           DateTime(currentDate.year, currentDate.month, currentDate.day);
//       DateTime todayPlusOneDay = currentDateWithoutTime.add(Duration(days: 1));
//       print(todayPlusOneDay.toString());
//       // latest library date
//       DocumentSnapshot latestLibrarySnapshot = otLibrariesSnapshot.docs[0];
//       Timestamp latestLibraryTimestamp = latestLibrarySnapshot.get('date');
//       DateTime latestLibraryDate = DateTime(
//         latestLibraryTimestamp.toDate().year,
//         latestLibraryTimestamp.toDate().month,
//         latestLibraryTimestamp.toDate().day,
//       );
//       print(latestLibraryDate.toString());
//       if (todayPlusOneDay.isAfter(latestLibraryDate)) {
//         print('same day');
//         questionService.updateTestStatus(userId);
//         print('finish update test status');
//         notificationServices.showTaskNotification(
//             title: "bgtask 2",
//             body: 'New Weekly activity list be refreshed !',
//             fln: flutterLocalNotificationsPlugin);
//       }
//       print('not same day');
//     } else {
//       questionService.updateTestStatus(userId);
//       notificationServices.showTaskNotification(
//           title: "bgtask 2",
//           body: 'New Weekly activity list be refreshed !',
//           fln: flutterLocalNotificationsPlugin);
//     }
//     print("otLibrariesSnapshot is empty");
//   }
//   notificationServices.showTaskNotification(
//       title: "bgtask 2",
//       body: 'Testing 1234',
//       fln: flutterLocalNotificationsPlugin);
// }

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('notification title ${message.notification!.title.toString()}');
// }
