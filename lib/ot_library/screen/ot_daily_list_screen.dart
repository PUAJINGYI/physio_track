import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:physio_track/ot_library/model/ot_activity_detail_model.dart';
import 'package:physio_track/ot_library/model/ot_activity_model.dart';
import 'package:physio_track/ot_library/model/ot_library_model.dart';
import '../../constant/ImageConstant.dart';
import '../../notification/widget/shimmering_text_list_widget.dart';
import '../../translations/locale_keys.g.dart';
import '../../translations/service/translate_service.dart';
import 'ot_daily_detail_screen.dart';

class OTDailyListScreen extends StatefulWidget {
  final String uid;
  const OTDailyListScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<OTDailyListScreen> createState() => _OTDailyListScreenState();
}

class _OTDailyListScreenState extends State<OTDailyListScreen> {
  late List<OTActivityDetail> dailyOTList = [];
  late List<OTLibrary> otLibraryList = [];
  late int activityId = 0;
  late double progress = 0.0;
  TranslateService translateService = TranslateService();

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
      return Colors.orange[500]!;
    } else if (level == 'Beginner') {
      return Colors.green[500]!;
    }
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

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return true;
      },
      child: Scaffold(
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
                            itemCount: dailyOTList.length,
                            itemBuilder: (BuildContext context, int index) {
                              OTActivityDetail otActivityDetail =
                                  dailyOTList[index];

                              OTLibrary otLibrary = otLibraryList[index];

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
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  FutureBuilder(
                                                    future: translateService
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
                                                        return ShimmeringTextListWidget(
                                                            width: 300,
                                                            numOfLines:
                                                                2); 
                                                      } else if (snapshot
                                                          .hasError) {
                                                        return Text(
                                                            'Error: ${snapshot.error}');
                                                      } else {
                                                        String title =
                                                            snapshot.data!;
                                                        return Text(
                                                          title,
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
                                                    width:
                                                        90, 
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      border: Border.all(
                                                        color: _getLevelColor(
                                                            otLibrary
                                                                .level), 
                                                        width:
                                                            2.0, 
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center, 
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
                                return GestureDetector(
                                  onTap: () async {
                                    final needUpdate = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OTDailyDetailScreen(
                                          otLibraryId: otLibrary.id,
                                          activityId: activityId,
                                        ), 
                                      ),
                                    );

                                    if (needUpdate != null && needUpdate) {
                                      setState(() {
                                        _loadOTActivitiesRecord();
                                      });
                                    }
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                    child: Card(
                                      color: Color.fromRGBO(241, 243, 250, 1),
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
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    FutureBuilder(
                                                      future:
                                                          translateService
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
                                                          return ShimmeringTextListWidget(
                                                            width: 300,
                                                            numOfLines: 2,
                                                          ); 
                                                        } else if (snapshot
                                                            .hasError) {
                                                          return Text(
                                                              'Error: ${snapshot.error}');
                                                        } else {
                                                          String title =
                                                              snapshot.data!;
                                                          return Text(
                                                            title,
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
                                                      width:
                                                          90,
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        border: Border.all(
                                                          color: _getLevelColor(
                                                              otLibrary
                                                                  .level), 
                                                          width:
                                                              2.0, 
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center, 
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center, 
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
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.blue,
                                                  ),
                                                  child: IconButton(
                                                    onPressed: () async {
                                                      final needUpdate =
                                                          await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              OTDailyDetailScreen(
                                                            otLibraryId:
                                                                otLibrary.id,
                                                            activityId:
                                                                activityId,
                                                          ), 
                                                        ),
                                                      );

                                                      if (needUpdate != null &&
                                                          needUpdate) {
                                                        setState(() {
                                                          _loadOTActivitiesRecord();
                                                        });
                                                      }
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
                          LocaleKeys.Today_OT.tr(),
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
      ),
    );
  }
}
