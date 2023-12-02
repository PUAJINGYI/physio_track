import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:physio_track/constant/ColorConstant.dart';
import 'package:physio_track/constant/TextConstant.dart';

import '../../notification/service/notification_service.dart';
import '../../notification/widget/shimmering_text_list_widget.dart';
import '../../reusable_widget/reusable_widget.dart';
import '../../translations/locale_keys.g.dart';
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
  NotificationService notificationService = NotificationService();

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
                  FutureBuilder(
                    future: notificationService.translateText(
                        widget.achievement.title, context),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ShimmeringTextListWidget(width: 400, numOfLines: 1),
                          ],
                        ); // or any loading indicator
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        String title = snapshot.data!;
                        return Text(
                          title,
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        );
                      }
                    },
                  ),

                  SizedBox(height: 8.0), // Add some spacing
                  FutureBuilder(
                    future: notificationService.translateText(
                        widget.achievement.description, context),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ShimmeringTextListWidget(width: 400, numOfLines: 2),
                          ],
                        ); // or any loading indicator
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        String desc = snapshot.data!;
                        return Text(
                          desc,
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                          textAlign: TextAlign.center,
                        );
                      }
                    },
                  ),
                  SizedBox(height: 8.0), // Add some spacing
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                        child: widget.userAchievement.isTaken
                            ? Text(
                                LocaleKeys.Completed.tr(),
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
                bottom: TextConstant.CUSTOM_BUTTON_BOTTOM,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      TextConstant.CUSTOM_BUTTON_SIDE_PADDING,
                      TextConstant.CUSTOM_BUTTON_TB_PADDING,
                      TextConstant.CUSTOM_BUTTON_SIDE_PADDING,
                      TextConstant.CUSTOM_BUTTON_TB_PADDING),
                  child: customButton(
                    context,
                    LocaleKeys.Back.tr(),
                    ColorConstant.BLUE_BUTTON_TEXT,
                    ColorConstant.BLUE_BUTTON_UNPRESSED,
                    ColorConstant.BLUE_BUTTON_PRESSED,
                    () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
