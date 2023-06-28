import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:physio_track/screening_test/screen/test_part_1_screen.dart';
import 'package:physio_track/screening_test/screen/test_part_2_screen.dart';
import 'package:physio_track/screening_test/model/question_model.dart';
import 'package:physio_track/screening_test/model/question_response_model.dart';
import 'package:physio_track/screening_test/service/question_service.dart';

import '../../profile/model/user_model.dart';
import '../../reusable_widget/reusable_widget.dart';

class TestPhysiotherapistRequestScreen extends StatefulWidget {
  const TestPhysiotherapistRequestScreen({Key? key}) : super(key: key);

  @override
  State<TestPhysiotherapistRequestScreen> createState() =>
      _TestPhysiotherapistRequestScreenState();
}

class _TestPhysiotherapistRequestScreenState
    extends State<TestPhysiotherapistRequestScreen> {
  List<UserModel> physioList = [];
  UserModel? selectedUser;
  QuestionService questionService = QuestionService();
  String userId = FirebaseAuth.instance.currentUser!.uid;
  bool isSelectionEmpty = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchPhysios();
  }

  Future<void> fetchPhysios() async {
    List<UserModel> fetchedPhysios =
        await questionService.fetchUsersByRole('physio');

    setState(() {
      physioList = fetchedPhysios;
    });
  }

  void addPhysioToUser(String userId, UserModel? selectedUser) {
    if (_formKey.currentState!.validate()) {
      if (selectedUser == null) {
        setState(() {
          isSelectionEmpty = true;
        });
        return;
      }

      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'physio': selectedUser.username})
          .then((_) {
        print('Field added successfully!');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TestPart1Screen(),
          ),
        );
      }).catchError((error) {
        print('Error adding field: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 50),
          Text(
            'Remarkable Physiotherapy & Rehabilitation Sdn. Bhd.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Physiotherapist Incharged',
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
                    'assets/images/physio.png',
                    width: double.infinity,
                    height: 200,
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 150),
                            
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                              child: Text(
                                'Select your physiotherapist',
                                style: TextStyle(
                                    fontSize: 18.0, fontWeight: FontWeight.bold),textAlign: TextAlign.start,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                              child: DropdownButtonFormField<UserModel>(
                                value: selectedUser,
                                hint: Text(' Pick Here '),
                                onChanged: (UserModel? newValue) {
                                  setState(() {
                                    selectedUser = newValue;
                                    isSelectionEmpty = false;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a physiotherapist';
                                  }
                                  return null;
                                },
                                items: physioList.map((UserModel user) {
                                  return DropdownMenuItem<UserModel>(
                                    value: user,
                                    child: Text(user.username),
                                  );
                                }).toList(),
                              ),
                            ),
                            if (isSelectionEmpty)
                              Text(
                                'Please select a physiotherapist',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.0,
                                ),
                              ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: customButton(
              context,
              'Next',
              Colors.white,
              Color.fromARGB(255, 43, 222, 253),
              Color.fromARGB(255, 66, 157, 173),
              () {
                addPhysioToUser(userId, selectedUser);
              },
              // isDisabled: selectedUser == null,
            ),
          )
        ],
      ),
    );
  }
}
