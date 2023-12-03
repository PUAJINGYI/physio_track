import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../../notification/service/notification_service.dart';
import '../../notification/widget/shimmering_text_list_widget.dart';
import '../../ot_library/model/ot_activity_detail_model.dart';
import '../../ot_library/model/ot_activity_model.dart';
import '../../ot_library/model/ot_library_model.dart';
import '../../translations/locale_keys.g.dart';

class WeeklyAnalysisOTActivityDetailScreen extends StatefulWidget {
  final int id;
  final String uid;
  final bool isPatientView;
  const WeeklyAnalysisOTActivityDetailScreen(
      {super.key,
      required this.id,
      required this.uid,
      required this.isPatientView});

  @override
  State<WeeklyAnalysisOTActivityDetailScreen> createState() =>
      _WeeklyAnalysisOTActivityDetailScreenState();
}

class _WeeklyAnalysisOTActivityDetailScreenState
    extends State<WeeklyAnalysisOTActivityDetailScreen> {
  //String uId = FirebaseAuth.instance.currentUser!.uid;
  late List<OTActivityDetail> dailyOTList = [];
  late List<OTLibrary> otLibraryList = [];
  late double progress = 0.0;
  late bool afterToday = false;
  NotificationService notificationService = NotificationService();

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
      return otActivity.id == widget.id;
    });

    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);

    if (today.isBefore(otActivity.date.toDate())) {
      afterToday = true;
    }

    QuerySnapshot otActivitiesSnapshot =
        await otCollection.where('id', isEqualTo: otActivity.id).get();

    if (otActivitiesSnapshot.docs.isNotEmpty) {
      progress = otActivity.progress;
      DocumentSnapshot otActivityDoc = otActivitiesSnapshot.docs[0];
      DocumentReference otActivityDocumentRef = otActivityDoc.reference;
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
      print(otActivity.progress);
    }
  }

  Color _getLevelColor(String level) {
    if (level == 'Advanced') {
      return Colors.red[500]!;
    } else if (level == 'Intermediate') {
      return Colors.orange[500]!;
    } else if (level == 'Beginner') {
      return Colors.green[500]!;
    }
    // Default color if the level doesn't match the conditions
    return Colors.black;
  }

  String _getLevelText(String level) {
    if (level == 'Advanced') {
      return LocaleKeys.Advanced.tr();
    } else if (level == 'Intermediate') {
      return LocaleKeys.Intermediate.tr();
    } else if (level == 'Beginner') {
      return LocaleKeys.Beginner.tr();
    }
    // Default text if the level doesn't match the conditions
    return LocaleKeys.Beginner.tr();
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
              return Center(
                  child: Text('${LocaleKeys.Error.tr()}: ${snapshot.error}'));
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
                            if (widget.isPatientView == true) {
                              if (afterToday == false) {
                                if (otActivityDetail.isDone) {
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
                                                        image: otLibrary
                                                                    .thumbnailUrl !=
                                                                null
                                                            ? NetworkImage(otLibrary
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
                                                    // Text(
                                                    //   otLibrary.title,
                                                    //   style: TextStyle(
                                                    //       fontWeight:
                                                    //           FontWeight.w500,
                                                    //       fontSize: 14.0),
                                                    // ),
                                                    FutureBuilder(
                                                      future:
                                                          notificationService
                                                              .translateText(
                                                                  otLibrary
                                                                      .title,
                                                                  context),
                                                      builder: (BuildContext
                                                              context,
                                                          AsyncSnapshot<String>
                                                              snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .stretch,
                                                            children: [
                                                              ShimmeringTextListWidget(
                                                                  width: 300,
                                                                  numOfLines:
                                                                      2),
                                                            ],
                                                          ); // or any loading indicator
                                                        } else if (snapshot
                                                            .hasError) {
                                                          return Text(
                                                              'Error: ${snapshot.error}');
                                                        } else {
                                                          String desc =
                                                              snapshot.data!;
                                                          return Text(
                                                            desc,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 14.0),
                                                          );
                                                        }
                                                      },
                                                    ),

                                                    Container(
                                                      // This is your new Container
                                                      width:
                                                          90, // Customize width
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        border: Border.all(
                                                          color: _getLevelColor(
                                                              otLibrary
                                                                  .level), // Set the border color to black
                                                          width:
                                                              2.0, // Set the border width
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
                                                            _getLevelText(
                                                                otLibrary
                                                                    .level),
                                                            style: TextStyle(
                                                              fontSize: 12.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  _getLevelColor(
                                                                      otLibrary
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
                                                      LocaleKeys.Done.tr(),
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
                                                        image: otLibrary
                                                                    .thumbnailUrl !=
                                                                null
                                                            ? NetworkImage(otLibrary
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
                                                    FutureBuilder(
                                                      future:
                                                          notificationService
                                                              .translateText(
                                                                  otLibrary
                                                                      .title,
                                                                  context),
                                                      builder: (BuildContext
                                                              context,
                                                          AsyncSnapshot<String>
                                                              snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .stretch,
                                                            children: [
                                                              ShimmeringTextListWidget(
                                                                  width: 300,
                                                                  numOfLines:
                                                                      2),
                                                            ],
                                                          ); // or any loading indicator
                                                        } else if (snapshot
                                                            .hasError) {
                                                          return Text(
                                                              'Error: ${snapshot.error}');
                                                        } else {
                                                          String desc =
                                                              snapshot.data!;
                                                          return Text(
                                                            desc,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 14.0),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                    Container(
                                                      // This is your new Container
                                                      width:
                                                          90, // Customize width
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        border: Border.all(
                                                          color: _getLevelColor(
                                                              otLibrary
                                                                  .level), // Set the border color to black
                                                          width:
                                                              2.0, // Set the border width
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
                                                            _getLevelText(
                                                                otLibrary
                                                                    .level),
                                                            style: TextStyle(
                                                              fontSize: 12.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  _getLevelColor(
                                                                      otLibrary
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
                                                      LocaleKeys.Miss.tr(),
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
                                                      image: otLibrary
                                                                  .thumbnailUrl !=
                                                              null
                                                          ? NetworkImage(otLibrary
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
                                                  FutureBuilder(
                                                    future: notificationService
                                                        .translateText(
                                                            otLibrary.title,
                                                            context),
                                                    builder: (BuildContext
                                                            context,
                                                        AsyncSnapshot<String>
                                                            snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .stretch,
                                                          children: [
                                                            ShimmeringTextListWidget(
                                                                width: 300,
                                                                numOfLines: 2),
                                                          ],
                                                        ); // or any loading indicator
                                                      } else if (snapshot
                                                          .hasError) {
                                                        return Text(
                                                            'Error: ${snapshot.error}');
                                                      } else {
                                                        String desc =
                                                            snapshot.data!;
                                                        return Text(
                                                          desc,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 14.0),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                  Container(
                                                    // This is your new Container
                                                    width:
                                                        90, // Customize width
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      border: Border.all(
                                                        color: _getLevelColor(
                                                            otLibrary
                                                                .level), // Set the border color to black
                                                        width:
                                                            2.0, // Set the border width
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
                                                          _getLevelText(
                                                              otLibrary.level),
                                                          style: TextStyle(
                                                            fontSize: 12.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                _getLevelColor(
                                                                    otLibrary
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
                                                  FutureBuilder(
                                                    future: notificationService
                                                        .translateText(
                                                            otLibrary.title,
                                                            context),
                                                    builder: (BuildContext
                                                            context,
                                                        AsyncSnapshot<String>
                                                            snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .stretch,
                                                          children: [
                                                            ShimmeringTextListWidget(
                                                                width: 300,
                                                                numOfLines: 2),
                                                          ],
                                                        ); // or any loading indicator
                                                      } else if (snapshot
                                                          .hasError) {
                                                        return Text(
                                                            'Error: ${snapshot.error}');
                                                      } else {
                                                        String desc =
                                                            snapshot.data!;
                                                        return Text(
                                                          desc,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 14.0),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                  Container(
                                                    // This is your new Container
                                                    width:
                                                        90, // Customize width
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      border: Border.all(
                                                        color: _getLevelColor(
                                                            otLibrary
                                                                .level), // Set the border color to black
                                                        width:
                                                            2.0, // Set the border width
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
                                                          _getLevelText(
                                                              otLibrary.level),
                                                          style: TextStyle(
                                                            fontSize: 12.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                _getLevelColor(
                                                                    otLibrary
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
                                                    LocaleKeys.Done.tr(),
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
                                                      image: otLibrary
                                                                  .thumbnailUrl !=
                                                              null
                                                          ? NetworkImage(otLibrary
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
                                                  FutureBuilder(
                                                    future: notificationService
                                                        .translateText(
                                                            otLibrary.title,
                                                            context),
                                                    builder: (BuildContext
                                                            context,
                                                        AsyncSnapshot<String>
                                                            snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .stretch,
                                                          children: [
                                                            ShimmeringTextListWidget(
                                                                width: 300,
                                                                numOfLines: 2),
                                                          ],
                                                        ); // or any loading indicator
                                                      } else if (snapshot
                                                          .hasError) {
                                                        return Text(
                                                            'Error: ${snapshot.error}');
                                                      } else {
                                                        String desc =
                                                            snapshot.data!;
                                                        return Text(
                                                          desc,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 14.0),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                  Container(
                                                    // This is your new Container
                                                    width:
                                                        90, // Customize width
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      border: Border.all(
                                                        color: _getLevelColor(
                                                            otLibrary
                                                                .level), // Set the border color to black
                                                        width:
                                                            2.0, // Set the border width
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
                                                          _getLevelText(
                                                              otLibrary.level),
                                                          style: TextStyle(
                                                            fontSize: 12.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                _getLevelColor(
                                                                    otLibrary
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
                                                    LocaleKeys.Undone.tr(),
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
                        LocaleKeys.OT_Activities.tr(),
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
