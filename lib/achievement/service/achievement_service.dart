import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:physio_track/achievement/model/user_achievement_model.dart';
import 'package:physio_track/pt_library/model/pt_activity_model.dart';

import '../../ot_library/model/ot_activity_model.dart';
import '../model/achievement_model.dart';

class AchievementService {
  CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  CollectionReference achievementCollection =
      FirebaseFirestore.instance.collection('achievements');

  // add achievement record to achievement collection
  Future<void> addArchievementRecord(Achievement achievement) async {
    QuerySnapshot querySnapshot = await achievementCollection
        .orderBy('id', descending: true)
        .limit(1)
        .get();
    int currentMaxId =
        querySnapshot.docs.isEmpty ? 0 : querySnapshot.docs.first['id'];
    int newId = currentMaxId + 1;

    Achievement newAchievement = achievement;
    newAchievement.id = newId;
    await achievementCollection.add(newAchievement.toMap()).then((value) {
      print("Achievement Added");
    }).catchError((error) {
      print("Failed to add achievement: $error");
    });
  }

  // add achievement record to user collection
  Future<void> addAchievementCollectionToUser(String uid) async {
    final QuerySnapshot achievementSnapshot = await achievementCollection.get();
    final List<Achievement> achievementList = achievementSnapshot.docs
        .map((doc) => Achievement.fromSnapshot(doc))
        .toList();

    final CollectionReference userAchievementCollection =
        userCollection.doc(uid).collection('achievements');

    DateTime defaultDateTime = DateTime(2000, 1, 1);

    achievementList.forEach((achievement) async {
      final UserAchievement userAchievement = UserAchievement(
        achId: achievement.id,
        isTaken: false,
        progress: 0.0,
        completedTime: defaultDateTime,
      );

      try {
        await userAchievementCollection.add(userAchievement.toMap());
        print("Achievement Added");
      } catch (error) {
        print("Failed to add achievement: $error");
      }
    });
  }

  // fetch all achievements from user
  Future<List<UserAchievement>> fetchAllAchievements(String uid) async {
    final CollectionReference userAchievementCollection =
        userCollection.doc(uid).collection('achievements');

    final QuerySnapshot userAchievementSnapshot =
        await userAchievementCollection.get();
    final List<UserAchievement> userAchievementList = userAchievementSnapshot
        .docs
        .map((doc) => UserAchievement.fromSnapshot(doc))
        .toList();

    return userAchievementList;
  }

  Future<List<Achievement>> fetchCompletedAchievements(String uid) async {
    List<Achievement> ach = [];
    final CollectionReference userAchievementCollection =
        userCollection.doc(uid).collection('achievements');

    final QuerySnapshot userAchievementSnapshot =
        await userAchievementCollection.where('isTaken', isEqualTo: true).get();
    final List<UserAchievement> userAchievementList = userAchievementSnapshot
        .docs
        .map((doc) => UserAchievement.fromSnapshot(doc))
        .toList();
    for (var uAch in userAchievementList) {
      final QuerySnapshot achievementSnapshot = await achievementCollection
          .where('id', isEqualTo: uAch.achId)
          .limit(1)
          .get();
      if (achievementSnapshot.docs.isNotEmpty) {
        final Achievement achievement =
            Achievement.fromSnapshot(achievementSnapshot.docs[0]);
        ach.add(achievement);
      }
    }
    return ach;
  }

  //fetch achievements by achid
  Future<Achievement?> fetchAchievementsByAchId(int achId) async {
    final QuerySnapshot achievementSnapshot = await achievementCollection
        .where('id', isEqualTo: achId)
        .limit(1)
        .get();

    if (achievementSnapshot.docs.isNotEmpty) {
      final Achievement achievement =
          Achievement.fromSnapshot(achievementSnapshot.docs[0]);
      return achievement;
    } else {
      return null;
    }
  }

  // check complete first pt activity
  Future<bool> checkFirstPTActivity(String uid) async {
    bool isCompleted = false;
    final CollectionReference userAchievementCollection =
        userCollection.doc(uid).collection('achievements');

    final QuerySnapshot userAchievementSnapshot =
        await userAchievementCollection.get();
    final List<UserAchievement> userAchievementList = userAchievementSnapshot
        .docs
        .map((doc) => UserAchievement.fromSnapshot(doc))
        .toList();

    final UserAchievement firstPTActivity = userAchievementList.firstWhere(
      (userAchievement) => userAchievement.achId == 1,
      orElse: () => UserAchievement(
          achId: -1,
          isTaken: false,
          progress: 0.0,
          completedTime: DateTime(2000, 1, 1)),
    );

    if (firstPTActivity.achId != -1) {
      if (firstPTActivity.isTaken == false) {
        QuerySnapshot querySnapshot =
            await userAchievementCollection.where('achId', isEqualTo: 1).get();
        String documentId = querySnapshot.docs.first.id;
        await userAchievementCollection.doc(documentId).update({
          'isTaken': true,
          'progress': 1.0,
          'completedTime': DateTime.now()
        });
        isCompleted = true;
      }
    }
    return isCompleted;
  }

  // check first complete pt activities of the day
  Future<bool> checkFirstCompleteDailyPTActivity(String uid) async {
    bool isCompleted = false;
    final CollectionReference userAchievementCollection =
        userCollection.doc(uid).collection('achievements');
    final QuerySnapshot userAchievementSnapshot =
        await userAchievementCollection.get();
    final List<UserAchievement> userAchievementList = userAchievementSnapshot
        .docs
        .map((doc) => UserAchievement.fromSnapshot(doc))
        .toList();

    final UserAchievement ach = userAchievementList.firstWhere(
      (userAchievement) => userAchievement.achId == 2,
      orElse: () => UserAchievement(
          achId: -1,
          isTaken: false,
          progress: 0.0,
          completedTime: DateTime(2000, 1, 1)),
    );

    if (ach.achId != -1) {
      if (ach.isTaken == false) {
        DateTime todayDate = DateTime.now();
        todayDate = DateTime(todayDate.year, todayDate.month,
            todayDate.day); // Reset milliseconds to zero

        final CollectionReference ptCollection =
            userCollection.doc(uid).collection('pt_activities');

        //empty snapshot
        final QuerySnapshot ptSnapshot = await ptCollection
            .where('date', isEqualTo: Timestamp.fromDate(todayDate))
            .limit(1)
            .get();
        if (ptSnapshot.docs.isNotEmpty) {
          PTActivity ptActivity =
              PTActivity.fromSnapshot(ptSnapshot.docs.first);
          if (ptActivity.isDone == true) {
            QuerySnapshot querySnapshot = await userAchievementCollection
                .where('achId', isEqualTo: 2)
                .get();
            String documentId = querySnapshot.docs.first.id;
            await userAchievementCollection.doc(documentId).update({
              'isTaken': true,
              'progress': 1.0,
              'completedTime': DateTime.now()
            });
            isCompleted = true;
          } else {
            QuerySnapshot querySnapshot = await userAchievementCollection
                .where('achId', isEqualTo: 2)
                .get();
            String documentId = querySnapshot.docs.first.id;
            await userAchievementCollection.doc(documentId).update({
              'progress': ptActivity.progress,
            });
          }
        }
      }
    }
    return isCompleted;
  }

  // check complete 30 pt activities
  // call when every time complete a pt activity to update progress
  Future<bool> check30PTActivities(String uid) async {
    bool isCompleted = false;
    final CollectionReference userAchievementCollection =
        userCollection.doc(uid).collection('achievements');

    final QuerySnapshot userAchievementSnapshot =
        await userAchievementCollection.get();
    final List<UserAchievement> userAchievementList = userAchievementSnapshot
        .docs
        .map((doc) => UserAchievement.fromSnapshot(doc))
        .toList();

    final UserAchievement first30PTActivities = userAchievementList.firstWhere(
      (userAchievement) => userAchievement.achId == 3,
      orElse: () => UserAchievement(
          achId: -1,
          isTaken: false,
          progress: 0.0,
          completedTime: DateTime(2000, 1, 1)),
    );

    if (first30PTActivities.achId != -1) {
      if (first30PTActivities.isTaken == false) {
        double progress = 1 / 30;
        double newProgress = first30PTActivities.progress + progress;

        QuerySnapshot querySnapshot =
            await userAchievementCollection.where('achId', isEqualTo: 3).get();
        String documentId = querySnapshot.docs.first.id;
        if (newProgress == 1.0) {
          await userAchievementCollection.doc(documentId).update({
            'isTaken': true,
            'progress': newProgress,
            'completedTime': DateTime.now()
          });
          isCompleted = true;
        } else {
          await userAchievementCollection.doc(documentId).update({
            'progress': newProgress,
          });
        }
      }
    }
    return isCompleted;
  }

  // check complete 50 pt activities
  Future<bool> check50PTActivities(String uid) async {
    bool isCompleted = false;
    final CollectionReference userAchievementCollection =
        userCollection.doc(uid).collection('achievements');

    final QuerySnapshot userAchievementSnapshot =
        await userAchievementCollection.get();
    final List<UserAchievement> userAchievementList = userAchievementSnapshot
        .docs
        .map((doc) => UserAchievement.fromSnapshot(doc))
        .toList();

    final UserAchievement first50PTActivities = userAchievementList.firstWhere(
      (userAchievement) => userAchievement.achId == 4,
      orElse: () => UserAchievement(
          achId: -1,
          isTaken: false,
          progress: 0.0,
          completedTime: DateTime(2000, 1, 1)),
    );

    if (first50PTActivities.achId != -1) {
      if (first50PTActivities.isTaken == false) {
        double progress = 1 / 50;
        double newProgress = first50PTActivities.progress + progress;

        QuerySnapshot querySnapshot =
            await userAchievementCollection.where('achId', isEqualTo: 4).get();
        String documentId = querySnapshot.docs.first.id;
        if (newProgress == 1.0) {
          await userAchievementCollection.doc(documentId).update({
            'isTaken': true,
            'progress': newProgress,
            'completedTime': DateTime.now()
          });
          isCompleted = true;
        } else {
          await userAchievementCollection.doc(documentId).update({
            'progress': newProgress,
          });
        }
      }
    }
    return isCompleted;
  }

  // check complete 80 pt activities
  Future<bool> check80PTActivities(String uid) async {
    bool isCompleted = false;
    final CollectionReference userAchievementCollection =
        userCollection.doc(uid).collection('achievements');

    final QuerySnapshot userAchievementSnapshot =
        await userAchievementCollection.get();
    final List<UserAchievement> userAchievementList = userAchievementSnapshot
        .docs
        .map((doc) => UserAchievement.fromSnapshot(doc))
        .toList();

    final UserAchievement first80PTActivities = userAchievementList.firstWhere(
      (userAchievement) => userAchievement.achId == 5,
      orElse: () => UserAchievement(
          achId: -1,
          isTaken: false,
          progress: 0.0,
          completedTime: DateTime(2000, 1, 1)),
    );

    if (first80PTActivities.achId != -1) {
      if (first80PTActivities.isTaken == false) {
        double progress = 1 / 80;
        double newProgress = first80PTActivities.progress + progress;

        QuerySnapshot querySnapshot =
            await userAchievementCollection.where('achId', isEqualTo: 5).get();
        String documentId = querySnapshot.docs.first.id;
        if (newProgress == 1.0) {
          await userAchievementCollection.doc(documentId).update({
            'isTaken': true,
            'progress': newProgress,
            'completedTime': DateTime.now()
          });
          isCompleted = true;
        } else {
          await userAchievementCollection.doc(documentId).update({
            'progress': newProgress,
          });
        }
      }
    }
    return isCompleted;
  }

  // check complete 3-day streak of pt module
  Future<bool> check3DayStreakPTModule(String uid) async {
    bool isCompleted = false;
    final CollectionReference userAchievementCollection =
        userCollection.doc(uid).collection('achievements');
    final QuerySnapshot userAchievementSnapshot =
        await userAchievementCollection.get();
    final List<UserAchievement> userAchievementList = userAchievementSnapshot
        .docs
        .map((doc) => UserAchievement.fromSnapshot(doc))
        .toList();
    final UserAchievement ach = userAchievementList.firstWhere(
      (userAchievement) => userAchievement.achId == 6,
      orElse: () => UserAchievement(
          achId: -1,
          isTaken: false,
          progress: 0.0,
          completedTime: DateTime.now()),
    );
    if (ach.achId != -1 && ach.isTaken == false) {
      final CollectionReference ptCollection =
          userCollection.doc(uid).collection('pt_activities');
      DateTime todayDate = DateTime.now();
      todayDate = DateTime(todayDate.year, todayDate.month, todayDate.day);

      DateTime yesterdayDate = todayDate.subtract(Duration(days: 1));
      DateTime twoDaysAgoDate = todayDate.subtract(Duration(days: 2));

      // Fetch PT activities for the last three days
      final QuerySnapshot ptSnapshot =
          await ptCollection.where('date', whereIn: [
        Timestamp.fromDate(todayDate),
        Timestamp.fromDate(yesterdayDate),
        Timestamp.fromDate(twoDaysAgoDate)
      ]).get();

      // Calculate progress based on the number of days completed
      double progress = 0.0;

      for (QueryDocumentSnapshot doc in ptSnapshot.docs) {
        PTActivity activity = PTActivity.fromSnapshot(doc);
        if (activity.isDone) {
          progress += (1 / 3);
        } else {
          progress = 0.0;
        }
      }

      if (progress == 1.0) {
        await updateAchievementProgress(
            userAchievementCollection, ach, progress, DateTime.now());
        isCompleted = true;
      } else {
        await updateAchievementDailyProgress(
            userAchievementCollection, ach.achId, progress);
      }
    }
    return isCompleted;
  }

  // check complete 7-day streak of pt module
  Future<bool> check7DayStreakPTModule(String uid) async {
    bool isCompleted = false;
    final CollectionReference userAchievementCollection =
        userCollection.doc(uid).collection('achievements');
    final QuerySnapshot userAchievementSnapshot =
        await userAchievementCollection.get();
    final List<UserAchievement> userAchievementList = userAchievementSnapshot
        .docs
        .map((doc) => UserAchievement.fromSnapshot(doc))
        .toList();
    final UserAchievement ach = userAchievementList.firstWhere(
      (userAchievement) => userAchievement.achId == 7,
      orElse: () => UserAchievement(
          achId: -1,
          isTaken: false,
          progress: 0.0,
          completedTime: DateTime.now()),
    );

    if (ach.achId != -1 && ach.isTaken == false) {
      final CollectionReference ptCollection =
          userCollection.doc(uid).collection('pt_activities');
      DateTime todayDate = DateTime.now();
      todayDate = DateTime(todayDate.year, todayDate.month, todayDate.day);
      DateTime sevenDaysAgoDate = todayDate.subtract(Duration(days: 7));

      // Fetch PT activities for the last seven days
      final QuerySnapshot ptSnapshot = await ptCollection
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgoDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(todayDate))
          .get();

      double progress = 0.0;
      if (ptSnapshot.size > 0) {
        for (QueryDocumentSnapshot doc in ptSnapshot.docs) {
          PTActivity activity = PTActivity.fromSnapshot(doc);
          if (activity.isDone) {
            progress += (1 / 7);
          } else {
            progress = 0.0;
          }
        }

        if (progress == 1.0) {
          await updateAchievementProgress(
              userAchievementCollection, ach, progress, DateTime.now());
          isCompleted = true;
        } else {
          await updateAchievementDailyProgress(
              userAchievementCollection, ach.achId, progress);
        }
      }
    }
    return isCompleted;
  }

  Future<void> updateAchievementProgress(CollectionReference collection,
      UserAchievement achievement, double progress, DateTime date) async {
    QuerySnapshot querySnapshot =
        await collection.where('achId', isEqualTo: achievement.achId).get();
    String documentId = querySnapshot.docs.first.id;

    await collection.doc(documentId).update({
      'isTaken': true,
      'progress': progress,
      'completedTime': date,
    });
  }

  // check complete first ot activity
  Future<bool> checkFirstOTActivity(String uid) async {
    bool isCompleted = false;
    final CollectionReference userAchievementCollection =
        userCollection.doc(uid).collection('achievements');

    final QuerySnapshot userAchievementSnapshot =
        await userAchievementCollection.get();
    final List<UserAchievement> userAchievementList = userAchievementSnapshot
        .docs
        .map((doc) => UserAchievement.fromSnapshot(doc))
        .toList();

    final UserAchievement firstPTActivity = userAchievementList.firstWhere(
      (userAchievement) => userAchievement.achId == 8,
      orElse: () => UserAchievement(
          achId: -1,
          isTaken: false,
          progress: 0.0,
          completedTime: DateTime(2000, 1, 1)),
    );

    if (firstPTActivity.achId != -1) {
      if (firstPTActivity.isTaken == false) {
        QuerySnapshot querySnapshot =
            await userAchievementCollection.where('achId', isEqualTo: 8).get();
        String documentId = querySnapshot.docs.first.id;
        await userAchievementCollection.doc(documentId).update({
          'isTaken': true,
          'progress': 1.0,
          'completedTime': DateTime.now()
        });
        isCompleted = true;
      }
    }
    return isCompleted;
  }

  // check first complete ot activities of the day
  Future<bool> checkFirstCompleteDailyOTActivity(String uid) async {
    bool isCompleted = false;
    final CollectionReference userAchievementCollection =
        userCollection.doc(uid).collection('achievements');
    final QuerySnapshot userAchievementSnapshot =
        await userAchievementCollection.get();
    final List<UserAchievement> userAchievementList = userAchievementSnapshot
        .docs
        .map((doc) => UserAchievement.fromSnapshot(doc))
        .toList();

    final UserAchievement ach = userAchievementList.firstWhere(
      (userAchievement) => userAchievement.achId == 9,
      orElse: () => UserAchievement(
          achId: -1,
          isTaken: false,
          progress: 0.0,
          completedTime: DateTime(2000, 1, 1)),
    );

    if (ach.achId != -1) {
      if (ach.isTaken == false) {
        DateTime todayDate = DateTime.now();
        todayDate = DateTime(todayDate.year, todayDate.month, todayDate.day);

        final CollectionReference otCollection =
            userCollection.doc(uid).collection('ot_activities');
        final QuerySnapshot otSnapshot = await otCollection
            .where('date', isEqualTo: Timestamp.fromDate(todayDate))
            .limit(1)
            .get();
        if (otSnapshot.docs.isNotEmpty) {
          OTActivity otActivity =
              OTActivity.fromSnapshot(otSnapshot.docs.first);
          print('ot is done? ${otActivity.isDone}');
          if (otActivity.isDone == true) {
            QuerySnapshot querySnapshot = await userAchievementCollection
                .where('achId', isEqualTo: 9)
                .get();
            String documentId = querySnapshot.docs.first.id;
            await userAchievementCollection.doc(documentId).update({
              'isTaken': true,
              'progress': 1.0,
              'completedTime': DateTime.now()
            });
            isCompleted = true;
          } else {
            QuerySnapshot querySnapshot = await userAchievementCollection
                .where('achId', isEqualTo: 2)
                .get();
            String documentId = querySnapshot.docs.first.id;
            await userAchievementCollection.doc(documentId).update({
              'progress': otActivity.progress,
            });
          }
        }
      }
    }
    return isCompleted;
  }

  // check complete 30 ot activities
  Future<bool> check30OTActivities(String uid) async {
    bool isCompleted = false;
    final CollectionReference userAchievementCollection =
        userCollection.doc(uid).collection('achievements');

    final QuerySnapshot userAchievementSnapshot =
        await userAchievementCollection.get();
    final List<UserAchievement> userAchievementList = userAchievementSnapshot
        .docs
        .map((doc) => UserAchievement.fromSnapshot(doc))
        .toList();

    final UserAchievement first30OTActivities = userAchievementList.firstWhere(
      (userAchievement) => userAchievement.achId == 10,
      orElse: () => UserAchievement(
          achId: -1,
          isTaken: false,
          progress: 0.0,
          completedTime: DateTime(2000, 1, 1)),
    );

    if (first30OTActivities.achId != -1) {
      if (first30OTActivities.isTaken == false) {
        double progress = 1 / 30;
        double newProgress = first30OTActivities.progress + progress;

        QuerySnapshot querySnapshot =
            await userAchievementCollection.where('achId', isEqualTo: 10).get();
        String documentId = querySnapshot.docs.first.id;
        if (newProgress == 1.0) {
          await userAchievementCollection.doc(documentId).update({
            'isTaken': true,
            'progress': newProgress,
            'completedTime': DateTime.now()
          });
          isCompleted = true;
        } else {
          await userAchievementCollection.doc(documentId).update({
            'progress': newProgress,
          });
        }
      }
    }
    return isCompleted;
  }

  // check complete 50 ot activities
  Future<bool> check50OTActivities(String uid) async {
    bool isCompleted = false;
    final CollectionReference userAchievementCollection =
        userCollection.doc(uid).collection('achievements');

    final QuerySnapshot userAchievementSnapshot =
        await userAchievementCollection.get();
    final List<UserAchievement> userAchievementList = userAchievementSnapshot
        .docs
        .map((doc) => UserAchievement.fromSnapshot(doc))
        .toList();

    final UserAchievement first50OTActivities = userAchievementList.firstWhere(
      (userAchievement) => userAchievement.achId == 11,
      orElse: () => UserAchievement(
          achId: -1,
          isTaken: false,
          progress: 0.0,
          completedTime: DateTime(2000, 1, 1)),
    );

    if (first50OTActivities.achId != -1) {
      if (first50OTActivities.isTaken == false) {
        double progress = 1 / 50;
        double newProgress = first50OTActivities.progress + progress;

        QuerySnapshot querySnapshot =
            await userAchievementCollection.where('achId', isEqualTo: 11).get();
        String documentId = querySnapshot.docs.first.id;
        if (newProgress == 1.0) {
          await userAchievementCollection.doc(documentId).update({
            'isTaken': true,
            'progress': newProgress,
            'completedTime': DateTime.now()
          });
          isCompleted = true;
        } else {
          await userAchievementCollection.doc(documentId).update({
            'progress': newProgress,
          });
        }
      }
    }
    return isCompleted;
  }

  // check complete 80 ot activities
  Future<bool> check80OTActivities(String uid) async {
    bool isCompleted = false;
    final CollectionReference userAchievementCollection =
        userCollection.doc(uid).collection('achievements');

    final QuerySnapshot userAchievementSnapshot =
        await userAchievementCollection.get();
    final List<UserAchievement> userAchievementList = userAchievementSnapshot
        .docs
        .map((doc) => UserAchievement.fromSnapshot(doc))
        .toList();

    final UserAchievement first80OTActivities = userAchievementList.firstWhere(
      (userAchievement) => userAchievement.achId == 12,
      orElse: () => UserAchievement(
          achId: -1,
          isTaken: false,
          progress: 0.0,
          completedTime: DateTime(2000, 1, 1)),
    );

    if (first80OTActivities.achId != -1) {
      if (first80OTActivities.isTaken == false) {
        double progress = 1 / 80;
        double newProgress = first80OTActivities.progress + progress;

        QuerySnapshot querySnapshot =
            await userAchievementCollection.where('achId', isEqualTo: 12).get();
        String documentId = querySnapshot.docs.first.id;
        if (newProgress == 1.0) {
          await userAchievementCollection.doc(documentId).update({
            'isTaken': true,
            'progress': newProgress,
            'completedTime': DateTime.now()
          });
          isCompleted = true;
        } else {
          await userAchievementCollection.doc(documentId).update({
            'progress': newProgress,
          });
        }
      }
    }
    return isCompleted;
  }

  // check complete 3-day streak of ot module
  Future<bool> check3DayStreakOTModule(String uid) async {
    bool isCompleted = false;
    final CollectionReference userAchievementCollection =
        userCollection.doc(uid).collection('achievements');
    final QuerySnapshot userAchievementSnapshot =
        await userAchievementCollection.get();
    final List<UserAchievement> userAchievementList = userAchievementSnapshot
        .docs
        .map((doc) => UserAchievement.fromSnapshot(doc))
        .toList();
    final UserAchievement ach = userAchievementList.firstWhere(
      (userAchievement) => userAchievement.achId == 13,
      orElse: () => UserAchievement(
          achId: -1,
          isTaken: false,
          progress: 0.0,
          completedTime: DateTime.now()),
    );
    if (ach.achId != -1 && ach.isTaken == false) {
      final CollectionReference otCollection =
          userCollection.doc(uid).collection('ot_activities');
      DateTime todayDate = DateTime.now();
      todayDate = DateTime(todayDate.year, todayDate.month, todayDate.day);
      DateTime yesterdayDate = todayDate.subtract(Duration(days: 1));
      DateTime twoDaysAgoDate = todayDate.subtract(Duration(days: 2));

      // Fetch OT activities for the last three days
      final QuerySnapshot otSnapshot =
          await otCollection.where('date', whereIn: [
        Timestamp.fromDate(todayDate),
        Timestamp.fromDate(yesterdayDate),
        Timestamp.fromDate(twoDaysAgoDate)
      ]).get();

      // Calculate progress based on the number of days completed
      double progress = 0.0;

      for (QueryDocumentSnapshot doc in otSnapshot.docs) {
        OTActivity activity = OTActivity.fromSnapshot(doc);
        if (activity.isDone) {
          progress += (1 / 3);
        } else {
          progress = 0.0;
        }
      }

      if (progress == 1.0) {
        await updateAchievementProgress(
            userAchievementCollection, ach, progress, DateTime.now());
        isCompleted = true;
      } else {
        await updateAchievementDailyProgress(
            userAchievementCollection, ach.achId, progress);
      }
    }
    return isCompleted;
  }

  // check complete 7-day streak of ot module
  Future<bool> check7DayStreakOTModule(String uid) async {
    bool isCompleted = false;
    final CollectionReference userAchievementCollection =
        userCollection.doc(uid).collection('achievements');
    final QuerySnapshot userAchievementSnapshot =
        await userAchievementCollection.get();
    final List<UserAchievement> userAchievementList = userAchievementSnapshot
        .docs
        .map((doc) => UserAchievement.fromSnapshot(doc))
        .toList();
    final UserAchievement ach = userAchievementList.firstWhere(
      (userAchievement) => userAchievement.achId == 14,
      orElse: () => UserAchievement(
          achId: -1,
          isTaken: false,
          progress: 0.0,
          completedTime: DateTime.now()),
    );

    if (ach.achId != -1 && ach.isTaken == false) {
      final CollectionReference otCollection =
          userCollection.doc(uid).collection('ot_activities');
      DateTime todayDate = DateTime.now();
      todayDate = DateTime(todayDate.year, todayDate.month, todayDate.day);
      DateTime sevenDaysAgoDate = todayDate.subtract(Duration(days: 7));

      // Fetch OT activities for the last seven days
      final QuerySnapshot otSnapshot = await otCollection
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgoDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(todayDate))
          .get();
      //^^^^
      //fetch 7 days after today record
      double progress = 0.0;
      if (otSnapshot.size > 0) {
        for (QueryDocumentSnapshot doc in otSnapshot.docs) {
          OTActivity activity = OTActivity.fromSnapshot(doc);
          if (activity.isDone) {
            progress += (1 / 7);
          } else {
            progress = 0.0;
          }
        }

        if (progress == 1.0) {
          await updateAchievementProgress(
              userAchievementCollection, ach, progress, DateTime.now());
          isCompleted = true;
        } else {
          await updateAchievementDailyProgress(
              userAchievementCollection, ach.achId, progress);
        }
      }
    }
    return isCompleted;
  }

// need check whether achievement is done?
  // check first complete pt and ot activities of the day
  Future<bool> checkAndHandleDailyActivities(String uid) async {
    bool isCompleted = false;
    final CollectionReference userAchievementCollection =
        userCollection.doc(uid).collection('achievements');

    final QuerySnapshot userAchievementSnapshot =
        await userAchievementCollection.get();
    final List<UserAchievement> userAchievementList = userAchievementSnapshot
        .docs
        .map((doc) => UserAchievement.fromSnapshot(doc))
        .toList();

    final UserAchievement firstCompleteDailyAct =
        userAchievementList.firstWhere(
      (userAchievement) => userAchievement.achId == 15,
      orElse: () => UserAchievement(
          achId: -1,
          isTaken: false,
          progress: 0.0,
          completedTime: DateTime(2000, 1, 1)),
    );

    if (firstCompleteDailyAct.achId != -1 &&
        firstCompleteDailyAct.isTaken == false) {
      DateTime todayDate = DateTime.now();
      todayDate = DateTime(todayDate.year, todayDate.month, todayDate.day);

      // Check PT activity
      final CollectionReference ptCollection =
          userCollection.doc(uid).collection('pt_activities');
      final QuerySnapshot ptSnapshot = await ptCollection
          .where('date', isEqualTo: Timestamp.fromDate(todayDate))
          .limit(1)
          .get();

      // Check OT activity
      final CollectionReference otCollection =
          userCollection.doc(uid).collection('ot_activities');
      final QuerySnapshot otSnapshot = await otCollection
          .where('date', isEqualTo: Timestamp.fromDate(todayDate))
          .limit(1)
          .get();

      final bool ptDone = ptSnapshot.docs.isNotEmpty
          ? PTActivity.fromSnapshot(ptSnapshot.docs.first).isDone
          : false;

      final bool otDone = otSnapshot.docs.isNotEmpty
          ? OTActivity.fromSnapshot(otSnapshot.docs.first).isDone
          : false;

      if (ptDone && otDone) {
        // Both PT and OT are done on the same day
        await updateAchievement(
            userAchievementCollection, 15, true, 1.0, DateTime.now());
        isCompleted = true;
      } else if (ptDone || otDone) {
        // Either PT or OT is done on the same day
        await updateAchievement(
            userAchievementCollection, 15, false, 0.5, DateTime(2000, 1, 1));
      } else {
        await updateAchievement(
            userAchievementCollection, 15, false, 0.0, DateTime(2000, 1, 1));
      }
    }
    return isCompleted;
  }

  Future<void> updateAchievement(
    CollectionReference collection,
    int achId,
    bool isTaken,
    double progress,
    DateTime completedTime,
  ) async {
    final QuerySnapshot querySnapshot =
        await collection.where('achId', isEqualTo: achId).get();

    if (querySnapshot.docs.isNotEmpty) {
      final String documentId = querySnapshot.docs.first.id;
      await collection.doc(documentId).update({
        'isTaken': isTaken,
        'progress': progress,
        'completedTime': DateTime.now(),
      });
    }
  }

  Future<void> updateAchievementDailyProgress(
      CollectionReference collection, int achId, double progress) async {
    QuerySnapshot querySnapshot =
        await collection.where('achId', isEqualTo: achId).get();
    String documentId = querySnapshot.docs.first.id;
    await collection.doc(documentId).update({
      'progress': progress,
    });
  }

  // check first complete pt and ot activities for a month
  Future<bool> checkAndHandleMonthlyActivities(String uid) async {
    bool isCompleted = false;
    final CollectionReference userAchievementCollection =
        userCollection.doc(uid).collection('achievements');

    final QuerySnapshot userAchievementSnapshot =
        await userAchievementCollection.get();
    final List<UserAchievement> userAchievementList = userAchievementSnapshot
        .docs
        .map((doc) => UserAchievement.fromSnapshot(doc))
        .toList();

    final UserAchievement firstCompleteMonthlyAct =
        userAchievementList.firstWhere(
      (userAchievement) => userAchievement.achId == 15,
      orElse: () => UserAchievement(
          achId: -1,
          isTaken: false,
          progress: 0.0,
          completedTime: DateTime(2000, 1, 1)),
    );

    if (firstCompleteMonthlyAct.achId != -1 &&
        firstCompleteMonthlyAct.isTaken == false) {
      DateTime todayDate = DateTime.now();
      todayDate = DateTime(todayDate.year, todayDate.month, todayDate.day);

      // Calculate the start date for the past month
      final DateTime lastMonthStartDate =
          DateTime(todayDate.year, todayDate.month - 1, todayDate.day);

      // Calculate the end date for the past month (today)
      final DateTime dayBeforeEndDate =
          DateTime(todayDate.year, todayDate.month, todayDate.day - 1);

      // Check PT activity for the past month
      final CollectionReference ptCollection =
          userCollection.doc(uid).collection('pt_activities');
      final QuerySnapshot ptSnapshot = await ptCollection
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(lastMonthStartDate),
              isLessThanOrEqualTo: Timestamp.fromDate(dayBeforeEndDate))
          .get();

      List<PTActivity> ptList =
          ptSnapshot.docs.map((doc) => PTActivity.fromSnapshot(doc)).toList();

      // Check OT activity for the past month
      final CollectionReference otCollection =
          userCollection.doc(uid).collection('ot_activities');
      final QuerySnapshot otSnapshot = await otCollection
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(lastMonthStartDate),
              isLessThanOrEqualTo: Timestamp.fromDate(dayBeforeEndDate))
          .get();
      List<OTActivity> otList =
          otSnapshot.docs.map((doc) => OTActivity.fromSnapshot(doc)).toList();

      double progress = 0.0;
      //nt cumulativeDay = 0;
      if (ptList.isNotEmpty && otList.isNotEmpty) {
        //<= change to <
        for (int i = 0; i < ptList.length; i++) {
          if (ptList[i].isDone == true && otList[i].isDone == true) {
            progress += (1 / 30);
          } else {
            progress = 0.0;
          }
        }

        await updateAchievementMonthlyProgress(
            userAchievementCollection, 16, progress);
      }
      final QuerySnapshot ptTodaySnapshot = await ptCollection
          .where('date', isEqualTo: Timestamp.fromDate(todayDate))
          .get();

      final QuerySnapshot otTodaySnapshot = await otCollection
          .where('date', isEqualTo: Timestamp.fromDate(todayDate))
          .get();

      if (ptTodaySnapshot.docs.isNotEmpty && otTodaySnapshot.docs.isNotEmpty) {
        PTActivity todayPTActivity =
            PTActivity.fromSnapshot(ptTodaySnapshot.docs.first);
        OTActivity todayOTActivity =
            OTActivity.fromSnapshot(otTodaySnapshot.docs.first);

        if (todayOTActivity.isDone == true && todayPTActivity.isDone == true) {
          QuerySnapshot querySnapshot = await userAchievementCollection
              .where('achId', isEqualTo: 16)
              .get();
          UserAchievement userAchievement =
              UserAchievement.fromSnapshot(querySnapshot.docs.first);
          if (userAchievement.isTaken == false) {
            double latestProgress = userAchievement.progress + (1 / 30);
            if (latestProgress == 1.0) {
              await updateAchievement(userAchievementCollection, 16, true,
                  latestProgress, DateTime.now());
              isCompleted = true;
            } else {
              await updateAchievementMonthlyProgress(
                  userAchievementCollection, 16, latestProgress);
            }
          }
        }
      }
    }
    return isCompleted;
  }

  Future<void> updateAchievementMonthlyProgress(
      CollectionReference collection, int achId, double progress) async {
    QuerySnapshot querySnapshot =
        await collection.where('achId', isEqualTo: achId).get();
    String documentId = querySnapshot.docs.first.id;
    await collection.doc(documentId).update({
      'progress': progress,
    });
  }

  // check first complete journal
  Future<bool> checkFirstJournal(String uid) async {
    bool isCompleted = false;
    final CollectionReference userAchievementCollection =
        userCollection.doc(uid).collection('achievements');

    final QuerySnapshot userAchievementSnapshot =
        await userAchievementCollection.get();
    final List<UserAchievement> userAchievementList = userAchievementSnapshot
        .docs
        .map((doc) => UserAchievement.fromSnapshot(doc))
        .toList();

    final UserAchievement firstJournal = userAchievementList.firstWhere(
      (userAchievement) => userAchievement.achId == 17,
      orElse: () => UserAchievement(
          achId: -1,
          isTaken: false,
          progress: 0.0,
          completedTime: DateTime(2000, 1, 1)),
    );

    if (firstJournal.achId != -1) {
      if (firstJournal.isTaken == false) {
        QuerySnapshot querySnapshot =
            await userAchievementCollection.where('achId', isEqualTo: 17).get();
        String documentId = querySnapshot.docs.first.id;
        await userAchievementCollection.doc(documentId).update({
          'isTaken': true,
          'progress': 1.0,
          'completedTime': DateTime.now()
        });
        isCompleted = true;
      }
    }
    return isCompleted;
  }
}
