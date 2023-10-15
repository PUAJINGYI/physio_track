// import 'dart:io';
// import 'dart:async';
// import 'dart:developer';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:googleapis_auth/auth_io.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:googleapis_auth/googleapis_auth.dart' as auth;
// import 'package:googleapis/calendar/v3.dart' as calendar;
// import 'package:http/http.dart' as http;
// import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

// class GoogleCalendarService {
//   static const List<String> _scopes = [calendar.CalendarApi.calendarScope];
//   final String _androidClientId =
//       "415705875568-hl59d6fg4n76lek4elhla1ai6s3dpkm3.apps.googleusercontent.com";
//   final String _iosClientId = "";

//   GoogleCalendarService();

// // Future<AccessCredentials> obtainCredentials() async {
// //   final flow = await createImplicitBrowserFlow(
// //     ClientId('....apps.googleusercontent.com'),
// //     ['scope1', 'scope2'],
// //   );

// //   try {
// //     return await flow.obtainAccessCredentialsViaUserConsent();
// //   } finally {
// //     flow.close();
// //   }
// // }
//   Future<AccessCredentials> obtainCredentials2() async {
//     var client = http.Client();

//     AccessCredentials credentials =
//         await obtainAccessCredentialsViaMetadataServer(client);

//     client.close();
//     return credentials;
//   }

//   Future<AccessCredentials> obtainCredentials() async {
//     final client = http.Client();

//     try {
//       return await obtainAccessCredentialsViaUserConsent(
//         ClientId('....apps.googleusercontent.com', '...'),
//         ['scope1', 'scope2'],
//         client,
//         _prompt,
//       );
//     } finally {
//       client.close();
//     }
//   }

//   void _prompt(String url) {
//     print('Please go to the following URL and grant access:');
//     print('  => $url');
//     print('');
//   }

//   Future<auth.AutoRefreshingAuthClient> _getClient() async {
//     final auth.ClientId clientId = Platform.isAndroid
//         ? auth.ClientId(_androidClientId, "415705875568-hl59d6fg4n76lek4elhla1ai6s3dpkm3.apps.googleusercontent.com")
//         : auth.ClientId(
//             _iosClientId,
//             "",
//           );
//     //final baseClient = http.Client();
//     var httpClient = http.Client();

//     try {
//       final clientCredentials = await obtainCredentials2();

//       // await obtainAccessCredentialsViaUserConsent(
//       //   clientId,
//       //    [...],
//       //   httpClient,
//       //   prompt,
//       // );

//       final accessToken = auth.AccessToken(
//           'Bearer',
//           clientCredentials.accessToken.data,
//           clientCredentials.accessToken.expiry.toUtc());

//       final credentials = auth.AccessCredentials(
//         accessToken,
//         clientCredentials.refreshToken,
//         _scopes,
//       );

//       return auth.autoRefreshingClient(
//         clientId,
//         credentials,
//         httpClient,
//       );
//     } catch (e) {
//       throw Exception('Error obtaining client: $e');
//     }
//   }

//   void prompt(String url) async {
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }

//   Future<void> insertEvent(calendar.Event event) async {
//     try {
//       final client = await _getClient();
//       final calendarApi = calendar.CalendarApi(client);

//       //can self define email for calendarId
//       const calendarId =
//           'primary'; // You can change this to use a different calendar

//       final response = await calendarApi.events.insert(event, calendarId);
//       if (response.status == "confirmed") {
//         log('Event added to Google Calendar!!!!!!');
//       } else {
//         log('Unable to add event to Google Calendar');
//       }
//     } catch (e) {
//       log('Error creating event: $e');
//     }
//   }

//   //fetch events from google calendar
//   Future<List<calendar.Event>> getEventsFromCalendar(String calendarId) async {
//     try {
//       final client = await _getClient();
//       final calendarApi = calendar.CalendarApi(client);

//       final events = await calendarApi.events.list(calendarId);

//       return events.items ?? [];
//     } catch (e) {
//       log('Error fetching events: $e');
//       return [];
//     }
//   }
// }
// import 'package:googleapis_auth/auth_io.dart';
// import 'package:googleapis/calendar/v3.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:http/http.dart' as http;

// class GoogleCalendarService {
//   final String apiKey;
//   final String calendarId;
//   final String clientId;
//   final String clientSecret;
//   final List<String> scopes;

//   GoogleCalendarService({
//     required this.apiKey,
//     required this.calendarId,
//     required this.clientId,
//     required this.clientSecret,
//     required this.scopes,
//   });

//   Future<AuthClient> _getClient() async {
//     final client = await clientViaUserConsent(
//       ClientId(clientId, clientSecret),
//       scopes,
//       _prompt,
//     );
//     return client;
//   }

//   void _prompt(String url) async {
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }

//   Future<void> createEvent(Event event) async {
//     try {
//       final client = await  http.Client();
//       final calendar = CalendarApi(client);
//       await calendar.events.insert(event, calendarId);
//       client.close();
//     } catch (e) {
//       print('Error creating event: $e');
//     }
//   }

//   // Add more methods for interacting with the Google Calendar API here.
// }

// import 'dart:developer';

// import 'package:flutter/material.dart';
// import "package:googleapis_auth/auth_io.dart";
// import 'package:googleapis/calendar/v3.dart';
// import 'package:url_launcher/url_launcher.dart';

// class CalendarClient {
//   static const _scopes = const [CalendarApi.calendarScope];

//   insert(title, startTime, endTime) {
//     var _clientID = new ClientId("415705875568-hl59d6fg4n76lek4elhla1ai6s3dpkm3.apps.googleusercontent.com", "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");
//     clientViaUserConsent(_clientID, _scopes, prompt).then((AuthClient client) {
//       var calendar = CalendarApi(client);
//       calendar.calendarList.list().then((value) => print("VAL________$value"));

//       String calendarId = "primary";
//       Event event = Event(); // Create object of event

//       event.summary = title;

//       EventDateTime start = new EventDateTime();
//       start.dateTime = startTime;
//       start.timeZone = "GMT+05:00";
//       event.start = start;

//       EventDateTime end = new EventDateTime();
//       end.timeZone = "GMT+05:00";
//       end.dateTime = endTime;
//       event.end = end;
//       try {
//         calendar.events.insert(event, calendarId).then((value) {
//           print("ADDEDDD_________________${value.status}");
//           if (value.status == "confirmed") {
//             log('Event added in google calendar');
//           } else {
//             log("Unable to add event in google calendar");
//           }
//         });
//       } catch (e) {
//         log('Error creating event $e');
//       }
//     });
//   }

//   void prompt(String url) async {
//     print("Please go to the following URL and grant access:");
//     print("  => $url");
//     print("");

//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }
// }

import 'dart:developer';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleCalendarService {
  static const _scopes = [CalendarApi.calendarScope];

  Future<String> insertEvent(String title, DateTime startTime, DateTime endTime,
      List<EventAttendee> attendees, AuthClient _authClient) async {
    try {
      var calendar = CalendarApi(_authClient);
      calendar.calendarList.list().then((value) => print("VAL________$value"));

      String calendarId = "primary";
      Event event = Event()..summary = title;
      EventDateTime start = new EventDateTime();
      start.dateTime = startTime;
      start.timeZone = "GMT+08:00";
      event.start = start;

      EventDateTime end = new EventDateTime();
      end.timeZone = "GMT+08:00";
      end.dateTime = endTime;
      event.end = end;

      event.attendees = attendees;

      var result = await calendar.events.insert(event, calendarId);
      print('Event Id: ${result.id}');
      print("ADDEDDD_________________${result.status}");
      if (result.status == "confirmed") {
        log('Event added in Google Calendar');
        return result.id!;
      } else {
        log("Unable to add event in Google Calendar");
        return "Unable to add event in Google Calendar"; // Add this return statement
      }
    } catch (e) {
      log('Error creating event $e');
      throw e; // You can also throw an exception here if needed
    }
  }

  Future<List<Event>> getEventsFromCalendar(AuthClient _authClient) async {
    List<Event> eventsList = [];
    try {
      var calendar = CalendarApi(_authClient);
      String calendarId = "primary";

      var events = await calendar.events.list(calendarId);

      if (events.items != null) {
        eventsList.addAll(events.items!);
      }

      eventsList = eventsList.where((event) {
        // Check if the event has both startTime and endTime
        if (event.start != null && event.end != null) {
          DateTime eventStartTime = event.start!.dateTime!.toLocal();
          DateTime eventEndTime = event.end!.dateTime!.toLocal();

          // Calculate 14 days before today
          DateTime fourteenDaysAgo =
              DateTime.now().subtract(Duration(days: 14));

          // Check if startTime is greater than 14 days ago
          return eventStartTime.isAfter(fourteenDaysAgo);
        }
        return false; // Event doesn't have both startTime and endTime
      }).toList();

      return eventsList;
    } catch (e) {
      log('Error fetching events: $e');
      return [];
    }
  }

  Future<void> deleteEvent(String eventId, AuthClient _authClient) async {
    try {
      var calendar = CalendarApi(_authClient);
      String calendarId = "primary";
      await calendar.events.delete(calendarId, eventId,
          sendNotifications: true, sendUpdates: 'all');
      log('Event deleted from Google Calendar');
    } catch (e) {
      log('Error deleting event: $e');
    }
  }

  Future<void> updateEvent(
      String eventId, Event event, AuthClient _authClient) async {
    try {
      var calendar = CalendarApi(_authClient);
      String calendarId = "primary";
      var result = await calendar.events.update(event, calendarId, eventId);
      if (result.status == "confirmed") {
        log('Event updated in Google Calendar');
      } else {
        log("Unable to update event in Google Calendar");
      }
    } catch (e) {
      log('Error updating event: $e');
    }
  }

  Future<Event> fetchEventById(String eventId, AuthClient _authClient) async {
    try {
      var calendarService = GoogleCalendarService();
      var calendar = CalendarApi(_authClient);
      String calendarId = "primary";

      var event = await calendar.events.get(calendarId, eventId);
      return event;
    } catch (e) {
      log('Error fetching event by eventId: $e');
      throw e;
    }
  }

  Future<void> updateEventWithNewTime(String eventId, DateTime newStartTime,
      DateTime newEndTime, AuthClient _authClient) async {
    try {
      // Fetch the existing event by eventId
      var existingEvent = await fetchEventById(eventId, _authClient);

      // Update the startTime and endTime with the new values
      existingEvent.start!.dateTime = newStartTime.toUtc();
      existingEvent.end!.dateTime = newEndTime.toUtc();

      // Call the updateEvent method to update the event in Google Calendar
      await updateEvent(eventId, existingEvent, _authClient);
    } catch (e) {
      log('Error updating event with new time: $e');
      throw e;
    }
  }

  void prompt(String url) async {
    print("Please go to the following URL and grant access:");
    print("  => $url");
    print("");

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
