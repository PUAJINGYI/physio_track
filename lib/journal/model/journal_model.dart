import 'package:cloud_firestore/cloud_firestore.dart';

class Journal {
  int id;
  DateTime date;
  String title;
  String weather;
  String feeling;
  String healthCondition;
  String comment;
  String imageUrl;

  Journal({
    required this.id,
    required this.date,
    required this.title,
    required this.weather,
    required this.feeling,
    required this.healthCondition,
    required this.comment,
    this.imageUrl = '',
  });

  factory Journal.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Journal(
      id: data['id'],
      date: data['date'].toDate(),
      title: data['title'],
      weather: data['weather'],
      feeling: data['feeling'],
      healthCondition: data['healthCondition'],
      comment: data['comment'],
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'id': id,
      'date': date,
      'title': title,
      'weather': weather,
      'feeling': feeling,
      'healthCondition': healthCondition,
      'comment': comment,
    };

    if (imageUrl != null && imageUrl.isNotEmpty) {
      map['imageUrl'] = imageUrl;
    }

    return map;
  }
}
