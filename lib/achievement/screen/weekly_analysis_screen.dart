import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:physio_track/achievement/screen/weekly_analysis_detail_screen.dart';

import '../../constant/ColorConstant.dart';
import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../../ot_library/model/ot_activity_model.dart';
import '../../ot_library/service/user_ot_list_service.dart';
import '../../pt_library/model/pt_activity_model.dart';
import '../../pt_library/service/user_pt_list_service.dart';
import '../../reusable_widget/reusable_widget.dart';
import '../../translations/locale_keys.g.dart';

// Import other necessary packages and classes

class WeeklyAnalysisScreen extends StatefulWidget {
  final String uid;
  const WeeklyAnalysisScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _WeeklyAnalysisScreenState createState() => _WeeklyAnalysisScreenState();
}

class _WeeklyAnalysisScreenState extends State<WeeklyAnalysisScreen> {
  // Define your member variables
  //String uId = FirebaseAuth.instance.currentUser!.uid;
  UserOTListService _userOTListService = UserOTListService();
  UserPTListService _userPTListService = UserPTListService();
  List<OTActivity> otList = [];
  List<PTActivity> ptList = [];
  late DateTime fromDate;
  late DateTime toDate;

  @override
  void initState() {
    super.initState();
    // Set default fromDate and toDate for the current week (Monday to Sunday)
    fromDate = DateTime.now();
    while (fromDate.weekday != DateTime.monday) {
      fromDate = fromDate.subtract(Duration(days: 1));
    }
    toDate = fromDate.add(Duration(days: 6));
    _fetchDateList();
  }

  Future<void> _fetchDateList() async {
    List<OTActivity> otFetch = await _userOTListService.fetchUserListByDate(
        widget.uid, fromDate, toDate);
    List<PTActivity> ptFetch = await _userPTListService.fetchUserListByDate(
        widget.uid, fromDate, toDate);
    if (otList.length == ptList.length) {
      otList = otFetch;
      ptList = ptFetch;
    }
  }

  Future<void> _selectDates(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023), // You can set your desired start date here
      lastDate: DateTime(2101), // You can set your desired end date here
      initialDateRange: DateTimeRange(start: fromDate, end: toDate),
    );
    if (picked != null) {
      setState(() {
        fromDate = picked.start;
        toDate = picked.end;
      });
      // Fetch data for the selected date range here
      await _fetchDateList();
    }
  }

  String _getImageByDate(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return ImageConstant.MONDAY;
      case DateTime.tuesday:
        return ImageConstant.TUESDAY;
      case DateTime.wednesday:
        return ImageConstant.WEDNESDAY;
      case DateTime.thursday:
        return ImageConstant.THURSDAY;
      case DateTime.friday:
        return ImageConstant.FRIDAY;
      case DateTime.saturday:
        return ImageConstant.SATURDAY;
      case DateTime.sunday:
        return ImageConstant.SUNDAY;
      default:
        return ImageConstant.DATA_NOT_FOUND;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _fetchDateList(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('${LocaleKeys.Error.tr()}: ${snapshot.error}'));
          } else {
            return Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 320.0, // Adjust the height as needed
                    ),
                    if (otList.isEmpty)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 100.0,
                                height: 100.0,
                                child:
                                    Image.asset(ImageConstant.DATA_NOT_FOUND),
                              ),
                              Text(LocaleKeys.No_Record_Found.tr(),
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: otList.length,
                          itemBuilder: (BuildContext context, int index) {
                            DateTime date = otList[index].date.toDate();
                            String formattedDate =
                                DateFormat('dd/MM/yyyy (EEEE)').format(date);

                            return GestureDetector(
                              onTap: () {
                                // Navigate to the other page when the card is tapped
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      WeeklyAnalsisDetailScreen(
                                          ot: otList[index],
                                          pt: ptList[index],
                                          uid: widget.uid),
                                ));
                              },
                              child: Card(
                                elevation: 5.0,
                                margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                child: Container(
                                  height: 80.0,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(_getImageByDate(
                                          date)), // Replace with your image path
                                      fit: BoxFit
                                          .cover, // Adjust the fit as needed
                                    ),
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        formattedDate,
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    SizedBox(
                      height: 40.0,
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
                      LocaleKeys.Weekly_Analysis.tr(),
                      style: TextStyle(
                        fontSize: TextConstant.TITLE_FONT_SIZE,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 64,
                  right: 5,
                  child: Image.asset(
                    ImageConstant.WEEKLY_ANALYSIS,
                    width: 200.0,
                    height: 170.0,
                  ),
                ),
                Positioned(
                  top: 125,
                  left: 25,
                  child: Text(LocaleKeys.Weekly_Analysis.tr(),
                      style: TextStyle(
                          fontSize: 25.0, fontWeight: FontWeight.bold)),
                ),
                Positioned(
                  top: 160,
                  left: 60,
                  child: Text(LocaleKeys.Here_is_your_records.tr(),
                      style: TextStyle(fontSize: 15.0)),
                ),
                Positioned(
                  top: kToolbarHeight + 240,
                  left: 16.0,
                  right: 16.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${LocaleKeys.From.tr()}: ${DateFormat('dd/MM/yyyy').format(fromDate)}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '${LocaleKeys.To.tr()}: ${DateFormat('dd/MM/yyyy').format(toDate)}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Positioned(
                    top: kToolbarHeight + 150,
                    left: 0.0,
                    right: 0.0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          TextConstant.CUSTOM_BUTTON_SIDE_PADDING,
                          TextConstant.CUSTOM_BUTTON_TB_PADDING,
                          TextConstant.CUSTOM_BUTTON_SIDE_PADDING,
                          TextConstant.CUSTOM_BUTTON_TB_PADDING),
                      child: customButton(
                          context,
                          LocaleKeys.Select_Dates.tr(),
                          ColorConstant.BLUE_BUTTON_TEXT,
                          ColorConstant.BLUE_BUTTON_UNPRESSED,
                          ColorConstant.BLUE_BUTTON_PRESSED, () {
                        _selectDates(context);
                      }),
                    )
                    //  ElevatedButton(
                    //   onPressed: () => _selectDates(context),
                    //   child: Text("Select Dates"),
                    // ),
                    ),
              ],
            );
          }
        },
      ),
    );
  }
}
