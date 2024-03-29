import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:physio_track/appointment/service/appointment_service.dart';

import '../../../constant/ImageConstant.dart';
import '../../../constant/TextConstant.dart';
import '../../../translations/locale_keys.g.dart';
import '../../../treatment/model/treatment_model.dart';
import '../../../treatment/screen/create_treatment_report_screen.dart';
import '../../../treatment/screen/view_treatment_report_screen.dart';
import '../../../treatment/service/treatment_service.dart';
import '../../../user_management/service/user_management_service.dart';
import '../../model/appointment_model.dart';

class AppointmentHistoryPhysioScreen extends StatefulWidget {
  const AppointmentHistoryPhysioScreen({super.key});

  @override
  State<AppointmentHistoryPhysioScreen> createState() =>
      _AppointmentHistoryPhysioScreenState();
}

class _AppointmentHistoryPhysioScreenState
    extends State<AppointmentHistoryPhysioScreen> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  AppointmentService appointmentService = AppointmentService();
  TreatmentService treatmentService = TreatmentService();
  UserManagementService userManagementService = UserManagementService();
  late Future<List<Appointment>> _appointmentList;

  @override
  void initState() {
    super.initState();
    _appointmentList = _fetchAppointmentList(uid);
  }

  Future<List<Appointment>> _fetchAppointmentList(String uid) async {
    int id = await userManagementService.fetchUserIdByUid(uid);
    return await appointmentService.fetchAppointmentListByPhysioId(id);
  }

  Future<bool> _fetchTreatmentReport(int appointmentId) async {
    Treatment? treatment = await treatmentService
        .fetchTreatmentReportByAppointmentId(appointmentId);

    return treatment != null;
  }

  String shortenUsername(String fullName) {
    List<String> parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts.first}';
    } else {
      return fullName;
    }
  }

  Future<String> _getUsernameById(int id) async {
    return userManagementService.getUsernameById(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 250.0,
            ),
            Expanded(
              child: FutureBuilder<List<Appointment>>(
                future: _appointmentList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text(
                            '${LocaleKeys.Error.tr()}: ${snapshot.error}'));
                  }
                  if (snapshot.hasData) {
                    List<Appointment> appointments = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: appointments.map((Appointment appointment) {
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                DateFormat('dd MMM yyyy')
                                                    .format(
                                                        appointment.startTime),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              Text(
                                                DateFormat('hh:mm a').format(
                                                    appointment.startTime),
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
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return CircularProgressIndicator();
                                                      }
                                                      if (snapshot.hasError) {
                                                        return Text(
                                                            '${LocaleKeys.Error.tr()}: ${snapshot.error}');
                                                      }
                                                      if (snapshot.hasData) {
                                                        String username =
                                                            snapshot.data!;
                                                        return Text(
                                                            shortenUsername(
                                                                username));
                                                      }
                                                      return Container();
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          FutureBuilder<bool>(
                                            future: _fetchTreatmentReport(
                                                appointment.id),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Expanded(
                                                    child: Center(
                                                        child:
                                                            CircularProgressIndicator()));
                                              }
                                              if (snapshot.hasError) {
                                                return Text(
                                                    '${LocaleKeys.Error.tr()}: ${snapshot.error}');
                                              }
                                              if (snapshot.hasData) {
                                                bool status = snapshot.data!;

                                                if (status == true &&
                                                    appointment.startTime
                                                        .isBefore(
                                                            DateTime.now())) {
                                                  return Expanded(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25.0),
                                                      child: TextButton(
                                                        onPressed: () async {
                                                          final needUpdate =
                                                              await Navigator
                                                                  .push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ViewTreatmentReportScreen(
                                                                appointmentId:
                                                                    appointment
                                                                        .id,
                                                              ),
                                                            ),
                                                          );
                                                          if (needUpdate !=
                                                                  null &&
                                                              needUpdate) {
                                                            setState(() {
                                                              _appointmentList =
                                                                  _fetchAppointmentList(
                                                                      uid);
                                                            });
                                                          }
                                                        },
                                                        style: TextButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Color.fromARGB(
                                                                  255,
                                                                  250,
                                                                  224,
                                                                  191),
                                                          primary: Colors.white,
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              LocaleKeys
                                                                      .View_Report
                                                                  .tr(),
                                                              style: TextStyle(
                                                                fontSize: 15.0,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        255,
                                                                        147,
                                                                        47),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                } else if (status == false &&
                                                    appointment.startTime
                                                        .isBefore(
                                                            DateTime.now())) {
                                                  return Expanded(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25.0),
                                                      child: TextButton(
                                                        onPressed: () async {
                                                          final needUpdate =
                                                              await Navigator
                                                                  .push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  CreateTreatmentReportScreen(
                                                                appointmentId:
                                                                    appointment
                                                                        .id,
                                                              ),
                                                            ),
                                                          );

                                                          if (needUpdate !=
                                                                  null &&
                                                              needUpdate) {
                                                            setState(() {
                                                              _appointmentList =
                                                                  _fetchAppointmentList(
                                                                      uid);
                                                            });
                                                          }
                                                        },
                                                        style: TextButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Color.fromARGB(
                                                                  255,
                                                                  197,
                                                                  245,
                                                                  199),
                                                          primary: Colors.white,
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              LocaleKeys
                                                                      .Create_Report
                                                                  .tr(),
                                                              style: TextStyle(
                                                                fontSize: 15.0,
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                              return Container();
                                            },
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
                    );
                  }
                  return Container();
                },
              ),
            ),
            SizedBox(height: 70),
          ],
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
          left: 0,
          right: 0,
          child: Container(
            height: kToolbarHeight,
            alignment: Alignment.center,
            child: Text(
              LocaleKeys.Appointment_History.tr(),
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
            ImageConstant.PHYSIO_HOME,
            width: 271.0,
            height: 200.0,
          ),
        ),
      ],
    ));
  }
}
