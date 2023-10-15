import 'package:cloud_firestore/cloud_firestore.dart';

class UserAchievement {
  int achId;
  bool isTaken;
  double progress;
  DateTime completedTime;
  

  UserAchievement({
    required this.achId,
    required this.isTaken,
    required this.progress,
    required this.completedTime,
  });

  factory UserAchievement.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserAchievement(
      achId: data['achId'],
      isTaken: data['isTaken'],
      progress: (data['progress'] ?? 0).toDouble(),
      completedTime: data['completedTime'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'achId': achId,
      'isTaken': isTaken,
      'progress': progress,
      'completedTime': completedTime,
    };
    return map;
  }
}
