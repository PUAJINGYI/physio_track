import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:physio_track/achievement/screen/physio/patient_details_journal_detail_screen.dart';
import 'package:physio_track/achievement/screen/physio/patient_details_journal_list_screen.dart';
import 'package:physio_track/constant/ImageConstant.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../appointment/screen/appointment_history_screen.dart';
import '../../../constant/ColorConstant.dart';
import '../../../constant/TextConstant.dart';
import '../../../ot_library/model/ot_activity_model.dart';
import '../../../ot_library/service/user_ot_list_service.dart';
import '../../../profile/model/user_model.dart';
import '../../../pt_library/model/pt_activity_model.dart';
import '../../../pt_library/screen/pt_daily_list_screen.dart';
import '../../../pt_library/service/user_pt_list_service.dart';
import '../../../translations/locale_keys.g.dart';
import '../../../user_management/service/user_management_service.dart';
import '../../model/achievement_model.dart';
import '../../service/achievement_service.dart';
import '../achievement_list_screen.dart';
import '../weekly_analysis_otActivity_detail_screen.dart';
import '../weekly_analysis_ptActivity_detail_screen.dart';
import '../weekly_analysis_screen.dart';

class PatientDetailsScreen extends StatefulWidget {
  final int patientId;
  const PatientDetailsScreen({super.key, required this.patientId});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  UserManagementService userManagementService = UserManagementService();
  late UserModel patientInfo = UserModel(
      id: -1,
      username: '',
      email: '',
      profileImageUrl: '',
      role: '',
      level: 0,
      progressToNextLevel: 0.0,
      createTime: Timestamp.fromDate(DateTime.now()),
      isTakenTest: false,
      address: '',
      phone: '',
      totalExp: 0,
      sharedJournal: false,
      gender: '');
  AchievementService _achievementService = AchievementService();
  final double width = 10;
  late List<BarChartGroupData> rawBarGroups = [];
  late List<OTActivity> otList = [];
  late List<PTActivity> ptList = [];
  int touchedGroupIndex = -1;
  String mondayThisWeek = '';
  String sundayThisWeek = '';
  int level = 1;
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
  late String uid = '';
  List<String> imageUrls = [];
  final Color leftBarColor = Color.fromARGB(255, 129, 238, 143);
  final Color rightBarColor = Color.fromARGB(255, 243, 124, 116);
  final Color avgColor = Colors.orange;
  late bool sharedJournal = false;
  UserPTListService userPTListService = UserPTListService();
  UserOTListService userOTListService = UserOTListService();

  @override
  void initState() {
    super.initState();
    // fetchData();
  }

  Future<void> fetchData() async {
    patientInfo = await userManagementService.fecthUserById(widget.patientId);
    uid = await userManagementService.fetchUidByUserId(widget.patientId);
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
      progressToNextLevel =
          userSnapshot.get('progressToNextLevel').toDouble() ?? 0.0;
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
      } else if (daysToAdd < 0) {
        // Change condition to check for a gap before Monday
        for (int i = daysToAdd; i < 0; i++) {
          ptList.insert(
            0,
            PTActivity(
              id: 0,
              isDone: false,
              date: Timestamp.fromDate(monday.add(Duration(days: i))),
              progress: 0.0,
            ),
          );
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
      } else if (daysToAdd < 0) {
        // Change condition to check for a gap before Monday
        for (int i = daysToAdd; i < 0; i++) {
          otList.insert(
            0,
            OTActivity(
              id: 0,
              isDone: false,
              date: Timestamp.fromDate(monday.add(Duration(days: i))),
              progress: 0.0,
            ),
          );
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
    await createBarGroups(); // After fetching data, create bar groups
  }

  Future<void> createBarGroups() async {
    final List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < ptList.length; i++) {
      final BarChartGroupData barGroup = makeGroupData(
        i,
        ptList[i].progress * 100,
        otList[i].progress * 100,
      );
      barGroups.add(barGroup);
    }

    //setState(() {
    rawBarGroups = barGroups;
    //});
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: leftBarColor,
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
          color: rightBarColor,
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
    final titles = <String>[
      LocaleKeys.Mon.tr(),
      LocaleKeys.Tue.tr(),
      LocaleKeys.Wed.tr(),
      LocaleKeys.Thu.tr(),
      LocaleKeys.Fri.tr(),
      LocaleKeys.Sat.tr(),
      LocaleKeys.Sun.tr()
    ];

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

  void sendWhatsAppMessage(String phoneNumber) async {
    if (phoneNumber.length > 0 && phoneNumber != '') {
      String number = formatPhoneNumber(phoneNumber);

      final message =
          LocaleKeys.Hello_this_is_my_message.tr(); // Replace with your message

      // Construct the WhatsApp URL
      //final url = 'https://wa.me/$number/?text=${Uri.parse(message)}';
      final url = dotenv.get('WHATSAPP_API_KEY', fallback: '') +
          number +
          dotenv.get('WHATSAPP_WITH_TEXT', fallback: '') +
          Uri.parse(message).toString();

      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } else {
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
                Text(LocaleKeys.Error.tr()),
                IconButton(
                  icon: Icon(Icons.close, color: ColorConstant.RED_BUTTON_TEXT),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            ),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                LocaleKeys.User_No_HP.tr(),
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
                        backgroundColor: ColorConstant.BLUE_BUTTON_UNPRESSED,
                      ),
                      child: Text(LocaleKeys.OK.tr(),
                          style:
                              TextStyle(color: ColorConstant.BLUE_BUTTON_TEXT)),
                      onPressed: () async {
                        Navigator.pop(context);
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
  }

  String formatPhoneNumber(String phoneNumber) {
    // Remove any '-' or spaces within the phone number
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[-\s]'), '');

    // Check if the phone number starts with '0', and if not, add '60' in front
    if (phoneNumber.startsWith('60')) {
      phoneNumber = phoneNumber;
    } else if (!phoneNumber.startsWith('0')) {
      phoneNumber = '60' + phoneNumber;
    } else {
      phoneNumber = '6' + phoneNumber;
    }

    return phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    String formattedProgress = (progressToNextLevel * 100).toStringAsFixed(2);
    return Scaffold(
        body: Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 90.0,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 70.0,
                  backgroundImage: patientInfo.profileImageUrl == null ||
                          patientInfo.profileImageUrl == ''
                      ? AssetImage(ImageConstant.DEFAULT_USER)
                      : NetworkImage(patientInfo.profileImageUrl)
                          as ImageProvider<Object>?,
                  backgroundColor: Colors.grey,
                ),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              patientInfo.username,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10.0,
            ),
            FutureBuilder(
                future: fetchData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Display a loading indicator while waiting for data
                    return Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    // Display an error message if there's an error during data fetching
                    return Expanded(
                      child: Center(
                        child: Text('Error loading data'),
                      ),
                    );
                  } else {
                    return Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: 1,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      LocaleKeys.Current_Level.tr(),
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
                                                    padding: const EdgeInsets
                                                        .fromLTRB(10, 0, 0, 0),
                                                    child: Text(
                                                      '${LocaleKeys.Level.tr()} ${level}',
                                                      style: TextStyle(
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                            Radius.circular(
                                                                10.0),
                                                        progressColor:
                                                            Colors.yellow,
                                                      ),
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  10, 5, 0, 0),
                                                          child: Text(
                                                            '${formattedProgress}%',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black,
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
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 8, 8, 0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      LocaleKeys.Achivement_Gained.tr(),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 0, 15, 0),
                                  child: GestureDetector(
                                    onTap: () async {
                                      // Navigate to the new page here
                                      String uid = await userManagementService
                                          .fetchUidByUserId(widget.patientId);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AchievementListScreen(
                                                    uid:
                                                        uid)), // Replace DetailsPage() with your actual page
                                      );
                                    },
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        '${LocaleKeys.More_Details.tr()} >',
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
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 0, 8, 8),
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
                                                    color: Colors.red,
                                                    size: 50.0),
                                                Center(
                                                  child: Text(
                                                    LocaleKeys.No_Record.tr(),
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 20.0,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                builder:
                                                    (BuildContext context) {
                                                  return Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5.0),
                                                    decoration: BoxDecoration(
                                                      color: Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                            imageUrl),
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
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 8, 8, 0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      LocaleKeys.Today_Progress.tr(),
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
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          WeeklyAnalysisPTActivityDetailScreen(
                                                            id: todayPT.id,
                                                            uid: uid,
                                                            isPatientView:
                                                                false,
                                                          )));
                                            },
                                            child: Card(
                                              elevation: 5.0,
                                              child: Padding(
                                                padding: EdgeInsets.all(16.0),
                                                child: Column(
                                                  children: <Widget>[
                                                    Text(
                                                      LocaleKeys.PT.tr(),
                                                      style: TextStyle(
                                                        fontSize: 20.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    CircularPercentIndicator(
                                                      radius: 60,
                                                      lineWidth: 15.0,
                                                      percent: todayPT.progress,
                                                      progressColor:
                                                          Colors.blue,
                                                      backgroundColor:
                                                          Colors.blue.shade100,
                                                      circularStrokeCap:
                                                          CircularStrokeCap
                                                              .round,
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
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          WeeklyAnalysisOTActivityDetailScreen(
                                                              id: todayOT.id,
                                                              uid: uid,
                                                              isPatientView:
                                                                  false)));
                                            },
                                            child: Card(
                                              elevation: 5.0,
                                              child: Padding(
                                                padding: EdgeInsets.all(16.0),
                                                child: Column(
                                                  children: <Widget>[
                                                    Text(
                                                      LocaleKeys.OT.tr(),
                                                      style: TextStyle(
                                                        fontSize: 20.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    CircularPercentIndicator(
                                                      radius: 60,
                                                      lineWidth: 15.0,
                                                      percent: todayOT.progress,
                                                      progressColor:
                                                          Colors.blue,
                                                      backgroundColor:
                                                          Colors.blue.shade100,
                                                      circularStrokeCap:
                                                          CircularStrokeCap
                                                              .round,
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
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 8, 8, 0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      LocaleKeys.Weekly_Statistics.tr(),
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
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
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
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
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
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Row(
                                                          children: <Widget>[
                                                            Container(
                                                              width: 10,
                                                              height: 10,
                                                              color: Color.fromARGB(
                                                                  255,
                                                                  129,
                                                                  238,
                                                                  143), // PT color
                                                            ),
                                                            SizedBox(width: 5),
                                                            Text(
                                                                LocaleKeys.PT
                                                                    .tr(),
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black)),
                                                            SizedBox(width: 10),
                                                            Container(
                                                              width: 10,
                                                              height: 10,
                                                              color: Color.fromARGB(
                                                                  255,
                                                                  243,
                                                                  124,
                                                                  116), // OT color
                                                            ),
                                                            SizedBox(width: 5),
                                                            Text(
                                                                LocaleKeys.OT
                                                                    .tr(),
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black))
                                                          ],
                                                        )),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                Expanded(
                                                  child: BarChart(
                                                    BarChartData(
                                                      maxY: 100,
                                                      titlesData: FlTitlesData(
                                                        show: true,
                                                        rightTitles: AxisTitles(
                                                          sideTitles:
                                                              SideTitles(
                                                                  showTitles:
                                                                      false),
                                                        ),
                                                        topTitles: AxisTitles(
                                                          sideTitles:
                                                              SideTitles(
                                                                  showTitles:
                                                                      false),
                                                        ),
                                                        bottomTitles:
                                                            AxisTitles(
                                                          sideTitles:
                                                              SideTitles(
                                                            showTitles: true,
                                                            getTitlesWidget:
                                                                bottomTitles,
                                                            reservedSize: 42,
                                                          ),
                                                        ),
                                                        leftTitles: AxisTitles(
                                                          sideTitles:
                                                              SideTitles(
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
                                                      gridData: FlGridData(
                                                          show: false),
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
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 8, 8, 0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      LocaleKeys.Appointment_History.tr(),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 8, 8, 8),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AppointmentHistoryScreen(
                                            uid: uid,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      color: Colors.blue.shade100,
                                      elevation: 5.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        child: Container(
                                          height:
                                              150.0, // Adjust the height as needed
                                          width: double.infinity,
                                          child: Image.asset(
                                            ImageConstant.PATIENT_LIST,
                                            // fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 8, 8, 0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      LocaleKeys.Patient_Journal.tr(),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 8, 8, 8),
                                  child: sharedJournal
                                      ? GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PatientDetailsJournalListScreen(
                                                    userId: uid,
                                                  ),
                                                ));
                                          },
                                          child: Card(
                                            color: Colors.blue.shade100,
                                            elevation: 5.0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                              child: Container(
                                                height:
                                                    150.0, // Adjust the height as needed
                                                width: double.infinity,
                                                child: Image.asset(
                                                  ImageConstant.JOURNAL_IMAGE,
                                                  //fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  contentPadding: EdgeInsets
                                                      .zero, // Remove content padding
                                                  titlePadding: EdgeInsets.fromLTRB(
                                                      16,
                                                      0,
                                                      16,
                                                      0), // Adjust title padding
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  title: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(LocaleKeys
                                                          .Unable_Access.tr()),
                                                      IconButton(
                                                        icon: Icon(Icons.close,
                                                            color: ColorConstant
                                                                .RED_BUTTON_TEXT),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop(); // Close the dialog
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  content: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      LocaleKeys
                                                          .patient_not_granted_permission_for_sharing_journal
                                                          .tr(),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  actions: [
                                                    Center(
                                                      // Wrap actions in Center widget
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                              ),
                                                              backgroundColor:
                                                                  ColorConstant
                                                                      .BLUE_BUTTON_UNPRESSED,
                                                            ),
                                                            child: Text(
                                                                LocaleKeys.OK
                                                                    .tr(),
                                                                style: TextStyle(
                                                                    color: ColorConstant
                                                                        .BLUE_BUTTON_TEXT)),
                                                            onPressed:
                                                                () async {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Card(
                                            color: Colors.grey.shade400,
                                            elevation: 5.0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                              child: Container(
                                                height:
                                                    150.0, // Adjust the height as needed
                                                width: double.infinity,
                                                child: Image.asset(
                                                  ImageConstant
                                                      .JOURNAL_IMAGE_GREY,
                                                  //fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  }
                })
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
              LocaleKeys.Patient_Details.tr(),
              style: TextStyle(
                fontSize: TextConstant.TITLE_FONT_SIZE,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Positioned(
            top: 190,
            left: 80,
            right: 0,
            child: GestureDetector(
              onTap: () {
                sendWhatsAppMessage(patientInfo.phone);
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.green,
                child: Icon(
                  FontAwesomeIcons.whatsapp,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            )),
      ],
    ));
  }
}
