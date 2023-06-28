import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class SurveyQuestion {
  final String question;
  int selectedValue;

  SurveyQuestion(this.question, this.selectedValue);
}

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
//   int currentQuestionIndex = 0;
//   List<Map<String, dynamic>> questions = [
//     {
//       'question': 'What is the capital of France?',
//       'options': ['Paris', 'London', 'Berlin', 'Rome', 'Madrid'],
//       'correctAnswer': 'Paris',
//     },
//     {
//       'question': 'What is UM?',
//       'options': [
//         'University Malaya',
//         'Utara Malaysia',
//         'Umbrella Man',
//         'Unmentioned'
//       ],
//       'correctAnswer': 'University Malaya',
//     },
//     // Add more questions here...
//   ];

//   List<dynamic> selectedOptions = [];

// void selectOption(String? option) {
//   setState(() {
//     selectedOptions[currentQuestionIndex] = option!;
//   });
// }

//   void nextQuestion() {
//     if (currentQuestionIndex < questions.length - 1) {
//       setState(() {
//         currentQuestionIndex++;
//       });
//     }
//   }

//   void submitQuiz() {
//     // Process and submit the quiz
//     // You can store the selected options in Firestore here
//   }

//   @override
//   void initState() {
//     super.initState();
//     selectedOptions = List<dynamic>.filled(questions.length, null);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Quiz'),
//       ),
//       body: Column(
//         children: [
//           SizedBox(height: 20),
//           Text(
//             'Question ${currentQuestionIndex + 1}:',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 10),
//           Text(
//             questions[currentQuestionIndex]['question'],
//             style: TextStyle(fontSize: 18),
//           ),
//           SizedBox(height: 20),
//           Column(
//             children: List.generate(
//               questions[currentQuestionIndex]['options'].length,
//               (index) => ListTile(
//                 title: Text(questions[currentQuestionIndex]['options'][index]),
//                 leading: Radio<String>(
//                   value: questions[currentQuestionIndex]['options'][index],
//                   groupValue: selectedOptions[currentQuestionIndex] as String?,
//                   onChanged: (String? option) {
//                     selectOption(option);
//                   },
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: nextQuestion,
//             child: Text('Next'),
//           ),
//           if (currentQuestionIndex == questions.length - 1) ...[
//             SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: submitQuiz,
//               child: Text('Submit'),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
  List<SurveyQuestion> questions = [
    SurveyQuestion('Are you happy?', 3),
    SurveyQuestion('How satisfied are you?', 3),
    SurveyQuestion('Do you feel motivated?', 3),
    SurveyQuestion('Are you stressed?', 3),
    SurveyQuestion('Do you feel energized?', 3),
    SurveyQuestion('Are you happy?', 3),
    SurveyQuestion('How satisfied are you?', 3),
    SurveyQuestion('Do you feel motivated?', 3),
    SurveyQuestion('Are you stressed?', 3),
    SurveyQuestion('Do you feel energized?', 3),
    SurveyQuestion('Are you happy?', 3),
    SurveyQuestion('How satisfied are you?', 3),
    SurveyQuestion('Do you feel motivated?', 3),
    SurveyQuestion('Are you stressed?', 3),
    SurveyQuestion('Do you feel energized?', 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screening Test'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Part 1',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              Text(
                'Body Part Affected',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Container(
                        color: Colors.blue[50],
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                questions[index].question,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Least Affected'),
                                  Text('Most Affected'),
                                ],
                              ),
                              Slider(
                                value:
                                    questions[index].selectedValue.toDouble(),
                                min: 1,
                                max: 5,
                                divisions: 4,
                                onChanged: (newValue) {
                                  setState(() {
                                    questions[index].selectedValue =
                                        newValue.round();
                                  });
                                },
                              ),
                              SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Submit the survey and print the responses
                  List responses = questions
                      .map((question) => question.selectedValue)
                      .toList();
                  print('Survey Responses: $responses');
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
