import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:physio_track/achievement/screen/weekly_analysis_screen.dart';
import 'package:physio_track/pt_library/screen/pt_daily_list_screen.dart';

import '../../constant/ImageConstant.dart';
import '../../ot_library/model/ot_activity_model.dart';
import '../../ot_library/screen/file2.dart';
import '../../pt_library/model/pt_activity_model.dart';
import '../model/achievement_model.dart';
import '../service/achievement_service.dart';
import 'achievement_list_screen.dart';

class ProgressScreen extends StatefulWidget {
  ProgressScreen({super.key});
  final Color leftBarColor = Color.fromARGB(255, 129, 238, 143);
  final Color rightBarColor = Color.fromARGB(255, 243, 124, 116);
  final Color avgColor = Colors.orange;

  @override
  State<StatefulWidget> createState() => ProgressScreenState();
}

class ProgressScreenState extends State<ProgressScreen> {
  AchievementService _achievementService = AchievementService();
  final double width = 10;
  String uid = FirebaseAuth.instance.currentUser!.uid;
  late List<BarChartGroupData> rawBarGroups = [];
  late List<OTActivity> otList = [];
  late List<PTActivity> ptList = [];
  int touchedGroupIndex = -1;
  String mondayThisWeek = '';
  String sundayThisWeek = '';
  int level = 0;
  double progressToNextLevel = 0.0;
  late PTActivity todayPT = PTActivity(
      id: -1,
      isDone: false,
      date: Timestamp.fromDate(DateTime.now()),
      progress: 0);
  late OTActivity todayOT = OTActivity(
      id: -1,
      isDone: false,
      date: Timestamp.fromDate(DateTime.now()),
      progress: 0);
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    DateTime today = DateTime.now();
    DateTime todayWithoutTime = DateTime(today.year, today.month, today.day);

    DateTime monday =
        todayWithoutTime.subtract(Duration(days: todayWithoutTime.weekday - 1));
    DateTime sunday =
        todayWithoutTime.add(Duration(days: 7 - todayWithoutTime.weekday));
    print(monday);
    print(sunday);
    CollectionReference userCollection =
        FirebaseFirestore.instance.collection('users');
    DocumentReference userRef = userCollection.doc(uid);
    DocumentSnapshot userSnapshot = await userRef.get();

    if (userSnapshot.exists) {
      // Retrieve the existing experience and level from the document snapshot
      level = userSnapshot.get('level') ?? 0;
      progressToNextLevel = userSnapshot.get('progressToNextLevel') ?? 0.0;
    }
    final CollectionReference ptCollection =
        userCollection.doc(uid).collection('pt_activities');

    // Query for documents between Monday and Sunday of this week
    final QuerySnapshot ptSnapshot = await ptCollection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(monday))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(sunday))
        .get();
    ptList =
        ptSnapshot.docs.map((doc) => PTActivity.fromSnapshot(doc)).toList();

    for (var pt in ptList) {
      if (pt.date.toDate().day == todayWithoutTime.day) {
        todayPT = pt;
      }
    }
    // Check the first date in ptList
    if (ptList.isNotEmpty) {
      DateTime firstDate = ptList[0].date.toDate();
      int daysToAdd = monday.difference(firstDate).inDays;

      // Add PTActivity objects at the beginning or end based on the first date
      if (daysToAdd > 0) {
        for (int i = 0; i < daysToAdd; i++) {
          ptList.insert(
              0,
              PTActivity(
                  id: 0,
                  isDone: false,
                  date: Timestamp.fromDate(monday.add(Duration(days: i))),
                  progress: 0.0));
        }
      }
    }
    DateTime lastDatePTList = ptList[ptList.length - 1].date.toDate();
    int i = 1;
    // Ensure both lists have a length of 7
    while (ptList.length < 7) {
      ptList.add(PTActivity(
          id: 0,
          isDone: false,
          date: Timestamp.fromDate(lastDatePTList.add(Duration(days: i))),
          progress: 0.0));
      i++;
    }

    final CollectionReference otCollection =
        userCollection.doc(uid).collection('ot_activities');

    // Query for documents between Monday and Sunday of this week
    final QuerySnapshot otSnapshot = await otCollection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(monday))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(sunday))
        .get();
    otList =
        otSnapshot.docs.map((doc) => OTActivity.fromSnapshot(doc)).toList();
    for (var ot in otList) {
      if (ot.date.toDate().day == todayWithoutTime.day) {
        todayOT = ot;
      }
    }
    if (otList.isNotEmpty) {
      DateTime firstDate = otList[0].date.toDate();
      int daysToAdd = monday.difference(firstDate).inDays;

      // Add PTActivity objects at the beginning or end based on the first date
      if (daysToAdd > 0) {
        for (int i = 0; i < daysToAdd; i++) {
          otList.insert(
              0,
              OTActivity(
                  id: 0,
                  isDone: false,
                  date: Timestamp.fromDate(monday.add(Duration(days: i))),
                  progress: 0.0));
        }
      }
    }
    DateTime lastDateOTList = otList[otList.length - 1].date.toDate();

    int j = 1;
    while (otList.length < 7) {
      otList.add(OTActivity(
          id: 0,
          isDone: false,
          date: Timestamp.fromDate(lastDateOTList.add(Duration(days: i))),
          progress: 0.0));
      j++;
    }
    print("ptlength :${ptList.length}");
    print("otlength :${otList.length}");
    mondayThisWeek = DateFormat('dd/MM').format(monday);
    sundayThisWeek = DateFormat('dd/MM').format(sunday);
    List<Achievement> ach =
        await _achievementService.fetchCompletedAchievements(uid);
    if (ach.isNotEmpty) {
      for (int i = 0; i < ach.length; i++) {
        imageUrls.add(ach[i].imageUrl);
      }
    }
    createBarGroups(); // After fetching data, create bar groups
  }

  void createBarGroups() {
    final List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < ptList.length; i++) {
      final BarChartGroupData barGroup = makeGroupData(
        i,
        ptList[i].progress * 100,
        otList[i].progress * 100,
      );
      barGroups.add(barGroup);
    }

    setState(() {
      rawBarGroups = barGroups;
    });
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: widget.leftBarColor,
          width: width,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            //background bar percentage
            toY: 100,
            color: Colors.grey.shade300,
          ),
        ),
        BarChartRodData(
          toY: y2,
          color: widget.rightBarColor,
          width: width,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            //background bar percentage
            toY: 100,
            color: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

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
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Current Level',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    15.0), // Adjust the radius as needed
                                child: Card(
                                  color: Color.fromARGB(255, 255, 231, 196),
                                  elevation: 5.0,
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: Image.asset(
                                              ImageConstant
                                                  .LEVEL, // Replace with your image path
                                              width: 60.0,
                                              height: 60.0,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 0, 0, 0),
                                                child: Text(
                                                  'Level ${level}',
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5.0),
                                              Column(
                                                children: [
                                                  LinearPercentIndicator(
                                                    animation: true,
                                                    lineHeight: 10.0,
                                                    animationDuration: 2000,
                                                    percent:
                                                        progressToNextLevel,
                                                    barRadius:
                                                        Radius.circular(10.0),
                                                    progressColor:
                                                        Colors.yellow,
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          10, 5, 0, 0),
                                                      child: Text(
                                                        '${progressToNextLevel * 100}%',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
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
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Achievement Gained',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 15, 0),
                              child: GestureDetector(
                                onTap: () {
                                  // Navigate to the new page here
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AchievementListScreen(
                                            uid:
                                                uid)), // Replace DetailsPage() with your actual page
                                  );
                                },
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'More Details >',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors
                                          .black, // You can change the text color to indicate it's clickable
                                      // Add underline to indicate it's clickable
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                            //   child: Card(
                            //     elevation: 2.0,
                            //     color: Colors.blue[50],
                            //     child: CarouselSlider(
                            //       options: CarouselOptions(
                            //         height: 100.0,
                            //         autoPlay: true,
                            //         autoPlayInterval: Duration(
                            //             seconds:
                            //                 3), // Set the auto-play interval
                            //         enlargeCenterPage:
                            //             true, // Enable center enlargement
                            //         viewportFraction: 0.3,
                            //       ),
                            //       items: imageUrls.map((imageUrl) {
                            //         return Builder(
                            //           builder: (BuildContext context) {
                            //             return Container(
                            //               width:
                            //                   MediaQuery.of(context).size.width,
                            //               margin: EdgeInsets.symmetric(
                            //                   horizontal: 5.0),
                            //               decoration: BoxDecoration(
                            //                 color: Colors.transparent,
                            //                 borderRadius:
                            //                     BorderRadius.circular(8.0),
                            //                 image: DecorationImage(
                            //                   image: NetworkImage(imageUrl),
                            //                   fit: BoxFit.fitHeight,
                            //                 ),
                            //               ),
                            //             );
                            //           },
                            //         );
                            //       }).toList(),
                            //     ),
                            //   ),
                            // ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                              child: Card(
                                elevation: 2.0,
                                color: imageUrls.isEmpty
                                    ? Color.fromARGB(255, 255, 196, 196)
                                    : Colors.blue[50],
                                child: imageUrls.isEmpty
                                    ? Container(
                                        height: 100.0,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.error,
                                                color: Colors.red, size: 50.0),
                                            Center(
                                              child: Text(
                                                'No Record',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : CarouselSlider(
                                        options: CarouselOptions(
                                          height: 100.0,
                                          autoPlay: true,
                                          autoPlayInterval:
                                              Duration(seconds: 3),
                                          enlargeCenterPage: true,
                                          viewportFraction: 0.3,
                                        ),
                                        items: imageUrls.map((imageUrl) {
                                          return Builder(
                                            builder: (BuildContext context) {
                                              return Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 5.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  image: DecorationImage(
                                                    image:
                                                        NetworkImage(imageUrl),
                                                    fit: BoxFit.fitHeight,
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }).toList(),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Today’s Progress',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          15.0), // Adjust the radius as needed
                                      child: GestureDetector(
                                        onTap: () {
                                          // Navigate to the other page when the card is tapped
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (context) =>
                                                PTDailyListScreen(uid: uid),
                                          ));
                                        },
                                        child: Card(
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
                                                  height: 5,
                                                ),
                                                CircularPercentIndicator(
                                                  radius: 60,
                                                  lineWidth: 15.0,
                                                  percent: todayPT.progress,
                                                  progressColor: Colors.blue,
                                                  backgroundColor:
                                                      Colors.blue.shade100,
                                                  circularStrokeCap:
                                                      CircularStrokeCap.round,
                                                  center: Text(
                                                    '${todayPT.progress * 100}%',
                                                    style: TextStyle(
                                                      fontSize: 20.0,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          15.0), // Adjust the radius as needed
                                      child: GestureDetector(
                                        onTap: () {
                                          // Navigate to the other page when the card is tapped
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (context) =>
                                                OTDailyListScreen(uid: uid),
                                          ));
                                        },
                                        child: Card(
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
                                                  height: 5,
                                                ),
                                                CircularPercentIndicator(
                                                  radius: 60,
                                                  lineWidth: 15.0,
                                                  percent: todayOT.progress,
                                                  progressColor: Colors.blue,
                                                  backgroundColor:
                                                      Colors.blue.shade100,
                                                  circularStrokeCap:
                                                      CircularStrokeCap.round,
                                                  center: Text(
                                                    '${todayOT.progress * 100}%',
                                                    style: TextStyle(
                                                      fontSize: 20.0,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Weekly Statistics',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  // Navigate to the other page when the card is tapped
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        WeeklyAnalysisScreen(uid: uid),
                                  ));
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      15.0), // Adjust the radius as needed
                                  child: Card(
                                    elevation: 5.0,
                                    child: Container(
                                      height: 200,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 15, 10, 10),
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment
                                                  .centerLeft, // Align left
                                              child: Text(
                                                mondayThisWeek +
                                                    " - " +
                                                    sundayThisWeek,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Expanded(
                                              child: BarChart(
                                                BarChartData(
                                                  maxY: 100,
                                                  // barTouchData: BarTouchData(
                                                  //   touchTooltipData: BarTouchTooltipData(
                                                  //     tooltipBgColor: Colors.grey,
                                                  //     getTooltipItem: (a, b, c, d) => null,
                                                  //   ),
                                                  //   touchCallback: (FlTouchEvent event, response) {
                                                  //     if (response == null || response.spot == null) {
                                                  //       setState(() {
                                                  //         touchedGroupIndex = -1;
                                                  //       });
                                                  //       return;
                                                  //     }

                                                  //     touchedGroupIndex =
                                                  //         response.spot!.touchedBarGroupIndex;

                                                  //     setState(() {
                                                  //       if (!event.isInterestedForInteractions) {
                                                  //         touchedGroupIndex = -1;
                                                  //       }
                                                  //     });
                                                  //   },
                                                  // ),
                                                  titlesData: FlTitlesData(
                                                    show: true,
                                                    rightTitles: AxisTitles(
                                                      sideTitles: SideTitles(
                                                          showTitles: false),
                                                    ),
                                                    topTitles: AxisTitles(
                                                      sideTitles: SideTitles(
                                                          showTitles: false),
                                                    ),
                                                    bottomTitles: AxisTitles(
                                                      sideTitles: SideTitles(
                                                        showTitles: true,
                                                        getTitlesWidget:
                                                            bottomTitles,
                                                        reservedSize: 42,
                                                      ),
                                                    ),
                                                    leftTitles: AxisTitles(
                                                      sideTitles: SideTitles(
                                                        showTitles: true,
                                                        reservedSize: 28,
                                                        interval: 1,
                                                        getTitlesWidget:
                                                            leftTitles,
                                                      ),
                                                    ),
                                                  ),
                                                  borderData: FlBorderData(
                                                    show: false,
                                                  ),
                                                  barGroups: rawBarGroups,
                                                  gridData:
                                                      FlGridData(show: false),
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
                        );
                      }),
                ),
              ],
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
                'Progress',
                style: TextStyle(
                  fontSize: 20.0,
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

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    String text;
    if (value == 0) {
      text = '0%';
    } else if (value == 50) {
      text = '50%';
    } else if (value == 100) {
      text = '100%';
    } else {
      return Container();
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Text(text, style: style),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    final titles = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final Widget text = Text(
      titles[value.toInt()],
      style: const TextStyle(
        color: Color(0xff7589a2),
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16, //margin top
      child: text,
    );
  }
}
