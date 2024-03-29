import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis/calendar/v3.dart' as Calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:physio_track/appointment/service/appointment_in_pending_service.dart';
import 'package:physio_track/reusable_widget/reusable_widget.dart';

import '../../constant/ColorConstant.dart';
import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../../leave/model/leave_model.dart';
import '../../leave/service/leave_service.dart';
import '../../translations/locale_keys.g.dart';
import '../../user_management/service/user_management_service.dart';

class AppointmentUpdateScreen extends StatefulWidget {
  final int? appointmentId;
  final DateTime? appointmentDate;

  AppointmentUpdateScreen({this.appointmentId, this.appointmentDate});

  @override
  _AppointmentUpdateScreenState createState() =>
      _AppointmentUpdateScreenState(appointmentId: appointmentId);
}

class _AppointmentUpdateScreenState extends State<AppointmentUpdateScreen> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  AppointmentInPendingService appointmentInPendingService =
      AppointmentInPendingService();
  UserManagementService userManagementService = UserManagementService();
  LeaveService leaveService = LeaveService();
  List<Leave> leaves = [];
  late Map<String, dynamic> patientData = {};
  late Map<String, dynamic> physioData = {};
  bool isFullDayLeave = false;

  List<Calendar.Event> events = [];
  DateTime _selectedValue = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  int? selectedHour;
  int? oriSelectedHour;
  final int? appointmentId; 
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
    _loadLeave(_selectedValue);
    _loadUsersData();
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
        _selectedValue = appointment.date;
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
                            initialSelectedDate: DateTime(_selectedValue.year,
                                _selectedValue.month, _selectedValue.day),
                            selectionColor: Colors.blue,
                            selectedTextColor: Colors.white,
                            onDateChange: (date) {
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
                                _loadLeave(_selectedValue);
                              });
                            },
                          ),
                          SizedBox(height: 20),
                          Visibility(
                            visible:
                                isFullDayLeave,
                            child: Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 190.0,
                                    height: 190.0,
                                    child: Image.asset(ImageConstant.ON_LEAVE),
                                  ),
                                  Text(LocaleKeys.Physiotherapist_On_Leave.tr(),
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
                                for (int startHour = 10;
                                    startHour <= 20;
                                    startHour += 3)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      for (int hour = startHour;
                                          hour < startHour + 3;
                                          hour++)
                                        if (hour <= 20)
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                7, 15, 7, 15),
                                            child: Container(
                                              width: 110,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    if (events.any((event) {
                                                      final eventStartTime =
                                                          event.start!.dateTime!
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
                                                    })) {
                                                      MaterialState.disabled;
                                                      return;
                                                    }

                                                    if (selectedHour != null) {
                                                      selectedHour = null;
                                                    }

                                                    selectedHour = hour;

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
                                                        return Color.fromARGB(
                                                            255, 239, 154, 154);
                                                      } else if (states.contains(
                                                              MaterialState
                                                                  .pressed) ||
                                                          selectedHour ==
                                                              hour) {
                                                        return Color.fromARGB(
                                                            255, 138, 193, 238);
                                                      } else {
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
                                                                .white 
                                                            : Color.fromARGB(
                                                                255,
                                                                150,
                                                                200,
                                                                238), 
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
                          LocaleKeys.Update.tr(),
                          ColorConstant.BLUE_BUTTON_TEXT,
                          ColorConstant.BLUE_BUTTON_UNPRESSED,
                          ColorConstant.BLUE_BUTTON_PRESSED,
                          () async {
                            if (selectedHour == null) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    contentPadding: EdgeInsets
                                        .zero, 
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
                                              color: ColorConstant
                                                  .RED_BUTTON_TEXT),
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
                                        LocaleKeys
                                                .Please_select_an_appointment_time
                                            .tr(),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    actions: [
                                      Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                              return; 
                            }

                            await appointmentInPendingService
                                .updatePendingAppointmentRecordByDetails(
                                    context,
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
                            Navigator.pop(context, true);
                          },
                        ),
                      ),
                    ),
                  ],
                )),
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
                LocaleKeys.Appointment_Update.tr(),
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
