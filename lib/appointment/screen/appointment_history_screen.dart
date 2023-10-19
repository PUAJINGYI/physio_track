import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/intl.dart';
import 'package:physio_track/appointment/service/appointment_service.dart';
import 'package:physio_track/constant/ImageConstant.dart';
import 'package:physio_track/treatment/screen/view_treatment_report_screen.dart';

import '../../constant/TextConstant.dart';
import '../../treatment/model/treatment_model.dart';
import '../../treatment/service/treatment_service.dart';
import '../../user_management/service/user_management_service.dart';
import '../model/appointment_model.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  final String uid;
  const AppointmentHistoryScreen({super.key, required this.uid});

  @override
  State<AppointmentHistoryScreen> createState() =>
      _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen> {
  //String uid = FirebaseAuth.instance.currentUser!.uid;
  AppointmentService appointmentService = AppointmentService();
  UserManagementService userManagementService = UserManagementService();
  TreatmentService treatmentService = TreatmentService();
  late Future<List<Appointment>> _appointmentList;

  @override
  void initState() {
    super.initState();
    _appointmentList = _fetchAppointmentList(widget.uid);
  }

  Future<List<Appointment>> _fetchAppointmentList(String uid) async {
    int id = await userManagementService.fetchUserIdByUid(uid);
    return await appointmentService.fetchAppointmentListByPatientId(id);
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

  Future<Treatment?> _getTreatmentReportByAppointmentId(
      int appointmentId) async {
    return await treatmentService
        .fetchTreatmentReportByAppointmentId(appointmentId);
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
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.hasData) {
                    List<Appointment> appointments = snapshot.data!;
                    // Check if the appointments list is empty
                    if (appointments.isEmpty) {
                      // Display an image when the list is empty
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100.0,
                            height: 100.0,
                            child: Image.asset(ImageConstant.DATA_NOT_FOUND),
                          ),
                          Text('No Record Found',
                              style: TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.bold)),
                        ],
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView(
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
                                          // date and time column
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
                                          // patient and physio column
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
                                                            'Error: ${snapshot.error}');
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
                                      FutureBuilder<Treatment?>(
                                        future:
                                            _getTreatmentReportByAppointmentId(
                                                appointment.id),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          } else {
                                            final treatmentReport =
                                                snapshot.data;
                                            if (treatmentReport != null) {
                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25.0),
                                                      child: TextButton(
                                                        onPressed: () {
                                                          Navigator.push(
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
                                                              "View Report",
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
                                                  ),
                                                ],
                                              );
                                            } else {
                                              // If treatment data is not available, do not show the button
                                              return Container();
                                            }
                                          }
                                        },
                                      )
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
            )
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
              'Appointment History',
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
            ImageConstant.APPOINTMENT_HISTORY,
            width: 271.0,
            height: 230.0,
          ),
        ),
      ],
    ));
  }
}
