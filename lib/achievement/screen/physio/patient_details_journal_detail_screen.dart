import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../constant/ColorConstant.dart';
import '../../../constant/ImageConstant.dart';
import '../../../constant/TextConstant.dart';
import '../../../journal/model/journal_model.dart';
import '../../../journal/service/journal_service.dart';
import '../../../reusable_widget/reusable_widget.dart';
import '../../../translations/locale_keys.g.dart';

class PatientDetailsJournalDetailScreen extends StatefulWidget {
  final int journalId;
  final String userId;
  const PatientDetailsJournalDetailScreen(
      {Key? key, required this.journalId, required this.userId})
      : super(key: key);

  @override
  State<PatientDetailsJournalDetailScreen> createState() =>
      _PatientDetailsJournalDetailScreenState();
}

class _PatientDetailsJournalDetailScreenState
    extends State<PatientDetailsJournalDetailScreen> {
  JournalService journalService = JournalService();
  Journal? journal;

  @override
  void initState() {
    super.initState();
    fetchJournal();
  }

  Future<void> fetchJournal() async {
    try {
      journal =
          await journalService.fetchJournal(widget.userId, widget.journalId);
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
          return LocaleKeys.Bad.tr();
        case '2':
          return LocaleKeys.Poor.tr();
        case '3':
          return LocaleKeys.Neutral.tr();
        case '4':
          return LocaleKeys.Good.tr();
        case '5':
          return LocaleKeys.Great.tr();
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
              Text(LocaleKeys.Delete_Journal.tr()),
              IconButton(
                icon: Icon(Icons.close, color: ColorConstant.RED_BUTTON_TEXT),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
            ],
          ),
          content: Text(
            LocaleKeys.are_you_sure_delete_journal.tr(),
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
                    child: Text(LocaleKeys.Yes.tr(),
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
                    child: Text(LocaleKeys.No.tr(),
                        style: TextStyle(color: ColorConstant.RED_BUTTON_TEXT)),
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
      journalService.deleteJournal(widget.userId, widget.journalId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.Journal_deleted.tr())),
      );
    } catch (error) {
      print('Error deleting journal: $error');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text(LocaleKeys.Journal_could_not_be_deleted.tr())),
      // );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero, // Remove content padding
            titlePadding:
                EdgeInsets.fromLTRB(16, 0, 16, 0), // Adjust title padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(LocaleKeys.Error.tr()),
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
                LocaleKeys.Journal_could_not_be_deleted.tr(),
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
                      child: Text(LocaleKeys.OK.tr(),
                          style:
                              TextStyle(color: ColorConstant.BLUE_BUTTON_TEXT)),
                      onPressed: () async {
                        Navigator.pop(context);
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
            return Center(
                child: Text('${LocaleKeys.Error.tr()}: ${snapshot.error}'));
          } else {
            String formattedDate = journal != null
                ? DateFormat('dd/MM/yyyy').format(journal!.date)
                : '';
            return Scaffold(
              body: Stack(children: [
                Column(
                  children: [
                    SizedBox(
                      height: 70.0,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 120.0),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: Stack(
                                    children: [
                                      Card(
                                        color:
                                            Color.fromRGBO(131, 183, 200, 0.8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 10, 10, 10),
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
                                                    color: Color.fromRGBO(
                                                        5, 117, 155, 1),
                                                    fontSize: 16.0,
                                                  ),
                                                ),
                                              ),
                                              Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                color: Color.fromRGBO(
                                                    241, 243, 250, 1),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          20, 10, 20, 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        LocaleKeys.Weather_Today
                                                            .tr(),
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                                                color:
                                                                    Colors.blue,
                                                                size: 40.0,
                                                              ),
                                                              Text(journal !=
                                                                      null
                                                                  ? journal!
                                                                      .weather
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
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                color: Color.fromRGBO(
                                                    241, 243, 250, 1),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          20, 10, 20, 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        LocaleKeys.Feeling_Today
                                                            .tr(),
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                                                color:
                                                                    Colors.blue,
                                                                size: 40.0,
                                                              ),
                                                              Text(journal !=
                                                                      null
                                                                  ? journal!
                                                                      .feeling
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
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                color: Color.fromRGBO(
                                                    241, 243, 250, 1),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          20, 10, 20, 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        LocaleKeys
                                                                .Health_Condition
                                                            .tr(),
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                                                    fontSize:
                                                                        20.0,
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
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                color: Color.fromRGBO(
                                                    241, 243, 250, 1),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          20, 10, 20, 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        LocaleKeys
                                                                .Comment_of_Day
                                                            .tr(),
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromRGBO(
                                                              1, 101, 134, 1),
                                                          fontSize: 18.0,
                                                        ),
                                                      ),
                                                      SizedBox(height: 10.0),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Column(
                                                            children: [
                                                              Text(
                                                                journal != null
                                                                    ? journal!
                                                                        .comment
                                                                    : '',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        20.0,
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
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      TextConstant.CUSTOM_BUTTON_SIDE_PADDING,
                                      TextConstant.CUSTOM_BUTTON_TB_PADDING,
                                      TextConstant.CUSTOM_BUTTON_SIDE_PADDING,
                                      TextConstant.CUSTOM_BUTTON_TB_PADDING),
                                  child: customButton(
                                      context,
                                      LocaleKeys.Back.tr(),
                                      ColorConstant.BLUE_BUTTON_TEXT,
                                      ColorConstant.BLUE_BUTTON_UNPRESSED,
                                      ColorConstant.BLUE_BUTTON_PRESSED,
                                      () async {
                                    await back();
                                  }),
                                ),
                                SizedBox(height: 50.0),
                              ],
                            ),
                            Positioned(
                              top: 30,
                              left: 0,
                              right: 0,
                              child: SizedBox(
                                height: 160.0,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(60, 0, 60, 0),
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
                    ),
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
                  left: 0,
                  right: 0,
                  child: Container(
                      height: kToolbarHeight,
                      alignment: Alignment.center,
                      child: Text(
                        journal != null ? journal!.title : '',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: TextConstant.TITLE_FONT_SIZE),
                      )),
                ),
              ]),
            );
          }
        },
      ),
    );
  }
}
