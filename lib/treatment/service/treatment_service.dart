import 'package:cloud_firestore/cloud_firestore.dart';

import '../../user_management/service/user_management_service.dart';
import '../model/treatment_model.dart';

class TreatmentService {
  CollectionReference appointmentCollection =
      FirebaseFirestore.instance.collection('appointments');
  CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  UserManagementService userManagementService = UserManagementService();

  // add treatment report
  Future<void> addTreatmentReport(
      int appointmentId, Treatment treatment) async {
    try {
      QuerySnapshot appointmentQuerySnapshot = await appointmentCollection
          .where('id', isEqualTo: appointmentId)
          .get();
      DocumentSnapshot appointmentDocumentSnapshot =
          appointmentQuerySnapshot.docs.first;
      CollectionReference treatmentCollection =
          appointmentDocumentSnapshot.reference.collection('treatments');

      // Add the treatment record data to Firestore
      await treatmentCollection.add(treatment.toMap());

      print('Treatment record added successfully');
    } catch (error) {
      print('Error adding treatment record: $error');
      throw Exception('Error adding treatment record');
    }
  }

  // fetch treatment report by appointment id
  Future<Treatment?> fetchTreatmentReportByAppointmentId(
      int appointmentId) async {
    QuerySnapshot querySnapshot =
        await appointmentCollection.where('id', isEqualTo: appointmentId).get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      CollectionReference treatmentCollection =
          documentSnapshot.reference.collection('treatments');
      QuerySnapshot treatmentQuerySnapshot = await treatmentCollection.get();

      if (treatmentQuerySnapshot.docs.isNotEmpty) {
        DocumentSnapshot treatmentDocumentSnapshot =
            treatmentQuerySnapshot.docs.first;
        Treatment treatment = Treatment.fromSnapshot(treatmentDocumentSnapshot);
        return treatment;
      }
    }
    return null;
  }

  // update treatment report
  Future<void> updateTreatmentReportByAppointmentId(
      int appointmentId, Treatment treatment) async {
    QuerySnapshot querySnapshot =
        await appointmentCollection.where('id', isEqualTo: appointmentId).get();
    DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
    CollectionReference treatmentCollection =
        documentSnapshot.reference.collection('treatments');
    QuerySnapshot treatmentQuerySnapshot = await treatmentCollection.get();
    DocumentSnapshot treatmentDocumentSnapshot =
        treatmentQuerySnapshot.docs.first;
    treatmentDocumentSnapshot.reference.update(treatment.toMap());
  }

  // delerte treatment report
  Future<void> deleteTreatmentReportByAppointmentId(int appointmentId) async {
    QuerySnapshot querySnapshot =
        await appointmentCollection.where('id', isEqualTo: appointmentId).get();
    DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
    CollectionReference treatmentCollection =
        documentSnapshot.reference.collection('treatments');
    QuerySnapshot treatmentQuerySnapshot = await treatmentCollection.get();
    DocumentSnapshot treatmentDocumentSnapshot =
        treatmentQuerySnapshot.docs.first;
    treatmentDocumentSnapshot.reference.delete();
  }
}
