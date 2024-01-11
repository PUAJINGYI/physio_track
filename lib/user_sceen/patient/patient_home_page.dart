import 'dart:async';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:physio_track/achievement/screen/progress_screen.dart';
import 'package:physio_track/journal/screen/view_journal_list_screen.dart';
import 'package:physio_track/user_sceen/patient/patient_home_screen.dart';

import '../../appointment/model/appointment_model.dart';
import '../../appointment/screen/appointment_patient_screen.dart';
import '../../appointment/service/appointment_service.dart';
import '../../main.dart';
import '../../notification/api/notification_api.dart';
import '../../notification/model/received_notification_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../profile/screen/profile_screen.dart';
import '../../user_management/service/user_management_service.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({Key? key}) : super(key: key);

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  List<Widget>? _page;
  List<BottomNavigationBarItem>? _navBarItems;
  BottomNavigationBar? bottomNavBar;
  final StreamController<ReceivedNotification>
      didReceiveLocalNotificationStream =
      StreamController<ReceivedNotification>.broadcast();

  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();
  bool _notificationsEnabled = false;
  AppointmentService appointmentService = AppointmentService();
  UserManagementService userManagementService = UserManagementService();

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _updateTabs();
      print('hello $_currentIndex');
    });
  }

  _updateTabs() {
    _page = [
      PatientHomeScreen(uniqueKey: UniqueKey()),
      ProgressScreen(uniqueKey: UniqueKey()),
      const ViewJournalListScreen(),
      const AppointmentPatientScreen(),
      const ProfileScreen(),
    ];

    _navBarItems = const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        label: "Home",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.pie_chart_outline),
        label: 'Progress',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.book_outlined),
        label: 'Journal',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month_outlined),
        label: 'Appointment',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings_outlined),
        label: 'Settings',
      ),
    ];

    bottomNavBar = BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.black,
      currentIndex: _currentIndex,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: _navBarItems!,
      onTap: _onItemTapped,
    );
  }

  @override
  void initState() {
    _updateTabs();
    super.initState();
    _isAndroidPermissionGranted();
    _requestPermissions();
    NotificationApi.init();
    pushNotiForPatient();
    pushAppointmentNoti();
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;

      setState(() {
        _notificationsEnabled = granted;
      });
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();
      setState(() {
        _notificationsEnabled = grantedNotificationPermission ?? false;
      });
    }
  }

  void pushNotiForPatient() {
    final ptNotiId = dotenv.env['PT_REMINDER'];
    NotificationApi.periodicallyPushNoti(
      id: int.parse(ptNotiId!),
      title: 'Physiotherapy Reminder',
      body: 'Please complete your Physiotherapy Activities for today',
      payload: 'pt',
      interval: RepeatInterval.daily,
    );

    final otNotiId = dotenv.env['OT_REMINDER'];
    NotificationApi.periodicallyPushNoti(
      id: int.parse(otNotiId!),
      title: 'Occupational Therapy Reminder',
      body: 'Please complete your Occupational Therapy Activities for today',
      payload: 'ot',
      interval: RepeatInterval.daily,
    );
  }

  void pushAppointmentNoti() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    int patientId = await userManagementService.fetchUserIdByUid(uid);
    Appointment? appointment =
        await appointmentService.fetchLatestAppointmentByPatientId(patientId);
    if (appointment != null) {
      DateTime appointmentDate = appointment.startTime;
      String formattedTime = DateFormat('hh:mm a').format(appointmentDate);

      NotificationApi.showScheduledNotification(
          id: appointment.id,
          title: 'Appointment Reminder',
          body: 'You have an appointment at ${formattedTime}',
          payload: 'appointment',
          scheduledDate: appointmentDate.subtract(Duration(minutes: 30)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomNavBar,
      body: _page![_currentIndex],
    );
  }
}
