import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../../notification/service/notification_service.dart';
import '../../notification/widget/shimmering_text_list_widget.dart';
import '../../translations/locale_keys.g.dart';
import '../model/achievement_model.dart';
import '../model/user_achievement_model.dart';
import '../service/achievement_service.dart';
import 'achievement_detail_screen.dart';

class AchievementListScreen extends StatefulWidget {
  final String uid;
  const AchievementListScreen({super.key, required this.uid});

  @override
  State<AchievementListScreen> createState() => _AchievementListScreenState();
}

class _AchievementListScreenState extends State<AchievementListScreen> {
  // String uId = FirebaseAuth.instance.currentUser!.uid;
  final AchievementService _achievementService = AchievementService();
  late Map<UserAchievement, Achievement> achievementMap = {};

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadUserAchievement() async {
    List<UserAchievement> userAchievements =
        await _achievementService.fetchAllAchievements(widget.uid);
    userAchievements.sort((a, b) => b.progress.compareTo(a.progress));
    print('length :${userAchievements.length}');
    for (var ach in userAchievements) {
      Achievement? achievement =
          await _achievementService.fetchAchievementsByAchId(ach.achId);
      if (achievement != null) {
        achievementMap[ach] = achievement;
      }
    }
    print('length 2:${achievementMap.length}');
    for (var ach in achievementMap.keys) {
      print(ach.achId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<void>(
      future: _loadUserAchievement(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Column(
                  children: [
                    SizedBox(height: 240),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Two columns
                        ),
                        padding: EdgeInsets.zero,
                        itemCount: achievementMap.length,
                        itemBuilder: (context, index) {
                          final UserAchievement achievement =
                              achievementMap.keys.elementAt(index);
                          final Achievement ach =
                              achievementMap.values.elementAt(index);
                          return AchievementCard(
                              achievement: achievement, ach: ach);
                        },
                      ),
                    ),
                  ],
                ),
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
                    LocaleKeys.Achievements.tr(),
                    style: TextStyle(
                      fontSize: TextConstant.TITLE_FONT_SIZE,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 80,
                right: 5,
                child: Image.asset(
                  ImageConstant.ACHIEVEMENT,
                  width: 190.0,
                  height: 150.0,
                ),
              ),
              Positioned(
                top: 125,
                left: 25,
                child: Text(LocaleKeys.Keep_it_up.tr(),
                    style:
                        TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold)),
              ),
              Positioned(
                top: 160,
                left: 40,
                child: Text(LocaleKeys.Unlock_more_goals.tr(),
                    style: TextStyle(fontSize: 15.0)),
              ),
            ],
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    ));
  }
}

class AchievementCard extends StatelessWidget {
  final UserAchievement achievement;
  final Achievement ach;
  AchievementCard({required this.achievement, required this.ach});

  NotificationService notificationService = NotificationService();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to a new screen here
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AchievementDetailScreen(
              achievement: ach,
              userAchievement: achievement,
            ), // Pass the achievement details to the new screen
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Card(
          color: Colors.yellow[50],
          margin: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8, 15, 8, 0),
                child: Container(
                  height: 30,
                  child: FutureBuilder(
                    future: notificationService.translateText(ach.title, context),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ShimmeringTextListWidget(width: 100, numOfLines: 1),
                          ],
                        ); // or any loading indicator
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        String title = snapshot.data!;
                        return Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                          ),
                          textAlign: TextAlign.center,
                        );
                      }
                    },
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    width: 100.0, // Set the fixed width
                    height: 150.0, // Set the fixed height
                    child: Image.network(
                      ach.imageUrl,
                      fit: BoxFit
                          .fitHeight, // You can specify the BoxFit as needed
                    ),
                  ),
                ),
              ),
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                    child: achievement.isTaken
                        ? Text(
                            LocaleKeys.Completed.tr(),
                            style: TextStyle(
                                fontSize: 14.0, fontWeight: FontWeight.bold),
                          )
                        : LinearPercentIndicator(
                            animation: true,
                            lineHeight: 10.0,
                            animationDuration: 2000,
                            percent: achievement.progress,
                            barRadius: Radius.circular(10.0),
                            progressColor: Colors.greenAccent,
                          ),
                  ),
                  if (!achievement.isTaken)
                    Positioned(
                      top: -10,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${(achievement.progress * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
