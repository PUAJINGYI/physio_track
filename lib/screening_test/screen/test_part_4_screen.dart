import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:physio_track/screening_test/model/question_model.dart';
import 'package:physio_track/screening_test/model/question_response_model.dart';
import 'package:physio_track/screening_test/screen/test_end_screen.dart';

import '../../constant/ColorConstant.dart';
import '../../constant/ImageConstant.dart';
import '../../reusable_widget/reusable_widget.dart';
import '../../translations/locale_keys.g.dart';
import '../service/question_service.dart';
import '../widget/question_card.dart';

class TestPart4Screen extends StatefulWidget {
  const TestPart4Screen({super.key});

  @override
  State<TestPart4Screen> createState() => _TestPart4ScreenState();
}

class _TestPart4ScreenState extends State<TestPart4Screen> {
  List<Question> questions = [];
  List<QuestionResponse> responses = [];
  QuestionService questionService = QuestionService();

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  String uId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> fetchQuestions() async {
    List<Question> fetchedQuestions =
        await questionService.fetchQuestionsByTopic('daily');

    setState(() {
      questions = fetchedQuestions;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  void updateResponse(int index, double value) {
    if (index >= responses.length) {
      // Add new QuestionResponse objects for unanswered questions
      for (int i = responses.length; i < index; i++) {
        responses.add(
          QuestionResponse(
            id: questions[i].id,
            question: questions[i].question,
            topic: questions[i].topic,
            questionType: questions[i].questionType,
            response:
                '1.0', // Set a default response of 1.0 for unanswered questions
          ),
        );
      }

      // Add the QuestionResponse for the current question
      responses.add(
        QuestionResponse(
          id: questions[index].id,
          question: questions[index].question,
          topic: questions[index].topic,
          questionType: questions[index].questionType,
          response: value.toStringAsFixed(1),
        ),
      );
    } else {
      // Update the existing QuestionResponse object
      responses[index] = QuestionResponse(
        id: questions[index].id,
        question: questions[index].question,
        topic: questions[index].topic,
        questionType: questions[index].questionType,
        response: value.toStringAsFixed(1),
      );
    }
  }

  void submitResponses() {
    // Check if all questions are answered
    bool allQuestionsAnswered = responses.length == questions.length;

    if (!allQuestionsAnswered) {
      // Show snackbar alerting the user to answer all questions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.Please_answer_all_questions_before_proceeding.tr()),
        ),
      );
      return; // Stop the submission process
    }

    // Save responses to Firestore or perform any other operations
    questionService.addResponse(uId, responses);

    // Print responses for demonstration
    responses.forEach((response) {
      print('ID: ${response.id}');
      print('Question: ${response.question}');
      print('Topic: ${response.topic}');
      print('Question Type: ${response.questionType}');
      print('Response: ${response.response}');
      print('--------------');
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestFinishScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 50),
          Text(
            LocaleKeys.Part_4.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            LocaleKeys.Daily_Activities.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
            child: Card(
              color: Colors.blue[50],
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Image.asset(
                    ImageConstant.TEST_DAILY,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (questions.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          final sortedQuestions = questions
                            ..sort((a, b) => a.id.compareTo(b.id));
                          final question = sortedQuestions[index];
                          final responseIndex =
                              responses.indexWhere((r) => r.id == question.id);
                          final responseValue = responseIndex != -1
                              ? double.tryParse(
                                      responses[responseIndex].response) ??
                                  1.0
                              : 1.0;

                          return StatefulBuilder(
                            builder: (context, setState) {
                              return QuestionCard(
                                question: question,
                                responses:
                                    responses, // Provide the responses list
                                onChanged: (value) {
                                  setState(() {
                                    updateResponse(
                                        index, value); // Update the response
                                  });
                                },
                                context: context,
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: customButton(
                context,
                LocaleKeys.Next.tr(),
                ColorConstant.BLUE_BUTTON_TEXT,
                ColorConstant.BLUE_BUTTON_UNPRESSED,
                ColorConstant.BLUE_BUTTON_PRESSED, () {
              submitResponses();
            }),
          )
        ],
      ),
    );
  }
}
