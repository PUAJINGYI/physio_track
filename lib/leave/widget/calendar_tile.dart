import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../translations/locale_keys.g.dart';

class CalendarTile extends StatelessWidget {
  final DateTime date;

  CalendarTile({required this.date});

  String getMonthText(String month) {
    if (month == 'Jan') {
      return LocaleKeys.Jan.tr();
    } else if (month == 'Feb') {
      return LocaleKeys.Feb.tr();
    } else if (month == 'Mar') {
      return LocaleKeys.Mar.tr();
    } else if (month == 'Apr') {
      return LocaleKeys.Apr.tr();
    } else if (month == 'May') {
      return LocaleKeys.May.tr();
    } else if (month == 'Jun') {
      return LocaleKeys.Jun.tr();
    } else if (month == 'Jul') {
      return LocaleKeys.Jul.tr();
    } else if (month == 'Aug') {
      return LocaleKeys.Aug.tr();
    } else if (month == 'Sep') {
      return LocaleKeys.Sep.tr();
    } else if (month == 'Oct') {
      return LocaleKeys.Oct.tr();
    } else if (month == 'Nov') {
      return LocaleKeys.Nov.tr();
    } else if (month == 'Dec') {
      return LocaleKeys.Dec.tr();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60, 
      decoration: BoxDecoration(
        border: Border.all(
            color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom:
                30, 
            child: Container(
              color: Colors.black,
              child: Center(
                child: Text(
                  getMonthText(DateFormat.MMM()
                      .format(date)), 
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
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
                date.day.toString(), 
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
