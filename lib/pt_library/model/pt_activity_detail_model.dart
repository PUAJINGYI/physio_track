import 'package:cloud_firestore/cloud_firestore.dart';

class PTActivityDetail{
  int ptid;
  bool isDone;
  //Timestamp completeTime;

    PTActivityDetail({
    required this.ptid,
    required this.isDone,
    //required this.completeTime,
  });

  factory PTActivityDetail.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return PTActivityDetail(
      ptid: data['ptid'],
      isDone: data['isDone'], 
      //completeTime: data['completeTime'],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'ptid': ptid,
      'isDone': isDone,
      //'completeTime': completeTime,
    };

    return map;
  }
}