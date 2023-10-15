import 'package:cloud_firestore/cloud_firestore.dart';

class UserAppointment {
  int appointmentId;

  UserAppointment({
    required this.appointmentId,
  });

  factory UserAppointment.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserAppointment(
      appointmentId: data['appointmentId'],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'appointmentId': appointmentId,
    };
    return map;
  }
}
