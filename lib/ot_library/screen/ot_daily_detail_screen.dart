import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../achievement/model/achievement_model.dart';
import '../../achievement/service/achievement_service.dart';
import '../../constant/AchievementConstant.dart';
import '../../constant/ColorConstant.dart';
import '../../constant/TextConstant.dart';
import '../../notification/widget/shimmering_text_list_widget.dart';
import '../../reusable_widget/reusable_widget.dart';
import '../../translations/locale_keys.g.dart';
import '../../translations/service/translate_service.dart';
import '../model/ot_activity_model.dart';
import '../model/ot_library_model.dart';
import '../service/ot_library_service.dart';
import '../../achievement/widget/achievement_dialog_widget.dart';
import 'ot_daily_finished_screen.dart';

class OTDailyDetailScreen extends StatefulWidget {
  final int otLibraryId;
  final int activityId;
  const OTDailyDetailScreen(
      {required this.otLibraryId, required this.activityId});

  @override
  State<OTDailyDetailScreen> createState() => _OTDailyDetailScreenState();
}

class _OTDailyDetailScreenState extends State<OTDailyDetailScreen> {
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  String uId = FirebaseAuth.instance.currentUser!.uid;
  late OTLibrary _otLibraryRecord;
  final OTLibraryService _otLibraryService = OTLibraryService();
  final AchievementService _achievementService = AchievementService();
  TranslateService translateService = TranslateService();
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    //_loadOTLibraryRecord();
  }

  Future<void> _loadOTLibraryRecord() async {
    try {
      _otLibraryRecord =
          (await _otLibraryService.fetchOTLibrary(widget.otLibraryId))!;
    } catch (e) {
      print('Error fetching OTLibrary record: $e');
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

    return '';
  }

  Future<void> _markAsCompleted() async {
    _controller.pauseVideo();
    final CollectionReference otCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection('ot_activities');
    QuerySnapshot otActivitiesSnapshot =
        await otCollection.where('id', isEqualTo: widget.activityId).get();
    OTActivity otActivity = otActivitiesSnapshot.docs
        .map((doc) => OTActivity.fromSnapshot(doc))
        .toList()[0];
    if (otActivitiesSnapshot.docs.isNotEmpty && otActivity != null) {
      double progress = otActivity.progress;
      DocumentSnapshot otActivitySnapshot = otActivitiesSnapshot.docs[0];
      DocumentReference otActivityDocumentRef = otActivitySnapshot.reference;

      if (progress < 1.0) {
        await otActivityDocumentRef.update({'progress': progress + 0.20});
        if (progress + 0.20 == 1.0) {
          await otActivityDocumentRef.update({'isDone': true});
          await otActivityDocumentRef.update({'completeTime': Timestamp.now()});
          bool checkFirstCompleteDailyOTActivity =
              await _achievementService.checkFirstCompleteDailyOTActivity(uId);
          bool check3DayStreakOTModule =
              await _achievementService.check3DayStreakOTModule(uId);
          bool check7DayStreakOTModule =
              await _achievementService.check7DayStreakOTModule(uId);
          bool checkAndHandleDailyActivities =
              await _achievementService.checkAndHandleDailyActivities(uId);
          bool checkAndHandleMonthlyActivities =
              await _achievementService.checkAndHandleMonthlyActivities(uId);
          if (checkFirstCompleteDailyOTActivity) {
            Achievement? ach =
                await _achievementService.fetchAchievementsByAchId(
                    AchievementConstant.DAILY_ENGAGEMENT_ID);
            if (ach != null) {
              await showDialog(
                context: context,
                builder: (context) {
                  return AchievementDialogWidget(ach: ach);
                },
              );
            }
          }
          if (check3DayStreakOTModule) {
            Achievement? ach = await _achievementService
                .fetchAchievementsByAchId(AchievementConstant
                    .OCCUPATIONAL_ENTHUSIAST_3_DAY_STREAK_ID);
            if (ach != null) {
              await showDialog(
                context: context,
                builder: (context) {
                  return AchievementDialogWidget(ach: ach);
                },
              );
            }
          }
          if (check7DayStreakOTModule) {
            Achievement? ach =
                await _achievementService.fetchAchievementsByAchId(
                    AchievementConstant.OCCUPATIONAL_MASTER_7_DAY_STREAK_ID);
            if (ach != null) {
              await showDialog(
                context: context,
                builder: (context) {
                  return AchievementDialogWidget(ach: ach);
                },
              );
            }
          }
          if (checkAndHandleDailyActivities) {
            Achievement? ach =
                await _achievementService.fetchAchievementsByAchId(
                    AchievementConstant.TWO_MODULE_TRIUMPH_ID);
            if (ach != null) {
              await showDialog(
                context: context,
                builder: (context) {
                  return AchievementDialogWidget(ach: ach);
                },
              );
            }
          }
          if (checkAndHandleMonthlyActivities) {
            Achievement? ach =
                await _achievementService.fetchAchievementsByAchId(
                    AchievementConstant.LIFELONG_WELLNESS_CHAMPION);
            if (ach != null) {
              await showDialog(
                context: context,
                builder: (context) {
                  return AchievementDialogWidget(ach: ach);
                },
              );
            }
          }
        }
      }
      final activitiesRef = otActivityDocumentRef.collection('activities');
      final QuerySnapshot activitySnapshot = await activitiesRef
          .where('otid', isEqualTo: widget.otLibraryId)
          .get();

      if (activitySnapshot.docs.isNotEmpty) {
        DocumentSnapshot activityDocSnapshot = activitySnapshot.docs[0];
        DocumentReference activityDocRef = activityDocSnapshot.reference;
        await activityDocRef.update({'isDone': true});
        await activityDocRef.update({'completeTime': Timestamp.now()});
        bool checkFirstOTActivity =
            await _achievementService.checkFirstOTActivity(uId);
        bool check30OTActivities =
            await _achievementService.check30OTActivities(uId);
        bool check50OTActivities =
            await _achievementService.check50OTActivities(uId);
        bool check80OTActivities =
            await _achievementService.check80OTActivities(uId);
        if (checkFirstOTActivity) {
          Achievement? ach = await _achievementService.fetchAchievementsByAchId(
              AchievementConstant.OCCUPATIONAL_ONSET_ID);
          if (ach != null) {
            await showDialog(
              context: context,
              builder: (context) {
                return AchievementDialogWidget(ach: ach);
              },
            );
          }
        }
        if (check30OTActivities) {
          Achievement? ach = await _achievementService
              .fetchAchievementsByAchId(AchievementConstant.ADAPTIVE_ADEPT_ID);
          if (ach != null) {
            await showDialog(
              context: context,
              builder: (context) {
                return AchievementDialogWidget(ach: ach);
              },
            );
          }
        }
        if (check50OTActivities) {
          Achievement? ach = await _achievementService.fetchAchievementsByAchId(
              AchievementConstant.LIFE_IMPROVEMENT_TRAILBLAZER_ID);
          if (ach != null) {
            await showDialog(
              context: context,
              builder: (context) {
                return AchievementDialogWidget(ach: ach);
              },
            );
          }
        }
        if (check80OTActivities) {
          Achievement? ach = await _achievementService.fetchAchievementsByAchId(
              AchievementConstant.OCCUPATIONAL_ODYSSEY_ID);
          if (ach != null) {
            await showDialog(
              context: context,
              builder: (context) {
                return AchievementDialogWidget(ach: ach);
              },
            );
          }
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.Activity_marked_as_completed.tr()),
          backgroundColor: Colors.green[500],
        ),
      );
      await _updateLevelAndProgress();
      if (progress + 0.20 == 1.0) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTDailyFinishedScreen(),
          ),
        );
      } else {
        Navigator.pop(context, true);
      }
    }
  }

  String extractVideoIdFromUrl(String url) {
    // Check if the URL contains 'v='
    final startIndex = url.indexOf('v=');
    if (startIndex != -1) {
      // Find the '&' character or the end of the string, whichever comes first
      final endIndex = url.indexOf('&', startIndex);
      if (endIndex != -1) {
        // Extract the substring between 'v=' and '&' (or end of string)
        return url.substring(startIndex + 2, endIndex);
      } else {
        // If there's no '&', return the substring from 'v=' to the end of the string
        return url.substring(startIndex + 2);
      }
    }
    // If 'v=' is not found in the URL, return an empty string or handle it as needed
    return '';
  }

  Future<void> _updateLevelAndProgress() async {
    DocumentReference userRef = usersCollection.doc(uId);

    try {
      DocumentSnapshot userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        // Retrieve the existing experience and level from the document snapshot
        int existingExperience = userSnapshot.get('totalExp') ?? 0;
        //int existingLevel = userSnapshot.get('level') ?? 1;
        int updatedExperience = _otLibraryRecord.exp + existingExperience;
        // Calculate the new level and progress using the provided method
        //int level = calculateLevelAndProgress(existingExperience);
        Map<int, double> levelInfo =
            calculateLevelAndProgress(updatedExperience);
        // Update the user document with the new level and progress
        int levelUpdated = levelInfo.keys.first;
        double progressToNextLevel = levelInfo.values.first;

        if ((levelUpdated == 10 || levelUpdated == 20) &&
            progressToNextLevel == 0.0) {
          String dailyStatus = userSnapshot.get('dailyStatus');
          String upperStatus = userSnapshot.get('upperStatus');
          String lowerStatus = userSnapshot.get('lowerStatus');
          dailyStatus = changeAndUpdateStatus(dailyStatus);
          upperStatus = changeAndUpdateStatus(upperStatus);
          lowerStatus = changeAndUpdateStatus(lowerStatus);

          await userRef.update({
            'dailyStatus': dailyStatus,
            'upperStatus': upperStatus,
            'lowerStatus': lowerStatus,
          });
        }
        await userRef.update({
          'level': levelUpdated,
          'progressToNextLevel': progressToNextLevel,
          'totalExp': updatedExperience,
        });

        print("Level and progress updated successfully.");
      } else {
        print("User document does not exist.");
      }
    } catch (error) {
      print("Error updating level and progress: $error");
    }
  }

  String changeAndUpdateStatus(String status) {
    if (status == 'beginner') {
      return 'intermediate';
    } else if (status == 'intermediate') {
      return 'advanced';
    } else {
      return 'advanced';
    }
  }

  Map<int, double> calculateLevelAndProgress(int experience) {
    Map<int, double> levelInfo = {};

    int level = 1;
    int requiredExperience = 50;
    double progressToNextLevel = 0;
    // exp =150 > rexp=150
    while (experience >= requiredExperience) {
      level++;
      if (experience == requiredExperience) {
        progressToNextLevel = 0.0;
        break;
      }
      requiredExperience = requiredExperience + (level - 1) * 50 + 50;
      progressToNextLevel = experience / requiredExperience;
    }
    // progressToNextLevel gt issue
    // if (experience == requiredExperience) {
    //   level++;
    // }

    if (level == 1) {
      progressToNextLevel = experience / 50.0;
    }

    levelInfo[level] = progressToNextLevel;
    return levelInfo;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadOTLibraryRecord(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Ensure that the OTLibrary record is loaded
          final videoUrl = _otLibraryRecord.videoUrl;
          final id = extractVideoIdFromUrl(videoUrl);
          print('videoUrl: ${videoUrl}');

          _controller = YoutubePlayerController.fromVideoId(
            videoId: id,
            autoPlay: false,
            params: const YoutubePlayerParams(
                showControls: true,
                mute: false,
                showFullscreenButton: true,
                loop: false,
                enableJavaScript: false,
                color: 'red'),
          );

          _controller.setFullScreenListener(
            (isFullScreen) {
              log('${isFullScreen ? 'Entered' : 'Exited'} Fullscreen.');
            },
          );
          return YoutubePlayerScaffold(
            controller: _controller,
            builder: (context, player) {
              return Scaffold(
                body: Stack(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (kIsWeb && constraints.maxWidth > 750) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 40.0),
                              Expanded(
                                flex: 20,
                                child: Column(
                                  children: [
                                    player,
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: FutureBuilder(
                                        future:
                                            translateService.translateText(
                                                _otLibraryRecord.title,
                                                context),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<String> snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return ShimmeringTextListWidget(
                                              width: 300,
                                              numOfLines: 2,
                                            ); // or any loading indicator
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          } else {
                                            String title = snapshot.data!;
                                            return Text(
                                              title,
                                              style: TextStyle(
                                                fontSize: 24.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            border: Border.all(
                                              color: Colors.blue[500]!,
                                              width: 2.0,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.access_time,
                                                  color: Colors.blue[500]),
                                              SizedBox(width: 4.0),
                                              Text(
                                                '${_otLibraryRecord.duration} ${LocaleKeys.minutes.tr()}',
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: Colors.blue[500],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 8.0),
                                        Container(
                                          padding: EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            border: Border.all(
                                              color: _getLevelColor(
                                                  _otLibraryRecord.level),
                                              width: 2.0,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.directions_run,
                                                  color: _getLevelColor(
                                                      _otLibraryRecord.level)),
                                              SizedBox(width: 4.0),
                                              Text(
                                                _getLevelText(
                                                    _otLibraryRecord.level),
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: _getLevelColor(
                                                      _otLibraryRecord.level),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.0),
                                    Container(
                                      height: 340,
                                      child: FutureBuilder(
                                        future:
                                            translateService.translateText(
                                                _otLibraryRecord.description,
                                                context),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<String> snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return ShimmeringTextListWidget(
                                              width: 400,
                                              numOfLines: 4,
                                            ); // or any loading indicator
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          } else {
                                            String desc = snapshot.data!;
                                            return Text(
                                              desc,
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  color: Colors.grey[500]),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 250.0),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            SizedBox(height: 70),
                            Expanded(
                              child: ListView(
                                padding: EdgeInsets.zero,
                                children: [
                                  player,
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: FutureBuilder(
                                            future: translateService
                                                .translateText(
                                                    _otLibraryRecord.title,
                                                    context),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<String>
                                                    snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return ShimmeringTextListWidget(
                                                  width: 300,
                                                  numOfLines: 2,
                                                ); // or any loading indicator
                                              } else if (snapshot.hasError) {
                                                return Text(
                                                    'Error: ${snapshot.error}');
                                              } else {
                                                String title = snapshot.data!;
                                                return Text(
                                                  title,
                                                  style: TextStyle(
                                                    fontSize: 24.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                border: Border.all(
                                                  color: Colors.blue[500]!,
                                                  width: 2.0,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.access_time,
                                                      color: Colors.blue[500]),
                                                  SizedBox(width: 4.0),
                                                  Text(
                                                    '${_otLibraryRecord.duration} ${LocaleKeys.minutes.tr()}',
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                      color: Colors.blue[500],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 8.0),
                                            Container(
                                              padding: EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                border: Border.all(
                                                  color: _getLevelColor(
                                                      _otLibraryRecord.level),
                                                  width: 2.0,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.directions_run,
                                                      color: _getLevelColor(
                                                          _otLibraryRecord
                                                              .level)),
                                                  SizedBox(width: 4.0),
                                                  Text(
                                                    _getLevelText(
                                                        _otLibraryRecord.level),
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                      color: _getLevelColor(
                                                          _otLibraryRecord
                                                              .level),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.0),
                                        Container(
                                          height: 310,
                                          child: FutureBuilder(
                                            future: translateService
                                                .translateText(
                                                    _otLibraryRecord
                                                        .description,
                                                    context),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<String>
                                                    snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    ShimmeringTextListWidget(
                                                        width: 400,
                                                        numOfLines: 4),
                                                  ],
                                                ); // or any loading indicator
                                              } else if (snapshot.hasError) {
                                                return Text(
                                                    'Error: ${snapshot.error}');
                                              } else {
                                                String desc = snapshot.data!;
                                                return Text(
                                                  desc,
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      color: Colors.grey[500]),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  TextConstant.CUSTOM_BUTTON_SIDE_PADDING,
                                  TextConstant.CUSTOM_BUTTON_TB_PADDING,
                                  TextConstant.CUSTOM_BUTTON_SIDE_PADDING,
                                  TextConstant.CUSTOM_BUTTON_TB_PADDING),
                              child: Container(
                                height: kToolbarHeight,
                                alignment: Alignment.center,
                                child: customButton(
                                  context,
                                  LocaleKeys.Mark_as_Completed.tr(),
                                  ColorConstant.GREEN_BUTTON_TEXT,
                                  ColorConstant.GREEN_BUTTON_UNPRESSED,
                                  ColorConstant.GREEN_BUTTON_PRESSED,
                                  () {
                                    _markAsCompleted();
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 45),
                          ],
                        );
                      },
                    ),
                    Positioned(
                      top: 25,
                      left: 0,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          size: 35.0,
                        ),
                        onPressed: () async {
                          await _controller.stopVideo();
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
                          LocaleKeys.Today_OT_Act1.tr(),
                          style: TextStyle(
                            fontSize: TextConstant.TITLE_FONT_SIZE,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          // While loading, you can show a loading indicator or other widgets
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
