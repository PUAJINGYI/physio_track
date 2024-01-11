import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
    List<QuestionResponse> defaultResponses = [];
    for (Question question in fetchedQuestions) {
      if (question.questionType == "short" || question.questionType == "date") {
        continue;
      }
      defaultResponses.add(QuestionResponse(
        id: question.id,
        question: question.question,
        topic: question.topic,
        questionType: question.questionType,
        response: '1.0', 
      ));
    }
    setState(() {
      questions = fetchedQuestions;
      responses = defaultResponses;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  void updateResponse(int index, double value) {
    if (index >= responses.length) {
      for (int i = responses.length; i < index; i++) {
        responses.add(
          QuestionResponse(
            id: questions[i].id,
            question: questions[i].question,
            topic: questions[i].topic,
            questionType: questions[i].questionType,
            response:
                '1.0', 
          ),
        );
      }

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
    bool allQuestionsAnswered = responses.length == questions.length;

    if (!allQuestionsAnswered) {
      reusableDialog(context, LocaleKeys.Error.tr(),
          LocaleKeys.Please_answer_all_questions_before_proceeding.tr());
      return; 
    }

    questionService.addResponse(uId, responses);

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
                    width: 250,
                    height: 150,
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
                        padding: EdgeInsets.zero,
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
                                    responses, 
                                onChanged: (value) {
                                  setState(() {
                                    updateResponse(
                                        index, value);
                                  });
                                },
                                context: context,
                              );
                            },
                          );
                        },
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
