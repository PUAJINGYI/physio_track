import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:physio_track/appointment/screen/appointment_booking_screen.dart';

import '../../constant/ColorConstant.dart';
import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../../translations/locale_keys.g.dart';
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
  String uid = FirebaseAuth.instance.currentUser!.uid;
  AppointmentInPending latestPendingAppointment = AppointmentInPending(
      id: -1,
      title: '',
      date: DateTime(2000, 1, 1),
      startTime: DateTime(2000, 1, 1),
      endTime: DateTime(
        2000,
        1,
        1,
      ),
      durationInSecond: 0,
      status: '',
      isApproved: false,
      patientId: 0,
      physioId: 0,
      eventId: '');
  bool hasRecord = false;
  bool hasUnreadNotifications = false;
  final DateTime defaultDate = DateTime(2000, 1, 1);

  @override
  void initState() {
    super.initState();
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
        return ColorConstant.GREEN_BUTTON_UNPRESSED;
      default:
        return Colors
            .white; 
    }
  }

  Color _getTextColor(bool isApproved) {
    switch (isApproved) {
      case false:
        return Color.fromRGBO(255, 165, 0, 1);
      case true:
        return ColorConstant.GREEN_BUTTON_TEXT;
      default:
        return Colors
            .white;
    }
  }

  String _getText(bool isApproved, String status) {
    String approveText = '';
    String statusText = '';
    switch (isApproved) {
      case true:
        approveText = LocaleKeys.APPROVED.tr();
        break;
      case false:
        approveText = LocaleKeys.PENDING.tr();
        break;
      default:
        approveText = '';
    }

    switch (status) {
      case TextConstant.NEW:
        statusText = LocaleKeys.N.tr();
        break;
      case TextConstant.UPDATED:
        statusText = LocaleKeys.U.tr();
        break;
      case TextConstant.CANCELLED:
        statusText = LocaleKeys.C.tr();
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
                    child: Text(LocaleKeys.Yes.tr(),
                        style:
                            TextStyle(color: ColorConstant.BLUE_BUTTON_TEXT)),
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
                      backgroundColor: ColorConstant.RED_BUTTON_UNPRESSED,
                    ),
                    child: Text(LocaleKeys.No.tr(),
                        style: TextStyle(color: ColorConstant.RED_BUTTON_TEXT)),
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
      title = LocaleKeys.Cancel_Appointment.tr();
      message = LocaleKeys.are_you_sure_cancel_appointment.tr();
      onConfirm = () async {
        await appointmentInPendingService
            .cancelPendingAppointmentRecord(latestPendingAppointment.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocaleKeys
                .Cancel_appointment_request_is_sent_to_admin_successfully.tr()),
          ),
        );
        setState(() {});
      };
    } else if (status == TextConstant.NEW) {
      title = LocaleKeys.Cancel_Appointment.tr();
      message = LocaleKeys.are_you_sure_cancel_appointment.tr();
      onConfirm = () async {
        await appointmentInPendingService.removeNewPendingAppointment(
            latestPendingAppointment.id, context);
        setState(() {});
      };
    } else if (status == TextConstant.UPDATED) {
      title = LocaleKeys.Cancel_Appointment_Update.tr();
      message = LocaleKeys.are_you_sure_cancel_appointment_update.tr();
      onConfirm = () async {
        await appointmentInPendingService
            .removeUpdatedPendingAppointmentRecordByUser(
                latestPendingAppointment.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocaleKeys.Pending_Update_Appointment_Removed.tr()),
          ),
        );
        setState(() {});
      };
    } else if (status == TextConstant.CANCELLED) {
      title = LocaleKeys.Undo_Cancel_Appointment.tr();
      message = LocaleKeys.are_you_sure_undo_appointment_cancellation.tr();
      onConfirm = () async {
        await appointmentInPendingService
            .removeCancelPendingAppointmentRecordByUser(
                latestPendingAppointment.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocaleKeys
                .Pending_appointment_cancellation_request_is_removed.tr()),
          ),
        );
        setState(() {});
      };
    }

    showConfirmationDialog(context, title, message, onConfirm);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<void>(
      future: _loadLatestRecord(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            hasRecord &&
            !DateTime(
                    latestPendingAppointment.startTime.year,
                    latestPendingAppointment.startTime.month,
                    latestPendingAppointment.startTime.day)
                .isAtSameMomentAs(defaultDate)) {
          return buildAppointmentWidget();
        } else if ((snapshot.connectionState == ConnectionState.done &&
                hasRecord == false) ||
            DateTime(
                    latestPendingAppointment.startTime.year,
                    latestPendingAppointment.startTime.month,
                    latestPendingAppointment.startTime.day)
                .isAtSameMomentAs(defaultDate)) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 200,
                    ),
                    Expanded(
                        child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: 1,
                            itemBuilder: (BuildContext context, int index) {
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        LocaleKeys.Appointment_Status.tr(),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          15.0), 
                                      child: Container(
                                        height: 120,
                                        child: Card(
                                          color: Color.fromARGB(
                                              255, 255, 196, 196),
                                          elevation: 5.0,
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Column(
                                              children: [
                                                Icon(Icons.error,
                                                    color: ColorConstant
                                                        .RED_BUTTON_TEXT,
                                                    size: 50.0),
                                                Center(
                                                  child: Text(
                                                    LocaleKeys.No_Record.tr(),
                                                    style: TextStyle(
                                                      color: ColorConstant
                                                          .RED_BUTTON_TEXT,
                                                      fontSize: 20.0,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                        LocaleKeys.Appointment_Booking.tr(),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                    child: latestPendingAppointment.startTime
                                            .isAfter(DateTime.now())
                                        ? IgnorePointer(
                                            ignoring: true,
                                            child: Card(
                                              color: Colors.blue.shade100,
                                              elevation: 5.0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                                child: Container(
                                                  height:
                                                      150.0, 
                                                  width: double.infinity,
                                                  child: Image.asset(
                                                    ImageConstant.APPOINTMENT,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () async {
                                              final needUpdate =
                                                  await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AppointmentBookingScreen(),
                                                ),
                                              );

                                              if (needUpdate != null &&
                                                  needUpdate) {
                                                setState(() {});
                                              }
                                            },
                                            child: Card(
                                              color: Colors.blue.shade100,
                                              elevation: 5.0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                                child: Container(
                                                  height:
                                                      150.0, 
                                                  width: double.infinity,
                                                  child: Image.asset(
                                                    ImageConstant.APPOINTMENT,
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
                                        LocaleKeys.Appointment_History.tr(),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AppointmentHistoryScreen(
                                                    uid: uid),
                                          ),
                                        );
                                      },
                                      child: Card(
                                        color: Colors.blue.shade100,
                                        elevation: 5.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          child: Container(
                                            height:
                                                150.0, 
                                            width: double.infinity,
                                            child: Image.asset(
                                              ImageConstant.APPOINTMENT_HISTORY,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }))
                  ],
                ),
              ),
              Positioned(
                top: 50,
                right: 5,
                child: Image.asset(
                  ImageConstant.SCHEDULE,
                  width: 170.0,
                  height: 170.0,
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
                    LocaleKeys.Appointment.tr(),
                    style: TextStyle(
                      fontSize: TextConstant.TITLE_FONT_SIZE,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 125,
                left: 25,
                child: Text(LocaleKeys.Planning.tr(),
                    style:
                        TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold)),
              ),
              Positioned(
                top: 160,
                left: 50,
                child: Text(LocaleKeys.appointment_schedule.tr(),
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
                height: 200,
              ),
              Expanded(
                  child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: 1,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  LocaleKeys.Appointment_Status.tr(),
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
                                    15.0),
                                child: Card(
                                  color: _getCardBackgroundColor(
                                      latestPendingAppointment.isApproved),
                                  elevation: 5.0,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                                                    latestPendingAppointment
                                                        .isApproved,
                                                    latestPendingAppointment
                                                        .status,
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
                                                  const EdgeInsets.fromLTRB(
                                                      0, 20, 0, 0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    DateFormat('jm').format(
                                                            latestPendingAppointment
                                                                .startTime) +
                                                        DateFormat(', dd MMM')
                                                            .format(
                                                                latestPendingAppointment
                                                                    .startTime),
                                                    style: TextStyle(
                                                      fontSize: 20.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Visibility(
                                        visible:
                                            latestPendingAppointment.isApproved,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              16, 0, 16, 8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.0),
                                                  child: TextButton(
                                                    onPressed: () async {
                                                      final needUpdate =
                                                          await Navigator.push(
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

                                                      if (needUpdate != null &&
                                                          needUpdate) {
                                                        setState(() {});
                                                      }
                                                    },
                                                    style: TextButton.styleFrom(
                                                      backgroundColor: ColorConstant
                                                          .BLUE_BUTTON_UNPRESSED,
                                                      primary: Colors.white,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.update,
                                                          color: ColorConstant
                                                              .BLUE_BUTTON_TEXT,
                                                        ),
                                                        SizedBox(width: 10.0),
                                                        Text(
                                                          LocaleKeys.Update
                                                              .tr(),
                                                          style: TextStyle(
                                                            fontSize: 15.0,
                                                            color: ColorConstant
                                                                .BLUE_BUTTON_TEXT,
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
                                                      BorderRadius.circular(
                                                          25.0),
                                                  child: TextButton(
                                                    onPressed: () {
                                                      showCancelConfirmationDialog(
                                                        context,
                                                        latestPendingAppointment
                                                            .isApproved,
                                                        latestPendingAppointment
                                                            .status,
                                                      );
                                                    },
                                                    style: TextButton.styleFrom(
                                                      backgroundColor:
                                                          Color.fromARGB(255,
                                                              241, 163, 157),
                                                      primary: Colors.white,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.cancel,
                                                          color: ColorConstant
                                                              .RED_BUTTON_TEXT,
                                                        ),
                                                        SizedBox(width: 10.0),
                                                        Text(
                                                          LocaleKeys.Cancel
                                                              .tr(),
                                                          style: TextStyle(
                                                            fontSize: 15.0,
                                                            color: ColorConstant
                                                                .RED_BUTTON_TEXT,
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
                                        visible: !latestPendingAppointment
                                            .isApproved,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              16, 0, 16, 8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.0),
                                                  child: TextButton(
                                                    onPressed: () {
                                                      showCancelConfirmationDialog(
                                                        context,
                                                        latestPendingAppointment
                                                            .isApproved,
                                                        latestPendingAppointment
                                                            .status,
                                                      );
                                                    },
                                                    style: TextButton.styleFrom(
                                                      backgroundColor:
                                                          Color.fromARGB(255,
                                                              241, 163, 157),
                                                      primary: Colors.white,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.cancel,
                                                          color: ColorConstant
                                                              .RED_BUTTON_TEXT,
                                                        ),
                                                        SizedBox(width: 10.0),
                                                        Text(
                                                          LocaleKeys.Cancel
                                                              .tr(),
                                                          style: TextStyle(
                                                            fontSize: 15.0,
                                                            color: ColorConstant
                                                                .RED_BUTTON_TEXT,
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
                                  LocaleKeys.Appointment_Booking.tr(),
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
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          child: Container(
                                            height:
                                                150.0, 
                                            width: double.infinity,
                                            child: Image.asset(
                                              ImageConstant.APPOINTMENT_GREY,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () async {
                                        final needUpdate = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AppointmentBookingScreen(),
                                          ),
                                        );

                                        if (needUpdate != null && needUpdate) {
                                          setState(() {});
                                        }
                                      },
                                      child: Card(
                                        color: Colors.blue.shade100,
                                        elevation: 5.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          child: Container(
                                            height:
                                                150.0,
                                            width: double.infinity,
                                            child: Image.asset(
                                              ImageConstant.APPOINTMENT,
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
                                  LocaleKeys.Appointment_History.tr(),
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
                                      height:
                                          150.0,
                                      width: double.infinity,
                                      child: Image.asset(
                                        ImageConstant.APPOINTMENT_HISTORY,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }))
            ],
          ),
        ),
        Positioned(
          top: 50,
          right: 20,
          child: Image.asset(
            ImageConstant.SCHEDULE,
            width: 160.0,
            height: 160.0,
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
              LocaleKeys.Appointment.tr(),
              style: TextStyle(
                fontSize: TextConstant.TITLE_FONT_SIZE,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Positioned(
          top: 125,
          left: 25,
          child: Text(LocaleKeys.Planning.tr(),
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold)),
        ),
        Positioned(
          top: 160,
          left: 50,
          child: Text(LocaleKeys.appointment_schedule.tr(),
              style: TextStyle(fontSize: 15.0)),
        ),
      ],
    );
  }
}
