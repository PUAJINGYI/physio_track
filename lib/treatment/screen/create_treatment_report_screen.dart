import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:physio_track/treatment/screen/treatment_card.dart';

import '../../appointment/model/appointment_model.dart';
import '../../appointment/screen/physio/appointment_history_physio_screen.dart';
import '../../appointment/service/appointment_service.dart';
import '../../constant/ColorConstant.dart';
import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../../reusable_widget/reusable_widget.dart';
import '../model/treatment_model.dart';
import '../service/treatment_service.dart';

class CreateTreatmentReportScreen extends StatefulWidget {
  final int appointmentId;
  const CreateTreatmentReportScreen({super.key, required this.appointmentId});

  @override
  State<CreateTreatmentReportScreen> createState() =>
      _CreateTreatmentReportScreenState();
}

class _CreateTreatmentReportScreenState
    extends State<CreateTreatmentReportScreen> {
  bool legLifting = false;
  bool standing = false;
  bool armLifting = false;
  bool footStepping = false;
  int legLiftingSets = 0;
  int legLiftingReps = 0;
  int standingSets = 0;
  int standingReps = 0;
  int armLiftingSets = 0;
  int armLiftingReps = 0;
  int footSteppingSets = 0;
  int footSteppingReps = 0;
  double performance = 1.0;
  String remarks = '';
  TextEditingController _legLiftingSetsController = TextEditingController();
  TextEditingController _legLiftingRepsController = TextEditingController();
  TextEditingController _standingSetsController = TextEditingController();
  TextEditingController _standingRepsController = TextEditingController();
  TextEditingController _armLiftingSetsController = TextEditingController();
  TextEditingController _armLiftingRepsController = TextEditingController();
  TextEditingController _footSteppingSetsController = TextEditingController();
  TextEditingController _footSteppingRepsController = TextEditingController();
  TextEditingController _remarksController = TextEditingController();
  TreatmentService treatmentService = TreatmentService();
  AppointmentService appointmentService = AppointmentService();

  Widget buildSlider(double value, ValueChanged<double> onChanged) {
    final roundedValue =
        value.round(); // Round the value to the nearest integer

    return Card(
      child: Container(
        color: Colors.blue[50],
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Poor',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('Outstanding',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: roundedValue
                        .toDouble(), // Use the rounded value for the slider
                    min: 1,
                    max: 5,
                    divisions: 4,
                    onChanged: (newValue) {
                      onChanged(newValue);
                    },
                    onChangeEnd: (newValue) {
                      final roundedNewValue =
                          newValue.round(); // Round the new value
                      onChanged(roundedNewValue
                          .toDouble()); // Use the rounded new value
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addTreatmentReport() async {
    if (armLifting) {
      if (_armLiftingSetsController.text.isEmpty ||
          _armLiftingRepsController.text.isEmpty) {
        showAlertDialog(
            context, 'Please fill in the sets and reps for Arm Lifting');
        return;
      } else {
        armLiftingSets = int.tryParse(_armLiftingSetsController.text) ?? 0;
        armLiftingReps = int.tryParse(_armLiftingRepsController.text) ?? 0;
      }
    }

    if (legLifting) {
      if (_legLiftingSetsController.text.isEmpty ||
          _legLiftingRepsController.text.isEmpty) {
        showAlertDialog(
            context, 'Please fill in the sets and reps for Leg Lifting');
        return;
      } else {
        legLiftingSets = int.tryParse(_legLiftingSetsController.text) ?? 0;
        legLiftingReps = int.tryParse(_legLiftingRepsController.text) ?? 0;
      }
    }

    if (standing) {
      if (_standingSetsController.text.isEmpty ||
          _standingRepsController.text.isEmpty) {
        showAlertDialog(
            context, 'Please fill in the sets and reps for Standing');
        return;
      } else {
        standingSets = int.tryParse(_standingSetsController.text) ?? 0;
        standingReps = int.tryParse(_standingRepsController.text) ?? 0;
      }
    }

    if (footStepping) {
      if (_footSteppingSetsController.text.isEmpty ||
          _footSteppingRepsController.text.isEmpty) {
        showAlertDialog(
            context, 'Please fill in the sets and reps for Foot Stepping');
        return;
      } else {
        footSteppingSets = int.tryParse(_footSteppingSetsController.text) ?? 0;
        footSteppingReps = int.tryParse(_footSteppingRepsController.text) ?? 0;
      }
    }

    if (remarks.isEmpty) {
      showAlertDialog(context, 'Please fill in the remarks');
      return;
    }
    Appointment? appointment =
        await appointmentService.fetchAppointmentById(widget.appointmentId);

    if (appointment != null) {
      Treatment treatment = new Treatment(
        id: widget.appointmentId,
        dateTime: appointment.startTime,
        physioId: appointment.physioId,
        patientId: appointment.patientId,
        standingRep: standingReps,
        standingSet: standingSets,
        armLiftingSet: armLiftingSets,
        armLiftingRep: armLiftingReps,
        legLiftingSet: legLiftingSets,
        legLiftingRep: legLiftingReps,
        footStepSet: footSteppingSets,
        footStepRep: footSteppingReps,
        performamce: performance.toInt(),
        remark: remarks,
      );

      await treatmentService
          .addTreatmentReport(widget.appointmentId, treatment)
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Treatment report added successfully!")),
        );
        Navigator.pop(context, true);
      });
    }
  }

  void showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          titlePadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Incomplete Info", style: TextStyle(fontSize: 18)),
              IconButton(
                icon: Icon(Icons.close, color: ColorConstant.RED_BUTTON_TEXT),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              message,
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
   
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: ColorConstant.BLUE_BUTTON_UNPRESSED,
                    ),
                    child: Text('OK',
                        style:
                            TextStyle(color: ColorConstant.BLUE_BUTTON_TEXT)),
                    onPressed: () {
                      Navigator.of(context).pop();
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
              child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: 1,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Card(
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Container(
                              height: 435.0,
                              color: Colors.grey[100],
                              child: Column(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(16, 3, 16, 0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Card(
                                        elevation: 5.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        color: legLifting
                                            ? Colors.orange[100]
                                            : Colors.grey[
                                                300], // Use different colors for active and inactive states
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            children: [
                                              // Left side with icon
                                              Icon(
                                                Icons.directions_walk_outlined,
                                                size: 48.0,
                                                color: Colors
                                                    .black, // Customize the icon color here
                                              ),
                                              SizedBox(width: 16.0),

                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Leg Lifting',
                                                      style: TextStyle(
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: IgnorePointer(
                                                            ignoring:
                                                                !legLifting,
                                                            child: TextField(
                                                              controller:
                                                                  _legLiftingSetsController,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              decoration:
                                                                  InputDecoration(),
                                                              enabled:
                                                                  legLifting,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number, // This sets the keyboard to numeric
                                                              inputFormatters: <
                                                                  TextInputFormatter>[
                                                                FilteringTextInputFormatter
                                                                    .digitsOnly, // Allow only digits
                                                              ],
                                                              onChanged:
                                                                  (value) {
                                                                legLiftingSets =
                                                                    int.tryParse(
                                                                            value) ??
                                                                        0;
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          'set',
                                                          style: TextStyle(
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: IgnorePointer(
                                                            // Prevent user interaction when the card is inactive
                                                            ignoring:
                                                                !legLifting,
                                                            child: TextField(
                                                              controller:
                                                                  _legLiftingRepsController, // Add the controller here
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              decoration:
                                                                  InputDecoration(),
                                                              enabled:
                                                                  legLifting,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number, // This sets the keyboard to numeric
                                                              inputFormatters: <
                                                                  TextInputFormatter>[
                                                                FilteringTextInputFormatter
                                                                    .digitsOnly, // Allow only digits
                                                              ],
                                                              onChanged:
                                                                  (value) {
                                                                legLiftingReps =
                                                                    int.tryParse(
                                                                            value) ??
                                                                        0;
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          'rep',
                                                          style: TextStyle(
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),

                                              SizedBox(width: 16.0),
                                              // Right side with Checkbox
                                              Checkbox(
                                                value: legLifting,
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    legLifting = value ?? false;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(16, 3, 16, 0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Card(
                                        elevation: 5.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        color: standing
                                            ? Colors.orange[100]
                                            : Colors.grey[
                                                300], // Use different colors for active and inactive states
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            children: [
                                              // Left side with icon
                                              Icon(
                                                Icons.directions_walk_outlined,
                                                size: 48.0,
                                                color: Colors
                                                    .black, // Customize the icon color here
                                              ),
                                              SizedBox(width: 16.0),

                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Standing',
                                                      style: TextStyle(
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: IgnorePointer(
                                                            ignoring: !standing,
                                                            child: TextField(
                                                              controller:
                                                                  _standingSetsController,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              decoration:
                                                                  InputDecoration(),
                                                              enabled: standing,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number, // This sets the keyboard to numeric
                                                              inputFormatters: <
                                                                  TextInputFormatter>[
                                                                FilteringTextInputFormatter
                                                                    .digitsOnly, // Allow only digits
                                                              ],
                                                              onChanged:
                                                                  (value) {
                                                                standingSets =
                                                                    int.tryParse(
                                                                            value) ??
                                                                        0;
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          'set',
                                                          style: TextStyle(
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: IgnorePointer(
                                                            // Prevent user interaction when the card is inactive
                                                            ignoring: !standing,
                                                            child: TextField(
                                                              controller:
                                                                  _standingRepsController, // Add the controller here
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              decoration:
                                                                  InputDecoration(),
                                                              enabled: standing,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number, // This sets the keyboard to numeric
                                                              inputFormatters: <
                                                                  TextInputFormatter>[
                                                                FilteringTextInputFormatter
                                                                    .digitsOnly, // Allow only digits
                                                              ],
                                                              onChanged:
                                                                  (value) {
                                                                standingReps =
                                                                    int.tryParse(
                                                                            value) ??
                                                                        0;
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          'rep',
                                                          style: TextStyle(
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),

                                              SizedBox(width: 16.0),
                                              // Right side with Checkbox
                                              Checkbox(
                                                value: standing,
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    standing = value ?? false;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(16, 3, 16, 0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Card(
                                        elevation: 5.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        color: armLifting
                                            ? Colors.orange[100]
                                            : Colors.grey[
                                                300], // Use different colors for active and inactive states
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            children: [
                                              // Left side with icon
                                              Icon(
                                                FontAwesomeIcons.dumbbell,
                                                size: 48.0,
                                                color: Colors
                                                    .black, // Customize the icon color here
                                              ),
                                              SizedBox(width: 16.0),

                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Arm Lifting',
                                                      style: TextStyle(
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: IgnorePointer(
                                                            ignoring:
                                                                !armLifting,
                                                            child: TextField(
                                                              controller:
                                                                  _armLiftingSetsController,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              decoration:
                                                                  InputDecoration(),
                                                              enabled:
                                                                  armLifting,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number, // This sets the keyboard to numeric
                                                              inputFormatters: <
                                                                  TextInputFormatter>[
                                                                FilteringTextInputFormatter
                                                                    .digitsOnly, // Allow only digits
                                                              ],
                                                              onChanged:
                                                                  (value) {
                                                                armLiftingSets =
                                                                    int.tryParse(
                                                                            value) ??
                                                                        0;
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          'set',
                                                          style: TextStyle(
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: IgnorePointer(
                                                            // Prevent user interaction when the card is inactive
                                                            ignoring:
                                                                !armLifting,
                                                            child: TextField(
                                                              controller:
                                                                  _armLiftingRepsController, // Add the controller here
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              decoration:
                                                                  InputDecoration(),
                                                              enabled:
                                                                  armLifting,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number, // This sets the keyboard to numeric
                                                              inputFormatters: <
                                                                  TextInputFormatter>[
                                                                FilteringTextInputFormatter
                                                                    .digitsOnly, // Allow only digits
                                                              ],
                                                              onChanged:
                                                                  (value) {
                                                                armLiftingReps =
                                                                    int.tryParse(
                                                                            value) ??
                                                                        0;
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          'rep',
                                                          style: TextStyle(
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),

                                              SizedBox(width: 16.0),
                                              // Right side with Checkbox
                                              Checkbox(
                                                value: armLifting,
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    armLifting = value ?? false;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(16, 3, 16, 0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Card(
                                        elevation: 5.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        color: footStepping
                                            ? Colors.orange[100]
                                            : Colors.grey[
                                                300], // Use different colors for active and inactive states
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            children: [
                                              // Left side with icon
                                              Icon(
                                                FontAwesomeIcons.shoePrints,
                                                size: 48.0,
                                                color: Colors
                                                    .black, // Customize the icon color here
                                              ),
                                              SizedBox(width: 16.0),

                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Foot Stepping',
                                                      style: TextStyle(
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: IgnorePointer(
                                                            ignoring:
                                                                !footStepping,
                                                            child: TextField(
                                                              controller:
                                                                  _footSteppingSetsController,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              decoration:
                                                                  InputDecoration(),
                                                              enabled:
                                                                  footStepping,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number, // This sets the keyboard to numeric
                                                              inputFormatters: <
                                                                  TextInputFormatter>[
                                                                FilteringTextInputFormatter
                                                                    .digitsOnly, // Allow only digits
                                                              ],
                                                              onChanged:
                                                                  (value) {
                                                                footSteppingSets =
                                                                    int.tryParse(
                                                                            value) ??
                                                                        0;
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          'set',
                                                          style: TextStyle(
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: IgnorePointer(
                                                            // Prevent user interaction when the card is inactive
                                                            ignoring:
                                                                !footStepping,
                                                            child: TextField(
                                                              controller:
                                                                  _footSteppingRepsController, // Add the controller here
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              decoration:
                                                                  InputDecoration(),
                                                              enabled:
                                                                  footStepping,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number, // This sets the keyboard to numeric
                                                              inputFormatters: <
                                                                  TextInputFormatter>[
                                                                FilteringTextInputFormatter
                                                                    .digitsOnly, // Allow only digits
                                                              ],
                                                              onChanged:
                                                                  (value) {
                                                                footSteppingReps =
                                                                    int.tryParse(
                                                                            value) ??
                                                                        0;
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          'rep',
                                                          style: TextStyle(
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 16.0),
                                              // Right side with Checkbox
                                              Checkbox(
                                                value: footStepping,
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    footStepping =
                                                        value ?? false;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Performance',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: buildSlider(
                            performance,
                            (newValue) {
                              setState(() {
                                performance = newValue
                                    .toDouble(); // Update the value when the slider changes
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Remarks',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Card(
                            child: Container(
                              color: Colors.blue[50],
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 15, 20, 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextField(
                                      controller: _remarksController,
                                      decoration: InputDecoration(
                                        hintText: 'Enter remarks',
                                      ),
                                      onChanged: (value) {
                                        remarks = value;
                                      },
                                    ),
                                    SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: customButton(
                context,
                'Submit',
                ColorConstant.GREEN_BUTTON_TEXT,
                ColorConstant.GREEN_BUTTON_UNPRESSED,
                ColorConstant.GREEN_BUTTON_PRESSED,
                () {
                  _addTreatmentReport();
                },
              ),
            ),
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
              'Treatment Report',
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
