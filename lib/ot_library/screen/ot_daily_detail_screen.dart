import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../achievement/service/achievement_service.dart';
import '../../constant/ColorConstant.dart';
import '../../reusable_widget/reusable_widget.dart';
import '../model/ot_activity_model.dart';
import '../model/ot_library_model.dart';
import '../service/ot_library_service.dart';
import 'ot_daily_finished_screen.dart';
import 'ot_daily_list_screen.dart';

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

  Future<void> _markAsCompleted() async {
    try {
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
            await otActivityDocumentRef
                .update({'completeTime': Timestamp.now()});
            bool checkFirstCompleteDailyOTActivity = await _achievementService
                .checkFirstCompleteDailyOTActivity(uId);
            bool check3DayStreakOTModule =
                await _achievementService.check3DayStreakOTModule(uId);
            bool check7DayStreakOTModule =
                await _achievementService.check7DayStreakOTModule(uId);
            bool checkAndHandleDailyActivities =
                await _achievementService.checkAndHandleDailyActivities(uId);
            bool checkAndHandleMonthlyActivities =
                await _achievementService.checkAndHandleMonthlyActivities(uId);
            if (checkFirstCompleteDailyOTActivity) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Daily Engagement badge unlocked!")),
              );
            }
            if (check3DayStreakOTModule) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        "Occupational Enthusiast (3-Day Streak) badge unlocked!")),
              );
            }
            if (check7DayStreakOTModule) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        "Occupational Master (7-Day Streak) badge unlocked!")),
              );
            }
            if (checkAndHandleDailyActivities) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Two-Module Triumph badge unlocked!")),
              );
            }
            if (checkAndHandleMonthlyActivities) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text("Lifelong Wellness Champion badge unlocked!")),
              );
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Occupational Onset badge unlocked!")),
            );
          }
          if (check30OTActivities) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Adaptive Adept badge unlocked!")),
            );
          }
          if (check50OTActivities) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text("Life Improvement Trailblazer badge unlocked!")),
            );
          }
          if (check80OTActivities) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Occupational Odyssey badge unlocked!")),
            );
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Activity marked as completed'),
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTDailyListScreen(),
            ),
          );
        }
      }
    } catch (e) {
      print('Error marking activity as completed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error marking activity as completed'),
          backgroundColor: Colors.red[500],
        ),
      );
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

  Map<int, double> calculateLevelAndProgress(int experience) {
    Map<int, double> levelInfo = {};
    // Initial level requires 50 experience
    int baseExperience = 50;

    // Calculate the level based on the given experience
    int level = 1;
    int requiredExperience = baseExperience;

    while (experience >= requiredExperience) {
      level++;
      requiredExperience +=
          50; // Increase the required experience for the next level
    }

    // Calculate progress towards the next level
    double progressToNextLevel =
        (experience - (requiredExperience - 50)) / 50.0;

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
                                      child: Text(
                                        _otLibraryRecord.title,
                                        style: TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold,
                                        ),
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
                                                '${_otLibraryRecord.duration} mins',
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
                                                _otLibraryRecord.level),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.directions_run,
                                                  color: _getLevelColor(
                                                      _otLibraryRecord.level)),
                                              SizedBox(width: 4.0),
                                              Text(
                                                _otLibraryRecord.level,
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
                                    Text(
                                      _otLibraryRecord.description,
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.grey[500]),
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
                                    child: Text(
                                      _otLibraryRecord.title,
                                      style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                              '${_otLibraryRecord.duration} mins',
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
                                              _otLibraryRecord.level),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.directions_run,
                                                color: _getLevelColor(
                                                    _otLibraryRecord.level)),
                                            SizedBox(width: 4.0),
                                            Text(
                                              _otLibraryRecord.level,
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
                                  Text(
                                    _otLibraryRecord.description,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.grey[500]),
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
                          Navigator.of(context).pop();
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
                          'Today\'s OT Activity',
                          style: TextStyle(
                            fontSize: 20.0,
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
                            'Mark as Completed',
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
