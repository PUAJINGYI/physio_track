import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../authentication/signin_screen.dart';
import '../../screening_test/model/question_response_model.dart';
import '../../screening_test/service/question_service.dart';
import '../model/user_model.dart';

class UserService {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
      QuestionService questionService = QuestionService();
  // Create a new user record
  Future<void> addNewUserToFirestore(UserModel userModel, String userId) async {
    QuerySnapshot userSnapshot =
        await usersCollection.orderBy('id', descending: true).limit(1).get();
    int currentMaxId =
        userSnapshot.docs.isEmpty ? 0 : userSnapshot.docs.first['id'];
    int newId = currentMaxId + 1;
    await usersCollection.doc(userId).set({
      'id': newId,
      'username': userModel.username,
      'email': userModel.email,
      'role': userModel.role,
      'createTime': userModel.createTime,
      'isTakenTest': userModel.isTakenTest,
      'address': userModel.address,
      'phone': userModel.phone,
      'profileImageUrl': userModel.profileImageUrl,
      'level': userModel.level,
      'totalExp': userModel.totalExp,
      'progressToNextLevel': userModel.progressToNextLevel,
    });
  }

  // Retrieve a user record by ID
  Future<UserModel> getUser(String userId) async {
    DocumentSnapshot snapshot = await usersCollection.doc(userId).get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      return UserModel.fromSnapshot(snapshot);
    } else {
      throw Exception('User not found');
    }
  }

  // // Update a user record
  // Future<void> updateUser(UserModel user) async {
  //   await usersCollection.doc(user.id).update({
  //     'username': user.username,
  //     'email': user.email,
  //     'password': user.password,
  //   });
  // }

  // // Delete a user record
  // Future<void> deleteUser(String userId) async {
  //   await usersCollection.doc(userId).delete();
  // }

  Future<void> updateGender(DocumentReference userRef) async {
    QuerySnapshot querySnapshot = await userRef
        .collection('questionResponses')
        .where('questionType', isEqualTo: 'gender')
        .limit(1)
        .get();

    DocumentSnapshot genderSnapshot = querySnapshot.docs[0];
    String gender = genderSnapshot.get('response');

    if (gender == '1.0') {
      await userRef.update({'gender': 'male'});
    } else if (gender == '0.0') {
      await userRef.update({'gender': 'female'});
    }
  }

  Future<void> updateStatusForTopic(
      DocumentReference userRef, String topic) async {
    List<QuestionResponse> topicResponse =
        await questionService.fetchQuestionResponseByTopic(userRef, topic);
    print(topicResponse);

    double topicScore = 0.0; // Initialize as double
    topicResponse.forEach((response) {
      print("response: ${response.response}");
      topicScore += double.parse(response.response); // Parse as double
    });

    double topicStatusScore =
        topicScore / (topicResponse.length * 5); // Use double division
    if (topicStatusScore <= 0.4) {
      userRef.update({'${topic}Status': 'beginner'});
    } else if (topicStatusScore <= 0.8) {
      userRef.update({'${topic}Status': 'intermediate'});
    } else if (topicStatusScore <= 1.0) {
      userRef.update({'${topic}Status': 'advanced'});
    } else {
      userRef.update({'${topic}Status': '-'});
    }
  }

  Future<void> updateTakenTestStatus(DocumentReference userRef) async {
    await userRef.update({'isTakenTest': true});
  }
  
}
