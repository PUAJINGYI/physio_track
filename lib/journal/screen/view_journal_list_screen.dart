import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:physio_track/journal/screen/add_journal_screen.dart';
import 'package:physio_track/journal/screen/view_journal_screen.dart';

import '../../constant/ImageConstant.dart';
import '../../patient/patient_home_screen.dart';
import '../model/journal_model.dart';

class ViewJournalListScreen extends StatefulWidget {
  const ViewJournalListScreen({super.key});

  @override
  State<ViewJournalListScreen> createState() => _ViewJournalListScreenState();
}

class _ViewJournalListScreenState extends State<ViewJournalListScreen> {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  final dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 25,
            left: 0,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: 35.0,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            top: 25,
            right: 0,
            child: IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                size: 35.0,
              ),
              onPressed: () {
                // Perform your desired action here
                // For example, show notifications
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
            child: Text('Express',
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold)),
          ),
          Positioned(
            top: 160,
            left: 40,
            child: Text('your feelings and thought',
                style: TextStyle(fontSize: 15.0)),
          ),
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
                      return Text('Error: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                                ImageConstant.DATA_NOT_FOUND), // Replace 'assets/no_data_image.png' with the actual image asset path
                            Text('No Journal Found',
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
                                              ImageConstant.DEFAULT_JOURNAL, // Replace with the default image path
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
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ViewJournalScreen(
                                              journalId: journal.id,
                                            ), // Replace NextPage with your desired page
                                          ),
                                        );
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
                height: 90.0,)
            ],
          ),
          Positioned(
            bottom: 20,
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
