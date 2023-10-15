import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:physio_track/ot_library/model/ot_activity_model.dart';

import '../model/ot_library_model.dart';

class UserOTListService {
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  CollectionReference ptLibraryCollection =
      FirebaseFirestore.instance.collection('pt_library');
  CollectionReference otLibraryCollection =
      FirebaseFirestore.instance.collection('ot_library');

  Future<List<OTActivity>> fetchUserListByDate(
      String uId, DateTime fromDate, toDate) async {
    fromDate = DateTime(fromDate.year, fromDate.month, fromDate.day);
    toDate = DateTime(toDate.year, toDate.month, toDate.day);

    final CollectionReference otCollection =
        usersCollection.doc(uId).collection('ot_activities');
    final QuerySnapshot otSnapshot = await otCollection
        .where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate),
            isLessThanOrEqualTo: Timestamp.fromDate(toDate))
        .get();
    List<OTActivity> otList =
        otSnapshot.docs.map((doc) => OTActivity.fromSnapshot(doc)).toList();
    return otList;
  }

  Future<void> suggestOTActivityList(
      DocumentReference userRef, String userId) async {
    try {
      DocumentSnapshot userDoc = await userRef.get();
      String dailyStatus = userDoc.get('dailyStatus');
      String gender = userDoc.get('gender');

      QuerySnapshot dailySnapshot = await otLibraryCollection.get();
      QuerySnapshot dailyBeginnerSnapshot =
          await otLibraryCollection.where('level', isEqualTo: 'Beginner').get();
      QuerySnapshot dailyIntermediateSnapshot = await otLibraryCollection
          .where('level', whereIn: ['Beginner', 'Intermediate']).get();
      QuerySnapshot dailyAdvancedSnapshot = await otLibraryCollection.where(
          'level',
          whereIn: ['Beginner', 'Intermediate', 'Advanced']).get();

      List<OTLibrary> dailyBeginnerList = dailyBeginnerSnapshot.docs
          .map((doc) => OTLibrary.fromSnapshot(doc))
          .toList();
      List<OTLibrary> dailyIntermediateList = dailyIntermediateSnapshot.docs
          .map((doc) => OTLibrary.fromSnapshot(doc))
          .toList();
      List<OTLibrary> dailyAdvancedList;

      if (gender == 'male') {
        dailyAdvancedList = dailyAdvancedSnapshot.docs
            .map((doc) => OTLibrary.fromSnapshot(doc))
            .where((otLibrary) => !otLibrary.title.contains('Bra'))
            .toList();
      } else {
        dailyAdvancedList = dailyAdvancedSnapshot.docs
            .map((doc) => OTLibrary.fromSnapshot(doc))
            .toList();
      }
      print('All dailyAdvancedList:');
      for (var activity in dailyAdvancedList) {
        print(activity.id);
      }

      dailyBeginnerList.shuffle();
      dailyIntermediateList.shuffle();
      dailyAdvancedList.shuffle();

      int totalSelected = 5;
      List<OTLibrary> selectedActivities = [];

      if (dailyStatus == 'beginner') {
        selectedActivities = dailyBeginnerList.toList();
      } else if (dailyStatus == 'intermediate') {
        selectedActivities = dailyIntermediateList.toList();
      } else if (dailyStatus == 'advanced') {
        selectedActivities = dailyAdvancedList.toList();
      } else {
        selectedActivities = dailyBeginnerList.toList();
      }

      final CollectionReference otCollection =
          usersCollection.doc(userId).collection('ot_activities');

      DateTime newRecordDate;
      int id = 0;
      QuerySnapshot otLibrariesSnapshot = await userRef
          .collection('ot_activities')
          .orderBy('date', descending: true)
          .limit(1)
          .get();
      DocumentSnapshot? latestLibrarySnapshot =
          otLibrariesSnapshot.docs.isNotEmpty
              ? otLibrariesSnapshot.docs[0]
              : null;
      if (latestLibrarySnapshot != null) {
        Timestamp latestLibraryTimestamp = latestLibrarySnapshot.get('date');
        DateTime latestLibraryDate = DateTime(
          latestLibraryTimestamp.toDate().year,
          latestLibraryTimestamp.toDate().month,
          latestLibraryTimestamp.toDate().day,
        ).add(Duration(days: 1));
        newRecordDate = latestLibraryDate;
        int recordId = latestLibrarySnapshot.get('id');
        id = recordId + 1;
      } else {
        // Calculate the current date and time
        DateTime currentDate = DateTime.now();
        DateTime currentDateWithoutTime =
            DateTime(currentDate.year, currentDate.month, currentDate.day);
        newRecordDate = currentDateWithoutTime;
        id = 1;
      }

      for (int i = 0; i < 14; i++) {
        DateTime activityDate = newRecordDate.add(Duration(days: i));
        OTActivity newActivity = OTActivity(
            id: id + i, // Incremental ID starting from 1
            isDone: false,
            date: Timestamp.fromDate(activityDate),
            progress: 0.0);

        DocumentReference otActivityDocument =
            await otCollection.add(newActivity.toMap());

        DocumentSnapshot otActivitySnapshot = await otActivityDocument.get();
        if (otActivitySnapshot.exists) {
          await addOTActivitiesToUser(
              otActivityDocument, selectedActivities, totalSelected);
        }
      }
    } catch (e) {
      print('Error suggesting activity list: $e');
    }
  }

  Future<void> addOTActivitiesToUser(DocumentReference otActivityDocument,
      List<OTLibrary> selectedActivities, int totalSelected) async {
    CollectionReference activitiesCollection =
        otActivityDocument.collection('activities');

    // Shuffle the selectedActivities list for each activity
    selectedActivities.shuffle();
    selectedActivities = selectedActivities.take(totalSelected).toList();
    selectedActivities.shuffle();

    for (var addedActivity in selectedActivities) {
      DocumentReference activityDocument = activitiesCollection.doc();
      await activityDocument.set({
        'otid': addedActivity.id,
        'isDone': false,
      });
    }
  }
}
