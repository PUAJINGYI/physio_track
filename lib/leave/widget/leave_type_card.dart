import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../translations/locale_keys.g.dart';

class LeaveTypeCard extends StatelessWidget {
  final int leaveType;
  final int? selectedLeaveType;
  final Function(int) onChanged;

  LeaveTypeCard({
    required this.leaveType,
    required this.selectedLeaveType,
    required this.onChanged,
  });

  String getLeaveType(int leaveType) {
    if (leaveType == 1) {
      return LocaleKeys.Sick_Leave.tr();
    } else if (leaveType == 2) {
      return LocaleKeys.Annual_Leave.tr();
    } else if (leaveType == 3) {
      return LocaleKeys.Casual_Leave.tr();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          onChanged(leaveType);
        },
        child: Container(
          height: 100,
          child: Card(
            color: selectedLeaveType == leaveType ? Colors.blue : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  getLeaveType(leaveType),
                  style: TextStyle(
                      color: selectedLeaveType == leaveType
                          ? Colors.white
                          : Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
