import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:physio_track/screening_test/service/question_service.dart';

import '../../../constant/ColorConstant.dart';
import '../../../notification/service/notification_service.dart';
import '../../../notification/widget/shimmering_text_list_widget.dart';
import '../../../translations/locale_keys.g.dart';
import '../../model/question_model.dart';

class LowerQuestionListScreen extends StatefulWidget {
  const LowerQuestionListScreen({Key? key}) : super(key: key);

  @override
  State<LowerQuestionListScreen> createState() =>
      _LowerQuestionListScreenState();
}

class _LowerQuestionListScreenState extends State<LowerQuestionListScreen> {
  QuestionService questionService = QuestionService();
  NotificationService notificationService = NotificationService();
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
              Text(LocaleKeys.Delete_Question.tr()),
              IconButton(
                icon: Icon(Icons.close, color: ColorConstant.RED_BUTTON_TEXT),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              LocaleKeys.are_you_sure_delete_question.tr(),
              textAlign: TextAlign.center,
            ),
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
                      LocaleKeys.Yes.tr(),
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
                      LocaleKeys.No.tr(),
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
        SnackBar(content: Text(LocaleKeys.Question_Deleted.tr())),
      );
    } catch (error) {
      print('Error deleting question: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.Question_could_not_be_deleted.tr())),
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
        SnackBar(content: Text(LocaleKeys.New_Question_Added.tr())),
      );

      setState(() {
        _lowerQuestionListFuture = _fetchQuestionList();
      });
    } catch (error) {
      print('Error adding question: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.Question_could_not_be_added.tr())),
      );
    }
  }

  Future<void> performEditLogic(int id, String newQuestionText) async {
    try {
      await questionService.editQuestion(id, newQuestionText);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.Question_updated.tr())),
      );
      setState(() {
        _lowerQuestionListFuture = _fetchQuestionList();
      });
    } catch (error) {
      print('Error editing question: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.Question_could_not_be_updated.tr())),
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
                      LocaleKeys.Add_Question.tr(),
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
                        labelText: LocaleKeys.Question.tr(),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      LocaleKeys.Question_Type.tr(),
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
                        Text(LocaleKeys.Option.tr()),
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
                        Text(LocaleKeys.Scale.tr()),
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
                        Text(LocaleKeys.Date.tr()),
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
                        Text(LocaleKeys.Short_Answer.tr()),
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
                            SnackBar(
                                content: Text(
                                    LocaleKeys.Question_cannot_be_empty.tr())),
                          );
                        }
                      },
                      child: Text(LocaleKeys.Add_Question.tr()),
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
                      LocaleKeys.Edit_Question.tr(),
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
                        labelText: LocaleKeys.Question.tr(),
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
                            SnackBar(
                                content: Text(
                                    LocaleKeys.Question_cannot_be_empty.tr())),
                          );
                        }
                      },
                      child: Text(LocaleKeys.Save.tr()),
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

  String getQuestionType(String qType) {
    if (qType == 'option') {
      return LocaleKeys.Option.tr();
    } else if (qType == 'scale') {
      return LocaleKeys.Scale.tr();
    } else if (qType == 'date') {
      return LocaleKeys.Date.tr();
    } else if (qType == 'short') {
      return LocaleKeys.Short_Answer.tr();
    } else if (qType == 'gender') {
      return LocaleKeys.Gender.tr();
    } else {
      return '';
    }
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
          return Center(
              child: Text('${LocaleKeys.Error.tr()}: ${snapshot.error}'));
        }
        if (snapshot.hasData) {
          List<Question> questions = snapshot.data!;
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: questions.map((Question question) {
                    return Card(
                      color: Color.fromRGBO(241, 243, 250, 1),
                      child: Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: FutureBuilder(
                                future: notificationService.translateText(
                                    question.question, context),
                                builder: (BuildContext context,
                                    AsyncSnapshot<String> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        ShimmeringTextListWidget(
                                            width: 400, numOfLines: 1),
                                      ],
                                    ); // or any loading indicator
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    String title = snapshot.data!;
                                    return Text(
                                      title,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    );
                                  }
                                },
                              ),
                              subtitle:
                                  Text(getQuestionType(question.questionType)),
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
