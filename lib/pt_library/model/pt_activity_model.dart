import 'package:cloud_firestore/cloud_firestore.dart';

class PTActivity{
  int id;
  bool isDone;
  Timestamp date;
  double progress;

    PTActivity({
    required this.id,
    required this.isDone,
    required this.date,
    required this.progress,
  });

  factory PTActivity.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return PTActivity(
      id: data['id'],
      isDone: data['isDone'], 
      date: data['date'],
      progress:  (data['progress'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'id': id,
      'isDone': isDone,
      'date': date,
      'progress': progress,
    };

    return map;
  }
}