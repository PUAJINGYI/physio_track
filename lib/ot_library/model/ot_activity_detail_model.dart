import 'package:cloud_firestore/cloud_firestore.dart';

class OTActivityDetail{
  int otid;
  bool isDone;
  //Timestamp completeTime;

    OTActivityDetail({
    required this.otid,
    required this.isDone,
    //required this.completeTime,
  });

  factory OTActivityDetail.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return OTActivityDetail(
      otid: data['otid'],
      isDone: data['isDone'], 
      //completeTime: data['completeTime'],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'otid': otid,
      'isDone': isDone,
      //'completeTime': completeTime,
    };

    return map;
  }
}