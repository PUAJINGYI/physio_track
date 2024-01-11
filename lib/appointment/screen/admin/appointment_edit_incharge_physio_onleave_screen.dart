import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../constant/ColorConstant.dart';
import '../../../constant/ImageConstant.dart';
import '../../../translations/locale_keys.g.dart';
import '../../../user_management/service/user_management_service.dart';
import '../../model/appointment_in_pending_model.dart';
import '../../service/appointment_in_pending_service.dart';
import '../../service/appointment_service.dart';
import 'edit_appointment_detail_screen.dart';

class AppointmentEditInChargePhysioOnLeaveScreen extends StatefulWidget {
  const AppointmentEditInChargePhysioOnLeaveScreen({super.key});

  @override
  State<AppointmentEditInChargePhysioOnLeaveScreen> createState() =>
      _AppointmentEditInChargePhysioOnLeaveScreenState();
}

class _AppointmentEditInChargePhysioOnLeaveScreenState
    extends State<AppointmentEditInChargePhysioOnLeaveScreen> {
  AppointmentService appointmentService = AppointmentService();
  AppointmentInPendingService appointmentInPendingService =
      AppointmentInPendingService();
  UserManagementService userManagementService = UserManagementService();
  late Future<List<AppointmentInPending>> _appointmentEditList;
  late String patientName;
  late String physioName;

  @override
  void initState() {
    super.initState();
    _appointmentEditList = _fetchConlicAppointmentList();
  }

  Future<List<AppointmentInPending>> _fetchConlicAppointmentList() async {
    return await appointmentInPendingService.fetchConflictAppointmentRecord();
  }

  Future<String> _getUsernameById(int id) async {
    return userManagementService.getUsernameById(id);
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
        future: _appointmentEditList,
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
                    child: Image.asset(ImageConstant.DATA_NOT_FOUND),
                  ),
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
                        color: Color.fromRGBO(241, 243, 250, 1),
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
                                      SizedBox(width: 7),
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
                                                    return Container(
                                                      width: 40,
                                                      child: AutoSizeText(
                                                        shortenUsername(
                                                            username),
                                                        maxLines: 1,
                                                        minFontSize: 10,
                                                      ),
                                                    );
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
                                                    return Container(
                                                      width: 40,
                                                      child: AutoSizeText(
                                                        shortenUsername(
                                                            username),
                                                        maxLines: 1,
                                                        minFontSize: 10,
                                                      ),
                                                    );
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
                                            onPressed: () async {
                                              final needUpdate =
                                                  await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditAppointmentDetailScreen(
                                                    appointmentInPendingId:
                                                        appointment.id,
                                                  ),
                                                ),
                                              );

                                              if (needUpdate != null &&
                                                  needUpdate) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      LocaleKeys.Appointment_conflict_has_been_solved.tr()),
                                                    duration:
                                                        Duration(seconds: 3),
                                                  ),
                                                );
                                                setState(() {
                                                  _appointmentEditList =
                                                      _fetchConlicAppointmentList();
                                                });
                                              }
                                            },
                                            style: TextButton.styleFrom(
                                              backgroundColor: ColorConstant
                                                  .YELLOW_BUTTON_UNPRESSED,
                                              primary:
                                                  Colors.white, 
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons
                                                      .edit_calendar_outlined,
                                                  color: ColorConstant
                                                      .YELLOW_BUTTON_TEXT, 
                                                ),
                                                SizedBox(width: 10.0),
                                                Text(
                                                  LocaleKeys.Edit.tr(),
                                                  style: TextStyle(
                                                    fontSize:
                                                        15.0,
                                                    color: ColorConstant
                                                        .YELLOW_BUTTON_TEXT,
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
