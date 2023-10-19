import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:physio_track/achievement/screen/weekly_analysis_otActivity_detail_screen.dart';
import 'package:physio_track/achievement/screen/weekly_analysis_ptActivity_detail_screen.dart';
import 'package:physio_track/ot_library/screen/ot_daily_list_screen.dart';
import 'package:physio_track/pt_library/model/pt_activity_model.dart';

import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../../ot_library/model/ot_activity_model.dart';
import '../../pt_library/screen/pt_daily_list_screen.dart';

class WeeklyAnalsisDetailScreen extends StatefulWidget {
  final String uid;
  final OTActivity ot;
  final PTActivity pt;
  const WeeklyAnalsisDetailScreen(
      {super.key, required this.ot, required this.pt, required this.uid});

  @override
  State<WeeklyAnalsisDetailScreen> createState() =>
      _WeeklyAnalsisDetailScreenState();
}

class _WeeklyAnalsisDetailScreenState extends State<WeeklyAnalsisDetailScreen> {
  DateTime today = DateTime.now();
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
                  height: 250,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        15.0), // Adjust the radius as needed
                    child: GestureDetector(
                      onTap: () {
                        today = DateTime(today.year, today.month, today.day);
                        if (widget.ot.date == Timestamp.fromDate(today)) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PTDailyListScreen(
                              uid: widget.uid,
                            ),
                          ));
                        } else {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                WeeklyAnalysisPTActivityDetailScreen(
                              id: widget.pt.id,
                              uid: widget.uid,
                              isPatientView: true,
                            ),
                          ));
                        }
                      },
                      child: Container(
                        child: Card(
                          color: Color.fromARGB(255, 208, 245, 208),
                          elevation: 5.0,
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  'PT',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Center(
                                  child: CircularPercentIndicator(
                                    radius: 80,
                                    lineWidth: 15.0,
                                    percent: widget.pt.progress,
                                    progressColor: Colors.blue,
                                    backgroundColor: Colors.blue.shade100,
                                    circularStrokeCap: CircularStrokeCap.round,
                                    center: Text(
                                      '${widget.pt.progress * 100}%',
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        15.0), // Adjust the radius as needed
                    child: GestureDetector(
                      onTap: () {
                        today = DateTime(today.year, today.month, today.day);
                        if (widget.ot.date == Timestamp.fromDate(today)) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => OTDailyListScreen(),
                          ));
                        } else {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                WeeklyAnalysisOTActivityDetailScreen(
                              id: widget.ot.id,
                              uid: widget.uid,
                              isPatientView: true,
                            ),
                          ));
                        }
                      },
                      child: Container(
                        child: Card(
                          color: Color.fromARGB(255, 245, 208, 208),
                          elevation: 5.0,
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  'OT',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Center(
                                  child: CircularPercentIndicator(
                                    radius: 80,
                                    lineWidth: 15.0,
                                    percent: widget.ot.progress,
                                    progressColor: Colors.blue,
                                    backgroundColor: Colors.blue.shade100,
                                    circularStrokeCap: CircularStrokeCap.round,
                                    center: Text(
                                      '${widget.ot.progress * 100}%',
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
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
                '${DateFormat('MMM dd').format(widget.ot.date.toDate())}\'s progress',
                style: TextStyle(
                  fontSize: TextConstant.TITLE_FONT_SIZE,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 45,
            right: 5,
            child: Image.asset(
              ImageConstant.PROGRESS,
              width: 220.0,
              height: 220.0,
            ),
          ),
          Positioned(
            top: 125,
            left: 25,
            child: Text('Keep Going',
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold)),
          ),
          Positioned(
            top: 160,
            left: 50,
            child: Text('Start today’s progress',
                style: TextStyle(fontSize: 15.0)),
          ),
        ],
      ),
    );
  }
}
