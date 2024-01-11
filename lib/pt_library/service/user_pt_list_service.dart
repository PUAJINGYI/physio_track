import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/pt_activity_model.dart';
import '../model/pt_library_model.dart';

class UserPTListService {
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  CollectionReference ptLibraryCollection =
      FirebaseFirestore.instance.collection('pt_library');

  Future<List<PTActivity>> fetchUserListByDate(
      String uId, DateTime fromDate, toDate) async {
    fromDate = DateTime(fromDate.year, fromDate.month, fromDate.day);
    toDate = DateTime(toDate.year, toDate.month, toDate.day);

    final CollectionReference otCollection =
        usersCollection.doc(uId).collection('pt_activities');
    final QuerySnapshot otSnapshot = await otCollection
        .where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate),
            isLessThanOrEqualTo: Timestamp.fromDate(toDate))
        .get();
    List<PTActivity> otList =
        otSnapshot.docs.map((doc) => PTActivity.fromSnapshot(doc)).toList();
    return otList;
  }

  Future<void> suggestPTActivityList(
      DocumentReference userRef, String userId) async {
    try {
      DocumentSnapshot userDoc = await userRef.get();
      String lowerStatus = userDoc.get('lowerStatus');
      String upperStatus = userDoc.get('upperStatus');

      QuerySnapshot snapshot = await ptLibraryCollection.get();
      List<PTLibrary> lowerPTActivitiesList = snapshot.docs
          .map((doc) => PTLibrary.fromSnapshot(doc))
          .where((ptLibrary) => ptLibrary.cat.contains('Lower'))
          .toList();

      List<PTLibrary> lowerPTActivitiesBEGList = snapshot.docs
          .map((doc) => PTLibrary.fromSnapshot(doc))
          .where((ptLibrary) =>
              ptLibrary.cat.contains('Lower') &&
              ptLibrary.level.contains('Beginner'))
          .toList();

      List<PTLibrary> lowerPTActivitiesINTList = snapshot.docs
          .map((doc) => PTLibrary.fromSnapshot(doc))
          .where((ptLibrary) =>
              ptLibrary.cat.contains('Lower') &&
              !ptLibrary.level.contains('Advanced'))
          .toList();

      List<PTLibrary> upperPTActivitiesList = snapshot.docs
          .map((doc) => PTLibrary.fromSnapshot(doc))
          .where((ptLibrary) => ptLibrary.cat.contains('Upper'))
          .toList();

      List<PTLibrary> upperPTActivitiesBEGList = snapshot.docs
          .map((doc) => PTLibrary.fromSnapshot(doc))
          .where((ptLibrary) =>
              ptLibrary.cat.contains('Upper') &&
              ptLibrary.level.contains('Beginner'))
          .toList();

      List<PTLibrary> upperPTActivitiesINTList = snapshot.docs
          .map((doc) => PTLibrary.fromSnapshot(doc))
          .where((ptLibrary) =>
              ptLibrary.cat.contains('Upper') &&
              !ptLibrary.level.contains('Advanced'))
          .toList();

      List<PTLibrary> otherPTActvitiesList = snapshot.docs
          .map((doc) => PTLibrary.fromSnapshot(doc))
          .where((ptLibrary) =>
              !ptLibrary.cat.contains('Upper') &&
              !ptLibrary.cat.contains('Lower'))
          .toList();

      List<PTLibrary> otherPTActvitiesBEGList = snapshot.docs
          .map((doc) => PTLibrary.fromSnapshot(doc))
          .where((ptLibrary) =>
              !ptLibrary.cat.contains('Upper') &&
              !ptLibrary.cat.contains('Lower') &&
              ptLibrary.level.contains('Beginner'))
          .toList();

      List<PTLibrary> otherPTActvitiesINTList = snapshot.docs
          .map((doc) => PTLibrary.fromSnapshot(doc))
          .where((ptLibrary) =>
              !ptLibrary.cat.contains('Upper') &&
              !ptLibrary.cat.contains('Lower') &&
              !ptLibrary.level.contains('Advanced'))
          .toList();

      int totalSelected = 5;
      List<PTLibrary> selectedUpperActivities = [];
      List<PTLibrary> selectedLowerActivities = [];
      List<PTLibrary> selectedOtherACtivities = [];

      if (upperStatus == 'beginner') {
        selectedUpperActivities = upperPTActivitiesBEGList.toList();
      } else if (upperStatus == 'intermediate') {
        selectedUpperActivities = upperPTActivitiesINTList.toList();
      } else {
        selectedUpperActivities = upperPTActivitiesList.toList();
      }

      if (lowerStatus == 'beginner') {
        selectedLowerActivities = lowerPTActivitiesBEGList.toList();
      } else if (lowerStatus == 'intermediate') {
        selectedLowerActivities = lowerPTActivitiesINTList.toList();
      } else {
        selectedLowerActivities = lowerPTActivitiesList.toList();
      }

      if (upperStatus == 'beginner' && lowerStatus == 'beginner') {
        selectedOtherACtivities = otherPTActvitiesBEGList.toList();
      } else if (upperStatus == 'advanced' && lowerStatus == 'advanced') {
        selectedOtherACtivities = otherPTActvitiesList.toList();
      } else {
        selectedOtherACtivities = otherPTActvitiesINTList.toList();
      }

      final CollectionReference ptCollection =
          usersCollection.doc(userId).collection('pt_activities');
      DateTime newRecordDate;
      int id = 0;
      QuerySnapshot ptLibrariesSnapshot = await userRef
          .collection('pt_activities')
          .orderBy('date', descending: true)
          .limit(1)
          .get();
      DocumentSnapshot? latestLibrarySnapshot =
          ptLibrariesSnapshot.docs.isNotEmpty
              ? ptLibrariesSnapshot.docs[0]
              : null;
      if (latestLibrarySnapshot != null) {
        Timestamp latestLibraryTimestamp = latestLibrarySnapshot.get('date');
        DateTime latestLibraryDate = DateTime(
          latestLibraryTimestamp.toDate().year,
          latestLibraryTimestamp.toDate().month,
          latestLibraryTimestamp.toDate().day,
        );
        DateTime currentDate = DateTime.now();
        DateTime currentDateWithoutTime =
            DateTime(currentDate.year, currentDate.month, currentDate.day);
        Duration difference =
            currentDateWithoutTime.difference(latestLibraryDate);
        int daysDifference = difference.inDays;
        int id = latestLibrarySnapshot.get('id');
        if (daysDifference > 0) {
          daysDifference = daysDifference + 7;
          for (int i = 1; i <= daysDifference; i++) {
            DateTime activityDate = latestLibraryDate.add(Duration(days: i));
            PTActivity newActivity = PTActivity(
                id: id + i, 
                isDone: false,
                date: Timestamp.fromDate(activityDate),
                progress: 0.0);

            DocumentReference ptActivityDocument =
                await ptCollection.add(newActivity.toMap());

            DocumentSnapshot ptActivitySnapshot =
                await ptActivityDocument.get();
            if (ptActivitySnapshot.exists) {
              await addPTActivitiesToUser(
                  ptActivityDocument,
                  selectedUpperActivities,
                  selectedLowerActivities,
                  selectedOtherACtivities,
                  totalSelected);
            }
          }
        } else if (daysDifference == -1) {
          for (int i = 1; i <= 6; i++) {
            DateTime activityDate = latestLibraryDate.add(Duration(days: i));
            PTActivity newActivity = PTActivity(
                id: id + i, 
                isDone: false,
                date: Timestamp.fromDate(activityDate),
                progress: 0.0);

            DocumentReference ptActivityDocument =
                await ptCollection.add(newActivity.toMap());

            DocumentSnapshot ptActivitySnapshot =
                await ptActivityDocument.get();
            if (ptActivitySnapshot.exists) {
              await addPTActivitiesToUser(
                  ptActivityDocument,
                  selectedUpperActivities,
                  selectedLowerActivities,
                  selectedOtherACtivities,
                  totalSelected);
            }
          }
        }
      } else {
        DateTime currentDate = DateTime.now();
        DateTime currentDateWithoutTime =
            DateTime(currentDate.year, currentDate.month, currentDate.day);
        newRecordDate = currentDateWithoutTime;
        id = 1;

        for (int i = 0; i < 8; i++) {
          DateTime activityDate = newRecordDate.add(Duration(days: i));
          PTActivity newActivity = PTActivity(
              id: id + i, 
              isDone: false,
              date: Timestamp.fromDate(activityDate),
              progress: 0.0);

          DocumentReference ptActivityDocument =
              await ptCollection.add(newActivity.toMap());

          DocumentSnapshot ptActivitySnapshot = await ptActivityDocument.get();
          if (ptActivitySnapshot.exists) {
            await addPTActivitiesToUser(
                ptActivityDocument,
                selectedUpperActivities,
                selectedLowerActivities,
                selectedOtherACtivities,
                totalSelected);
          }
        }
      }
    } catch (e) {
      print('Error suggesting activity list: $e');
    }
  }

  Future<void> addPTActivitiesToUser(
      DocumentReference ptActivityDocument,
      List<PTLibrary> selectedUpperActivities,
      List<PTLibrary> selectedLowerActivities,
      List<PTLibrary> selectedOtherACtivities,
      int totalSelected) async {
    List<PTLibrary> combinedList = [];
    selectedUpperActivities.shuffle();
    selectedLowerActivities.shuffle();
    selectedOtherACtivities.shuffle();

    CollectionReference activitiesCollection =
        ptActivityDocument.collection('activities');
    final Random random = Random();

    int upperRatio, lowerRatio, otherRatio;
    do {
      upperRatio = random.nextInt(6);
      lowerRatio = random.nextInt(6);
      otherRatio = random.nextInt(6);
    } while (upperRatio + lowerRatio + otherRatio != 5);

    print(
        'upperRatio: ${upperRatio}, lowerRatio: ${lowerRatio}, otherRatio: ${otherRatio}');

    selectedUpperActivities = selectedUpperActivities.take(upperRatio).toList();
    selectedLowerActivities = selectedLowerActivities.take(lowerRatio).toList();
    selectedOtherACtivities = selectedOtherACtivities.take(otherRatio).toList();

    combinedList.addAll(selectedUpperActivities);
    combinedList.addAll(selectedLowerActivities);
    combinedList.addAll(selectedOtherACtivities);

    combinedList.shuffle();

    for (var addedActivity in combinedList) {
      DocumentReference activityDocument = activitiesCollection.doc();
      await activityDocument.set({
        'ptid': addedActivity.id,
        'isDone': false,
      });
    }
  }
}
