import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/intl.dart';
import 'package:physio_track/appointment/model/appointment_in_pending_model.dart';
import 'package:physio_track/user_management/service/user_management_service.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../constant/ImageConstant.dart';
import '../../model/appointment_model.dart';
import '../../service/appointment_in_pending_service.dart';
import '../../service/appointment_service.dart';

class AppointmentScheduleScreen extends StatefulWidget {
  const AppointmentScheduleScreen({super.key});

  @override
  State<AppointmentScheduleScreen> createState() =>
      _AppointmentScheduleScreenState();
}

class _AppointmentScheduleScreenState extends State<AppointmentScheduleScreen> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  DateTime selectedDate = DateTime.now(); // Initialize with the current date
  CalendarFormat calendarFormat = CalendarFormat.month;
  AppointmentService appointmentService = AppointmentService();
  UserManagementService userManagementService = UserManagementService();
  late List<Appointment> allAppointment;

  Future<List<Appointment>> getAllAppointmentByPhysio() async {
    int physioId = await userManagementService.fetchUserIdByUid(uid);
    return appointmentService.fetchAppointmentListByPhysioId(physioId);
  }

  List<Appointment> getAppointmentForSelectedDate(DateTime date) {
    List<Appointment> selectedDateEvents = [];
    for (var appointment in allAppointment) {
      if (appointment.date.year == date.year &&
          appointment.date.month == date.month &&
          appointment.date.day == date.day) {
        selectedDateEvents.add(appointment);
      }
    }
    return selectedDateEvents;
  }

  Future<String> getUsernameById(int patientId) async {
    String username = await userManagementService.getUsernameById(patientId);
    return shortenUsername(username);
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
    return Scaffold(
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 210.0,
              ),
              Expanded(
                child: FutureBuilder<List<Appointment>>(
                  future: getAllAppointmentByPhysio(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // While the future is still loading, you can show a loading indicator
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      // If there's an error, display an error message
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      // If data is available, populate the allAppointment list
                      allAppointment = snapshot.data!;

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                            child: TableCalendar(
                              calendarFormat: calendarFormat,
                              focusedDay: selectedDate,
                              selectedDayPredicate: (day) =>
                                  isSameDay(selectedDate, day),
                              firstDay: DateTime(2023),
                              lastDay: DateTime(2030),
                              startingDayOfWeek: StartingDayOfWeek.monday,
                              eventLoader: getAppointmentForSelectedDate,
                              headerStyle: HeaderStyle(
                                formatButtonShowsNext: false,
                              ),
                              onDaySelected: (date, events) {
                                setState(() {
                                  selectedDate = date;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                ...getAppointmentForSelectedDate(selectedDate)
                                    .map((appointment) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 2, 20, 0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          15.0), // Adjust the radius as needed
                                      child: Card(
                                        color: Color.fromRGBO(241, 243, 250, 1),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
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
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            DateFormat(
                                                                    'dd MMM yyyy')
                                                                .format(appointment
                                                                    .startTime),
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 20,
                                                            ),
                                                          ),
                                                          Text(
                                                            DateFormat(
                                                                    'hh:mm a')
                                                                .format(appointment
                                                                    .startTime),
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 30,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(width: 10),
                                                      // patient and physio column
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                Icons.person,
                                                                color: Colors
                                                                    .black,
                                                                size: 20.0,
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              FutureBuilder<
                                                                  String>(
                                                                future: getUsernameById(
                                                                    appointment
                                                                        .patientId),
                                                                builder: (context,
                                                                    snapshot) {
                                                                  if (snapshot
                                                                          .connectionState ==
                                                                      ConnectionState
                                                                          .waiting) {
                                                                    return CircularProgressIndicator();
                                                                  }
                                                                  if (snapshot
                                                                      .hasError) {
                                                                    return Text(
                                                                        'Error: ${snapshot.error}');
                                                                  }
                                                                  if (snapshot
                                                                      .hasData) {
                                                                    String
                                                                        username =
                                                                        snapshot
                                                                            .data!;
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
                                                ],
                                              )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Center(child: Text('No data available.'));
                    }
                  },
                ),
              ),
            ],
          ),
          Positioned(
            top: 25,
            left: 0,
            right: 0,
            child: Container(
              height: kToolbarHeight,
              alignment: Alignment.center,
              child: Text(
                'Appointment Schedule',
                style: TextStyle(
                  fontSize: 20.0,
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
              ImageConstant.SCHEDULE,
              width: 271.0,
              height: 180.0,
            ),
          ),
        ],
      ),
    );
  }
}
