import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:physio_track/screening_test/model/question_model.dart';
import 'package:physio_track/screening_test/model/question_response_model.dart';

import '../../profile/model/user_model.dart';

class QuestionService {
  CollectionReference questionsCollection =
      FirebaseFirestore.instance.collection('questions');
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  // Fetch the questiFons from Firestore
  Future<List<Question>> fetchQuestions() async {
    final querySnapshot = await questionsCollection.get();
    return querySnapshot.docs.map((doc) => Question.fromSnapshot(doc)).toList();
  }

  // Retrieve all the user's responses from the "questions" subcollection
  Future<List<QuestionResponse>> fetchUserResponses(String userId) async {
    final userRef = usersCollection.doc(userId);
    final questionsRef = userRef.collection('questions');

    final querySnapshot = await questionsRef.get();
    return querySnapshot.docs
        .map((doc) => QuestionResponse.fromSnapshot(doc))
        .toList();
  }

  // Store the user's response in the "questions" subcollection within the user's document
  Future<void> storeUserResponse(
      String userId, String questionId, String response) async {
    final userRef = usersCollection.doc(userId);
    final questionsRef = userRef.collection('questions');

    // Create or update the document for the question
    await questionsRef.doc(questionId).set({'response': response});
  }

  Future<void> addQuestion({
    required String questionText,
    required String topic,
    required String questionType,
  }) async {
    QuerySnapshot querySnapshot = await questionsCollection
        .orderBy('id', descending: true)
        .limit(1)
        .get();
    int currentMaxId =
        querySnapshot.docs.isEmpty ? 0 : querySnapshot.docs.first['id'];
    int newId = currentMaxId + 1;

    Question newQuestion = Question(
      id: newId,
      question: questionText,
      topic: topic,
      questionType: questionType,
    );

    await questionsCollection.add(newQuestion.toMap());
  }

  Future<void> deleteQuestion(int id) async {
    QuerySnapshot querySnapshot =
        await questionsCollection.where('id', isEqualTo: id).get();

    if (querySnapshot.docs.isNotEmpty) {
      String documentId = querySnapshot.docs.first.id;
      await questionsCollection.doc(documentId).delete();
    }
  }

  Future<void> editQuestion(int id, String newQuestion) async {
  QuerySnapshot querySnapshot =
      await questionsCollection.where('id', isEqualTo: id).get();

  if (querySnapshot.docs.isNotEmpty) {
    String documentId = querySnapshot.docs.first.id;
    await questionsCollection.doc(documentId).update({'question': newQuestion});
  }
}

  Future<List<Question>> fetchQuestionsByTopic(String topic) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('questions')
        .where('topic', isEqualTo: topic)
        .get();

    List<Question> fetchedQuestions = querySnapshot.docs.map((doc) {
      int id = doc.get('id');
      String question = doc.get('question');
      String topic = doc.get('topic');
      String questionType = doc.get('questionType');
      return Question(
        id: id,
        question: question,
        topic: topic,
        questionType: questionType,
      );
    }).toList();

    fetchedQuestions.sort((a, b) => a.id.compareTo(b.id));

    return fetchedQuestions;
  }

  Future<void> updateTestStatus(String userId) async {
    DocumentReference userRef = usersCollection.doc(userId);
    await userRef.update({'isTakenTest': true});

    // Add on the result after analysis
  }

  Future<void> addResponse(String uId, List<QuestionResponse> responses) async {
    // Create a new collection reference under the user document
    final CollectionReference questionResponsesCollection =
        usersCollection.doc(uId).collection('questionResponses');

    // Add each QuestionResponse object to the collection
    responses.forEach((response) {
      questionResponsesCollection.add(response.toMap()).then((value) {
        print('Question response added successfully.');
      }).catchError((error) {
        print('Failed to add question response: $error');
      });
    });
  }

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
}
