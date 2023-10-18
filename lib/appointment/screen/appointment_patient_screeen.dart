import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/intl.dart';
import 'package:physio_track/appointment/screen/appointment_booking_screen.dart';
import 'package:physio_track/notification/screen/notification_list_screen.dart';

import '../../constant/ImageConstant.dart';
import '../../notification/service/notification_service.dart';
import '../model/appointment_in_pending_model.dart';
import '../service/appointment_in_pending_service.dart';
import 'appointment_history_screen.dart';
import 'appointment_update_screen.dart';

class AppointmentPatientScreen extends StatefulWidget {
  const AppointmentPatientScreen({super.key});

  @override
  State<AppointmentPatientScreen> createState() =>
      _AppointmentPatientScreenState();
}

class _AppointmentPatientScreenState extends State<AppointmentPatientScreen> {
  AppointmentInPendingService appointmentInPendingService =
      AppointmentInPendingService();
  NotificationService notificationService = NotificationService();
  String uid = FirebaseAuth.instance.currentUser!.uid;
  late AppointmentInPending latestPendingAppointment;
  bool hasRecord = false;
  bool hasUnreadNotifications = false;

  @override
  void initState() {
    super.initState();
    checkUnreadNotifications();
  }

  Future<void> _loadLatestRecord() async {
    latestPendingAppointment = await appointmentInPendingService
        .fetchLatestPendingAppointmentRecordByPatientId(uid);
    if (latestPendingAppointment.id >= 0 && latestPendingAppointment.id != -1) {
      hasRecord = true;
    }
  }

  Color _getCardBackgroundColor(bool isApproved) {
    switch (isApproved) {
      case false:
        return Color.fromARGB(255, 255, 231, 196);
      case true:
        return Color.fromARGB(255, 188, 250, 190);
      default:
        return Colors
            .white; // Default color if the status doesn't match any of the cases
    }
  }

  Color _getTextColor(bool isApproved) {
    switch (isApproved) {
      case false:
        return Color.fromRGBO(255, 165, 0, 1);
      case true:
        return Color.fromARGB(255, 13, 167, 18);
      default:
        return Colors
            .white; // Default color if the status doesn't match any of the cases
    }
  }

  String _getText(bool isApproved, String status) {
    String approveText = '';
    String statusText = '';
    switch (isApproved) {
      case true:
        approveText = 'APPROVED';
        break;
      case false:
        approveText = 'PENDING';
        break;
      default:
        approveText = '';
    }

    switch (status) {
      case 'New':
        statusText = '(N)';
        break;
      case 'Updated':
        statusText = '(U)';
        break;
      case 'Cancelled':
        statusText = '(C)';
        break;
      default:
        statusText = '';
    }

    return '$approveText $statusText';
  }

  void showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
    Function onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          titlePadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 18)),
              IconButton(
                icon: Icon(Icons.close, color: Colors.red),
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
                      backgroundColor: Color.fromRGBO(220, 241, 254, 1),
                    ),
                    child: Text('Yes',
                        style:
                            TextStyle(color: Color.fromRGBO(18, 190, 246, 1))),
                    onPressed: () async {
                      onConfirm();
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: Color.fromARGB(255, 237, 159, 153),
                    ),
                    child: Text('No',
                        style:
                            TextStyle(color: Color.fromARGB(255, 217, 24, 10))),
                    onPressed: () {
                      Navigator.of(context).pop();
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

  void showCancelConfirmationDialog(
    BuildContext context,
    bool isApproved,
    String status,
  ) {
    String title = '';
    String message = '';
    void Function() onConfirm = () {};

    if (isApproved) {
      title = 'Cancel Appointment';
      message = 'Are you sure to cancel this appointment？';
      onConfirm = () async {
        await appointmentInPendingService
            .cancelPendingAppointmentRecord(latestPendingAppointment.id);
        setState(() {});
      };
    } else if (status == 'New') {
      title = 'Cancel Appointment';
      message = 'Are you sure to cancel this appointment？';
      onConfirm = () async {
        await appointmentInPendingService
            .removeNewPendingAppointment(latestPendingAppointment.id);
        setState(() {});
      };
    } else if (status == 'Updated') {
      title = 'Cancel Appointment Update';
      message = 'Are you sure to cancel this appointment update？';
      onConfirm = () async {
        await appointmentInPendingService
            .removeUpdatedPendingAppointmentRecordByUser(
                latestPendingAppointment.id);
        setState(() {});
      };
    } else if (status == 'Cancelled') {
      title = 'Undo Cancel Appointment';
      message = 'Are you sure to undo this appointment cancellation？';
      onConfirm = () async {
        await appointmentInPendingService
            .removeCancelPendingAppointmentRecordByUser(
                latestPendingAppointment.id);
        setState(() {});
      };
    }

    showConfirmationDialog(context, title, message, onConfirm);
  }

  Future<void> checkUnreadNotifications() async {
    final notifications = await notificationService.fetchNotificationList(uid);
    final unreadNotifications =
        notifications.where((notification) => !notification.isRead).toList();
    setState(() {
      hasUnreadNotifications = unreadNotifications.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<void>(
      future: _loadLatestRecord(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.done && hasRecord) {
          return buildAppointmentWidget();
        } else if (snapshot.connectionState == ConnectionState.done &&
            hasRecord == false) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 220,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Appointment Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            15.0), // Adjust the radius as needed
                        child: Container(
                          height: 120,
                          child: Card(
                            color: Color.fromARGB(255, 255, 196, 196),
                            elevation: 5.0,
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Icon(Icons.error,
                                      color: Colors.red, size: 50.0),
                                  Center(
                                    child: Text(
                                      'No Record',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Appointment Booking',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: latestPendingAppointment.startTime
                              .isAfter(DateTime.now())
                          ? IgnorePointer(
                              ignoring: true,
                              child: Card(
                                color: Colors.blue.shade100,
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Container(
                                    height:
                                        150.0, // Adjust the height as needed
                                    width: double.infinity,
                                    child: Image.asset(
                                      ImageConstant.APPOINTMENT,
                                      // fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AppointmentBookingScreen(),
                                  ),
                                );
                              },
                              child: Card(
                                color: Colors.blue.shade100,
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Container(
                                    height:
                                        150.0, // Adjust the height as needed
                                    width: double.infinity,
                                    child: Image.asset(
                                      ImageConstant.APPOINTMENT,
                                      // fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Appointment History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AppointmentHistoryScreen(uid: uid),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.blue.shade100,
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: Container(
                              height: 150.0, // Adjust the height as needed
                              width: double.infinity,
                              child: Image.asset(
                                ImageConstant.APPOINTMENT_HISTORY,
                                // fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                top: 50,
                right: 0,
                child: Image.asset(
                  ImageConstant.SCHEDULE,
                  width: 200.0,
                  height: 200.0,
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
                    Navigator.pop(context);
                  },
                ),
              ),
              Positioned(
                top: 25,
                right: 0,
                child: Stack(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.notifications_outlined,
                        size: 35.0,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationListScreen(),
                          ),
                        );
                      },
                    ),
                    if (hasUnreadNotifications)
                      Positioned(
                        right: 5,
                        top: 5,
                        child: Container(
                          width: 10, // Adjust the size as needed
                          height: 10, // Adjust the size as needed
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                        ),
                      ),
                  ],
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
                    'Appointment',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 125,
                left: 25,
                child: Text('Planning',
                    style:
                        TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold)),
              ),
              Positioned(
                top: 160,
                left: 50,
                child: Text('appointment schedule',
                    style: TextStyle(fontSize: 15.0)),
              ),
            ],
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    ));
  }

  Widget buildAppointmentWidget() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 220,
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Appointment Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          15.0), // Adjust the radius as needed
                      child: Card(
                        color: _getCardBackgroundColor(
                            latestPendingAppointment.isApproved),
                        elevation: 5.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getText(
                                          latestPendingAppointment.isApproved,
                                          latestPendingAppointment.status,
                                        ),
                                        style: TextStyle(
                                          color: _getTextColor(
                                              latestPendingAppointment
                                                  .isApproved),
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          DateFormat('jm').format(
                                                  latestPendingAppointment
                                                      .startTime) +
                                              DateFormat(', dd MMM').format(
                                                  latestPendingAppointment
                                                      .startTime),
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              // Conditionally show the "Update" button
                              visible: latestPendingAppointment.isApproved,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AppointmentUpdateScreen(
                                                  appointmentId:
                                                      latestPendingAppointment
                                                          .id,
                                                  appointmentDate:
                                                      latestPendingAppointment
                                                          .startTime,
                                                ),
                                              ),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor: Color.fromARGB(
                                                255, 179, 209, 235),
                                            primary: Colors.white,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.update,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(width: 10.0),
                                              Text(
                                                "Update",
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                        child: TextButton(
                                          onPressed: () {
                                            showCancelConfirmationDialog(
                                              context,
                                              latestPendingAppointment
                                                  .isApproved,
                                              latestPendingAppointment.status,
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor: Color.fromARGB(
                                                255, 241, 163, 157),
                                            primary: Colors.white,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.cancel,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 10.0),
                                              Text(
                                                "Cancel",
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Visibility(
                              // Conditionally show the "Update" button
                              visible: !latestPendingAppointment.isApproved,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                        child: TextButton(
                                          onPressed: () {
                                            showCancelConfirmationDialog(
                                              context,
                                              latestPendingAppointment
                                                  .isApproved,
                                              latestPendingAppointment.status,
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor: Color.fromARGB(
                                                255, 241, 163, 157),
                                            primary: Colors.white,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.cancel,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 10.0),
                                              Text(
                                                "Cancel",
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Appointment Booking',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: latestPendingAppointment.startTime
                            .isAfter(DateTime.now())
                        ? IgnorePointer(
                            ignoring: true,
                            child: Card(
                              color: Colors.grey.shade400,
                              //elevation: 5.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Container(
                                  height: 150.0, // Adjust the height as needed
                                  width: double.infinity,
                                  child: Image.asset(
                                    ImageConstant.APPOINTMENT_GREY,
                                    // fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AppointmentBookingScreen(),
                                ),
                              );
                            },
                            child: Card(
                              color: Colors.blue.shade100,
                              elevation: 5.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Container(
                                  height: 150.0, // Adjust the height as needed
                                  width: double.infinity,
                                  child: Image.asset(
                                    ImageConstant.APPOINTMENT,
                                    // fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Appointment History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AppointmentHistoryScreen(uid: uid),
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.blue.shade100,
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Container(
                            height: 150.0, // Adjust the height as needed
                            width: double.infinity,
                            child: Image.asset(
                              ImageConstant.APPOINTMENT_HISTORY,
                              // fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        Positioned(
          top: 50,
          right: 0,
          child: Image.asset(
            ImageConstant.SCHEDULE,
            width: 200.0,
            height: 200.0,
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
              Navigator.pop(context);
            },
          ),
        ),
        Positioned(
          top: 25,
          right: 0,
          child: Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  size: 35.0,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationListScreen(),
                    ),
                  );
                },
              ),
              if (hasUnreadNotifications)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    width: 10, // Adjust the size as needed
                    height: 10, // Adjust the size as needed
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
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
              'Appointment',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Positioned(
          top: 125,
          left: 25,
          child: Text('Planning',
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold)),
        ),
        Positioned(
          top: 160,
          left: 50,
          child: Text('appointment schedule', style: TextStyle(fontSize: 15.0)),
        ),
      ],
    );
  }
}
