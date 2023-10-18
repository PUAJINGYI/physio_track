import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:physio_track/constant/ColorConstant.dart';

import '../../reusable_widget/reusable_widget.dart';
import '../model/achievement_model.dart';
import '../model/user_achievement_model.dart';

class AchievementDetailScreen extends StatefulWidget {
  final Achievement achievement;
  final UserAchievement userAchievement;

  const AchievementDetailScreen(
      {super.key, required this.achievement, required this.userAchievement});

  @override
  State<AchievementDetailScreen> createState() =>
      _AchievementDetailScreenState();
}

class _AchievementDetailScreenState extends State<AchievementDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 250.0,
                    child: Image.network(
                      widget.achievement.imageUrl,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  SizedBox(height: 16.0), // Add some spacing
                  Text(
                    widget.achievement.title,
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.0), // Add some spacing
                  Text(
                    widget.achievement.description,
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.0), // Add some spacing
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                        child: widget.userAchievement.isTaken
                            ? Text(
                                'Completed',
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green),
                                textAlign: TextAlign.center,
                              )
                            : LinearPercentIndicator(
                                animation: true,
                                lineHeight: 15.0,
                                animationDuration: 2000,
                                percent: widget.userAchievement.progress,
                                barRadius: Radius.circular(10.0),
                                progressColor: Colors.greenAccent,
                              ),
                      ),
                      if (!widget.userAchievement.isTaken)
                        Positioned(
                          top: -10,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${(widget.userAchievement.progress * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                  fontSize: 14.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: customButton(
                      context,
                      "Back",
                      ColorConstant.BLUE_BUTTON_TEXT,
                      ColorConstant.BLUE_BUTTON_UNPRESSED,
                      ColorConstant.BLUE_BUTTON_PRESSED,
                      () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}
