import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/calendar/v3.dart';

class AppointmentListScreen extends StatefulWidget {
  @override
  _AppointmentListScreenState createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  List<Event> events = [];
  bool isLoading = true;
  DateTime selectedDateTime = DateTime.now();
  List<DateTime> eventStartTimes = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final authClient = await loadServiceAccountClient();
    if (authClient != null) {
      try {
        final calendar = CalendarApi(authClient);
        final calendarId = dotenv.get('GOOGLE_CALENDAR_ID', fallback: '');
        final DateTime startDate = DateTime(2023, 9, 10);
        final DateTime endDate = DateTime(2023, 9, 17);

        final eventsResponse = await calendar.events.list(
          calendarId,
          timeMin: startDate.toUtc(),
          timeMax: endDate.toUtc(),
        );
        if (eventsResponse.items != null) {
          setState(() {
            events = eventsResponse.items!;
            isLoading = false;

            // Populate the event start times list
            eventStartTimes = events
                .map((event) =>
                    event.start?.dateTime?.toLocal() ?? DateTime.now())
                .toList();
          });
        }
      } catch (e) {
        print('Error loading events: $e');
      } finally {
        authClient.close();
      }
    } else {
      print('Failed to load service account client');
    }
  }

  Future<AuthClient?> loadServiceAccountClient() async {
    final credentials = ServiceAccountCredentials.fromJson({
      "type": dotenv.get('TYPE', fallback: ""),
      "project_id": dotenv.get('PROJECT_ID', fallback: ""),
      "private_key_id": dotenv.get('PRIVATE_KEY_ID', fallback: ""),
      "private_key": dotenv.get('PRIVATE_KEY', fallback: ""),
      "client_email": dotenv.get('CLIENT_EMAIL', fallback: ""),
      "client_id": dotenv.get('CLIENT_ID', fallback: ""),
      "auth_uri": dotenv.get('AUTH_URI', fallback: ""),
      "token_uri": dotenv.get('TOKEN_URI', fallback: ""),
      "auth_provider_x509_cert_url":
          dotenv.get('AUTH_PROVIDER_X509_CERT_URL', fallback: ""),
      "client_x509_cert_url": dotenv.get('CLIENT_X509_CERT_URL', fallback: ""),
      "universe_domain": dotenv.get('UNIVERSE_DOMAIN', fallback: ""),
    });

    final scopes = [CalendarApi.calendarScope];

    try {
      final authClient = await clientViaServiceAccount(credentials, scopes);
      return authClient;
    } catch (e) {
      print('Error loading service account client: $e');
      return null;
    }
  }

  // Function to show a date and time picker
  Future<void> _selectDateAndTime(BuildContext context) async {
    final pickedDateTime = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (pickedDateTime != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      );

      if (pickedTime != null) {
        final newDateTime = DateTime(
          pickedDateTime.year,
          pickedDateTime.month,
          pickedDateTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Check if the selected time conflicts with any event start time
        if (!eventStartTimes.any((eventStartTime) =>
            newDateTime
                .isAfter(eventStartTime.subtract(Duration(minutes: 30))) &&
            newDateTime.isBefore(eventStartTime.add(Duration(minutes: 30))))) {
          setState(() {
            selectedDateTime = newDateTime;
          });
        } else {
          // Show an error message or handle the conflict
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Conflict'),
              content: Text('The selected time conflicts with an event.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment List'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                ElevatedButton(
                  onPressed: () => _selectDateAndTime(context),
                  child: Text('Select Appointment Time'),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return ListTile(
                        title: Text(event.summary ?? 'Untitled Event'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Start: ${event.start?.dateTime?.toLocal()}'),
                            Text('End: ${event.end?.dateTime?.toLocal()}'),
                            Text('Event ID: ${event.id}'),
                            Text(
                                'Attendees: ${event.attendees?.map((a) => a.email).join(', ')}'),
                            // Add more attributes as needed
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Text(
                    'Selected Appointment Time: ${selectedDateTime.toString()}'),
              ],
            ),
    );
  }
}

// import 'package:googleapis_auth/auth_io.dart';
// import 'package:googleapis/calendar/v3.dart';

// Future<void> acceptInvitation(String serviceAccountEmail) async {
// final credentials = ServiceAccountCredentials.fromJson({
//       "type": dotenv.get('TYPE', fallback: ""),
//       "project_id": dotenv.get('PROJECT_ID', fallback: ""),
//       "private_key_id": dotenv.get('PRIVATE_KEY_ID', fallback: ""),
//       "private_key": dotenv.get('PRIVATE_KEY', fallback: ""),
//       "client_email": dotenv.get('CLIENT_EMAIL', fallback: ""),
//       "client_id": dotenv.get('CLIENT_ID', fallback: ""),
//       "auth_uri": dotenv.get('AUTH_URI', fallback: ""),
//       "token_uri": dotenv.get('TOKEN_URI', fallback: ""),
//       "auth_provider_x509_cert_url":
//           dotenv.get('AUTH_PROVIDER_X509_CERT_URL', fallback: ""),
//       "client_x509_cert_url": dotenv.get('CLIENT_X509_CERT_URL', fallback: ""),
//       "universe_domain": dotenv.get('UNIVERSE_DOMAIN', fallback: ""),
//     });
//   final scopes = [CalendarApi.calendarScope];

//   final authClient = await clientViaServiceAccount(credentials, scopes);
//   final calendar = CalendarApi(authClient);
//   final calendarId =
//       'Jingyi Pua'; // Replace with the calendar ID you want to access.

//   // Grant the service account access to the calendar.
//   final aclRule = AclRule()
//     ..scope = AclRuleScope()
//     ..scope?.type = 'user'
//     ..scope?.value = serviceAccountEmail
//     ..role =
//         'reader'; // Adjust the role as needed (e.g., 'writer' for write access).

//   await calendar.acl.insert(aclRule, calendarId);
//   authClient.close();
// }

// void main() {
//   final serviceAccountEmail =
//       'service-account@my-physiotrack-project.iam.gserviceaccount.comservice-account@my-physiotrack-project.iam.gserviceaccount.com';
//   acceptInvitation(serviceAccountEmail);
// }
