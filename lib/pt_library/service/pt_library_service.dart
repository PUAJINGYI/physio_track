import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/pt_library_model.dart';

class PTLibraryService {
  CollectionReference ptLibraryCollection =
      FirebaseFirestore.instance.collection('pt_library');

  // add PT Library record
  Future<void> addPTLibrary({
    required String title,
    required String description,
    required int duration,
    required String level,
    required String cat,
    required String videoUrl,
    required String thumbnailUrl,
    required int exp,
  }) async {
    QuerySnapshot querySnapshot = await ptLibraryCollection
        .orderBy('id', descending: true)
        .limit(1)
        .get();
    int currentMaxId =
        querySnapshot.docs.isEmpty ? 0 : querySnapshot.docs.first['id'];
    int newId = currentMaxId + 1;

    PTLibrary ptLibrary = PTLibrary(
      id: newId,
      title: title,
      description: description,
      duration: duration,
      level: level,
      cat: cat,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      exp: exp,
    );

    await ptLibraryCollection.add(ptLibrary.toMap());
  }

  // update PT Library record
  Future<void> updatePTLibrary({
    required int id,
    required String title,
    required String description,
    required int duration,
    required String level,
    required String cat,
    required String videoUrl,
    required String thumbnailUrl,
    required int exp,
  }) async {
    QuerySnapshot querySnapshot =
        await ptLibraryCollection.where('id', isEqualTo: id).get();

    if (querySnapshot.docs.isNotEmpty) {
      String documentId = querySnapshot.docs.first.id;
      PTLibrary ptLibrary = PTLibrary(
        id: id,
        title: title,
        description: description,
        duration: duration,
        level: level,
        cat: cat,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        exp: exp,
      );

      await ptLibraryCollection.doc(documentId).update(ptLibrary.toMap());
    }
  }

  // delete PT Library record
  Future<void> deletePTLibrary(int id) async {
    QuerySnapshot querySnapshot =
        await ptLibraryCollection.where('id', isEqualTo: id).get();

    if (querySnapshot.docs.isNotEmpty) {
      String documentId = querySnapshot.docs.first.id;
      await ptLibraryCollection.doc(documentId).delete();
    }
  }

  // get all PT Library records
  Future<List<PTLibrary>> fetchPTLibraryList() async {
    final querySnapshot = await ptLibraryCollection.get();
    return querySnapshot.docs.map((doc) {
      return PTLibrary.fromSnapshot(doc);
    }).toList();
  }

  // get PT Library record by id
  Future<PTLibrary?> fetchPTLibrary(int recordId) async {
    final querySnapshot =
        await ptLibraryCollection.where('id', isEqualTo: recordId).get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      return PTLibrary.fromSnapshot(doc);
    } else {
      return null;
    }
  }
}
