import 'package:cloud_firestore/cloud_firestore.dart';

import '../../appointment/service/appointment_service.dart';
import '../../user_management/service/user_management_service.dart';
import '../model/leave_model.dart';

class LeaveService {
  CollectionReference leaveCollection =
      FirebaseFirestore.instance.collection('leaves');
  CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  UserManagementService userManagementService = UserManagementService();
  AppointmentService appointmentService = AppointmentService();

  // add leave record
  Future<void> addLeaveRecord(Leave leave) async {
    QuerySnapshot querySnapshot =
        await leaveCollection.orderBy('id', descending: true).limit(1).get();

    int currentMaxId =
        querySnapshot.docs.isEmpty ? 0 : querySnapshot.docs.first['id'];
    int newId = currentMaxId + 1;
    leave.id = newId;
    Leave newLeave = leave;

    await leaveCollection.add(newLeave.toMap());
    await addLeaveReferenceToPhysio(newLeave);

    if (leave.isFullDay) {
      await removeLeaveRecordByPhysioIdAndDate(leave.physioId, leave.date);
    }
    await appointmentService.fetchAppointmentByDateTimeAndChangeStatus(leave);
  }

  // add leave reference to physio
  Future<void> addLeaveReferenceToPhysio(Leave newLeave) async {
    String uid =
        await userManagementService.fetchUidByUserId(newLeave.physioId);
    QuerySnapshot querySnapshot = await userCollection
        .where('id', isEqualTo: newLeave.physioId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final CollectionReference leaveCollection =
          userCollection.doc(querySnapshot.docs.first.id).collection('leaves');
      await leaveCollection
          .add({'leaveId': newLeave.id, 'leaveType': newLeave.leaveType});
    }
  }

  // delete leave refrence to physio
  Future<void> deleteLeaveReferenceToPhysio(Leave leave) async {
    String uid = await userManagementService.fetchUidByUserId(leave.physioId);
    QuerySnapshot querySnapshot = await userCollection
        .where('id', isEqualTo: leave.physioId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final CollectionReference leaveCollection =
          userCollection.doc(uid).collection('leaves');
      QuerySnapshot querySnapshot = await leaveCollection
          .where('leaveId', isEqualTo: leave.id)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await leaveCollection.doc(querySnapshot.docs.first.id).delete();
      }
    }
  }

  // fetch leave record by physioId and specific date, return null if empty record found
  Future<Leave?> fetchLeaveRecordByPhysioIdAndDate(
      int physioId, DateTime date) async {
    QuerySnapshot querySnapshot = await leaveCollection
        .where('physioId', isEqualTo: physioId)
        .where('date', isEqualTo: date)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      Leave leave = Leave.fromSnapshot(querySnapshot.docs.first);
      return leave;
    } else {
      return null;
    }
  }

  //fetch all leave history by physioId and specific date, in descending order
  Future<List<Leave>> fetchLeaveByPhysioIdAndDate(
      int physioId, DateTime date) async {
    QuerySnapshot querySnapshot = await leaveCollection
        .where('physioId', isEqualTo: physioId)
        .where('date', isEqualTo: date)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      List<Leave> leaveList =
          querySnapshot.docs.map((doc) => Leave.fromSnapshot(doc)).toList();
      return leaveList;
    } else {
      return [];
    }
  }

  //fetch all leave history by physioId, in descending order
  Future<List<Leave>> fetchLeaveHistoryByPhysioId(int physioId) async {
    QuerySnapshot querySnapshot =
        await leaveCollection.where('physioId', isEqualTo: physioId).get();

    if (querySnapshot.docs.isNotEmpty) {
      List<Leave> leaveList =
          querySnapshot.docs.map((doc) => Leave.fromSnapshot(doc)).toList();
      leaveList.sort((a, b) => b.date.compareTo(a.date));
      return leaveList;
    } else {
      return [];
    }
  }

  // remove specific leave record list by physioId and date
  Future<void> removeLeaveRecordByPhysioIdAndDate(
      int physioId, DateTime date) async {
    List<Leave> leaveList = [];
    QuerySnapshot querySnapshot = await leaveCollection
        .where('physioId', isEqualTo: physioId)
        .where('date', isEqualTo: date)
        .where('isFullDay', isEqualTo: false)
        .get();

    //return the querySnapshot in a list
    if (querySnapshot.docs.isNotEmpty) {
      leaveList =
          querySnapshot.docs.map((doc) => Leave.fromSnapshot(doc)).toList();
    }

    //remove the leave record from leave collection
    for (Leave leave in leaveList) {
      QuerySnapshot querySnapshot =
          await leaveCollection.where('id', isEqualTo: leave.id).get();

      if (querySnapshot.docs.isNotEmpty) {
        String documentId = querySnapshot.docs.first.id;
        await leaveCollection.doc(documentId).delete();
      }
      await deleteLeaveReferenceToPhysio(leave);
    }
  }

  // check availability of physio on now time
  Future<bool> checkPhysioAvailability(int physioId) async {
    DateTime now = DateTime.now();
    QuerySnapshot querySnapshot = await leaveCollection
        .where('physioId', isEqualTo: physioId)
        .where('date', isEqualTo: now)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      List<Leave> leaveList =
          querySnapshot.docs.map((doc) => Leave.fromSnapshot(doc)).toList();
      for (Leave leave in leaveList) {
        if (leave.isFullDay) {
          return false;
        } else {
          if (now.isAfter(leave.startTime) && now.isBefore(leave.endTime)) {
            return false;
          }
        }
      }
    }
    return true;
  }

  // check availibility of physio on specific date and specific time
  Future<bool> checkPhysioAvailabilityByDateAndTime(
      int physioId, DateTime date, DateTime startTime, DateTime endTime) async {
    QuerySnapshot querySnapshot = await leaveCollection
        .where('physioId', isEqualTo: physioId)
        .where('date', isEqualTo: date)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      List<Leave> leaveList =
          querySnapshot.docs.map((doc) => Leave.fromSnapshot(doc)).toList();
      for (Leave leave in leaveList) {
        if (leave.isFullDay) {
          return false;
        } else {
          if (startTime.isAtSameMomentAs(leave.startTime) ||
              (startTime.isAfter(leave.startTime) &&
                  startTime.isBefore(leave.endTime))) {
            return false;
          }
        }
      }
    }
    return true;
  }
}
