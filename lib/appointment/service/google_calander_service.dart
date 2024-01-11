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
        return "Unable to add event in Google Calendar"; 
      }
    } catch (e) {
      log('Error creating event $e');
      throw e;
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
        if (event.start != null && event.end != null) {
          DateTime eventStartTime = event.start!.dateTime!.toLocal();
          DateTime eventEndTime = event.end!.dateTime!.toLocal();

          DateTime fourteenDaysAgo =
              DateTime.now().subtract(Duration(days: 14));

          return eventStartTime.isAfter(fourteenDaysAgo);
        }
        return false; 
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
      var existingEvent = await fetchEventById(eventId, _authClient);

      existingEvent.start!.dateTime = newStartTime.toUtc();
      existingEvent.end!.dateTime = newEndTime.toUtc();

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
