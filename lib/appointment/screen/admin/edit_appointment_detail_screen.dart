import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/intl.dart';
import 'package:physio_track/reusable_widget/reusable_widget.dart';

import '../../../constant/ColorConstant.dart';
import '../../../constant/ImageConstant.dart';
import '../../../constant/TextConstant.dart';
import '../../../notification/service/notification_service.dart';
import '../../../profile/model/user_model.dart';
import '../../../translations/locale_keys.g.dart';
import '../../../user_management/service/user_management_service.dart';
import '../../model/appointment_in_pending_model.dart';
import '../../service/appointment_in_pending_service.dart';
import '../../service/appointment_service.dart';

class EditAppointmentDetailScreen extends StatefulWidget {
  final int appointmentInPendingId;
  const EditAppointmentDetailScreen(
      {super.key, required this.appointmentInPendingId});

  @override
  State<EditAppointmentDetailScreen> createState() =>
      _EditAppointmentDetailScreenState();
}

class _EditAppointmentDetailScreenState
    extends State<EditAppointmentDetailScreen> {
  late AppointmentInPending appointmentInPending = new AppointmentInPending(
      id: -1,
      title: '',
      date: DateTime.now(),
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      durationInSecond: 0,
      status: TextConstant.NEW,
      isApproved: true,
      patientId: -1,
      physioId: -1,
      eventId: '');
  late List<UserModel> physioAvailableList = [];
  UserModel? originalPhysio;
  UserModel? selectedUser;
  bool isSelectionEmpty = false;
  AppointmentInPendingService _appointmentInPendingService =
      AppointmentInPendingService();
  AppointmentService _appointmentService = AppointmentService();
  UserManagementService _userManagementService = UserManagementService();
  NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    fetchAppointmentInPendingDetail();
  }

  Future<void> fetchAppointmentInPendingDetail() async {
    final appointment = await _appointmentInPendingService
        .fetchPendingAppointmentById(widget.appointmentInPendingId);
    if (appointment != null) {
      setState(() {
        appointmentInPending = appointment;
      });

      final physioAvailable =
          await _appointmentService.fetchAvailablePhysioListAtTime(
              appointment.startTime, appointment.endTime);
      setState(() {
        physioAvailableList = physioAvailable;
      });

      final originalPhysio =
          await _userManagementService.fecthUserById(appointment.physioId);
      for (UserModel physio in physioAvailableList) {
        if (physio.id == originalPhysio.id) {
          setState(() {
            selectedUser = physio;
          });
        }
      }
    }
  }

  Future<void> performAppointmentUpdate(
      AppointmentInPending appointmentInPending, int oriPhysioId) async {
    String patientUid = await _userManagementService
        .fetchUidByUserId(appointmentInPending.patientId);
    String oriPhysioUid =
        await _userManagementService.fetchUidByUserId(oriPhysioId);
    String newPhysioName = await _userManagementService
        .getUsernameById(appointmentInPending.physioId);

    notificationService.addNotificationFromAdmin(
        patientUid,
        LocaleKeys.Physiotherapist_Incharged_Changed.tr(),
        'Dear patient, your recent appointment booking request for ${DateFormat('hh:mm a').format(appointmentInPending.startTime)}, ${DateFormat('dd MMM yyyy').format(appointmentInPending.startTime)} has been change the physiotherapist to ${newPhysioName}. Please remember to attend the appointment on that selected time slot. Thank you.');
    notificationService.addNotificationFromAdmin(
        oriPhysioUid,
        LocaleKeys.Physiotherapist_Incharged_Changed.tr(),
        'Dear physio, there is a new appointment on ${DateFormat('hh:mm a').format(appointmentInPending.startTime)}, ${DateFormat('dd MMM yyyy').format(appointmentInPending.startTime)} has been change to ${newPhysioName} due to you are not available on that time.');
    await _appointmentInPendingService.handleConflictUpdateAppointmentSlotExist(
        appointmentInPending, oriPhysioId);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 230,
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        Card(
                          color: Colors.blue[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_month_outlined,
                                  size: 50,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  DateFormat('dd MMM yyyy').format(
                                      appointmentInPending
                                          .date), // Display the date
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Card(
                            color: Colors.blue[50],
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Icon(Icons.schedule_outlined, size: 50),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    DateFormat('hh:mm a').format(
                                        appointmentInPending
                                            .startTime), // Display the start time
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        SizedBox(
                          height: 10,
                        ),
                        Card(
                          color: Colors.blue[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(Icons.medical_services_outlined, size: 50),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: DropdownButtonFormField<UserModel>(
                                    value: selectedUser,
                                    hint: Text(selectedUser?.username ?? ''),
                                    onChanged: (UserModel? newValue) {
                                      setState(() {
                                        selectedUser = newValue;
                                        isSelectionEmpty = false;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null) {
                                        return LocaleKeys
                                                .Please_select_a_physiotherapist
                                            .tr();
                                      }
                                      return null;
                                    },
                                    items: physioAvailableList
                                        .map((UserModel user) {
                                      return DropdownMenuItem<UserModel>(
                                        value: user,
                                        child: Text(user.username),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Card(
                          color: Colors.blue[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(Icons.person_outline, size: 50),
                                SizedBox(
                                  width: 20,
                                ),
                                FutureBuilder<String>(
                                  future:
                                      _userManagementService.getUsernameById(
                                          appointmentInPending.patientId),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<String> snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      // While the Future is still running, show a loading indicator.
                                      return CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      // If an error occurred, you can handle it here.
                                      return Text(
                                          '${LocaleKeys.Error.tr()}: ${snapshot.error}');
                                    } else {
                                      // When the Future is complete, display the patient's name.
                                      return Text(
                                        snapshot.data ??
                                            'N/A', // Display the patient name or 'N/A' if not available
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                            height: 110, ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              0,
                              TextConstant.CUSTOM_BUTTON_TB_PADDING,
                              0,
                              TextConstant.CUSTOM_BUTTON_TB_PADDING),
                          child: customButton(
                              context,
                              LocaleKeys.Update_Approve.tr(),
                              ColorConstant.BLUE_BUTTON_TEXT,
                              ColorConstant.BLUE_BUTTON_UNPRESSED,
                              ColorConstant.BLUE_BUTTON_PRESSED, () async {
                            String patientUsername =
                                await _userManagementService.getUsernameById(
                                    appointmentInPending.patientId);
                            String physioUsername = await _userManagementService
                                .getUsernameById(selectedUser!.id);
                            String newTitle =
                                '[Appointment] ${patientUsername} with ${physioUsername}';
                            int oriPhysioId = appointmentInPending.physioId;
                            AppointmentInPending appointment =
                                new AppointmentInPending(
                                    id: appointmentInPending.id,
                                    title: newTitle,
                                    date: appointmentInPending.date,
                                    startTime: appointmentInPending.startTime,
                                    endTime: appointmentInPending.endTime,
                                    durationInSecond:
                                        appointmentInPending.durationInSecond,
                                    status: appointmentInPending.status,
                                    isApproved: appointmentInPending.isApproved,
                                    patientId: appointmentInPending.patientId,
                                    physioId: selectedUser!.id,
                                    eventId: appointmentInPending.eventId);
                            if (selectedUser == null) {
                              setState(() {
                                isSelectionEmpty = true;
                              });
                            } else {
                              await performAppointmentUpdate(
                                  appointment, oriPhysioId);
                            }
                          }),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              )),
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
                LocaleKeys.Edit_Appointment.tr(),
                style: TextStyle(
                  fontSize: TextConstant.TITLE_FONT_SIZE,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 60,
            right: 0,
            left: 0,
            child: Image.asset(
              ImageConstant.APPOINTMENT,
              width: 190.0,
              height: 190.0,
            ),
          ),
        ],
      ),
    );
  }
}
