import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel{
  int id;
  String username;
  String email;
  String role;
  Timestamp createTime;
  bool isTakenTest;
  String address;
  String phone;
  String profileImageUrl;
  int level;
  int totalExp;
  double progressToNextLevel;
  bool sharedJournal;
  String gender;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.createTime,
    required this.isTakenTest,
    required this.address,
    required this.phone,
    required this.profileImageUrl,
    required this.level,
    required this.totalExp,
    required this.progressToNextLevel,
    required this.sharedJournal,
    required this.gender,
  });

  factory UserModel.fromSnapshot(DocumentSnapshot snapshot){
    final data = snapshot.data() as Map<String, dynamic>;
    return UserModel(
      id: data['id'],
      username: data['username'],
      email: data['email'],
      role: data['role'],
      createTime: data['createTime'],
      isTakenTest: data['isTakenTest'],
      address: data['address'],
      phone: data['phone'],
      profileImageUrl: data['profileImageUrl'],
      level: data['level'],
      totalExp: data['totalExp'],
      progressToNextLevel: (data['progressToNextLevel'] ?? 0).toDouble(),
      sharedJournal: data['sharedJournal'],
      gender: data['gender'],
    );
  }

  Map<String, dynamic> toMap(){
  Map<String, dynamic> map = {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'createTime': createTime,
      'isTakenTest': isTakenTest,
      'address': address,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'level': level,
      'totalExp': totalExp,
      'progressToNextLevel': progressToNextLevel,
      'sharedJournal': sharedJournal,
      'gender': gender,
    };
    return map;
  }
}

