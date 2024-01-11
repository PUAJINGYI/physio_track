import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:physio_track/screening_test/model/question_model.dart';
import 'package:physio_track/screening_test/model/question_response_model.dart';

import '../../achievement/service/achievement_service.dart';
import '../../ot_library/service/user_ot_list_service.dart';
import '../../pt_library/service/user_pt_list_service.dart';

class QuestionService {
  CollectionReference questionsCollection =
      FirebaseFirestore.instance.collection('questions');
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  CollectionReference ptLibraryCollection =
      FirebaseFirestore.instance.collection('pt_library');
  CollectionReference otLibraryCollection =
      FirebaseFirestore.instance.collection('ot_library');
  AchievementService achievementService = AchievementService();
  UserOTListService userOTListService = UserOTListService();
  UserPTListService userPTListService = UserPTListService();

  Future<List<Question>> fetchQuestions() async {
    final querySnapshot = await questionsCollection.get();
    return querySnapshot.docs.map((doc) => Question.fromSnapshot(doc)).toList();
  }

  Future<List<QuestionResponse>> fetchUserResponses(String userId) async {
    final userRef = usersCollection.doc(userId);
    final questionsRef = userRef.collection('questions');

    final querySnapshot = await questionsRef.get();
    return querySnapshot.docs
        .map((doc) => QuestionResponse.fromSnapshot(doc))
        .toList();
  }

  Future<void> storeUserResponse(
      String userId, String questionId, String response) async {
    final userRef = usersCollection.doc(userId);
    final questionsRef = userRef.collection('questions');

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
      await questionsCollection
          .doc(documentId)
          .update({'question': newQuestion});
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

    await updateStatusForTopic(userRef, 'upper');
    await updateStatusForTopic(userRef, 'lower');
    await updateStatusForTopic(userRef, 'daily');
    await updateGender(userRef);
    await updateTakenTestStatus(userRef);
    await userOTListService.suggestOTActivityList(userRef, userId);
    await userPTListService.suggestPTActivityList(userRef, userId);
    await achievementService.addAchievementCollectionToUser(userId);
  }

  Future<void> updateGender(DocumentReference userRef) async {
    QuerySnapshot querySnapshot = await userRef
        .collection('questionResponses')
        .where('questionType', isEqualTo: 'gender')
        .limit(1)
        .get();

    DocumentSnapshot genderSnapshot = querySnapshot.docs[0];
    String gender = genderSnapshot.get('response');

    if (gender == '1.0') {
      await userRef.update({'gender': 'male'});
    } else if (gender == '0.0') {
      await userRef.update({'gender': 'female'});
    }
  }

  Future<void> updateStatusForTopic(
      DocumentReference userRef, String topic) async {
    List<QuestionResponse> topicResponse =
        await fetchQuestionResponseByTopic(userRef, topic);
    print(topicResponse);

    double topicScore = 0.0; 
    topicResponse.forEach((response) {
      print("response: ${response.response}");
      topicScore += double.parse(response.response); 
    });

    double topicStatusScore =
        topicScore / (topicResponse.length * 5); 
    if (topicStatusScore <= 0.4) {
      userRef.update({'${topic}Status': 'beginner'});
    } else if (topicStatusScore <= 0.8) {
      userRef.update({'${topic}Status': 'intermediate'});
    } else if (topicStatusScore <= 1.0) {
      userRef.update({'${topic}Status': 'advanced'});
    } else {
      userRef.update({'${topic}Status': '-'});
    }
  }

  Future<void> updateTakenTestStatus(DocumentReference userRef) async {
    await userRef.update({'isTakenTest': true});
  }

  Future<List<QuestionResponse>> fetchQuestionResponseByTopic(
      DocumentReference userRef, String topic) async {
    QuerySnapshot querySnapshot = await userRef
        .collection('questionResponses')
        .where('topic', isEqualTo: topic)
        .get();

    List<QuestionResponse> fetchedQuestionResponse =
        querySnapshot.docs.map((doc) {
      int id = doc.get('id');
      String question = doc.get('question');
      String topic = doc.get('topic');
      String questionType = doc.get('questionType');
      String response = doc.get('response');
      return QuestionResponse(
        id: id,
        question: question,
        topic: topic,
        questionType: questionType,
        response: response,
      );
    }).toList();

    fetchedQuestionResponse.sort((a, b) => a.id.compareTo(b.id));

    return fetchedQuestionResponse;
  }

  Future<void> addResponse(String uId, List<QuestionResponse> responses) async {
    final CollectionReference questionResponsesCollection =
        usersCollection.doc(uId).collection('questionResponses');

    responses.forEach((response) {
      questionResponsesCollection.add(response.toMap()).then((value) {
        print('Question response added successfully.');
      }).catchError((error) {
        print('Failed to add question response: $error');
      });
    });
  }
}
