import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../constant/ImageConstant.dart';
import '../../pt_library/model/pt_activity_detail_model.dart';
import '../../pt_library/model/pt_activity_model.dart';
import '../../pt_library/model/pt_library_model.dart';

class WeeklyAnalysisPTActivityDetailScreen extends StatefulWidget {
  final int id;
  final String uid;
  final bool isPatientView;
  const WeeklyAnalysisPTActivityDetailScreen(
      {super.key,
      required this.id,
      required this.uid,
      required this.isPatientView});

  @override
  State<WeeklyAnalysisPTActivityDetailScreen> createState() =>
      _WeeklyAnalysisPTActivityDetailScreenState();
}

class _WeeklyAnalysisPTActivityDetailScreenState
    extends State<WeeklyAnalysisPTActivityDetailScreen> {
  //String uId = FirebaseAuth.instance.currentUser!.uid;
  late List<PTActivityDetail> dailyPTList = [];
  late List<PTLibrary> ptLibraryList = [];
  late double progress = 0.0;
  late bool afterToday = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadPTActivitiesRecord() async {
    DateTime currentDate = DateTime.now();
    DateTime currentDateWithoutTime =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    final CollectionReference ptCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('pt_activities');

    QuerySnapshot ptSnapshot = await ptCollection.get();
    PTActivity ptActivity = ptSnapshot.docs
        .map((doc) => PTActivity.fromSnapshot(doc))
        .firstWhere((ptActivity) {
      return ptActivity.id == widget.id;
    });

    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);

    if (today.isBefore(ptActivity.date.toDate())) {
      afterToday = true;
    }

    QuerySnapshot ptActivitiesSnapshot =
        await ptCollection.where('id', isEqualTo: ptActivity.id).get();

    if (ptActivitiesSnapshot.docs.isNotEmpty) {
      progress = ptActivity.progress;
      DocumentSnapshot ptActivityDoc = ptActivitiesSnapshot.docs[0];
      DocumentReference ptActivityDocumentRef = ptActivityDoc.reference;
      CollectionReference activitiesCollection =
          ptActivityDocumentRef.collection('activities');

      QuerySnapshot ptSnapshot = await activitiesCollection.get();
      dailyPTList = ptSnapshot.docs
          .map((doc) => PTActivityDetail.fromSnapshot(doc))
          .toList();

      for (PTActivityDetail ptActivityDetail in dailyPTList) {
        int ptLibraryId = ptActivityDetail.ptid;

        final CollectionReference ptLibraryCollection =
            FirebaseFirestore.instance.collection('pt_library');
        QuerySnapshot ptLibrarySnapshot =
            await ptLibraryCollection.where('id', isEqualTo: ptLibraryId).get();
        PTLibrary ptLibrary = ptLibrarySnapshot.docs
            .map((doc) => PTLibrary.fromSnapshot(doc))
            .firstWhere((ptLibrary) {
          return ptLibrary.id == ptLibraryId;
        });
        if (ptLibrary != null) {
          ptLibraryList.add(ptLibrary);
        }
      }
      print(ptActivity.progress);
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

  Color _getLevelBackgroundColor(String level) {
    if (level == 'Advanced') {
      return Colors.red[100]!;
    } else if (level == 'Intermediate') {
      return Colors.yellow[100]!;
    } else if (level == 'Beginner') {
      return Colors.green[100]!;
    }
    // Default background color if the level doesn't match the conditions
    return Colors.grey[300]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
          future: _loadPTActivitiesRecord(),
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
                          itemCount: ptLibraryList.length,
                          itemBuilder: (BuildContext context, int index) {
                            PTLibrary ptLibrary = ptLibraryList[index];
                            PTActivityDetail ptActivityDetail =
                                dailyPTList[index];
                            if (widget.isPatientView == true) {
                              if (afterToday == false) {
                                if (ptActivityDetail.isDone) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                    child: Card(
                                      color: Color.fromRGBO(198, 243, 205, 1),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 5, 0, 5),
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
                                                        image: ptLibrary
                                                                    .thumbnailUrl !=
                                                                null
                                                            ? NetworkImage(ptLibrary
                                                                    .thumbnailUrl)
                                                                as ImageProvider
                                                            : AssetImage(
                                                                    ImageConstant
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
                                                      ptLibrary.title,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 14.0),
                                                    ),
                                                    Container(
                                                      // This is your new Container
                                                      width:
                                                          90, // Customize width
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            _getLevelBackgroundColor(
                                                                ptLibrary
                                                                    .level),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        border: Border.all(
                                                          color: _getLevelColor(
                                                              ptLibrary
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
                                                            ptLibrary.level,
                                                            style: TextStyle(
                                                              fontSize: 12.0,
                                                              color:
                                                                  _getLevelColor(
                                                                      ptLibrary
                                                                          .level),
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
                                      color: Color.fromRGBO(243, 198, 198, 1),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 5, 0, 5),
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
                                                        image: ptLibrary
                                                                    .thumbnailUrl !=
                                                                null
                                                            ? NetworkImage(ptLibrary
                                                                    .thumbnailUrl)
                                                                as ImageProvider
                                                            : AssetImage(
                                                                    ImageConstant
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
                                                      ptLibrary.title,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 14.0),
                                                    ),
                                                    Container(
                                                      // This is your new Container
                                                      width:
                                                          90, // Customize width
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            _getLevelBackgroundColor(
                                                                ptLibrary
                                                                    .level),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        border: Border.all(
                                                          color: _getLevelColor(
                                                              ptLibrary
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
                                                            ptLibrary.level,
                                                            style: TextStyle(
                                                              fontSize: 12.0,
                                                              color:
                                                                  _getLevelColor(
                                                                      ptLibrary
                                                                          .level),
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
                                                      'Miss',
                                                      style: TextStyle(
                                                        fontSize: 15.0,
                                                        color: Color.fromRGBO(
                                                            228, 63, 57, 1),
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
                                }
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
                                                      image: ptLibrary
                                                                  .thumbnailUrl !=
                                                              null
                                                          ? NetworkImage(ptLibrary
                                                                  .thumbnailUrl)
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
                                                    ptLibrary.title,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14.0),
                                                  ),
                                                  Container(
                                                    // This is your new Container
                                                    width:
                                                        90, // Customize width
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          _getLevelBackgroundColor(
                                                              ptLibrary.level),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      border: Border.all(
                                                        color: _getLevelColor(
                                                            ptLibrary
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
                                                          ptLibrary.level,
                                                          style: TextStyle(
                                                            fontSize: 12.0,
                                                            color:
                                                                _getLevelColor(
                                                                    ptLibrary
                                                                        .level),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            } else {
                              if (ptActivityDetail.isDone) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                  child: Card(
                                    color: Color.fromRGBO(198, 243, 205, 1),
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
                                                      image: ptLibrary
                                                                  .thumbnailUrl !=
                                                              null
                                                          ? NetworkImage(ptLibrary
                                                                  .thumbnailUrl)
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
                                                    ptLibrary.title,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14.0),
                                                  ),
                                                  Container(
                                                    // This is your new Container
                                                    width:
                                                        90, // Customize width
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          _getLevelBackgroundColor(
                                                              ptLibrary.level),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      border: Border.all(
                                                        color: _getLevelColor(
                                                            ptLibrary
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
                                                          ptLibrary.level,
                                                          style: TextStyle(
                                                            fontSize: 12.0,
                                                            color:
                                                                _getLevelColor(
                                                                    ptLibrary
                                                                        .level),
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
                                    color: Color.fromRGBO(243, 198, 198, 1),
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
                                                      image: ptLibrary
                                                                  .thumbnailUrl !=
                                                              null
                                                          ? NetworkImage(ptLibrary
                                                                  .thumbnailUrl)
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
                                                    ptLibrary.title,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14.0),
                                                  ),
                                                  Container(
                                                    // This is your new Container
                                                    width:
                                                        90, // Customize width
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          _getLevelBackgroundColor(
                                                              ptLibrary.level),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      border: Border.all(
                                                        color: _getLevelColor(
                                                            ptLibrary
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
                                                          ptLibrary.level,
                                                          style: TextStyle(
                                                            fontSize: 12.0,
                                                            color:
                                                                _getLevelColor(
                                                                    ptLibrary
                                                                        .level),
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
                                                  child: AutoSizeText(
                                                    'Undone',
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                      color: Color.fromRGBO(
                                                          228, 63, 57, 1),
                                                    ),
                                                    maxLines: 1,
                                                    minFontSize: 11,
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
                        'PT Activities',
                        style: TextStyle(
                          fontSize: 20.0,
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
                        ImageConstant.PT,
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
