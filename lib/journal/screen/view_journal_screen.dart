import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:physio_track/journal/model/journal_model.dart';
import 'package:physio_track/journal/screen/view_journal_list_screen.dart';

import '../../constant/ColorConstant.dart';
import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../../reusable_widget/reusable_widget.dart';
import '../service/journal_service.dart';
import 'edit_journal_screen.dart';

class ViewJournalScreen extends StatefulWidget {
  final int journalId;

  const ViewJournalScreen({Key? key, required this.journalId})
      : super(key: key);

  @override
  State<ViewJournalScreen> createState() => _ViewJournalScreenState();
}

class _ViewJournalScreenState extends State<ViewJournalScreen> {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  JournalService journalService = JournalService();
  Journal? journal;

  @override
  void initState() {
    super.initState();
    fetchJournal();
  }

  Future<void> fetchJournal() async {
    try {
      journal = await journalService.fetchJournal(userId, widget.journalId);
    } catch (error) {
      print('Error fetching journal: $error');
    }
  }

  Future<void> back() async {
    Navigator.pop(context, true);
  }

  IconData _getWeatherIcon() {
    if (journal != null) {
      switch (journal!.weather) {
        case 'Sunny':
          return Icons.wb_sunny;
        case 'Cloudy':
          return Icons.cloud;
        case 'Rainy':
          return Icons.beach_access;
        case 'Rainbow':
          return Icons.waves;
        case 'Thundering':
          return Icons.flash_on;
        case 'Snowing':
          return Icons.snowing;
      }
    }

    return Icons.error;
  }

  IconData _getFeelingIcon() {
    if (journal != null) {
      switch (journal!.feeling) {
        case 'Depressed':
          return Icons.mood_bad;
        case 'Sad':
          return Icons.sentiment_dissatisfied;
        case 'Neutral':
          return Icons.sentiment_neutral;
        case 'Happy':
          return Icons.sentiment_satisfied;
        case 'Excited':
          return Icons.sentiment_very_satisfied;
      }
    }

    return Icons.error;
  }

  String _getHealthCondition() {
    if (journal != null) {
      switch (journal!.healthCondition) {
        case '1':
          return 'Bad';
        case '2':
          return 'Poor';
        case '3':
          return 'Neutral';
        case '4':
          return 'Good';
        case '5':
          return 'Great';
      }
    }

    return 'N/A';
  }

  Image _getImage() {
    if (journal != null && journal!.imageUrl.isNotEmpty) {
      return Image.network(
        journal!.imageUrl,
        fit: BoxFit.cover,
      );
    }
    return Image.asset(
      ImageConstant.DEFAULT_JOURNAL,
      fit: BoxFit.cover,
    );
  }

  void showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          titlePadding: EdgeInsets.fromLTRB(24, 0, 24, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Delete Journal'),
              IconButton(
                icon: Icon(Icons.close, color: ColorConstant.RED_BUTTON_TEXT),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
            ],
          ),
          content: Text(
            'Are you sure to delete this journal？',
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
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
                    child: Text('Yes',
                        style:
                            TextStyle(color: ColorConstant.BLUE_BUTTON_TEXT)),
                    onPressed: () {
                      performDeleteLogic();

                      Navigator.pop(context, true);
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
                    child: Text('No',
                        style:
                            TextStyle(color: ColorConstant.RED_BUTTON_TEXT)),
                    onPressed: () {
                      Navigator.pop(context, true);
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

  void performDeleteLogic() {
    try {
      journalService.deleteJournal(userId, widget.journalId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Journal deleted")),
      );
    } catch (error) {
      print('Error deleting journal: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Journal could not be deleted")),
      );
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: fetchJournal(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            String formattedDate = journal != null
                ? DateFormat('dd/MM/yyyy').format(journal!.date)
                : '';
            return Scaffold(
              body: SingleChildScrollView(
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: kToolbarHeight),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Text(
                                journal != null ? journal!.title : '',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 20.0),
                              )),
                        ),
                        SizedBox(height: 100.0),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Stack(
                            children: [
                              Card(
                                color: Color.fromRGBO(131, 183, 200, 0.8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 60.0),
                                      Center(
                                        child: Text(
                                          formattedDate,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromRGBO(5, 117, 155, 1),
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ),
                                      Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        color: Color.fromRGBO(241, 243, 250, 1),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 10, 20, 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Today\'s Weather',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromRGBO(
                                                      1, 101, 134, 1),
                                                  fontSize: 18.0,
                                                ),
                                              ),
                                              SizedBox(height: 10.0),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Icon(
                                                        _getWeatherIcon(),
                                                        color: Colors.blue,
                                                        size: 40.0,
                                                      ),
                                                      Text(journal != null
                                                          ? journal!.weather
                                                          : ''),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        color: Color.fromRGBO(241, 243, 250, 1),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 10, 20, 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Today\'s Feeling',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromRGBO(
                                                      1, 101, 134, 1),
                                                  fontSize: 18.0,
                                                ),
                                              ),
                                              SizedBox(height: 10.0),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Icon(
                                                        _getFeelingIcon(),
                                                        color: Colors.blue,
                                                        size: 40.0,
                                                      ),
                                                      Text(journal != null
                                                          ? journal!.feeling
                                                          : ''),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        color: Color.fromRGBO(241, 243, 250, 1),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 10, 20, 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Health Condition',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromRGBO(
                                                      1, 101, 134, 1),
                                                  fontSize: 18.0,
                                                ),
                                              ),
                                              SizedBox(height: 20.0),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Text(
                                                        _getHealthCondition(),
                                                        style: TextStyle(
                                                            fontSize: 20.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10.0),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        color: Color.fromRGBO(241, 243, 250, 1),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 10, 20, 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Comment of Day',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromRGBO(
                                                      1, 101, 134, 1),
                                                  fontSize: 18.0,
                                                ),
                                              ),
                                              SizedBox(height: 10.0),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Text(
                                                        journal != null
                                                            ? journal!.comment
                                                            : '',
                                                        style: TextStyle(
                                                            fontSize: 20.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10.0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: customButton(
                              context,
                              'Back',
                              ColorConstant.BLUE_BUTTON_TEXT,
                              ColorConstant.BLUE_BUTTON_UNPRESSED,
                              ColorConstant.BLUE_BUTTON_PRESSED, () async {
                            await back();
                          }),
                        )
                      ],
                    ),
                    Positioned(
                      top: 25,
                      left: 0,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          size: 35.0,
                        ),
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                      ),
                    ),
                    Positioned(
                      top: 25,
                      right: 30,
                      child: IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          size: 35.0,
                        ),
                        onPressed: () async {
                          final needUpdate = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditJournalScreen(
                                journalId: widget.journalId,
                              ),
                            ),
                          );

                          if (needUpdate != null && needUpdate) {
                            setState(() {
                               fetchJournal();
                            });
                          }
                        },
                      ),
                    ),
                    Positioned(
                      top: 25,
                      right: 0,
                      child: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: 35.0,
                        ),
                        onPressed: () {
                          showDeleteConfirmationDialog(context);
                        },
                      ),
                    ),
                    Positioned(
                      top: 25,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: kToolbarHeight,
                        alignment: Alignment.center,
                        child: Text(
                          'Journal',
                          style: TextStyle(
                            fontSize: TextConstant.TITLE_FONT_SIZE,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 110,
                      left: 0,
                      right: 0,
                      child: SizedBox(
                        height: 160.0,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Container(
                              color: Colors.grey,
                              child: _getImage(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
