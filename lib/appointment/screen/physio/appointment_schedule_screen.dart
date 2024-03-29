import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:physio_track/user_management/service/user_management_service.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../constant/ImageConstant.dart';
import '../../../constant/TextConstant.dart';
import '../../../translations/locale_keys.g.dart';
import '../../model/appointment_model.dart';
import '../../service/appointment_service.dart';

class AppointmentScheduleScreen extends StatefulWidget {
  const AppointmentScheduleScreen({super.key});

  @override
  State<AppointmentScheduleScreen> createState() =>
      _AppointmentScheduleScreenState();
}

class _AppointmentScheduleScreenState extends State<AppointmentScheduleScreen> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  DateTime selectedDate = DateTime.now();
  CalendarFormat calendarFormat = CalendarFormat.month;
  AppointmentService appointmentService = AppointmentService();
  UserManagementService userManagementService = UserManagementService();
  late List<Appointment> allAppointment;

  Future<List<Appointment>> getAllAppointmentByPhysio() async {
    int physioId = await userManagementService.fetchUserIdByUid(uid);
    print(physioId);
    return await appointmentService.fetchAppointmentListByPhysioId(physioId);
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
    print(selectedDateEvents.length);
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

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      selectedDate =
          DateTime(focusedDay.year, focusedDay.month, selectedDate.day);
    });
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
                    print(snapshot);
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text(
                              '${LocaleKeys.Error.tr()}: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      allAppointment = snapshot.data!;
                      return Column(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.42,
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 0),
                                  child: TableCalendar(
                                    calendarFormat: calendarFormat,
                                    focusedDay: selectedDate,
                                    locale: context.locale.toString(),
                                    selectedDayPredicate: (day) =>
                                        isSameDay(selectedDate, day),
                                    firstDay: DateTime.utc(2020,1,1),
                                    lastDay: DateTime.utc(2030,12,31),
                                    startingDayOfWeek:
                                        StartingDayOfWeek.monday,
                                    eventLoader:
                                        getAppointmentForSelectedDate,
                                    headerStyle: HeaderStyle(
                                      formatButtonShowsNext: false,
                                    ),
                                    onPageChanged: _onPageChanged,
                                    onDaySelected: (date, events) {
                                      setState(() {
                                        selectedDate = date;
                                      });
                                    },
                                  ),
                                ),
                              ],
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
                                          15.0),
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
                                                                  FontWeight.w500,
                                                              fontSize: 20,
                                                            ),
                                                          ),
                                                          Text(
                                                            DateFormat('hh:mm a')
                                                                .format(appointment
                                                                    .startTime),
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontSize: 30,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(width: 10),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                Icons.person,
                                                                color:
                                                                    Colors.black,
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
                                                                        '${LocaleKeys.Error.tr()}: ${snapshot.error}');
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
                          )
                        ],
                      );
                    } else {
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
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
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
                LocaleKeys.Appointment_Schedule.tr(),
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
              ImageConstant.SCHEDULE,
              width: 240.0,
              height: 160.0,
            ),
          ),
        ],
      ),
    );
  }
}
