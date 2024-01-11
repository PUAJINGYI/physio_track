import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionResponse {
  final int id;
  final String question;
  final String topic;
  final String questionType;
  final String response;

  QuestionResponse(
      {required this.id,
      required this.question,
      required this.topic,
      required this.questionType,
      required this.response});
  factory QuestionResponse.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return QuestionResponse(
      id: data['id'],
      question: data['question'],
      topic: data['topic'],
      questionType: data['questionType'],
      response: data['response'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'topic': topic,
      'questionType': questionType,
      'response': response,
    };
  }
}
