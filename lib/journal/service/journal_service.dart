import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:physio_track/journal/model/journal_model.dart';

class JournalService {
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<void> addJournal(String userId, Journal journal) async {
    final CollectionReference journalCollection =
        usersCollection.doc(userId).collection('journals');
    QuerySnapshot querySnapshot =
        await journalCollection.orderBy('id', descending: true).limit(1).get();
    int currentMaxId =
        querySnapshot.docs.isEmpty ? 0 : querySnapshot.docs.first['id'];
    int newId = currentMaxId + 1;

    Journal newJournal = journal;
    newJournal.id = newId;
    await journalCollection.add(newJournal.toMap()).then((value) {
      print("Journal Added");
    }).catchError((error) {
      print("Failed to add journal: $error");
    });
  }

  Future<Journal> fetchJournal(String userId, int journalId) async {
    try {
      QuerySnapshot journalSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('journals')
          .where('id', isEqualTo: journalId) // Query based on the id field
          .limit(1)
          .get();

      if (journalSnapshot.size > 0) {
        // Journal record found, create a Journal object
        Journal journal = Journal.fromSnapshot(journalSnapshot.docs[0]);

        print('Journal Record: $journal');
        return journal;
      } else {
        // Journal record not found
        print('Journal Record not found');
        throw Exception('Journal Record not found');
      }
    } catch (error) {
      // Handle any errors that occur during the fetch operation
      print('Error fetching journal record: $error');
      throw Exception('Error fetching journal record');
    }
  }

  Future<List<Journal>> fetchJournalList(String userId) async {
    try {
      QuerySnapshot journalQuerySnapshot =
          await usersCollection.doc(userId).collection('journals').get();

      if (journalQuerySnapshot.docs.isNotEmpty) {
        // Journal records found, create a list of Journal objects
        List<Journal> journalList = journalQuerySnapshot.docs
            .map((doc) => Journal.fromSnapshot(doc))
            .toList();

        print('Journal List: $journalList');
        return journalList;
      } else {
        // Journal records not found, return an empty list
        print('Journal List not found');
        return [];
      }
    } catch (error) {
      // Handle any errors that occur during the fetch operation
      print('Error fetching journal list: $error');
      throw Exception('Error fetching journal list');
    }
  }

  Future<void> updateJournal(
      String userId, int journalId, Journal updatedJournal) async {
    await usersCollection
        .doc(userId)
        .collection('journals')
        .where('id', isEqualTo: journalId)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.update(updatedJournal.toMap());
      });
    }).catchError((error) {
      print('Failed to update journal: $error');
    });
  }

  Future<void> deleteJournal(String userId, int journalId) async {
    try {
      final querySnapshot = await usersCollection
          .doc(userId)
          .collection('journals')
          .where('id', isEqualTo: journalId)
          .get();

      // Delete each document matching the query
      for (final document in querySnapshot.docs) {
        await document.reference.delete();
      }

      print('Journal deleted successfully');
    } catch (error) {
      // Handle any errors that occur during the delete operation
      print('Error deleting journal: $error');
      throw Exception('Error deleting journal');
    }
  }
}
