import 'package:avatar_glow/avatar_glow.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../translations/locale_keys.g.dart';
import '../model/achievement_model.dart';
import '../../constant/ColorConstant.dart';
import '../../reusable_widget/reusable_widget.dart';

class AchievementDialogWidget extends StatelessWidget {
  final Achievement ach;

  AchievementDialogWidget({required this.ach});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AvatarGlow(
              endRadius: 90,
              duration: Duration(seconds: 2),
              glowColor: Colors.yellow,
              repeat: true,
              showTwoGlows: true,
              repeatPauseDuration: Duration(seconds: 1),
              child: Material(
                  elevation: 8.0,
                  shape: CircleBorder(),
                  child: ClipOval(
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 50.0,
                      child: Image(
                        image: NetworkImage(ach.imageUrl),
                        fit: BoxFit.fill, 
                      ),
                    ),
                  )),
            ),
            Text(
              LocaleKeys.Achievement_Unlocked.tr(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 15),
            Text(
              LocaleKeys.You_unlock_ach.tr(),
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 5),
            Text(
              ach.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: customButton(
              context,
              LocaleKeys.Done.tr(),
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
    );
  }
}
