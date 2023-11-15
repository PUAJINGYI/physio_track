import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:physio_track/leave/screen/leave_apply_screen.dart';

import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
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
    setState(() {
      isOnCall = availability;
    });
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
                  child: Card(
                    child: Container(
                      height: 100,
                      padding: EdgeInsets.all(8.0),
                      color: isOnCall ? Colors.green : Colors.red,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isOnCall ? Icons.phone_in_talk : Icons.do_not_disturb,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            isOnCall ? LocaleKeys.On_Call.tr() : LocaleKeys.On_Leave.tr(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
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
                              child: Text('${LocaleKeys.Error.tr()}: ${snapshot.error}'));
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
                                    leading: CalendarTile(
                                        date: snapshot.data![index].date),
                                    title: Text(snapshot.data![index].reason),
                                    subtitle:
                                        Text(snapshot.data![index].leaveType),
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
                onTap: () async{
                  final needUpdate = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeaveApplyScreen(
                        physioId: widget.physioId,
                      ),
                    ),
                  );

                  if (needUpdate!= null && needUpdate) {
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
}
