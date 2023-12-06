import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserState extends ChangeNotifier {
  late AuthCredential userCredential;
  String userEmail = '';
  String userPassword = '';

  void setUserCredentials(AuthCredential credential) {
    userCredential = credential;
    notifyListeners();
  }

  void setUserEmailPassword(String email, String password) {
    userEmail = email;
    userPassword = password;
    notifyListeners();
  }
}
