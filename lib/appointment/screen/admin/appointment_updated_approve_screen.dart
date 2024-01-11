import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../constant/ColorConstant.dart';
import '../../../constant/ImageConstant.dart';
import '../../../translations/locale_keys.g.dart';
import '../../../user_management/service/user_management_service.dart';
import '../../model/appointment_in_pending_model.dart';
import '../../service/appointment_in_pending_service.dart';

class AppointmentUpdatedApproveScreen extends StatefulWidget {
  const AppointmentUpdatedApproveScreen({super.key});

  @override
  State<AppointmentUpdatedApproveScreen> createState() =>
      _AppointmentUpdatedApproveScreenState();
}

class _AppointmentUpdatedApproveScreenState
    extends State<AppointmentUpdatedApproveScreen> {
  AppointmentInPendingService appointmentInPendingService =
      AppointmentInPendingService();
  UserManagementService userManagementService = UserManagementService();
  late Future<List<AppointmentInPending>> _newAppointmentList;
  late String patientName;
  late String physioName;

  @override
  void initState() {
    super.initState();
    _newAppointmentList = _fetchAppointmentList();
  }

  Future<List<AppointmentInPending>> _fetchAppointmentList() async {
    return appointmentInPendingService
        .fetchAllUpdatedPendingAppointmentRecord();
  }

  Future<String> _getUsernameById(int id) async {
    return userManagementService.getUsernameById(id);
  }

  void showRejectConfirmationDialog(BuildContext context, int appointmentId) {
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
              Text(LocaleKeys.Reject_Appointment.tr()),
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
              LocaleKeys.are_you_sure_reject_appointment.tr(),
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
                      await appointmentInPendingService
                          .rejectUpdatePendingAppointmentRecord(appointmentId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(LocaleKeys.Update_appointment_request_is_rejected.tr()),
                          duration: Duration(seconds: 3),
                        ),
                      );
                      Navigator.pop(context);
                      setState(() {
                        _newAppointmentList = _fetchAppointmentList();
                      });
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

  void showAppproveConfirmationDialog(BuildContext context, int appointmentId) {
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
              Text(LocaleKeys.Approve_Appointment.tr()),
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
              LocaleKeys.are_you_sure_approve_appointment.tr(),
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
                      bool isApproved = await appointmentInPendingService
                          .checkIfUpdateAppointmentSlotExist(appointmentId);
                      if (!isApproved) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              contentPadding:
                                  EdgeInsets.zero, 
                              titlePadding: EdgeInsets.fromLTRB(
                                  16, 0, 16, 0), 
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(LocaleKeys.Error.tr()),
                                  IconButton(
                                    icon: Icon(Icons.close,
                                        color: ColorConstant.RED_BUTTON_TEXT),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); 
                                    },
                                  ),
                                ],
                              ),
                              content: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  LocaleKeys.Appointment_slot_not_available
                                      .tr(),
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
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          backgroundColor: ColorConstant
                                              .BLUE_BUTTON_UNPRESSED,
                                        ),
                                        child: Text(LocaleKeys.OK.tr(),
                                            style: TextStyle(
                                                color: ColorConstant
                                                    .BLUE_BUTTON_TEXT)),
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
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                LocaleKeys.Appointment_has_been_approved.tr()),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                      Navigator.pop(context);
                      setState(() {
                        _newAppointmentList = _fetchAppointmentList();
                      });
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

  String shortenUsername(String fullName) {
    List<String> parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts.first}';
    } else {
      return fullName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AppointmentInPending>>(
        future: _newAppointmentList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('${LocaleKeys.Error.tr()}: ${snapshot.error}'));
          }
          if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: 100.0,
                      height: 100.0,
                      child: Image.asset(
                        ImageConstant.DATA_NOT_FOUND,
                      )),
                  Text(LocaleKeys.No_Record_Found.tr(),
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }
          if (snapshot.hasData) {
            List<AppointmentInPending> appointments = snapshot.data!;
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children:
                        appointments.map((AppointmentInPending appointment) {
                      return Card(
                        color: Color.fromRGBO(250, 231, 209, 1),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.event,
                                  color: Colors.black,
                                  size: 50.0,
                                ),
                              ),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            DateFormat('dd MMM yyyy')
                                                .format(appointment.startTime),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 20,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('hh:mm a')
                                                .format(appointment.startTime),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 30,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.medical_services,
                                                color: Colors.black,
                                                size: 20.0,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              FutureBuilder<String>(
                                                future: _getUsernameById(
                                                    appointment.physioId),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return CircularProgressIndicator();
                                                  }
                                                  if (snapshot.hasError) {
                                                    return Text(
                                                        '${LocaleKeys.Error.tr()}: ${snapshot.error}');
                                                  }
                                                  if (snapshot.hasData) {
                                                    String username =
                                                        snapshot.data!;
                                                    return Text(shortenUsername(
                                                        username));
                                                  }
                                                  return Container();
                                                },
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.person,
                                                color: Colors.black,
                                                size: 20.0,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              FutureBuilder<String>(
                                                future: _getUsernameById(
                                                    appointment.patientId),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return CircularProgressIndicator();
                                                  }
                                                  if (snapshot.hasError) {
                                                    return Text(
                                                        '${LocaleKeys.Error.tr()}: ${snapshot.error}');
                                                  }
                                                  if (snapshot.hasData) {
                                                    String username =
                                                        snapshot.data!;
                                                    return Text(shortenUsername(
                                                        username));
                                                  }
                                                  return Container();
                                                },
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              25.0), 
                                          child: TextButton(
                                            onPressed: () {
                                              showAppproveConfirmationDialog(
                                                  context, appointment.id);
                                            },
                                            style: TextButton.styleFrom(
                                              backgroundColor: ColorConstant
                                                  .GREEN_BUTTON_UNPRESSED, 
                                              primary:
                                                  Colors.white, 
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons
                                                      .check_circle_outlined, 
                                                  color: ColorConstant
                                                      .GREEN_BUTTON_TEXT,
                                                ),
                                                SizedBox(width: 10.0),
                                                Text(
                                                  LocaleKeys.Approve.tr(),
                                                  style: TextStyle(
                                                    fontSize:
                                                        15.0, 
                                                    color: ColorConstant
                                                        .GREEN_BUTTON_TEXT,
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
                                          borderRadius: BorderRadius.circular(
                                              25.0), 
                                          child: TextButton(
                                            onPressed: () {
                                              showRejectConfirmationDialog(
                                                  context, appointment.id);
                                            },
                                            style: TextButton.styleFrom(
                                              backgroundColor: ColorConstant
                                                  .RED_BUTTON_UNPRESSED,
                                              primary:
                                                  Colors.white,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons
                                                      .cancel_outlined, 
                                                  color: ColorConstant
                                                      .RED_BUTTON_TEXT, 
                                                ),
                                                SizedBox(
                                                    width:
                                                        10.0), 
                                                Text(
                                                  LocaleKeys.Reject.tr(),
                                                  style: TextStyle(
                                                    fontSize:
                                                        15.0,
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
                                ],
                              )),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          }
          return Container();
        });
  }
}
