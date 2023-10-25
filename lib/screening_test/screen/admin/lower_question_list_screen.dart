import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:physio_track/screening_test/service/question_service.dart';

import '../../../constant/ColorConstant.dart';
import '../../model/question_model.dart';

class LowerQuestionListScreen extends StatefulWidget {
  const LowerQuestionListScreen({Key? key}) : super(key: key);

  @override
  State<LowerQuestionListScreen> createState() =>
      _LowerQuestionListScreenState();
}

class _LowerQuestionListScreenState extends State<LowerQuestionListScreen> {
  QuestionService questionService = QuestionService();
  late Future<List<Question>> _lowerQuestionListFuture;
  final TextEditingController _questionController = TextEditingController();
  String _questionType = 'scale';

  @override
  void initState() {
    super.initState();
    _lowerQuestionListFuture = _fetchQuestionList();
  }

  Future<List<Question>> _fetchQuestionList() async {
    return await questionService.fetchQuestionsByTopic("lower");
  }

  void showDeleteConfirmationDialog(BuildContext context, int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero, // Remove content padding
          titlePadding:
              EdgeInsets.fromLTRB(24, 0, 24, 0), // Adjust title padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Delete Question'),
              IconButton(
                icon: Icon(Icons.close, color: ColorConstant.RED_BUTTON_TEXT),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          ),
          content: Text(
            'Are you sure to delete this question?',
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              // Wrap actions in Center widget
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: ColorConstant.BLUE_BUTTON_UNPRESSED,
                    ),
                    child: Text(
                      'Yes',
                      style: TextStyle(color: ColorConstant.BLUE_BUTTON_TEXT),
                    ),
                    onPressed: () async {
                      await performDeleteLogic(
                          id, context); // Wait for the deletion to complete
                      setState(() {
                        _lowerQuestionListFuture =
                            _fetchQuestionList(); // Refresh the patient list
                      });
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: ColorConstant.RED_BUTTON_UNPRESSED,
                    ),
                    child: Text(
                      'No',
                      style: TextStyle(color: ColorConstant.RED_BUTTON_TEXT),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> performDeleteLogic(int id, context) async {
    try {
      await questionService
          .deleteQuestion(id); // Wait for the deletion to complete
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Question deleted")),
      );
    } catch (error) {
      print('Error deleting question: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Question could not be deleted")),
      );
    }
  }

  Future<void> performAddLogic(
      String questionText, String _questionType) async {
    try {
      await questionService.addQuestion(
        questionText: questionText,
        topic: 'lower',
        questionType: _questionType,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Question added")),
      );

      setState(() {
        _lowerQuestionListFuture = _fetchQuestionList();
      });
    } catch (error) {
      print('Error adding question: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Question could not be added")),
      );
    }
  }

  Future<void> performEditLogic(int id, String newQuestionText) async {
    try {
      await questionService.editQuestion(id, newQuestionText);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Question updated")),
      );
      setState(() {
        _lowerQuestionListFuture = _fetchQuestionList();
      });
    } catch (error) {
      print('Error editing question: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Question could not be updated")),
      );
    }
  }

  void showAddQuestionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.clear,
                          color: ColorConstant.RED_BUTTON_TEXT,
                        ),
                      ),
                    ),
                    Text(
                      'Add Question',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: _questionController,
                      decoration: InputDecoration(
                        labelText: 'Question',
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Question Type:',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Row(
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
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () async {
                        String questionText = _questionController.text;
                        if (questionText.isNotEmpty) {
                          await performAddLogic(questionText,
                              _questionType); // Wait for the deletion to complete
                          setState(() {
                            _lowerQuestionListFuture =
                                _fetchQuestionList(); // Refresh the patient list
                          });
                          Navigator.of(context).pop(); // Close the dialog
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Question cannot be empty")),
                          );
                        }
                      },
                      child: Text('Add Question'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showEditQuestionDialog(BuildContext context, Question question) {
    TextEditingController questionController =
        TextEditingController(text: question.question);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.clear,
                          color: ColorConstant.RED_BUTTON_TEXT,
                        ),
                      ),
                    ),
                    Text(
                      'Edit Question',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: questionController,
                      decoration: InputDecoration(
                        labelText: 'Question',
                      ),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () async {
                        String newQuestionText = questionController.text;
                        if (newQuestionText.isNotEmpty) {
                          await performEditLogic(question.id, newQuestionText);
                          setState(() {
                            _lowerQuestionListFuture = _fetchQuestionList();
                          });
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Question cannot be empty")),
                          );
                        }
                      },
                      child: Text('Save'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Question>>(
      future: _lowerQuestionListFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.hasData) {
          List<Question> questions = snapshot.data!;
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                child: ListView(
                  children: questions.map((Question question) {
                    return Card(
                      color: Color.fromRGBO(241, 243, 250, 1),
                      child: Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text(
                                question.question,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(question.questionType),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                            child: Container(
                              width: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: IconButton(
                                icon: Icon(Icons.edit),
                                color: Colors.blue,
                                onPressed: () {
                                  showEditQuestionDialog(context, question);
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: Container(
                              width: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: IconButton(
                                icon: Icon(Icons.delete_outline),
                                color: Colors.blue,
                                onPressed: () {
                                  showDeleteConfirmationDialog(
                                      context, question.id);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              Positioned(
                bottom: 5,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    showAddQuestionDialog(context);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.add,
                      size: 30,
                      color: Colors.white,
                    ),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return Container();
      },
    );
  }
}
