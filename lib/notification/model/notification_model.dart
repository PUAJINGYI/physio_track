import 'package:cloud_firestore/cloud_firestore.dart';

class Notifications{
  int id;
  DateTime date;
  String title;
  String message;
  bool isRead;
  int fromId;

  Notifications({
    required this.id,
    required this.date,
    required this.title,
    required this.message,
    required this.isRead,
    required this.fromId,
  });

  factory Notifications.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Notifications(
      id: data['id'],
      date: data['date'].toDate(),
      title: data['title'],
      message: data['message'],
      isRead: data['isRead'],
      fromId: data['fromId'],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'id': id,
      'date': date,
      'title': title,
      'message': message,
      'isRead': isRead,
      'fromId': fromId,
    };

    return map;
  }
}