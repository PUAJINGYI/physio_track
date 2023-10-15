import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentInPending{
  int id;
  String title;
  DateTime date;
  DateTime startTime;
  DateTime endTime;
  int durationInSecond;
  String status;
  bool isApproved;
  int patientId;
  int physioId;
  String eventId;

  AppointmentInPending({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.durationInSecond,
    required this.status,
    required this.isApproved,
    required this.patientId,
    required this.physioId,
    required this.eventId,
  });

  factory AppointmentInPending.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return AppointmentInPending(
      id: data['id'],
      title: data['title'],
      date: data['date'].toDate(),
      startTime: data['startTime'].toDate(),
      endTime: data['endTime'].toDate(),
      durationInSecond: data['durationInSecond'],
      status: data['status'],
      isApproved: data['isApproved'],
      patientId: data['patientId'],
      physioId: data['physioId'],
      eventId: data['eventId'],
    );
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      'id': id,
      'title': title,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'durationInSecond': durationInSecond,
      'status': status,
      'isApproved': isApproved,
      'patientId': patientId,
      'physioId': physioId,
      'eventId': eventId,
    };
    return map;
  }
}
