import 'package:cloud_firestore/cloud_firestore.dart';

class Treatment {
  int id;
  DateTime dateTime;
  int physioId;
  int patientId;
  int standingSet;
  int standingRep;
  int armLiftingSet;
  int armLiftingRep;
  int legLiftingSet;
  int legLiftingRep;
  int footStepSet;
  int footStepRep;
  int performamce;
  String remark;

  Treatment({
    required this.id,
    required this.dateTime,
    required this.physioId,
    required this.patientId,
    required this.standingSet,
    required this.standingRep,
    required this.armLiftingSet,
    required this.armLiftingRep,
    required this.legLiftingSet,
    required this.legLiftingRep,
    required this.footStepSet,
    required this.footStepRep,
    required this.performamce,
    required this.remark,
  });

  factory Treatment.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Treatment(
      id: data['id'],
      dateTime: data['dateTime'].toDate(),
      physioId: data['physioId'],
      patientId: data['patientId'],
      standingSet: data['standingSet'],
      standingRep: data['standingRep'],
      armLiftingSet: data['armLiftingSet'],
      armLiftingRep: data['armLiftingRep'],
      legLiftingSet: data['legLiftingSet'],
      legLiftingRep: data['legLiftingRep'],
      footStepSet: data['footStepSet'],
      footStepRep: data['footStepRep'],
      performamce: data['performamce'],
      remark: data['remark'],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'id': id,
      'dateTime': dateTime,
      'physioId': physioId,
      'patientId': patientId,
      'standingSet': standingSet,
      'standingRep': standingRep,
      'armLiftingSet': armLiftingSet,
      'armLiftingRep': armLiftingRep,
      'legLiftingSet': legLiftingSet,
      'legLiftingRep': legLiftingRep,
      'footStepSet': footStepSet,
      'footStepRep': footStepRep,
      'performamce': performamce,
      'remark': remark,
    };
    return map;
  }
}
