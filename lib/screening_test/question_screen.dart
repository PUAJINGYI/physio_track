// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:physio_track/screening_test/service/question_service.dart';

// import 'model/question_model.dart';

// class QuestionsScreen extends StatefulWidget {
//   const QuestionsScreen({Key? key}) : super(key: key);

//   @override
//   _QuestionsScreenState createState() => _QuestionsScreenState();
// }

// class _QuestionsScreenState extends State<QuestionsScreen> {
//   List<Question> questions = [];
//   QuestionService questionService = QuestionService();
//   Future<void> fetchQuestions() async {
//     List<Question> fetchedQuestions =
//         await questionService.fetchQuestionsByTopic('upper');

//     setState(() {
//       questions = fetchedQuestions;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     fetchQuestions();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text('Questions'),
//         ),
//         body: ListView.builder(
//           itemCount: questions.length,
//           itemBuilder: (context, index) {
//             Question question = questions[index];
//             return ListTile(
//               title: Text(question.question),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Topic: ${question.topic}'),
//                   Text('Question Type: ${question.questionType}'),
//                   // Add more attributes as needed
//                 ],
//               ),
//             );
//           },
//         ));
//   }
// }
