import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../constant/ImageConstant.dart';
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
                    'Achievements',
                    style: TextStyle(
                      fontSize: 20.0,
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
                  width: 211.0,
                  height: 169.0,
                ),
              ),
              Positioned(
                top: 125,
                left: 25,
                child: Text('Keep it up',
                    style:
                        TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold)),
              ),
              Positioned(
                top: 160,
                left: 40,
                child: Text('Unlock more goals!',
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
      child: Card(
        margin: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(8, 15, 8, 0),
              child: Container(
                height: 30,
                child: Text(
                  ach.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                  textAlign: TextAlign.center,
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
                          'Completed',
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
    );
  }
}
