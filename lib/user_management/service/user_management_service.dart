import 'package:cloud_firestore/cloud_firestore.dart';

import '../../profile/model/user_model.dart';

class UserManagementService {
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<List<UserModel>> fetchUsersByRole(String role) async {
    try {
      QuerySnapshot querySnapshot =
          await usersCollection.where('role', isEqualTo: role).get();
      if (querySnapshot.docs.isNotEmpty) {
        List<UserModel> userList = querySnapshot.docs
            .map((doc) => UserModel.fromSnapshot(doc))
            .toList();
        return userList;
      } else {
        print('User list not found');
        return [];
      }
    } catch (error) {
      print('Error fetching user list: $error');
      throw Exception('Error fetching user list');
    }
  }

  Future<UserModel> fecthUserById(int id) async {
    try {
      QuerySnapshot querySnapshot =
          await usersCollection.where('id', isEqualTo: id).limit(1).get();

      if (querySnapshot.size > 0) {
        UserModel user = UserModel.fromSnapshot(querySnapshot.docs[0]);
        print('User Record: $user');
        return user;
      } else {
        print('User Record not found');
        throw Exception('User Record not found');
      }
    } catch (error) {
      print('Error fetching user: $error');
      throw Exception('Error fetching user');
    }
  }

  Future<String> fetchUserEmailById(int id) async {
    try {
      QuerySnapshot querySnapshot =
          await usersCollection.where('id', isEqualTo: id).limit(1).get();

      if (querySnapshot.size > 0) {
        UserModel user = UserModel.fromSnapshot(querySnapshot.docs[0]);
        print('User Record: $user');
        return user.email;
      } else {
        print('User Record not found');
        throw Exception('User Record not found');
      }
    } catch (error) {
      print('Error fetching user: $error');
      throw Exception('Error fetching user');
    }
  }

  Future<String> fetchPhysioEmailByPatientId(int id) async {
    try {
      DocumentSnapshot userSnapshot = await usersCollection
          .where('id', isEqualTo: id)
          .limit(1)
          .get()
          .then((value) => value.docs.first);

      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>;

      String physioName = userData['physio'];

      QuerySnapshot querySnapshot = await usersCollection
          .where('username', isEqualTo: physioName)
          .limit(1)
          .get();

      if (querySnapshot.size > 0) {
        UserModel user = UserModel.fromSnapshot(querySnapshot.docs[0]);
        print('User Record: $user');
        return user.email;
      } else {
        print('User Record not found');
        throw Exception('User Record not found');
      }
    } catch (error) {
      print('Error fetching user: $error');
      throw Exception('Error fetching user');
    }
  }

  Future<void> deleteUser(int id) async {
    final usersCollection = FirebaseFirestore.instance.collection('users');
    final journalsCollection =
        FirebaseFirestore.instance.collection('journals');
    final questionResponseCollection =
        FirebaseFirestore.instance.collection('questionResponses');

    await usersCollection
        .where('id', isEqualTo: id)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) async {
        await doc.reference.delete();

        final userJournalsQuery =
            await journalsCollection.where('userId', isEqualTo: doc.id).get();
        for (final journalDoc in userJournalsQuery.docs) {
          await journalDoc.reference.delete();
        }

        final userQuizResponsesQuery = await questionResponseCollection
            .where('userId', isEqualTo: doc.id)
            .get();
        for (final quizResponseDoc in userQuizResponsesQuery.docs) {
          await quizResponseDoc.reference.delete();
        }
      });
    });
  }

  Future<int> fetchUserIdByUid(String uid) async {
    try {
      DocumentSnapshot querySnapshot = await usersCollection.doc(uid).get();

      if (querySnapshot.exists) {
        UserModel user = UserModel.fromSnapshot(querySnapshot);
        print('User Record: $user');
        return user.id;
      } else {
        print('User Record not found');
        throw Exception('User Record not found');
      }
    } catch (error) {
      print('Error fetching user: $error');
      throw Exception('Error fetching user');
    }
  }

  Future<String> getUsernameById(int id) async {
    String name = '';
    QuerySnapshot querySnapshot =
        await usersCollection.where('id', isEqualTo: id).get();
    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot doc = querySnapshot.docs.first;
      name = doc['username'];
    }
    return name;
  }

  Future<String> getUsernameByUid(String uid, bool shorten) async {
    String name = '';
    DocumentSnapshot documentSnapshot = await usersCollection.doc(uid).get();
    if (documentSnapshot.exists) {
      name = documentSnapshot['username'];

      if (shorten) {
        name = shortenUsername(name);
      }
    }
    return name;
  }

  String shortenUsername(String fullName) {
    List<String> parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts.first}';
    } else {
      return fullName;
    }
  }

  Future<int> getUserIdByEmail(String email) async {
    int id = -1;
    QuerySnapshot querySnapshot =
        await usersCollection.where('email', isEqualTo: email).get();
    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot doc = querySnapshot.docs.first;
      id = doc['id'];
    }
    return id;
  }

  Future<String> getUidByEmail(String email) async {
    String uid = '';
    QuerySnapshot querySnapshot =
        await usersCollection.where('email', isEqualTo: email).get();
    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot doc = querySnapshot.docs.first;
      uid = doc.id;
    }
    return uid;
  }

  Future<String> getEmailById(int id) async {
    String email = '';
    QuerySnapshot querySnapshot =
        await usersCollection.where('id', isEqualTo: id).get();
    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot doc = querySnapshot.docs.first;
      email = doc['email'];
    }
    return email;
  }

  Future<List<UserModel>> fetchPatientByPhysioId(int id) async {
    List<UserModel> patientList = [];
    String username = await getUsernameById(id);
    QuerySnapshot querySnapshot =
        await usersCollection.where('physio', isEqualTo: username).get();
    if (querySnapshot.docs.isNotEmpty) {
      patientList =
          querySnapshot.docs.map((doc) => UserModel.fromSnapshot(doc)).toList();
      patientList.sort((a, b) => a.id.compareTo(b.id));
    }
    return patientList;
  }

  Future<String> fetchUidByUserId(int id) {
    return usersCollection
        .where('id', isEqualTo: id)
        .get()
        .then((value) => value.docs.first.id);
  }

  Future<String> fetchPhoneNumberByUserId(int id) async {
    String phoneNumber = '';
    QuerySnapshot querySnapshot =
        await usersCollection.where('id', isEqualTo: id).get();
    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot doc = querySnapshot.docs.first;
      phoneNumber = doc['phone'];
    }
    return phoneNumber;
  }

  Future<void> updateSharedJournalStatus(String uid, bool sharedJournal) async {
    try {
      await usersCollection.doc(uid).update({'sharedJournal': sharedJournal});
    } catch (error) {
      print('Error updating shared journal status: $error');
      throw Exception('Error updating shared journal status');
    }
  }

  Future<bool> fetchSharedJournalStatus(String uid) {
    try {
      return usersCollection
          .doc(uid)
          .get()
          .then((value) => value['sharedJournal']);
    } catch (error) {
      print('Error fetching shared journal status: $error');
      throw Exception('Error fetching shared journal status');
    }
  }

  Future<int> fetchPhysioIdByPatientUid(String patientUid) async {
    int patientId = await fetchUserIdByUid(patientUid);
    String physioEmail = await fetchPhysioEmailByPatientId(patientId);
    String physioUid = await getUidByEmail(physioEmail);
    int physioId = await fetchUserIdByUid(physioUid);
    return physioId;
  }

  Future<String> getRoleByUid(String uid) async {
    String role = '';
    DocumentSnapshot documentSnapshot = await usersCollection.doc(uid).get();
    if (documentSnapshot.exists) {
      role = documentSnapshot['role'];
    }
    return role;
  }
}
