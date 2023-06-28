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

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.createTime,
    required this.isTakenTest,
    required this.address,
    required this.phone,
    required this.profileImageUrl
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
      profileImageUrl: data['profileImageUrl']
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
      'profileImageUrl': profileImageUrl
    };
    return map;
  }
}

