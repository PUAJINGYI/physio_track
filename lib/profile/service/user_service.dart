import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../authentication/signin_screen.dart';
import '../model/user_model.dart';

class UserService {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
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
}
