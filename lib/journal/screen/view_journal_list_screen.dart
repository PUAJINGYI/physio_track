import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:physio_track/journal/screen/add_journal_screen.dart';
import 'package:physio_track/journal/screen/view_journal_screen.dart';

import '../../constant/ImageConstant.dart';
import '../../constant/TextConstant.dart';
import '../../patient/patient_home_screen.dart';
import '../../translations/locale_keys.g.dart';
import '../../user_management/service/user_management_service.dart';
import '../model/journal_model.dart';

class ViewJournalListScreen extends StatefulWidget {
  const ViewJournalListScreen({super.key});

  @override
  State<ViewJournalListScreen> createState() => _ViewJournalListScreenState();
}

class _ViewJournalListScreenState extends State<ViewJournalListScreen> {
  String userId = FirebaseAuth.instance.currentUser!.uid;
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
          await userManagementService.fetchSharedJournalStatus(userId);
      setState(() {
        isSwitched = status;
      });
    } catch (error) {
      print('Error fetching status: $error'); // Handle any errors here
    }
  }

  Future<void> _updateSharedJournalStatus(bool newValue) async {
    try {
      await userManagementService.updateSharedJournalStatus(userId, newValue);
      print(
          'Update successful'); // You can add appropriate success handling here
    } catch (error) {
      print('Error updating status: $error'); // Handle any errors here
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
                      .doc(userId)
                      .collection('journals')
                      .orderBy('id')
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
                            Image.asset(ImageConstant
                                .DATA_NOT_FOUND), // Replace 'assets/no_data_image.png' with the actual image asset path
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
                                          journal
                                              .imageUrl, // Replace with the actual image URL
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(
                                              ImageConstant
                                                  .DEFAULT_JOURNAL, // Replace with the default image path
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
                                      color: Colors
                                          .white, // Replace with desired button color
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons
                                          .arrow_forward), // Replace with desired icon
                                      color: Colors
                                          .blue, // Replace with desired icon color
                                      onPressed: () async {
                                        final needUpdate = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ViewJournalScreen(
                                              journalId: journal.id,
                                            ), // Replace NextPage with your desired page
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
                height: 90.0,
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
                LocaleKeys.Journal.tr(),
                style: TextStyle(
                  fontSize: TextConstant.TITLE_FONT_SIZE,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 25,
            right: 0,
            child: Container(
              height: kToolbarHeight,
              alignment: Alignment.center,
              child: Switch(
                value: isSwitched,
                onChanged: (newValue) {
                  setState(() {
                    isSwitched = newValue;
                    _updateSharedJournalStatus(newValue);
                  });
                },
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
            bottom: 5,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddJournalScreen(), // Replace NextPage with your desired page
                  ),
                );
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
                  color: Colors.blue, // Replace with desired button color
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
