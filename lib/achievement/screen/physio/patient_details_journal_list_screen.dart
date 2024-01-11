import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:physio_track/achievement/screen/physio/patient_details_journal_detail_screen.dart';

import '../../../constant/ImageConstant.dart';
import '../../../constant/TextConstant.dart';
import '../../../journal/model/journal_model.dart';
import '../../../translations/locale_keys.g.dart';
import '../../../user_management/service/user_management_service.dart';

class PatientDetailsJournalListScreen extends StatefulWidget {
  final String userId;
  const PatientDetailsJournalListScreen({super.key, required this.userId});

  @override
  State<PatientDetailsJournalListScreen> createState() =>
      _PatientDetailsJournalListScreenState();
}

class _PatientDetailsJournalListScreenState
    extends State<PatientDetailsJournalListScreen> {
  final dateFormat = DateFormat('dd/MM/yyyy');
  bool isSwitched = false;
  UserManagementService userManagementService = UserManagementService();

  @override
  void initState() {
    super.initState();
    _fetchSwitchStatus();
  }

  Future<void> _fetchSwitchStatus() async {
    try {
      final status =
          await userManagementService.fetchSharedJournalStatus(widget.userId);
      setState(() {
        isSwitched = status;
      });
    } catch (error) {
      print('Error fetching status: $error');
    }
  }

  Future<void> _updateSharedJournalStatus(bool newValue) async {
    try {
      await userManagementService.updateSharedJournalStatus(
          widget.userId, newValue);
      print('Update successful');
    } catch (error) {
      print('Error updating status: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 240.0,
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.userId)
                      .collection('journals')
                      .orderBy('id', descending: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text(
                          '${LocaleKeys.Error.tr()}: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(ImageConstant.DATA_NOT_FOUND),
                            Text(LocaleKeys.No_Journal_Found.tr(),
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    }

                    return ListView(
                      padding: EdgeInsets.zero,
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Journal journal = Journal.fromSnapshot(document);
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: Card(
                            color: Color.fromRGBO(241, 243, 250, 1),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    leading: Container(
                                      width: 80.0,
                                      padding: EdgeInsets.zero,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: Image.network(
                                          journal.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(
                                              ImageConstant.DEFAULT_JOURNAL,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    title: Text(journal.title,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    subtitle:
                                        Text(dateFormat.format(journal.date)),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                  child: Container(
                                    width: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.arrow_forward),
                                      color: Colors.blue,
                                      onPressed: () async {
                                        final needUpdate = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PatientDetailsJournalDetailScreen(
                                              journalId: journal.id,
                                              userId: widget.userId,
                                            ),
                                          ),
                                        );

                                        if (needUpdate != null && needUpdate) {
                                          setState(() {});
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 55.0,
              )
            ],
          ),
          Positioned(
            top: 25,
            left: 0,
            right: 0,
            child: Container(
              height: kToolbarHeight,
              alignment: Alignment.center,
              child: Text(
                LocaleKeys.Patient_Journal.tr(),
                style: TextStyle(
                  fontSize: TextConstant.TITLE_FONT_SIZE,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 80,
            right: 5,
            child: Image.asset(
              ImageConstant.JOURNAL_IMAGE,
              width: 211.0,
              height: 169.0,
            ),
          ),
          Positioned(
            top: 125,
            left: 25,
            child: Text(LocaleKeys.Express.tr(),
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold)),
          ),
          Positioned(
            top: 160,
            left: 40,
            child: Text(LocaleKeys.your_feelings_and_thought.tr(),
                style: TextStyle(fontSize: 15.0)),
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
        ],
      ),
    );
  }
}
