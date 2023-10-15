import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/intl.dart';

import '../../../constant/ImageConstant.dart';
import '../../../user_management/service/user_management_service.dart';
import '../../model/appointment_in_pending_model.dart';
import '../../service/appointment_in_pending_service.dart';

class AppointmentNewApproveScreen extends StatefulWidget {
  const AppointmentNewApproveScreen({super.key});

  @override
  State<AppointmentNewApproveScreen> createState() =>
      _AppointmentNewApproveScreenState();
}

class _AppointmentNewApproveScreenState
    extends State<AppointmentNewApproveScreen> {
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
        .fetchAllNewAddedPendingAppointmentRecord();
  }

  Future<String> _getUsernameById(int id) async {
    return userManagementService.getUsernameById(id);
  }

  void showRejectConfirmationDialog(BuildContext context, int appointmentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero, // Remove content padding
          titlePadding:
              EdgeInsets.fromLTRB(16, 0, 16, 0), // Adjust title padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Reject Appointment'),
              IconButton(
                icon: Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Are you sure to reject this appointment？',
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            Center(
              // Wrap actions in Center widget
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: Color.fromRGBO(220, 241, 254, 1),
                    ),
                    child: Text('Yes',
                        style:
                            TextStyle(color: Color.fromRGBO(18, 190, 246, 1))),
                    onPressed: () async {
                      await appointmentInPendingService
                          .rejectNewPendingAppointmentRecord(appointmentId);
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
                      backgroundColor: Color.fromARGB(255, 237, 159, 153),
                    ),
                    child: Text('No',
                        style:
                            TextStyle(color: Color.fromARGB(255, 217, 24, 10))),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
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
          contentPadding: EdgeInsets.zero, // Remove content padding
          titlePadding:
              EdgeInsets.fromLTRB(16, 0, 16, 0), // Adjust title padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Approve Appointment'),
              IconButton(
                icon: Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Are you sure to approve this appointment？',
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            Center(
              // Wrap actions in Center widget
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: Color.fromRGBO(220, 241, 254, 1),
                    ),
                    child: Text('Yes',
                        style:
                            TextStyle(color: Color.fromRGBO(18, 190, 246, 1))),
                    onPressed: () async {
                      bool isApproved = await appointmentInPendingService
                          .checkIfNewAppointmentSlotExist(appointmentId);
                      if (!isApproved) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Appointment slot is not available. Please contact user to rebook appointment again.'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Appointment has been approved'),
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
                      backgroundColor: Color.fromARGB(255, 237, 159, 153),
                    ),
                    child: Text('No',
                        style:
                            TextStyle(color: Color.fromARGB(255, 217, 24, 10))),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
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
            return Center(child: Text('Error: ${snapshot.error}'));
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
                  Text('No Record Found',
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
                                      // date and time column
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
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return CircularProgressIndicator();
                                                  }
                                                  if (snapshot.hasError) {
                                                    return Text(
                                                        'Error: ${snapshot.error}');
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
                                                        'Error: ${snapshot.error}');
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
                                              25.0), // Adjust the radius as needed
                                          child: TextButton(
                                            onPressed: () {
                                              showAppproveConfirmationDialog(
                                                  context, appointment.id);
                                            },
                                            style: TextButton.styleFrom(
                                              backgroundColor: Color.fromARGB(
                                                  255,
                                                  197,
                                                  245,
                                                  199), // Background color of the button
                                              primary:
                                                  Colors.white, // Text color
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons
                                                      .check_circle_outlined, // Your icon here
                                                  color: Colors
                                                      .green, // Icon color
                                                ),
                                                SizedBox(width: 10.0),
                                                Text(
                                                  "Approve",
                                                  style: TextStyle(
                                                    fontSize:
                                                        15.0, // Text font size
                                                    color: Colors.green,
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
                                              25.0), // Adjust the radius as needed
                                          child: TextButton(
                                            onPressed: () {
                                              showRejectConfirmationDialog(
                                                  context, appointment.id);
                                            },
                                            style: TextButton.styleFrom(
                                              backgroundColor: Color.fromARGB(
                                                  255,
                                                  241,
                                                  163,
                                                  157), // Background color of the button
                                              primary:
                                                  Colors.white, // Text color
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons
                                                      .cancel_outlined, // Your icon here
                                                  color:
                                                      Colors.red, // Icon colorF
                                                ),
                                                SizedBox(
                                                    width:
                                                        10.0), // Adjust the spacing between the icon and text
                                                Text(
                                                  "Reject",
                                                  style: TextStyle(
                                                    fontSize:
                                                        15.0, // Text font size
                                                    color: Colors.red,
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
