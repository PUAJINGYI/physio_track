import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:physio_track/leave/screen/leave_apply_screen.dart';
import 'package:physio_track/leave/widget/leave_type_card.dart';

import '../../constant/ColorConstant.dart';
import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../../notification/service/notification_service.dart';
import '../../notification/widget/shimmering_text_list_widget.dart';
import '../../translations/locale_keys.g.dart';
import '../model/leave_model.dart';
import '../service/leave_service.dart';
import '../widget/calendar_tile.dart';

class LeaveListScreen extends StatefulWidget {
  final int physioId;
  const LeaveListScreen({super.key, required this.physioId});

  @override
  State<LeaveListScreen> createState() => _LeaveListScreenState();
}

class _LeaveListScreenState extends State<LeaveListScreen> {
  LeaveService leaveService = LeaveService();
  late Future<List<Leave>> leaveList;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool isOnCall = true;
  bool isOfficeHour = true;
  NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    leaveList = fetchLeaveHistory();
    updatePhysioAvailability();
  }

  Future<List<Leave>> fetchLeaveHistory() async {
    return await leaveService.fetchLeaveHistoryByPhysioId(widget.physioId);
  }

  Future<void> updatePhysioAvailability() async {
    bool availability =
        await leaveService.checkPhysioAvailability(widget.physioId);
    DateTime nowTime = DateTime.now();
    bool workingHour = true;

    if (nowTime.hour < 10 || nowTime.hour > 20) {
      workingHour = false;
    }
    setState(() {
      isOnCall = availability;
      isOfficeHour = workingHour;
    });
  }

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

  Color getStatusColor() {
    if (isOfficeHour && isOnCall) {
      return ColorConstant.GREEN_BUTTON_PRESSED;
    } else {
      return ColorConstant.RED_BUTTON_PRESSED;
    }
  }

  String getStatusText() {
    if (isOfficeHour && isOnCall) {
      return LocaleKeys.On_Call.tr();
    } else {
      if (!isOfficeHour) {
        return LocaleKeys.Off_Working_Hour.tr();
      }
      if (!isOnCall) {
        return LocaleKeys.On_Leave.tr();
      }
    }
    return '';
  }

  IconData getStatusIcon() {
    if (isOfficeHour && isOnCall) {
      return Icons.phone_in_talk;
    } else {
      return Icons.do_not_disturb;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 260,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Card(
                      child: Container(
                        height: 100,
                        padding: EdgeInsets.all(8.0),
                        color: getStatusColor(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              getStatusIcon(),
                              color: Colors.white,
                              size: 30.0,
                            ),
                            SizedBox(width: 8.0),
                            Text(
                              getStatusText(),
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: () async {
                      setState(() {
                        leaveList = fetchLeaveHistory();
                      });
                    },
                    child: FutureBuilder<List<Leave>>(
                      future: leaveList,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text(
                                  '${LocaleKeys.Error.tr()}: ${snapshot.error}'));
                        }
                        if (snapshot.hasData && snapshot.data!.isEmpty) {
                          return Center(
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
                          );
                        } else {
                          // Handle the case where you have notifications to display
                          return ListView.builder(
                            padding: EdgeInsets.only(top: 0),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                child: Card(
                                  child: ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: CalendarTile(
                                          date: snapshot.data![index].date),
                                    ),
                                    title: FutureBuilder(
                                      future: notificationService.translateText(
                                          snapshot.data![index].reason,
                                          context),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<String> snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return ShimmeringTextListWidget(
                                              width: 300,
                                              numOfLines:
                                                  1); // or any loading indicator
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        } else {
                                          String title = snapshot.data!;
                                          return Text(
                                            title,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20.0),
                                          );
                                        }
                                      },
                                    ),
                                    subtitle: Text(getLeaveType(
                                        snapshot.data![index].leaveType)),
                                    trailing: LeaveTag(snapshot.data![index]),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 70,
                )
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
                  LocaleKeys.Leave_Manager.tr(),
                  style: TextStyle(
                    fontSize: TextConstant.TITLE_FONT_SIZE,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 70,
              right: 0,
              left: 0,
              child: Image.asset(
                ImageConstant.LEAVE,
                width: 271.0,
                height: 190.0,
              ),
            ),
            Positioned(
              bottom: 5,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () async {
                  final needUpdate = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeaveApplyScreen(
                        physioId: widget.physioId,
                      ),
                    ),
                  );

                  if (needUpdate != null && needUpdate) {
                    setState(() {
                      leaveList = fetchLeaveHistory();
                    });
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.add,
                    size: 30,
                    color: Colors.white,
                  ),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue, // Replace with desired button color
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LeaveTag(Leave leave) {
    String leaveTime = '';
    DateTime startTime = leave.startTime;
    DateTime endTime = leave.endTime;
    leaveTime = '${startTime.hour}:00 - ${endTime.hour}:00';
    return Container(
      width: 100,
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: leave.isFullDay
              ? ColorConstant.RED_BUTTON_PRESSED
              : ColorConstant.GREEN_BUTTON_UNPRESSED,
          width: 2.0,
        ),
      ),
      child: Text(
        leave.isFullDay ? LocaleKeys.Full_Day_Text.tr() : leaveTime,
        style: TextStyle(
          color: leave.isFullDay
              ? ColorConstant.RED_BUTTON_PRESSED
              : ColorConstant.GREEN_BUTTON_UNPRESSED,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
