import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CalendarTile extends StatelessWidget {
  final DateTime date;

  CalendarTile({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60, // Adjust the width as needed
      height: 60, // Adjust the height as needed
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black), // Add a border for better visibility
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 30, // Adjust this value to control the height of the upper part
            child: Container(
              color: Colors.black, // Black background for the upper part
              child: Center(
                child: Text(
                  DateFormat.MMM().format(date), // Display the month abbreviation
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                date.day.toString(), // Display the day of the month
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
