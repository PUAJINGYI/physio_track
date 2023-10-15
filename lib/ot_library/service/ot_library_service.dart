import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:physio_track/ot_library/model/ot_library_model.dart';

class OTLibraryService {
  CollectionReference otLibraryCollection =
      FirebaseFirestore.instance.collection('ot_library');

  // add OT Library record
  Future<void> addOTLibrary({
    required String title,
    required String description,
    required int duration,
    required String level,
    required String videoUrl,
    required String thumbnailUrl,
    required int exp,
  }) async {
    QuerySnapshot querySnapshot = await otLibraryCollection
        .orderBy('id', descending: true)
        .limit(1)
        .get();
    int currentMaxId =
        querySnapshot.docs.isEmpty ? 0 : querySnapshot.docs.first['id'];
    int newId = currentMaxId + 1;

    OTLibrary otLibrary = OTLibrary(
      id: newId,
      title: title,
      description: description,
      duration: duration,
      level: level,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      exp: exp,
    );

    await otLibraryCollection.add(otLibrary.toMap());
  }

  // update OT Library record
  Future<void> updateOTLibrary({
    required int id,
    required String title,
    required String description,
    required int duration,
    required String level,
    required String videoUrl,
    required String thumbnailUrl,
    required int exp,
  }) async {
    QuerySnapshot querySnapshot =
        await otLibraryCollection.where('id', isEqualTo: id).get();

    if (querySnapshot.docs.isNotEmpty) {
      String documentId = querySnapshot.docs.first.id;
      OTLibrary otLibrary = OTLibrary(
        id: id,
        title: title,
        description: description,
        duration: duration,
        level: level,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        exp: exp,
      );

      await otLibraryCollection.doc(documentId).update(otLibrary.toMap());
    }
  }

  // delete OT Library record
  Future<void> deleteOTLibrary(int id) async {
    QuerySnapshot querySnapshot =
        await otLibraryCollection.where('id', isEqualTo: id).get();

    if (querySnapshot.docs.isNotEmpty) {
      String documentId = querySnapshot.docs.first.id;
      await otLibraryCollection.doc(documentId).delete();
    }
  }

  // get all OT Library records
  Future<List<OTLibrary>> fetchOTLibraryList() async {
    final querySnapshot = await otLibraryCollection.get();
    return querySnapshot.docs.map((doc) {
      return OTLibrary.fromSnapshot(doc);
    }).toList();
  }

 // get OT Library record by id
  Future<OTLibrary?> fetchOTLibrary(int recordId) async {
    final querySnapshot =
        await otLibraryCollection.where('id', isEqualTo: recordId).get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      return OTLibrary.fromSnapshot(doc);
    } else {
      return null;
    }
  }
}
