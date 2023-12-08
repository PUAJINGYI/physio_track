import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis/calendar/v3.dart' as Calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:intl/intl.dart';
import 'package:physio_track/appointment/screen/appointment_patient_screen.dart';
import 'package:physio_track/appointment/service/appointment_in_pending_service.dart';
import 'package:physio_track/reusable_widget/reusable_widget.dart';
import 'package:physio_track/user_management/service/user_management_service.dart';

import '../../constant/ColorConstant.dart';
import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../../leave/model/leave_model.dart';
import '../../leave/service/leave_service.dart';
import '../../translations/locale_keys.g.dart';
import '../model/appointment_in_pending_model.dart';
import '../service/appointment_service.dart';

class AppointmentBookingScreen extends StatefulWidget {
  @override
  _AppointmentBookingScreenState createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  AppointmentInPendingService appointmentInPendingService =
      AppointmentInPendingService();
  UserManagementService userManagementService = UserManagementService();
  AppointmentService appointmentService = AppointmentService();
  LeaveService leaveService = LeaveService();
  late Map<String, dynamic> patientData = {};
  late Map<String, dynamic> physioData = {};

  List<Calendar.Event> events = [];
  List<Leave> leaves = [];
  bool isFullDayLeave = false;
  DateTime _selectedValue = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  int? selectedHour;

  @override
  void initState() {
    super.initState();
    _checkAndUpdateEvents();
    _loadEvents(_selectedValue);
    _loadLeave(_selectedValue);
    _loadUsersData();
  }

  Future<void> _checkAndUpdateEvents() async {
    await appointmentService.checkAndAddAppointmentFromGCalendar();
  }

  Future<void> _loadLeave(DateTime date) async {
    int physioId = await userManagementService.fetchPhysioIdByPatientUid(uid);
    leaves = await leaveService.fetchLeaveByPhysioIdAndDate(physioId, date);
    if (leaves.isNotEmpty) {
      for (Leave leave in leaves) {
        if (leave.isFullDay) {
          isFullDayLeave = true;
          break;
        } else {
          isFullDayLeave = false;
        }
      }
    } else {
      isFullDayLeave = false;
    }
    print('full day leave ? $isFullDayLeave');
  }

  Future<void> _loadEvents(DateTime startDate) async {
    // fetch patient email from firebase
    int patientId = await userManagementService.fetchUserIdByUid(uid);
    String patientEmail =
        await userManagementService.fetchUserEmailById(patientId);
    String physioEmail =
        await userManagementService.fetchPhysioEmailByPatientId(patientId);

    final authClient = await loadServiceAccountClient();
    if (authClient != null) {
      try {
        final calendar = Calendar.CalendarApi(authClient);
        final calendarId = dotenv.get('GOOGLE_CALENDAR_ID', fallback: '');
        final DateTime endDate = DateTime(
            startDate.year, startDate.month, startDate.day, 23, 59, 59);

        final eventsResponse = await calendar.events.list(
          calendarId,
          timeMin: startDate.toUtc(),
          timeMax: endDate.toUtc(),
          timeZone: dotenv.get('CALENDAR_TIMEZONE', fallback: 'Asia/Singapore'),
        );
        if (eventsResponse.items != null) {
          setState(() {
            events = eventsResponse.items!;
            events = events.where((event) {
              if (event.attendees != null) {
                return event.attendees!.any((attendee) =>
                    attendee.email == patientEmail ||
                    attendee.email == physioEmail);
              }
              return false; // Return false for events with no attendees
            }).toList();
          });
        }
      } catch (e) {
        print('Error loading events: $e');
      } finally {
        authClient.close();
      }
    } else {
      print('Failed to load service account client');
    }
    print('events length: ${events.length}');
  }

  Future<void> _loadUsersData() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userRef = userCollection.doc(userId);
    DocumentSnapshot userSnapshot = await userRef.get();

    Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>;
    if (userData == null) {
      print("empty");
    } else {
      setState(() {
        this.patientData = userData;
      });

      final QuerySnapshot physioSnapshot = await userCollection
          .where('username', isEqualTo: patientData['physio'])
          .limit(1)
          .get();
      Map<String, dynamic>? physioData =
          physioSnapshot.docs.first.data() as Map<String, dynamic>;
      if (physioData == null) {
        print("empty physio");
      } else {
        setState(() {
          this.physioData = physioData;
        });
      }
    }
  }

  Future<AuthClient?> loadServiceAccountClient() async {
    final credentials = ServiceAccountCredentials.fromJson({
      "type": dotenv.get('TYPE', fallback: ""),
      "project_id": dotenv.get('PROJECT_ID', fallback: ""),
      "private_key_id": dotenv.get('PRIVATE_KEY_ID', fallback: ""),
      "private_key": dotenv.get('PRIVATE_KEY', fallback: ""),
      "client_email": dotenv.get('CLIENT_EMAIL', fallback: ""),
      "client_id": dotenv.get('CLIENT_ID', fallback: ""),
      "auth_uri": dotenv.get('AUTH_URI', fallback: ""),
      "token_uri": dotenv.get('TOKEN_URI', fallback: ""),
      "auth_provider_x509_cert_url":
          dotenv.get('AUTH_PROVIDER_X509_CERT_URL', fallback: ""),
      "client_x509_cert_url": dotenv.get('CLIENT_X509_CERT_URL', fallback: ""),
      "universe_domain": dotenv.get('UNIVERSE_DOMAIN', fallback: ""),
    });

    final scopes = [Calendar.CalendarApi.calendarScope];

    try {
      final authClient = await clientViaServiceAccount(credentials, scopes);
      return authClient;
    } catch (e) {
      print('Error loading service account client: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 220,
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      Container(
                        height: 500,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  LocaleKeys.Clinic_Appointment.tr(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            DatePicker(
                              locale: context.locale.toString(),
                              height: 100,
                              DateTime.now().add(Duration(days: 1)),
                              initialSelectedDate:
                                  DateTime.now().add(Duration(days: 1)),
                              selectionColor: Colors.blue,
                              selectedTextColor: Colors.white,
                              onDateChange: (date) {
                                // New date selected
                                setState(() {
                                  _selectedValue = date;
                                  _loadEvents(_selectedValue);
                                  _loadLeave(_selectedValue);
                                });
                              },
                            ),
                            SizedBox(height: 20),
                            Visibility(
                              visible:
                                  isFullDayLeave, // Show the Text when isFullDayLeave is false
                              child: Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 190.0,
                                      height: 190.0,
                                      child:
                                          Image.asset(ImageConstant.ON_LEAVE),
                                    ),
                                    Text(
                                        LocaleKeys.Physiotherapist_On_Leave
                                            .tr(),
                                        style: TextStyle(
                                            fontSize: 17.0,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                            Visibility(
                              visible: !isFullDayLeave,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Generate time slots from 10 AM to 8 PM with buttons
                                  for (int startHour = 10;
                                      startHour <= 20;
                                      startHour += 3)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        for (int hour = startHour;
                                            hour < startHour + 3;
                                            hour++)
                                          if (hour <= 20)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      7, 15, 7, 15),
                                              child: Container(
                                                width: 110,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    // Handle button tap for the selected time slot
                                                    setState(() {
                                                      if (events.any((event) {
                                                            final eventStartTime =
                                                                event.start!
                                                                    .dateTime!
                                                                    .toLocal();
                                                            final eventEndTime =
                                                                event.end!
                                                                    .dateTime!
                                                                    .toLocal();
                                                            final buttonStartTime =
                                                                DateTime(
                                                              _selectedValue
                                                                  .year,
                                                              _selectedValue
                                                                  .month,
                                                              _selectedValue
                                                                  .day,
                                                              hour,
                                                            );
                                                            return buttonStartTime
                                                                .isAtSameMomentAs(
                                                                    eventStartTime);
                                                          }) ||
                                                          leaves.any((leave) {
                                                            final leaveStartTime =
                                                                leave.startTime
                                                                    .toLocal();
                                                            final leaveEndTime =
                                                                leave.endTime
                                                                    .toLocal();
                                                            final buttonStartTime =
                                                                DateTime(
                                                              _selectedValue
                                                                  .year,
                                                              _selectedValue
                                                                  .month,
                                                              _selectedValue
                                                                  .day,
                                                              hour,
                                                            );
                                                            return buttonStartTime
                                                                    .isAtSameMomentAs(
                                                                        leaveStartTime) ||
                                                                (buttonStartTime
                                                                        .isAfter(
                                                                            leaveStartTime) &&
                                                                    buttonStartTime
                                                                        .isBefore(
                                                                            leaveEndTime));
                                                          })) {
                                                        // If the button meets a conflict, do nothing (it remains disabled)
                                                        MaterialState.disabled;
                                                        return;
                                                      }

                                                      // If there was a previous selection, make it default again
                                                      if (selectedHour !=
                                                          null) {
                                                        selectedHour = null;
                                                      }

                                                      // Set the current button as active
                                                      selectedHour = hour;

                                                      // Update _selectedValue to match the selected hour
                                                      _selectedValue = DateTime(
                                                        _selectedValue.year,
                                                        _selectedValue.month,
                                                        _selectedValue.day,
                                                        hour,
                                                      );
                                                    });
                                                  },
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .resolveWith<Color>(
                                                      (Set<MaterialState>
                                                          states) {
                                                        if (states.contains(
                                                            MaterialState
                                                                .disabled)) {
                                                          // Disabled state (conflict with an event or leave)
                                                          return Color.fromARGB(
                                                              255,
                                                              239,
                                                              154,
                                                              154);
                                                        } else if (states.contains(
                                                                MaterialState
                                                                    .pressed) ||
                                                            selectedHour ==
                                                                hour) {
                                                          // Active state (button is pressed or previously selected)
                                                          return Color.fromARGB(
                                                              255,
                                                              138,
                                                              193,
                                                              238);
                                                        } else {
                                                          // Default state (not pressed and not selected)
                                                          return Color.fromARGB(
                                                              255,
                                                              216,
                                                              234,
                                                              248);
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  child: Text(
                                                    '${hour % 12 == 0 ? 12 : hour % 12}:00 ${hour < 12 ? 'AM' : 'PM'}',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: selectedHour ==
                                                              hour
                                                          ? Color.fromARGB(
                                                              255, 5, 136, 243)
                                                          : events.any((event) {
                                                              final eventStartTime =
                                                                  event.start!
                                                                      .dateTime!
                                                                      .toLocal();
                                                              final eventEndTime =
                                                                  event.end!
                                                                      .dateTime!
                                                                      .toLocal();
                                                              final buttonStartTime =
                                                                  DateTime(
                                                                _selectedValue
                                                                    .year,
                                                                _selectedValue
                                                                    .month,
                                                                _selectedValue
                                                                    .day,
                                                                hour,
                                                              );
                                                              return buttonStartTime
                                                                  .isAtSameMomentAs(
                                                                      eventStartTime);
                                                            })
                                                              ? Colors
                                                                  .white // Text color for disabled button
                                                              : Color.fromARGB(
                                                                  255,
                                                                  150,
                                                                  200,
                                                                  238), // Text color for active button
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      Visibility(
                        visible: !isFullDayLeave,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                              TextConstant.CUSTOM_BUTTON_SIDE_PADDING,
                              TextConstant.CUSTOM_BUTTON_TB_PADDING,
                              TextConstant.CUSTOM_BUTTON_SIDE_PADDING,
                              TextConstant.CUSTOM_BUTTON_TB_PADDING),
                          child: customButton(
                            context,
                            LocaleKeys.Book_Now.tr(),
                            ColorConstant.BLUE_BUTTON_TEXT,
                            ColorConstant.BLUE_BUTTON_UNPRESSED,
                            ColorConstant.BLUE_BUTTON_PRESSED,
                            () {
                              if (selectedHour == null) {
                                // No hour selected, display a snackbar
                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   SnackBar(
                                //     content: Text(LocaleKeys
                                //             .Please_select_an_appointment_time
                                //         .tr()),
                                //   ),
                                // );
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      contentPadding: EdgeInsets
                                          .zero, // Remove content padding
                                      titlePadding: EdgeInsets.fromLTRB(
                                          16, 0, 16, 0), // Adjust title padding
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
                                                color: ColorConstant
                                                    .RED_BUTTON_TEXT),
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Close the dialog
                                            },
                                          ),
                                        ],
                                      ),
                                      content: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          LocaleKeys
                                                  .Please_select_an_appointment_time
                                              .tr(),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      actions: [
                                        Center(
                                          // Wrap actions in Center widget
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
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
                                return; // Do not proceed further
                              }

                              appointmentInPendingService
                                  .addPendingAppointmentRecordByDetails(
                                    context,
                                      '[Appointment] ${patientData['username']} with ${physioData['username']}',
                                      DateTime(
                                          _selectedValue.year,
                                          _selectedValue.month,
                                          _selectedValue.day),
                                      DateTime(
                                          _selectedValue.year,
                                          _selectedValue.month,
                                          _selectedValue.day,
                                          selectedHour!),
                                      DateTime(
                                          _selectedValue.year,
                                          _selectedValue.month,
                                          _selectedValue.day,
                                          selectedHour! + 1),
                                      Duration(hours: 1).inSeconds,
                                      patientData['id'],
                                      physioData['id']);
                              Navigator.pop(context, true);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
            left: 0,
            right: 0,
            child: Container(
              height: kToolbarHeight,
              alignment: Alignment.center,
              child: Text(
                LocaleKeys.Appointment_Booking.tr(),
                style: TextStyle(
                  fontSize: TextConstant.TITLE_FONT_SIZE,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 5,
            child: Image.asset(
              ImageConstant.APPOINTMENT,
              width: 190.0,
              height: 190.0,
            ),
          ),
          Positioned(
            top: 125,
            left: 20,
            child: Text(LocaleKeys.Physiotherapist_incharge.tr(),
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
          ),
          Positioned(
            top: 150,
            left: 20,
            child: Text(patientData['physio'] ?? '',
                style: TextStyle(fontSize: 15.0)),
          ),
        ],
      ),
    );
  }
}
