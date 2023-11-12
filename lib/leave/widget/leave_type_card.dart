import 'package:flutter/material.dart';

class LeaveTypeCard extends StatelessWidget {
  final String leaveType;
  final String? selectedLeaveType;
  final Function(String) onChanged;

  LeaveTypeCard({
    required this.leaveType,
    required this.selectedLeaveType,
    required this.onChanged,
  });

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
                  leaveType,
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
