import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:physio_track/appointment/screen/physio/appointment_history_physio_screen.dart';
import '../../appointment/model/appointment_model.dart';
import '../../appointment/service/appointment_in_pending_service.dart';
import '../../appointment/service/appointment_service.dart';
import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../../leave/screen/leave_list_screen.dart';
import '../../translations/locale_keys.g.dart';
import '../../user_management/service/user_management_service.dart';

class PhysioHomeScreen extends StatefulWidget {
  const PhysioHomeScreen({super.key});

  @override
  State<PhysioHomeScreen> createState() => _PhysioHomeScreenState();
}

class _PhysioHomeScreenState extends State<PhysioHomeScreen> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  AppointmentService appointmentService = AppointmentService();
  AppointmentInPendingService appointmentInPendingService =
      AppointmentInPendingService();
  UserManagementService userManagementService = UserManagementService();
  String username = "";

  void initState() {
    super.initState();
  }

  Future<Appointment?> fetchNextAppointment() async {
    int physioId = await userManagementService.fetchUserIdByUid(uid);
    List<Appointment> appointments =
        await appointmentService.fetchAppointmentListByPhysioId(physioId);

    List<Appointment> futureAppointments = appointments
        .where((appointment) => appointment.startTime.isAfter(DateTime.now()))
        .toList();

    futureAppointments.sort((a, b) => a.startTime.compareTo(b.startTime));

    if (futureAppointments.isNotEmpty) {
      return futureAppointments.first;
    } else {
      return null;
    }
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

  Future<void> getPhysioUsername() async {
    username = await userManagementService.getUsernameByUid(uid, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: FutureBuilder<void>(
          future: getPhysioUsername(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('${LocaleKeys.Error.tr()}: ${snapshot.error}'));
            } else {
              return Stack(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 230,
                      ),
                      Expanded(
                          child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: 1,
                              itemBuilder: (BuildContext context, int index) {
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 0, 0, 0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          LocaleKeys.Next_Appointment.tr(),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                    FutureBuilder<Appointment?>(
                                      future: fetchNextAppointment(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator(); // You can replace this with your preferred loading widget
                                        } else if (snapshot.hasError) {
                                          return Center(
                                              child: Text(
                                                  '${LocaleKeys.Error.tr()}: ${snapshot.error}'));
                                        } else if (!snapshot.hasData ||
                                            snapshot.data == null) {
                                          return Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 10, 20, 0),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                              child: Container(
                                                height: 120,
                                                child: Card(
                                                  color: Color.fromARGB(
                                                      255, 255, 196, 196),
                                                  elevation: 5.0,
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(16.0),
                                                    child: Column(
                                                      children: [
                                                        Icon(Icons.error,
                                                            color: Colors.red,
                                                            size: 50.0),
                                                        Center(
                                                          child: Text(
                                                            LocaleKeys.No_Record
                                                                .tr(),
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                              fontSize: 20.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        } else {
                                          Appointment nextAppointment =
                                              snapshot.data!;
                                          return Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 10, 20, 0),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                              child: Container(
                                                height: 120,
                                                child: Card(
                                                  color: Color.fromARGB(
                                                      255, 188, 250, 190),
                                                  elevation: 5.0,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Icon(
                                                            Icons.schedule,
                                                            color: Colors.black,
                                                            size: 50.0,
                                                          ),
                                                        ),
                                                        Expanded(
                                                            child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
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
                                                                          .format(
                                                                              nextAppointment.startTime),
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontSize:
                                                                            20,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      DateFormat(
                                                                              'hh:mm a')
                                                                          .format(
                                                                              nextAppointment.startTime),
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize:
                                                                            30,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                    width: 10),
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .person,
                                                                          color:
                                                                              Colors.black,
                                                                          size:
                                                                              20.0,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        FutureBuilder<
                                                                            String>(
                                                                          future:
                                                                              getUsernameById(nextAppointment.patientId),
                                                                          builder:
                                                                              (context, snapshot) {
                                                                            if (snapshot.connectionState ==
                                                                                ConnectionState.waiting) {
                                                                              return CircularProgressIndicator();
                                                                            }
                                                                            if (snapshot.hasError) {
                                                                              return Text('${LocaleKeys.Error.tr()}: ${snapshot.error}');
                                                                            }
                                                                            if (snapshot.hasData) {
                                                                              String username = snapshot.data!;
                                                                              return Text(shortenUsername(username));
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
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 8, 20, 8),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          LocaleKeys.Leave_Manager.tr(),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 0, 20, 0),
                                      child: GestureDetector(
                                        onTap: () async {
                                          int physioId =
                                              await userManagementService
                                                  .fetchUserIdByUid(uid);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  LeaveListScreen(
                                                physioId: physioId,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Card(
                                          color: Colors.blue.shade100,
                                          elevation: 5.0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            child: Container(
                                              height: 150.0,
                                              width: double.infinity,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Image.asset(
                                                  ImageConstant.LEAVE,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 8, 20, 8),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          LocaleKeys.Appointment_History.tr(),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 0, 20, 0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AppointmentHistoryPhysioScreen(),
                                            ),
                                          );
                                        },
                                        child: Card(
                                          color: Colors.blue.shade100,
                                          elevation: 5.0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            child: Container(
                                              height: 150.0,
                                              width: double.infinity,
                                              child: Image.asset(
                                                ImageConstant
                                                    .APPOINTMENT_HISTORY,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }))
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
                        LocaleKeys.Home.tr(),
                        style: TextStyle(
                          fontSize: TextConstant.TITLE_FONT_SIZE,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 70,
                    right: 0,
                    child: Image.asset(
                      ImageConstant.PHYSIO_HOME,
                      width: 211.0,
                      height: 169.0,
                    ),
                  ),
                  Positioned(
                    top: 125,
                    left: 25,
                    child: Text('${LocaleKeys.welcome.tr()} $username',
                        style: TextStyle(
                            fontSize: 25.0, fontWeight: FontWeight.bold)),
                  ),
                  Positioned(
                    top: 160,
                    left: 40,
                    child: Text(LocaleKeys.Start_tracking_your_patients.tr(),
                        style: TextStyle(fontSize: 13.0)),
                  ),
                ],
              );
            }
          }),
    ));
  }
}
