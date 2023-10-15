import 'package:cloud_firestore/cloud_firestore.dart';

class OTLibrary{
  int id;
  String title;
  String description;
  int duration;
  String level;
  String videoUrl;

    OTLibrary({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.level,
    required this.videoUrl,
  });

  factory OTLibrary.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return OTLibrary(
      id: data['id'],
      title: data['title'],
      description: data['description'],
      duration: data['duration'],
      level: data['level'],
      videoUrl: data['videoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'id': id,
      'title': title,
      'description': description,
      'duration': duration,
      'level': level,
      'videoUrl': videoUrl,
    };

    return map;
  }
}