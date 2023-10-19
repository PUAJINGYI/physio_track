import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:physio_track/ot_library/model/ot_activity_detail_model.dart';
import 'package:physio_track/ot_library/model/ot_activity_model.dart';
import 'package:physio_track/ot_library/model/ot_library_model.dart';
import 'package:physio_track/ot_library/screen/ot_library_detail_screen.dart';

import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import 'ot_daily_detail_screen.dart';

class OTDailyListScreen extends StatefulWidget {
  final String uid;
  const OTDailyListScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<OTDailyListScreen> createState() => _OTDailyListScreenState();
}

class _OTDailyListScreenState extends State<OTDailyListScreen> {
  //String uId = FirebaseAuth.instance.currentUser!.uid;
  late List<OTActivityDetail> dailyOTList = [];
  late List<OTLibrary> otLibraryList = [];
  late int activityId = 0;
  late double progress = 0.0;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadOTActivitiesRecord() async {
    DateTime currentDate = DateTime.now();
    DateTime currentDateWithoutTime =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    final CollectionReference otCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('ot_activities');

    QuerySnapshot otSnapshot = await otCollection.get();
    OTActivity otActivity = otSnapshot.docs
        .map((doc) => OTActivity.fromSnapshot(doc))
        .firstWhere((otActivity) {
      Timestamp otActivityTimestamp = otActivity.date;
      DateTime otActivityDate = otActivityTimestamp.toDate();
      // Compare the dates
      return otActivityDate.year == currentDateWithoutTime.year &&
          otActivityDate.month == currentDateWithoutTime.month &&
          otActivityDate.day == currentDateWithoutTime.day;
    });

    QuerySnapshot otActivitiesSnapshot =
        await otCollection.where('id', isEqualTo: otActivity.id).get();

    if (otActivitiesSnapshot.docs.isNotEmpty) {
      progress = otActivity.progress;
      DocumentSnapshot otActivityDoc = otActivitiesSnapshot.docs[0];
      DocumentReference otActivityDocumentRef = otActivityDoc.reference;
      // if (progress == 1.0) {
      //   otActivityDocumentRef.update({'isDone': true});
      //   otActivityDocumentRef.update({'completeTime': Timestamp.now()});
      // }
      CollectionReference activitiesCollection =
          otActivityDocumentRef.collection('activities');

      QuerySnapshot otSnapshot = await activitiesCollection.get();
      dailyOTList = otSnapshot.docs
          .map((doc) => OTActivityDetail.fromSnapshot(doc))
          .toList();

      for (OTActivityDetail otActivityDetail in dailyOTList) {
        int otLibraryId = otActivityDetail.otid;

        final CollectionReference otLibraryCollection =
            FirebaseFirestore.instance.collection('ot_library');
        QuerySnapshot otLibrarySnapshot =
            await otLibraryCollection.where('id', isEqualTo: otLibraryId).get();
        OTLibrary otLibrary = otLibrarySnapshot.docs
            .map((doc) => OTLibrary.fromSnapshot(doc))
            .firstWhere((otLibrary) {
          return otLibrary.id == otLibraryId;
        });
        if (otLibrary != null) {
          otLibraryList.add(otLibrary);
        }
      }
      activityId = otActivity.id;
      print(otActivity.progress);
    }
  }

  Color _getLevelColor(String level) {
    if (level == 'Advanced') {
      return Colors.red[500]!;
    } else if (level == 'Intermediate') {
      return Colors.yellow[500]!;
    } else if (level == 'Beginner') {
      return Colors.green[500]!;
    }
    // Default color if the level doesn't match the conditions
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
          future: _loadOTActivitiesRecord(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 290.0,
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: otLibraryList.length,
                          itemBuilder: (BuildContext context, int index) {
                            OTLibrary otLibrary = otLibraryList[index];
                            OTActivityDetail otActivityDetail =
                                dailyOTList[index];

                            if (otActivityDetail.isDone) {
                              return Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                child: Card(
                                  color: Color.fromRGBO(198, 243, 205, 1),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: ListTile(
                                            leading: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 5, 0, 5),
                                              child: Container(
                                                width: 80,
                                                height: 56,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.rectangle,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: otLibrary
                                                                .thumbnailUrl !=
                                                            null
                                                        ? NetworkImage(otLibrary
                                                                .thumbnailUrl!)
                                                            as ImageProvider
                                                        : AssetImage(ImageConstant
                                                                .DATA_NOT_FOUND)
                                                            as ImageProvider,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            title: Column(
                                              // Use a Column for title and the new Container
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  otLibrary.title,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14.0),
                                                ),
                                                Container(
                                                  // This is your new Container
                                                  width: 90, // Customize width
                                                  padding: EdgeInsets.all(8.0),
                                                  decoration: BoxDecoration(
                                                    color: Color.fromRGBO(
                                                        198, 243, 205, 1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    border: Border.all(
                                                      color: _getLevelColor(
                                                          otLibrary
                                                              .level), // Set the border color to black
                                                      width:
                                                          1.0, // Set the border width
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center, // Center the text horizontally
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center, // Center the text vertically
                                                    children: [
                                                      Text(
                                                        otLibrary.level,
                                                        style: TextStyle(
                                                          fontSize: 12.0,
                                                          color: _getLevelColor(
                                                              otLibrary.level),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            trailing: Container(
                                              width: 40,
                                              child: Center(
                                                child: Text(
                                                  'Done',
                                                  style: TextStyle(
                                                    fontSize: 15.0,
                                                    color: Color.fromRGBO(
                                                        57, 228, 83, 1),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                child: Card(
                                  color: Color.fromRGBO(241, 243, 250, 1),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: ListTile(
                                            leading: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 5, 0, 5),
                                              child: Container(
                                                width: 90,
                                                height: 56,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.rectangle,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: otLibrary
                                                                .thumbnailUrl !=
                                                            null
                                                        ? NetworkImage(otLibrary
                                                                .thumbnailUrl!)
                                                            as ImageProvider
                                                        : AssetImage(ImageConstant
                                                                .DATA_NOT_FOUND)
                                                            as ImageProvider,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            title: Column(
                                              // Use a Column for title and the new Container
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  otLibrary.title,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14.0),
                                                ),
                                                Container(
                                                  // This is your new Container
                                                  width: 90, // Customize width
                                                  padding: EdgeInsets.all(8.0),
                                                  decoration: BoxDecoration(
                                                    color: Color.fromRGBO(
                                                        241, 243, 250, 1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    border: Border.all(
                                                      color: _getLevelColor(
                                                          otLibrary
                                                              .level), // Set the border color to black
                                                      width:
                                                          1.0, // Set the border width
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center, // Center the text horizontally
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center, // Center the text vertically
                                                    children: [
                                                      Text(
                                                        otLibrary.level,
                                                        style: TextStyle(
                                                          fontSize: 12.0,
                                                          color: _getLevelColor(
                                                              otLibrary.level),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            trailing: Container(
                                              width: 40,
                                              // height: 40,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.blue,
                                              ),
                                              child: IconButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          OTDailyDetailScreen(
                                                        otLibraryId:
                                                            otLibrary.id,
                                                        activityId: activityId,
                                                      ), // Replace NextPage with your desired page
                                                    ),
                                                  );
                                                },
                                                icon: Icon(
                                                  Icons.play_arrow_outlined,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        height: 60.0,
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
                        'Today\'s OT Activities',
                        style: TextStyle(
                          fontSize: TextConstant.TITLE_FONT_SIZE,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 90,
                    left: 0,
                    right: 0,
                    child: CircularPercentIndicator(
                      radius: 90,
                      lineWidth: 20.0,
                      percent: progress,
                      progressColor: Colors.blue,
                      backgroundColor: Colors.blue.shade100,
                      circularStrokeCap: CircularStrokeCap.round,
                      center: Image.asset(
                        ImageConstant.OT,
                        width: 211.0,
                        height: 169.0,
                      ),
                    ),
                  ),
                ],
              );
            }
          }),
    );
  }
}
