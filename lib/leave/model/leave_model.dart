import 'package:cloud_firestore/cloud_firestore.dart';

class Leave {
  int id;
  DateTime date;
  DateTime startTime;
  DateTime endTime;
  String reason;
  bool isFullDay;
  int physioId;
  String leaveType;

  Leave({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.reason,
    required this.isFullDay,
    required this.physioId,
    required this.leaveType,
  });

  factory Leave.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Leave(
      id: data['id'],
      date: data['date'].toDate(),
      startTime: data['startTime'].toDate(),
      endTime: data['endTime'].toDate(),
      reason: data['reason'],
      isFullDay: data['isFullDay'],
      physioId: data['physioId'],
      leaveType: data['leaveType'],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'id': id,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'reason': reason,
      'isFullDay': isFullDay,
      'physioId': physioId,
      'leaveType': leaveType,
    };

    return map;
  }
}
