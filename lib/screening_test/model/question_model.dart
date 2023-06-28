import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final int id;
  final String question;
  final String topic;
  final String questionType;

  Question({required this.id, required this.question,required this.topic,required this.questionType});
  // Create a factory constructor to parse the Firestore document snapshot
  factory Question.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Question(
      id: data['id'],
      question: data['question'],
      topic: data['topic'],
      questionType: data['questionType'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'topic': topic,
      'questionType': questionType,
    };
  }
}
