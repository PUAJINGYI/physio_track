import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis/calendar/v3.dart' as Calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:intl/intl.dart';
import 'package:physio_track/appointment/service/appointment_in_pending_service.dart';
import 'package:physio_track/reusable_widget/reusable_widget.dart';

import '../../constant/ColorConstant.dart';
import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../model/appointment_in_pending_model.dart';
import 'appointment_patient_screeen.dart';

class AppointmentUpdateScreen extends StatefulWidget {
  final int? appointmentId;
  final DateTime? appointmentDate;

  AppointmentUpdateScreen({this.appointmentId, this.appointmentDate});

  @override
  _AppointmentUpdateScreenState createState() =>
      _AppointmentUpdateScreenState(appointmentId: appointmentId);
}

class _AppointmentUpdateScreenState extends State<AppointmentUpdateScreen> {
  CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  AppointmentInPendingService appointmentInPendingService =
      AppointmentInPendingService();
  late Map<String, dynamic> patientData = {};
  late Map<String, dynamic> physioData = {};

  List<Calendar.Event> events = [];
  DateTime _selectedValue = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  int? selectedHour;
  int? oriSelectedHour;
  final int? appointmentId; // Store the appointment ID

  _AppointmentUpdateScreenState({this.appointmentId});

  @override
  void initState() {
    super.initState();
    _selectedValue = DateTime(
      widget.appointmentDate!.year,
      widget.appointmentDate!.month,
      widget.appointmentDate!.day,
    );
    oriSelectedHour = widget.appointmentDate!.hour;
    if (appointmentId != null) {
      _loadAppointmentData(appointmentId!);
    } else {
      _loadEvents(_selectedValue);
    }
    _loadUsersData();
  }

  Future<void> _loadEvents(DateTime startDate) async {
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

  Future<void> _loadAppointmentData(int appointmentId) async {
    final appointment = await appointmentInPendingService
        .fetchPendingAppointmentById(appointmentId);

    if (appointment != null) {
      setState(() {
        // Set the initial selected date to the appointment date
        _selectedValue = appointment.date;

        // Set the selected hour based on the appointment start time
        selectedHour = appointment.startTime.hour;
      });

      _loadEvents(_selectedValue);
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 220,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Clinic Appointment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    DatePicker(
                      DateTime(
                        widget.appointmentDate!.year,
                        widget.appointmentDate!.month,
                        widget.appointmentDate!.day,
                      ).add(Duration(days: -1)),
                      initialSelectedDate: DateTime(_selectedValue.year,
                          _selectedValue.month, _selectedValue.day),
                      selectionColor: Colors.blue,
                      selectedTextColor: Colors.white,
                      onDateChange: (date) {
                        // New date selected
                        setState(() {
                          _selectedValue = date;
                          _loadEvents(_selectedValue);
                          if (_selectedValue.isAtSameMomentAs(DateTime(
                            widget.appointmentDate!.year,
                            widget.appointmentDate!.month,
                            widget.appointmentDate!.day,
                          ))) {
                            print('yes');
                            print(selectedHour);
                            selectedHour = oriSelectedHour;
                          } else {
                            selectedHour = null;
                          }
                        });
                      },
                    ),
                    SizedBox(
                        height:
                            20), // Add spacing between DatePicker and selected date text
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Generate time slots from 10 AM to 8 PM with buttons
                    for (int startHour = 10; startHour <= 20; startHour += 3)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          for (int hour = startHour;
                              hour < startHour + 3;
                              hour++)
                            if (hour <= 20)
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(7, 15, 7, 15),
                                child: Container(
                                  width: 110,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Handle button tap for the selected time slot
                                      setState(() {
                                        if (events.any((event) {
                                          final eventStartTime =
                                              event.start!.dateTime!.toLocal();
                                          final eventEndTime =
                                              event.end!.dateTime!.toLocal();
                                          final buttonStartTime = DateTime(
                                            _selectedValue.year,
                                            _selectedValue.month,
                                            _selectedValue.day,
                                            hour,
                                          );
                                          return buttonStartTime
                                              .isAtSameMomentAs(eventStartTime);
                                        })) {
                                          // If the button meets a conflict, do nothing (it remains disabled)
                                          return;
                                        }

                                        // If there was a previous selection, make it default again
                                        if (selectedHour != null) {
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
                                      backgroundColor: MaterialStateProperty
                                          .resolveWith<Color>(
                                        (Set<MaterialState> states) {
                                          if (states.contains(
                                              MaterialState.disabled)) {
                                            // Disabled state (conflict with an event)
                                            return Color.fromARGB(
                                                255, 239, 154, 154);
                                          } else if (states.contains(
                                                  MaterialState.pressed) ||
                                              selectedHour == hour) {
                                            // Active state (button is pressed or previously selected)
                                            return Color.fromARGB(
                                                255, 138, 193, 238);
                                          } else {
                                            // Default state (not pressed and not selected)
                                            return Color.fromARGB(
                                                255, 216, 234, 248);
                                          }
                                        },
                                      ),
                                    ),
                                    child: Text(
                                      '${hour % 12 == 0 ? 12 : hour % 12}:00 ${hour < 12 ? 'AM' : 'PM'}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: selectedHour == hour
                                            ? Color.fromARGB(255, 5, 136, 243)
                                            : events.any((event) {
                                                final eventStartTime = event
                                                    .start!.dateTime!
                                                    .toLocal();
                                                final eventEndTime = event
                                                    .end!.dateTime!
                                                    .toLocal();
                                                final buttonStartTime =
                                                    DateTime(
                                                  _selectedValue.year,
                                                  _selectedValue.month,
                                                  _selectedValue.day,
                                                  hour,
                                                );
                                                return buttonStartTime
                                                    .isAtSameMomentAs(
                                                        eventStartTime);
                                              })
                                                ? Colors
                                                    .white // Text color for disabled button
                                                : Color.fromARGB(255, 150, 200,
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
                SizedBox(
                  height: 50,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: customButton(
                    context,
                    'Update Now',
                    ColorConstant.BLUE_BUTTON_TEXT,
                    ColorConstant.BLUE_BUTTON_UNPRESSED,
                    ColorConstant.BLUE_BUTTON_PRESSED,
                    () {
                      if (selectedHour == null) {
                        // No hour selected, display a snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please select an appointment time.'),
                          ),
                        );
                        return; // Do not proceed further
                      }

                      appointmentInPendingService
                          .updatePendingAppointmentRecordByDetails(
                              widget.appointmentId!,
                              _selectedValue,
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
                              Duration(hours: 1).inSeconds);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppointmentPatientScreen(),
                        ),
                      );
                    },
                  ),
                )
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
                'Appointment Update',
                style: TextStyle(
                  fontSize: TextConstant.TITLE_FONT_SIZE,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 80,
            right: 5,
            child: Image.asset(
              ImageConstant.APPOINTMENT,
              width: 211.0,
              height: 169.0,
            ),
          ),
          Positioned(
            top: 125,
            left: 20,
            child: Text('Physiotherapist incharge:',
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
