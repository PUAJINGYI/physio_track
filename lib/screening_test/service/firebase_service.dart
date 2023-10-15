import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static final FirebaseService _singleton = FirebaseService._internal();

  factory FirebaseService() {
    return _singleton;
  }

  late final FirebaseApp app;

  FirebaseService._internal() {
    app = Firebase.app(); // Initialize the 'app' field using 'late'.
  }

  // Add other Firebase-related methods or properties here as needed.
}
