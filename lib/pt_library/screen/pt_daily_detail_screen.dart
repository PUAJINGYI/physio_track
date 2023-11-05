import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:physio_track/achievement/service/achievement_service.dart';
import 'package:physio_track/pt_library/screen/pt_daily_finished_screen.dart';
import 'package:physio_track/pt_library/screen/pt_daily_list_screen.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../achievement/model/achievement_model.dart';
import '../../constant/AchievementConstant.dart';
import '../../constant/ColorConstant.dart';
import '../../achievement/widget/achievement_dialog_widget.dart';
import '../../constant/TextConstant.dart';
import '../../notification/service/notification_service.dart';
import '../../notification/widget/shimmering_text_list_widget.dart';
import '../../reusable_widget/reusable_widget.dart';
import '../../translations/locale_keys.g.dart';
import '../model/pt_activity_model.dart';
import '../model/pt_library_model.dart';
import '../service/pt_library_service.dart';

class PTDailyDetailScreen extends StatefulWidget {
  final int ptLibraryId;
  final int activityId;
  const PTDailyDetailScreen(
      {required this.ptLibraryId, required this.activityId});

  @override
  State<PTDailyDetailScreen> createState() => _PTDailyDetailScreenState();
}

class _PTDailyDetailScreenState extends State<PTDailyDetailScreen> {
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  String uId = FirebaseAuth.instance.currentUser!.uid;
  late PTLibrary _ptLibraryRecord;
  final PTLibraryService _ptLibraryService = PTLibraryService();
  final AchievementService _achievementService = AchievementService();
  late YoutubePlayerController _controller;
  NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadPTLibraryRecord() async {
    try {
      _ptLibraryRecord =
          (await _ptLibraryService.fetchPTLibrary(widget.ptLibraryId))!;
    } catch (e) {
      print('Error fetching PTLibrary record: $e');
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

  String _getLevelText(String level) {
    if (level == 'Advanced') {
      return LocaleKeys.Advanced.tr();
    } else if (level == 'Intermediate') {
      return LocaleKeys.Intermediate.tr();
    } else if (level == 'Beginner') {
      return LocaleKeys.Beginner.tr();
    }
    // Default background color if the level doesn't match the conditions
    return '';
  }

  Color _getCatBackgroundColor(String cat) {
    if (cat == 'Lower') {
      return Colors.blue[100]!;
    } else if (cat == 'Upper') {
      return Colors.red[100]!;
    } else if (cat == 'Transfer') {
      return Colors.green[100]!;
    } else if (cat == 'Bed Mobility') {
      return Colors.purple[100]!;
    } else if (cat == 'Breathing') {
      return Colors.teal[100]!;
    } else if (cat == 'Core Movement') {
      return Colors.orange[100]!;
    } else if (cat == 'Passive Movement') {
      return Colors.grey[300]!;
    } else if (cat == 'Sitting') {
      return Colors.brown[100]!;
    } else if (cat == 'Active Assisted Movement') {
      return Colors.yellow[100]!;
    }
    // Default background color if the level doesn't match the conditions
    return Colors.grey[300]!;
  }

  IconData _getCatIcon(String cat) {
    if (cat == 'Lower') {
      return Icons.airline_seat_legroom_extra_outlined;
    } else if (cat == 'Upper') {
      return Icons.back_hand_outlined;
    } else if (cat == 'Transfer') {
      return Icons.transfer_within_a_station_outlined;
    } else if (cat == 'Bed Mobility') {
      return Icons.hotel;
    } else if (cat == 'Breathing') {
      return Icons.air_outlined;
    } else if (cat == 'Core Movement') {
      return Icons.accessibility_new_outlined;
    } else if (cat == 'Passive Movement') {
      return Icons.blind_outlined;
    } else if (cat == 'Sitting') {
      return Icons.event_seat_outlined;
    } else if (cat == 'Active Assisted Movement') {
      return Icons.directions_walk_outlined;
    }
    // Default background color if the level doesn't match the conditions
    return Icons.question_mark_outlined;
  }

  String _getCatText(String cat) {
    if (cat == 'Lower') {
      return LocaleKeys.Lower.tr();
    } else if (cat == 'Upper') {
      return LocaleKeys.Upper.tr();
    } else if (cat == 'Transfer') {
      return LocaleKeys.Transfer.tr();
    } else if (cat == 'Bed Mobility') {
      return LocaleKeys.Bed_Mobility.tr();
    } else if (cat == 'Breathing') {
      return LocaleKeys.Breathing.tr();
    } else if (cat == 'Core Movement') {
      return LocaleKeys.Core.tr();
    } else if (cat == 'Passive Movement') {
      return LocaleKeys.Passive.tr();
    } else if (cat == 'Sitting') {
      return LocaleKeys.Sitting.tr();
    } else if (cat == 'Active Assisted Movement') {
      return LocaleKeys.Active.tr();
    }
    return '';
  }

  Color _getCatColor(String cat) {
    if (cat == 'Lower') {
      return Colors.blue[500]!;
    } else if (cat == 'Upper') {
      return Colors.red[500]!;
    } else if (cat == 'Transfer') {
      return Colors.green[500]!;
    } else if (cat == 'Bed Mobility') {
      return Colors.purple[500]!;
    } else if (cat == 'Breathing') {
      return Colors.teal[500]!;
    } else if (cat == 'Core Movement') {
      return Colors.orange[500]!;
    } else if (cat == 'Passive Movement') {
      return Colors.grey[500]!;
    } else if (cat == 'Sitting') {
      return Colors.brown[500]!;
    } else if (cat == 'Active Assisted Movement') {
      return Colors.yellow[500]!;
    }
    // Default color if the level doesn't match the conditions
    return Colors.black;
  }

  Future<void> _markAsCompleted() async {
    // try {
    _controller.pauseVideo();
    final CollectionReference ptCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection('pt_activities');
    QuerySnapshot ptActivitiesSnapshot =
        await ptCollection.where('id', isEqualTo: widget.activityId).get();
    PTActivity ptActivity = ptActivitiesSnapshot.docs
        .map((doc) => PTActivity.fromSnapshot(doc))
        .toList()[0];
    if (ptActivitiesSnapshot.docs.isNotEmpty && ptActivity != null) {
      double progress = ptActivity.progress;
      DocumentSnapshot ptActivitySnapshot = ptActivitiesSnapshot.docs[0];
      DocumentReference ptActivityDocumentRef = ptActivitySnapshot.reference;

      if (progress < 1.0) {
        await ptActivityDocumentRef.update({'progress': progress + 0.20});
        if (progress + 0.2 == 1.0) {
          await ptActivityDocumentRef.update({'isDone': true});
          await ptActivityDocumentRef.update({'completeTime': Timestamp.now()});
          bool checkFirstCompleteDailyPTActivity =
              await _achievementService.checkFirstCompleteDailyPTActivity(uId);
          bool check3DayStreakPTModule =
              await _achievementService.check3DayStreakPTModule(uId);
          bool check7DayStreakPTModule =
              await _achievementService.check7DayStreakPTModule(uId);
          bool checkAndHandleDailyActivities =
              await _achievementService.checkAndHandleDailyActivities(uId);
          bool checkAndHandleMonthlyActivities =
              await _achievementService.checkAndHandleMonthlyActivities(uId);
          if (checkFirstCompleteDailyPTActivity) {
            Achievement? ach =
                await _achievementService.fetchAchievementsByAchId(
                    AchievementConstant.DAILY_DEDICATION_ID);
            if (ach != null) {
              await showDialog(
                context: context,
                builder: (context) {
                  return AchievementDialogWidget(ach: ach);
                },
              );
            }
          }
          if (check3DayStreakPTModule) {
            Achievement? ach =
                await _achievementService.fetchAchievementsByAchId(
                    AchievementConstant.PHYSIO_DYNAMO_3_DAY_STREAK_ID);
            if (ach != null) {
              await showDialog(
                context: context,
                builder: (context) {
                  return AchievementDialogWidget(ach: ach);
                },
              );
            }
          }
          if (check7DayStreakPTModule) {
            Achievement? ach =
                await _achievementService.fetchAchievementsByAchId(
                    AchievementConstant.PHYSIO_VIRTUOSO_7_DAY_STREAK_ID);
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
      final activitiesRef = ptActivityDocumentRef.collection('activities');
      final QuerySnapshot activitySnapshot = await activitiesRef
          .where('ptid', isEqualTo: widget.ptLibraryId)
          .get();

      if (activitySnapshot.docs.isNotEmpty) {
        DocumentSnapshot activityDocSnapshot = activitySnapshot.docs[0];
        DocumentReference activityDocRef = activityDocSnapshot.reference;
        await activityDocRef.update({'isDone': true});
        await activityDocRef.update({'completeTime': Timestamp.now()});
        bool checkFirstPTActivity =
            await _achievementService.checkFirstPTActivity(uId);
        bool check30PTActivities =
            await _achievementService.check30PTActivities(uId);
        bool check50PTActivities =
            await _achievementService.check50PTActivities(uId);
        bool check80OPTActivities =
            await _achievementService.check80PTActivities(uId);
        if (checkFirstPTActivity) {
          Achievement? ach = await _achievementService
              .fetchAchievementsByAchId(AchievementConstant.GOOD_START_ID);
          if (ach != null) {
            await showDialog(
              context: context,
              builder: (context) {
                return AchievementDialogWidget(ach: ach);
              },
            );
          }
        }
        if (check30PTActivities) {
          Achievement? ach = await _achievementService.fetchAchievementsByAchId(
              AchievementConstant.FLEXIBILITY_ACHIEVER_ID);
          if (ach != null) {
            await showDialog(
              context: context,
              builder: (context) {
                return AchievementDialogWidget(ach: ach);
              },
            );
          }
        }
        if (check50PTActivities) {
          Achievement? ach = await _achievementService.fetchAchievementsByAchId(
              AchievementConstant.RANGE_OF_MOTION_MAESTRO_ID);
          if (ach != null) {
            await showDialog(
              context: context,
              builder: (context) {
                return AchievementDialogWidget(ach: ach);
              },
            );
          }
        }
        if (check80OPTActivities) {
          Achievement? ach = await _achievementService.fetchAchievementsByAchId(
              AchievementConstant.PHYSIOTHERAPY_PRODIGY);
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

      // update level and progress
      await _updateLevelAndProgress();

      if (progress + 0.20 == 1.0) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PTDailyFinishedScreen(),
          ),
        );
      } else {
        Navigator.pop(context, true);
      }
    }
    // } catch (e) {
    //   print('Error marking activity as completed: $e');
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Error marking activity as completed'),
    //       backgroundColor: Colors.red[500],
    //     ),
    //   );
    // }
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
        int updatedExperience = _ptLibraryRecord.exp + existingExperience;
        // Calculate the new level and progress using the provided method
        //int level = calculateLevelAndProgress(existingExperience);
        Map<int, double> levelInfo =
            calculateLevelAndProgress(updatedExperience);
        // Update the user document with the new level and progress
        int levelUpdated = levelInfo.keys.first;
        double progressToNextLevel = levelInfo.values.first;

        if (levelUpdated == 10 && progressToNextLevel == 1.0) {
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

    while (experience >= requiredExperience) {
      level++;
      requiredExperience = requiredExperience + (level - 1) * 50 + 50;
      progressToNextLevel = experience / requiredExperience;
    }

    if (level == 1) {
      progressToNextLevel = experience / 50.0;
    }

    levelInfo[level] = progressToNextLevel;
    return levelInfo;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadPTLibraryRecord(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Ensure that the PTLibrary record is loaded
          final videoUrl = _ptLibraryRecord.videoUrl;
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
                                            notificationService.translateText(
                                                _ptLibraryRecord.title,
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
                                            color: Colors.blue[100],
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.access_time,
                                                  color: Colors.blue[500]),
                                              SizedBox(width: 4.0),
                                              Text(
                                                '${_ptLibraryRecord.duration} ${LocaleKeys.minutes.tr()}',
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
                                            color: _getLevelBackgroundColor(
                                                _ptLibraryRecord.level),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.directions_run,
                                                  color: _getLevelColor(
                                                      _ptLibraryRecord.level)),
                                              SizedBox(width: 4.0),
                                              Text(
                                                _getLevelText(
                                                    _ptLibraryRecord.level),
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: _getLevelColor(
                                                      _ptLibraryRecord.level),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 8.0),
                                        Container(
                                          padding: EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            color: _getCatBackgroundColor(
                                                _ptLibraryRecord.cat),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                  _getCatIcon(
                                                      _ptLibraryRecord.cat),
                                                  color: _getCatColor(
                                                      _ptLibraryRecord.cat)),
                                              SizedBox(width: 4.0),
                                              Text(
                                                _getCatText(
                                                    _ptLibraryRecord.cat),
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: _getCatColor(
                                                      _ptLibraryRecord.cat),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.0),
                                    FutureBuilder(
                                      future: notificationService.translateText(
                                          _ptLibraryRecord.description,
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
                                    SizedBox(height: 250.0),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }

                        return ListView(
                          children: [
                            SizedBox(height: 40.0),
                            player,
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: FutureBuilder(
                                      future: notificationService.translateText(
                                          _ptLibraryRecord.title, context),
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
                                          color: Colors.blue[100],
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.access_time,
                                                color: Colors.blue[500]),
                                            SizedBox(width: 4.0),
                                            Text(
                                              '${_ptLibraryRecord.duration} ${LocaleKeys.minutes.tr()}',
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
                                          color: _getLevelBackgroundColor(
                                              _ptLibraryRecord.level),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.directions_run,
                                                color: _getLevelColor(
                                                    _ptLibraryRecord.level)),
                                            SizedBox(width: 4.0),
                                            Text(
                                              _getLevelText(
                                                  _ptLibraryRecord.level),
                                              style: TextStyle(
                                                fontSize: 15.0,
                                                color: _getLevelColor(
                                                    _ptLibraryRecord.level),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 8.0),
                                      Container(
                                        padding: EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          color: _getCatBackgroundColor(
                                              _ptLibraryRecord.cat),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                                _getCatIcon(
                                                    _ptLibraryRecord.cat),
                                                color: _getCatColor(
                                                    _ptLibraryRecord.cat)),
                                            SizedBox(width: 4.0),
                                            Text(
                                              _getCatText(_ptLibraryRecord.cat),
                                              style: TextStyle(
                                                fontSize: 15.0,
                                                color: _getCatColor(
                                                    _ptLibraryRecord.cat),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.0),
                                  FutureBuilder(
                                    future: notificationService.translateText(
                                        _ptLibraryRecord.description, context),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<String> snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return ShimmeringTextListWidget(
                                          width: 400,
                                          numOfLines: 4,
                                        );
                                      } else if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
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
                                  SizedBox(height: 250.0),
                                ],
                              ),
                            ),
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
                          LocaleKeys.Today_PT_Act1.tr(),
                          style: TextStyle(
                            fontSize: TextConstant.TITLE_FONT_SIZE,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 70,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
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
