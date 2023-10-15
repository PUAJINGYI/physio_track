import 'package:cloud_firestore/cloud_firestore.dart';

class Achievement {
  int id;
  String title;
  String description;
  String imageUrl;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl = '',
  });

  factory Achievement.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Achievement(
      id: data['id'],
      title: data['title'],
      description: data['description'],
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'id': id,
      'title': title,
      'description': description,
    };

    if (imageUrl != null && imageUrl.isNotEmpty) {
      map['imageUrl'] = imageUrl;
    }

    return map;
  }
}
