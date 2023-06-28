import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:physio_track/screening_test/model/question_model.dart';
import 'package:physio_track/screening_test/service/question_service.dart';

class AddQuestionScreen extends StatefulWidget {
  const AddQuestionScreen({super.key});

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final TextEditingController _questionController = TextEditingController();
  String _topic = 'general';
  String _questionType = 'scale'; // Default question type

  QuestionService questionService = QuestionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Question'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              TextField(
                controller: _questionController,
                decoration: InputDecoration(
                  labelText: 'Question',
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Topic:',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Radio<String>(
                          value: 'general',
                          groupValue: _topic,
                          onChanged: (String? value) {
                            setState(() {
                              _topic = value!;
                            });
                          },
                        ),
                        Text('General'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Radio<String>(
                          value: 'upper',
                          groupValue: _topic,
                          onChanged: (String? value) {
                            setState(() {
                              _topic = value!;
                            });
                          },
                        ),
                        Text('Upper Extremity Function'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Radio<String>(
                          value: 'lower',
                          groupValue: _topic,
                          onChanged: (String? value) {
                            setState(() {
                              _topic = value!;
                            });
                          },
                        ),
                        Text('Lower Extremity Function'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Radio<String>(
                          value: 'daily',
                          groupValue: _topic,
                          onChanged: (String? value) {
                            setState(() {
                              _topic = value!;
                            });
                          },
                        ),
                        Text('Daily Activities'),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question Type:',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Radio<String>(
                          value: 'option',
                          groupValue: _questionType,
                          onChanged: (String? value) {
                            setState(() {
                              _questionType = value!;
                            });
                          },
                        ),
                        Text('Option'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Radio<String>(
                          value: 'scale',
                          groupValue: _questionType,
                          onChanged: (String? value) {
                            setState(() {
                              _questionType = value!;
                            });
                          },
                        ),
                        Text('Scale'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Radio<String>(
                          value: 'date',
                          groupValue: _questionType,
                          onChanged: (String? value) {
                            setState(() {
                              _questionType = value!;
                            });
                          },
                        ),
                        Text('Date'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Radio<String>(
                          value: 'short',
                          groupValue: _questionType,
                          onChanged: (String? value) {
                            setState(() {
                              _questionType = value!;
                            });
                          },
                        ),
                        Text('Short Answer'),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  String questionText = _questionController.text;
                  questionService.addQuestion(
                    questionText: questionText,
                    topic: _topic,
                    questionType: _questionType,
                  );
                  _questionController.clear();
                  setState(() {
                    _topic = 'general';
                    _questionType = 'scale';
                  });
                },
                child: Text('Add Question'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
