import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:physio_track/reusable_widget/reusable_widget.dart';

import '../../constant/ColorConstant.dart';
import '../../constant/TextConstant.dart';
import '../../translations/locale_keys.g.dart';
import '../model/leave_model.dart';
import '../service/leave_service.dart';
import '../widget/leave_type_card.dart';

class LeaveApplyScreen extends StatefulWidget {
  final int physioId;
  const LeaveApplyScreen({super.key, required this.physioId});

  @override
  State<LeaveApplyScreen> createState() => _LeaveApplyScreenState();
}

class _LeaveApplyScreenState extends State<LeaveApplyScreen> {
  int? selectedLeaveType;
  DateTime? selectedDate;
  bool isFullDay = false;
  TimeOfDay startTime = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay endTime = TimeOfDay(hour: 0, minute: 0);
  TextEditingController _reasonController = TextEditingController();
  bool _validateReasonInput = false;
  LeaveService leaveService = LeaveService();

  String formatTime(TimeOfDay time) {
    return DateFormat.Hm().format(DateTime(2023, 1, 1, time.hour, time.minute));
  }

  bool getTime(startTime, endTime) {
    int startTimeInt = (startTime.hour * 60 + startTime.minute) * 60;
    int endTimeInt = (endTime.hour * 60 + endTime.minute) * 60;
    int dif = endTimeInt - startTimeInt;

    if (endTimeInt > startTimeInt) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> submitApplication() async {
    if (selectedDate != null) {
      Leave newLeave = Leave(
        id: 0,
        date: selectedDate!,
        startTime: DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
          startTime.hour,
          startTime.minute,
        ),
        endTime: DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
          endTime.hour,
          endTime.minute,
        ),
        reason: _reasonController.text,
        isFullDay: isFullDay,
        physioId: widget.physioId,
        leaveType: selectedLeaveType!,
      );
      // check existing fuil day leave
      List<Leave> existingLeaves = await leaveService
          .fetchLeaveByPhysioIdAndDate(widget.physioId, selectedDate!);
      if (existingLeaves.isNotEmpty) {
        for (Leave leave in existingLeaves) {
          if (leave.isFullDay) {
            // showSnackBar(
            //     LocaleKeys.You_have_already_applied_for_a_full_day_leave.tr());
            reusableDialog(context, LocaleKeys.Error.tr(),
                LocaleKeys.You_have_already_applied_for_a_full_day_leave.tr());
            return;
          } else if (leave.startTime.hour == startTime.hour &&
              leave.endTime.hour == endTime.hour) {
            // showSnackBar(LocaleKeys
            //     .You_have_already_applied_for_a_leave_at_this_time.tr());
            reusableDialog(
                context,
                LocaleKeys.Error.tr(),
                LocaleKeys.You_have_already_applied_for_a_leave_at_this_time
                    .tr());
            return;
          }
        }
      }

      await leaveService.addLeaveRecord(newLeave);

      setState(() {
        selectedLeaveType = null;
        selectedDate = DateTime(
            selectedDate!.year, selectedDate!.month, selectedDate!.day);
        isFullDay = false;
        startTime = TimeOfDay(hour: 0, minute: 0);
        endTime = TimeOfDay(hour: 0, minute: 0);
        _reasonController.clear();
        _validateReasonInput = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(LocaleKeys.Leave_application_submitted.tr()),
        duration: Duration(seconds: 2),
      ));
      Navigator.pop(context, true);
    } else {
      print('Error: selectedDate is null');
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 70,
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    SizedBox(
                      height: 30.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          LocaleKeys.Leave_Type.tr(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        LeaveTypeCard(
                            leaveType: 1,
                            selectedLeaveType: selectedLeaveType,
                            onChanged: (value) {
                              setState(() {
                                selectedLeaveType = value;
                                print(selectedLeaveType);
                              });
                            }),
                        SizedBox(width: 2.0),
                        LeaveTypeCard(
                            leaveType: 2,
                            selectedLeaveType: selectedLeaveType,
                            onChanged: (value) {
                              setState(() {
                                selectedLeaveType = value;
                                print(selectedLeaveType);
                              });
                            }),
                        SizedBox(width: 2.0),
                        LeaveTypeCard(
                            leaveType: 3,
                            selectedLeaveType: selectedLeaveType,
                            onChanged: (value) {
                              setState(() {
                                selectedLeaveType = value;
                                print(selectedLeaveType);
                              });
                            }),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          LocaleKeys.Date.tr(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      color: Color.fromARGB(255, 233, 243, 252),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DatePicker(
                          locale: context.locale.toString(),
                          height: 100,
                          DateTime.now(),
                          initialSelectedDate: null,
                          selectionColor: Colors.blue,
                          selectedTextColor: Colors.white,
                          onDateChange: (date) {
                            // New date selected
                            setState(() {
                              selectedDate = date;
                              print(selectedDate);
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(LocaleKeys.Full_Day_Leave.tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              )),
                          Switch(
                            value: isFullDay,
                            onChanged: (value) {
                              setState(() {
                                isFullDay = value;
                                if (isFullDay) {
                                  startTime = TimeOfDay(hour: 0, minute: 0);
                                  endTime = TimeOfDay(hour: 23, minute: 59);
                                } else {
                                  startTime = TimeOfDay(hour: 0, minute: 0);
                                  endTime = TimeOfDay(hour: 0, minute: 0);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // Widget for Start Time and End Time Pickers
                    if (!isFullDay)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        LocaleKeys.Start_Time.tr(),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        TimeOfDay? selectedTime =
                                            await showTimePicker(
                                          context: context,
                                          initialTime: startTime,
                                        );
                                        if (selectedTime != null &&
                                            selectedTime != startTime) {
                                          setState(() {
                                            startTime = selectedTime;
                                          });
                                        }
                                      },
                                      child: Container(
                                        width: 150,
                                        height: 40,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          border:
                                              Border.all(color: Colors.black),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(formatTime(startTime)),
                                            Icon(Icons.access_time),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        LocaleKeys.End_Time.tr(),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        TimeOfDay? selectedTime =
                                            await showTimePicker(
                                          context: context,
                                          initialTime: endTime,
                                        );
                                        if (selectedTime != null &&
                                            selectedTime != endTime) {
                                          setState(() {
                                            endTime = selectedTime;
                                          });
                                        }
                                      },
                                      child: Container(
                                        width: 150,
                                        height: 40,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          border:
                                              Border.all(color: Colors.black),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(formatTime(endTime)),
                                            Icon(Icons.access_time),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          LocaleKeys.Reason.tr(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _reasonController,
                        onChanged: (value) {
                          setState(() {
                            _validateReasonInput = value.isEmpty;
                          });
                        },
                        maxLines: 3,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: LocaleKeys.Please_enter_your_reason.tr(),
                          errorText: _validateReasonInput
                              ? LocaleKeys.Please_enter_a_valid_reason.tr()
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(height: 45),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          TextConstant.CUSTOM_BUTTON_SIDE_PADDING,
                          TextConstant.CUSTOM_BUTTON_TB_PADDING,
                          TextConstant.CUSTOM_BUTTON_SIDE_PADDING,
                          TextConstant.CUSTOM_BUTTON_TB_PADDING),
                      child: customButton(
                          context,
                          LocaleKeys.Apply.tr(),
                          ColorConstant.BLUE_BUTTON_TEXT,
                          ColorConstant.BLUE_BUTTON_UNPRESSED,
                          ColorConstant.BLUE_BUTTON_PRESSED, () {
                        if (startTime == endTime ||
                            !getTime(startTime, endTime)) {
                          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          //   content:
                          //       Text(LocaleKeys.Please_enter_a_valid_time.tr()),
                          //   duration: Duration(seconds: 2),
                          // ));
                          reusableDialog(context, LocaleKeys.Error.tr(),
                              LocaleKeys.Please_enter_a_valid_time.tr());
                        } else if (!_validateReasonInput &&
                            selectedLeaveType != null &&
                            selectedDate != null &&
                            _reasonController.text.isNotEmpty &&
                            (!(startTime == TimeOfDay(hour: 0, minute: 0) &&
                                    endTime == TimeOfDay(hour: 0, minute: 0)) ||
                                isFullDay)) {
                          submitApplication();
                        } else {
                          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          //   content: Text(
                          //       LocaleKeys.Please_fill_in_all_the_fields.tr()),
                          //   duration: Duration(seconds: 2),
                          // ));
                          reusableDialog(context, LocaleKeys.Error.tr(),
                              LocaleKeys.Please_fill_in_all_the_fields.tr());
                        }
                      }),
                    ),
                  ],
                ),
              ),
            ],
          )),
      Positioned(
        top: 25,
        left: 0,
        child: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 35.0,
          ),
          onPressed: () {
            Navigator.pop(context, true);
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
            LocaleKeys.Leave_Application.tr(),
            style: TextStyle(
              fontSize: TextConstant.TITLE_FONT_SIZE,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ]));
  }
}
