import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:physio_track/authentication/redirect_screen.dart';
import 'package:physio_track/provider/user_state.dart';
import 'package:physio_track/translations/codegen_loader.g.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'authentication/splash_screen.dart';
import 'notification/model/received_notification_model.dart';

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
