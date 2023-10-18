import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:physio_track/journal/model/journal_model.dart';
import 'package:physio_track/journal/screen/view_journal_list_screen.dart';

import '../../constant/ColorConstant.dart';
import '../../constant/ImageConstant.dart';
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

  void fetchJournal() async {
    try {
      journal = await journalService.fetchJournal(userId, widget.journalId);
      setState(
          () {}); // Refresh the state to update the UI with the fetched journal
    } catch (error) {
      print('Error fetching journal: $error');
      // Handle the error as per your requirement
    }
  }

  void back() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewJournalListScreen(),
      ),
    );
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
          contentPadding: EdgeInsets.zero, // Remove content padding
          titlePadding:
              EdgeInsets.fromLTRB(24, 0, 24, 0), // Adjust title padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Delete Journal'),
              IconButton(
                icon: Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
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
              // Wrap actions in Center widget
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: Color.fromRGBO(220, 241, 254, 1),
                    ),
                    child: Text('Yes',
                        style:
                            TextStyle(color: Color.fromRGBO(18, 190, 246, 1))),
                    onPressed: () {
                      performDeleteLogic(); // Perform the delete logic
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => ViewJournalListScreen(),
                      //   ),
                      // ); // Close the dialog
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: Color.fromARGB(255, 237, 159, 153),
                    ),
                    child: Text('No',
                        style:
                            TextStyle(color: Color.fromARGB(255, 217, 24, 10))),
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

  void performDeleteLogic() {
    try {
      journalService.deleteJournal(userId, widget.journalId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Journal deleted")),
      );
      Navigator.of(context).pop();
    } catch (error) {
      print('Error deleting journal: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Journal could not be deleted")),
      );
    }
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewJournalListScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        journal != null ? DateFormat('dd/MM/yyyy').format(journal!.date) : '';
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: kToolbarHeight),
                // SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Text(
                        journal != null ? journal!.title : '',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(12, 57, 125, 1),
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
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 60.0),
                              Center(
                                child: Text(
                                  formattedDate, // Add the formatted date here
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(5, 117, 155, 1),
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                color: Color.fromRGBO(241, 243, 250, 1),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Today\'s Weather',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromRGBO(1, 101, 134, 1),
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      SizedBox(height: 10.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
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
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                color: Color.fromRGBO(241, 243, 250, 1),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Today\'s Feeling',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromRGBO(1, 101, 134, 1),
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      SizedBox(height: 10.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
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
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                color: Color.fromRGBO(241, 243, 250, 1),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Health Condition',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromRGBO(1, 101, 134, 1),
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      SizedBox(height: 20.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                _getHealthCondition(),
                                                style: TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                color: Color.fromRGBO(241, 243, 250, 1),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Comment of Day',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromRGBO(1, 101, 134, 1),
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
                                                        FontWeight.bold),
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
                      ColorConstant.BLUE_BUTTON_PRESSED, () {
                    back();
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
                  // Perform your desired action here
                  // For example, navigate to the previous screen
                  Navigator.pop(context);
                },
              ),
            ),
            Positioned(
              top: 25,
              right: 60,
              child: IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  size: 35.0,
                ),
                onPressed: () {
                  // Perform your desired action here
                  // For example, navigate to the edit journal screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditJournalScreen(
                        journalId: widget.journalId,
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 25,
              right: 30,
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
                    fontSize: 20.0,
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
                      color: Colors
                          .grey, // Replace with your desired container color
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
}
