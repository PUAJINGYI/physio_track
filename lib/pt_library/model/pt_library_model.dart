import 'package:cloud_firestore/cloud_firestore.dart';

class PTLibrary{
  int id;
  String title;
  String description;
  int duration;
  String level;
  String cat;
  String videoUrl;
  String thumbnailUrl;
  int exp;

    PTLibrary({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.level,
    required this.cat,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.exp,
  });

  factory PTLibrary.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return PTLibrary(
      id: data['id'],
      title: data['title'],
      description: data['description'],
      duration: data['duration'],
      level: data['level'],
      cat: data['cat'],
      videoUrl: data['videoUrl'],
      thumbnailUrl: data['thumbnailUrl'], 
      exp: data['exp'],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'id': id,
      'title': title,
      'description': description,
      'duration': duration,
      'level': level,
      'cat': cat,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'exp': exp,
    };

    return map;
  }
}