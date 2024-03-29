import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../appointment/service/appointment_service.dart';
import '../../constant/ColorConstant.dart';
import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../../reusable_widget/reusable_widget.dart';
import '../../translations/locale_keys.g.dart';
import '../../user_management/service/user_management_service.dart';
import '../model/treatment_model.dart';
import '../service/treatment_service.dart';

class ViewTreatmentReportScreen extends StatefulWidget {
  final int appointmentId;
  const ViewTreatmentReportScreen({super.key, required this.appointmentId});

  @override
  State<ViewTreatmentReportScreen> createState() =>
      _ViewTreatmentReportScreenState();
}

class _ViewTreatmentReportScreenState extends State<ViewTreatmentReportScreen> {
  late Treatment treatmentReport;
  TreatmentService treatmentService = TreatmentService();
  AppointmentService appointmentService = AppointmentService();
  UserManagementService userManagementService = UserManagementService();

  @override
  void initState() {
    super.initState();
  }

  Future<Treatment?> _loadTreatmentReport() async {
    return await treatmentService
        .fetchTreatmentReportByAppointmentId(widget.appointmentId);
  }

  Future<String> _getUsernameById(int id) async {
    String username = await userManagementService.getUsernameById(id);
    username = shortenUsername(username);
    return username;
  }

  String shortenUsername(String fullName) {
    List<String> parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts.first}';
    } else {
      return fullName;
    }
  }

  String getPerformanceText(int performance) {
    if (performance == 1) {
      return LocaleKeys.Poor.tr();
    } else if (performance == 2) {
      return LocaleKeys.Fair.tr();
    } else if (performance == 3) {
      return LocaleKeys.Good.tr();
    } else if (performance == 4) {
      return LocaleKeys.Excellent.tr();
    } else if (performance == 5) {
      return LocaleKeys.Outstanding.tr();
    } else {
      return 'N/A';
    }
  }

  Color getPerformanceTextColor(int performance) {
    if (performance == 1) {
      return Colors.red[500]!;
    } else if (performance == 2) {
      return Colors.orange[500]!;
    } else if (performance == 3) {
      return Colors.yellow[500]!;
    } else if (performance == 4) {
      return Colors.green[500]!;
    } else if (performance == 5) {
      return Colors.blue[500]!;
    } else {
      return Colors.white;
    }
  }

  Color getPerformanceColor(int performance) {
    if (performance == 1) {
      return Colors.red[100]!;
    } else if (performance == 2) {
      return Colors.orange[100]!;
    } else if (performance == 3) {
      return Colors.yellow[100]!;
    } else if (performance == 4) {
      return Colors.green[100]!;
    } else if (performance == 5) {
      return Colors.blue[100]!;
    } else {
      return Colors.white;
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
              height: 240.0,
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  FutureBuilder<Treatment?>(
                    future: _loadTreatmentReport(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        treatmentReport = snapshot.data!;
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: Card(
                            elevation: 3,
                            color: Color.fromRGBO(195, 232, 243, 1),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  '${LocaleKeys.Date.tr()} :',
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 40, 0, 0),
                                                  child: Text(
                                                    DateFormat('dd MMM yyyy')
                                                        .format(treatmentReport
                                                            .dateTime),
                                                    textAlign: TextAlign
                                                        .right, 
                                                    style: TextStyle(
                                                      fontSize: 16.0,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  '${LocaleKeys.Time.tr()} :',
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 40, 0, 0),
                                                  child: Text(
                                                    DateFormat('hh:mm a')
                                                        .format(treatmentReport
                                                            .dateTime),
                                                    textAlign: TextAlign
                                                        .right, 
                                                    style: TextStyle(
                                                      fontSize: 16.0,
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
                                  SizedBox(height: 10.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .medical_services_outlined,
                                                  color: Colors.black,
                                                  size: 25.0,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                FutureBuilder<String>(
                                                  future: _getUsernameById(
                                                      treatmentReport.physioId),
                                                  builder: (context, snapshot) {
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
                                                        username,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      );
                                                    }
                                                    return Container();
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.person,
                                                  color: Colors.black,
                                                  size: 25.0,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                FutureBuilder<String>(
                                                  future: _getUsernameById(
                                                      treatmentReport
                                                          .patientId),
                                                  builder: (context, snapshot) {
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
                                                        username,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      );
                                                    }
                                                    return Container();
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Card(
                                      elevation: 5.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      color: Colors.grey[
                                          300], 
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.directions_walk_outlined,
                                              size: 30.0,
                                              color: Colors
                                                  .black, 
                                            ),
                                            SizedBox(width: 16.0),

                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    LocaleKeys.Leg_Lifting.tr(),
                                                    style: TextStyle(
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${treatmentReport.legLiftingSet} ${LocaleKeys.Sets.tr()} * ${treatmentReport.legLiftingRep} ${LocaleKeys.Reps.tr()}',
                                                    style: TextStyle(
                                                      fontSize: 14.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Card(
                                      elevation: 5.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      color: Colors.grey[
                                          300], 
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.directions_walk_outlined,
                                              size: 30.0,
                                              color: Colors
                                                  .black,
                                            ),
                                            SizedBox(width: 16.0),

                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    LocaleKeys.Standing.tr(),
                                                    style: TextStyle(
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${treatmentReport.standingSet} ${LocaleKeys.Sets.tr()} * ${treatmentReport.standingRep} ${LocaleKeys.Reps.tr()}',
                                                    style: TextStyle(
                                                      fontSize: 14.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Card(
                                      elevation: 5.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      color: Colors.grey[
                                          300], 
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          children: [
                                            Icon(
                                              FontAwesomeIcons.dumbbell,
                                              size: 30.0,
                                              color: Colors
                                                  .black, 
                                            ),
                                            SizedBox(width: 16.0),

                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    LocaleKeys.Arm_Lifting.tr(),
                                                    style: TextStyle(
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${treatmentReport.armLiftingSet} ${LocaleKeys.Sets.tr()} * ${treatmentReport.armLiftingRep} ${LocaleKeys.Reps.tr()}',
                                                    style: TextStyle(
                                                      fontSize: 14.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Card(
                                      elevation: 5.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      color: Colors.grey[
                                          300], 
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          children: [
                                            Icon(
                                              FontAwesomeIcons.shoePrints,
                                              size: 30.0,
                                              color: Colors
                                                  .black, 
                                            ),
                                            SizedBox(width: 16.0),

                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    LocaleKeys.Foot_Stepping
                                                        .tr(),
                                                    style: TextStyle(
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${treatmentReport.footStepSet} ${LocaleKeys.Sets.tr()} * ${treatmentReport.footStepRep} ${LocaleKeys.Reps.tr()}',
                                                    style: TextStyle(
                                                      fontSize: 14.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Text(
                                    '${LocaleKeys.Performance.tr()}:',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Container(
                                    height: 35.0,
                                    color: getPerformanceColor(
                                        treatmentReport.performamce),
                                    child: Center(
                                        child: Text(
                                            getPerformanceText(
                                                treatmentReport.performamce),
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold,
                                              color: getPerformanceTextColor(
                                                  treatmentReport.performamce),
                                            ))),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Text(
                                    '${LocaleKeys.Remarks.tr()}:',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Text(
                                    '${treatmentReport.remark}',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        TextConstant.CUSTOM_BUTTON_SIDE_PADDING,
                        TextConstant.CUSTOM_BUTTON_TB_PADDING,
                        TextConstant.CUSTOM_BUTTON_SIDE_PADDING,
                        TextConstant.CUSTOM_BUTTON_TB_PADDING),
                    child: customButton(
                      context,
                      LocaleKeys.Back.tr(),
                      ColorConstant.BLUE_BUTTON_TEXT,
                      ColorConstant.BLUE_BUTTON_UNPRESSED,
                      ColorConstant.BLUE_BUTTON_PRESSED,
                      () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 45.0,
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
              LocaleKeys.Treatment_Report.tr(),
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
            height: 190.0,
          ),
        ),
      ],
    ));
  }
}
