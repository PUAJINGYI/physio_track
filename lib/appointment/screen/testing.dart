import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../service/google_calander_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleCalendarService calendarClient = GoogleCalendarService();

  // Method to obtain an AuthClient using Google Sign-In
  Future<AuthClient?> getAuthClientUsingGoogleSignIn() async {
    var scopes = [CalendarApi.calendarScope];
    final googleSignIn = GoogleSignIn(); // Adjust scopes as needed
    final isSignedIn = await googleSignIn.isSignedIn();
    final googleSignInAccount = isSignedIn
        ? await googleSignIn.signInSilently()
        : await googleSignIn.signIn();

    if (googleSignInAccount == null) {
      // The user is not signed in.
      return null;
    }

    final googleSignInAuthentication = await googleSignInAccount.authentication;
    final accessToken = googleSignInAuthentication.accessToken;
    final idToken = googleSignInAuthentication.idToken;

    return authenticatedClient(
      http.Client(),
      AccessCredentials(
        AccessToken('Bearer', accessToken!,
            DateTime.now().add(Duration(minutes: 60)).toUtc()),
        accessToken,
        idToken: idToken,
        scopes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Auth Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                final authClient = await getAuthClientUsingGoogleSignIn();
                if (authClient != null) {
                  print('gt authClient');
                  List<EventAttendee> attendees = [
                    EventAttendee(email: dotenv.get('ADMIN_EMAIL', fallback: ''))
                  ];
                  calendarClient.insertEvent(
                      'hello',
                      DateTime.now(),
                      DateTime.now().add(const Duration(hours: 1)),
                      attendees,
                      authClient);
                  // calendarClient.deleteEvent('iboa962k8085t2alk5so8opdbo', authClient);
                } else {
                  print('null authClient');
                }
              },
              child: Text('Authenticate with Google Sign-In'),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
