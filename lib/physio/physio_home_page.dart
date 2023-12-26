import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:physio_track/achievement/screen/physio/patient_list_by_physio_screen.dart';
import 'package:physio_track/appointment/screen/physio/appointment_schedule_screen.dart';
import 'package:physio_track/notification/api/notification_api.dart';
import 'package:physio_track/physio/physio_home_screen.dart';
import '../appointment/model/appointment_model.dart';
import '../appointment/screen/appointment_patient_screen.dart';
import '../appointment/service/appointment_service.dart';
import '../authentication/redirect_screen.dart';
import '../main.dart';
import '../notification/model/received_notification_model.dart';
import '../profile/screen/profile_screen.dart';
import '../user_management/service/user_management_service.dart';

class PhysioHomePage extends StatefulWidget {
  const PhysioHomePage({Key? key}) : super(key: key);

  @override
  State<PhysioHomePage> createState() => _PhysioHomePageState();
}

class _PhysioHomePageState extends State<PhysioHomePage>
    with TickerProviderStateMixin {
  PageController? _pageController;
  int _currentIndex = 0;
  final StreamController<ReceivedNotification>
      didReceiveLocalNotificationStream =
      StreamController<ReceivedNotification>.broadcast();

  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();
  bool _notificationsEnabled = false;
  AppointmentService appointmentService = AppointmentService();
  UserManagementService userManagementService = UserManagementService();

  List<Widget> _page = [
    PhysioHomeScreen(),
    AppointmentScheduleScreen(),
    PatientListByPhysioScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, keepPage: false);
    _isAndroidPermissionGranted();
    _requestPermissions();
    NotificationApi.init();
    // listenNotifications();
    cancelPatientNotification();
    pushAppointmentNoti();
  }

  void cancelPatientNotification() async {
    final ptNotiId = dotenv.env['PT_REMINDER'];
    final otNotiId = dotenv.env['OT_REMINDER'];
    NotificationApi.cancelNoti(id: int.parse(ptNotiId!));
    NotificationApi.cancelNoti(id: int.parse(otNotiId!));
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

  // void listenNotifications() =>
  //     NotificationApi.onNotifications.stream.listen(onClickedNotification);

  // Future<void> onClickedNotification(String? payload) async {
  //   String uid = FirebaseAuth.instance.currentUser!.uid;
  //   if (payload == 'appointment') {
  //     String role = await userManagementService.getRoleByUid(uid);
  //     if (role == 'patient') {
  //       Navigator.of(context).push(MaterialPageRoute(
  //           builder: (context) => AppointmentPatientScreen()));
  //     } else if (role == 'physio') {
  //       Navigator.of(context).push(MaterialPageRoute(
  //           builder: (context) => AppointmentScheduleScreen()));
  //     } else {
  //       Navigator.of(context)
  //           .push(MaterialPageRoute(builder: (context) => RedirectScreen()));
  //     }
  //     Navigator.of(context)
  //         .push(MaterialPageRoute(builder: (context) => RedirectScreen()));
  //   }
  // }

  void pushAppointmentNoti() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    int physioId = await userManagementService.fetchUserIdByUid(uid);
    List<Appointment> appointments = await appointmentService
        .fetchAppointmentListByPhysioIdInToday(physioId);
    if (appointments.length > 0) {
      for (Appointment appointment in appointments) {
        String formattedTime =
            DateFormat('hh:mm a').format(appointment.startTime);
        NotificationApi.showScheduledNotification(
          id: appointment.id,
          title: 'Appointment Reminder',
          body: 'You have an appointment at $formattedTime',
          payload: 'appointment',
          scheduledDate: appointment.startTime.subtract(Duration(minutes: 30)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        currentIndex: _currentIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: _navBarItems(),
        onTap: (value) {
          setState(() {
            _currentIndex = value;
            _pageController?.jumpToPage(value);
          });
        },
      ),
      body: PageView(
        controller: _pageController,
        children: _page,
        onPageChanged: (int page) {
          setState(() {
            _currentIndex = page;
          });
        },
      ),
    );
  }

  List<BottomNavigationBarItem> _navBarItems() {
    return [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month_outlined),
        label: 'Appointment',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.healing_outlined),
        label: 'Patients',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings_outlined),
        label: 'Settings',
      ),
    ];
  }
}
