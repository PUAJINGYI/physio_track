import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis/calendar/v3.dart' as Calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:physio_track/appointment/service/google_calander_service.dart';

import '../../constant/TextConstant.dart';
import '../../leave/model/leave_model.dart';
import '../../notification/service/notification_service.dart';
import '../../profile/model/user_model.dart';
import '../../user_management/service/user_management_service.dart';
import '../model/appointment_in_pending_model.dart';
import '../model/appointment_model.dart';
import '../model/user_appointment_model.dart';

class AppointmentService {
  CollectionReference appointmentCollection =
      FirebaseFirestore.instance.collection('appointments');
  CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  CollectionReference appointmentInPendingCollection =
      FirebaseFirestore.instance.collection('appointments_in_pending');
  CollectionReference leaveCollection =
      FirebaseFirestore.instance.collection('leaves');
  GoogleCalendarService googleCalendarService = GoogleCalendarService();
  UserManagementService userManagementService = UserManagementService();
  NotificationService notificationService = NotificationService();

  Future<AuthClient?> getAuthClientUsingGoogleSignIn() async {
    var scopes = [CalendarApi.calendarScope];
    final googleSignIn = GoogleSignIn();
    final isSignedIn = await googleSignIn.isSignedIn();
    final googleSignInAccount = isSignedIn
        ? await googleSignIn.signInSilently()
        : await googleSignIn.signIn();

    if (googleSignInAccount == null) {
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

  Future<void> addAppointmentRecord(AppointmentInPending appointment) async {
    final authClient = await getAuthClientUsingGoogleSignIn();
    if (authClient != null) {
      Appointment newAppointment = Appointment(
        id: appointment.id,
        title: appointment.title,
        date: appointment.date,
        startTime: appointment.startTime,
        endTime: appointment.endTime,
        durationInSecond: appointment.durationInSecond,
        patientId: appointment.patientId,
        physioId: appointment.physioId,
        eventId: "",
      );

      List<EventAttendee> attendees = [];

      String patientEmail = await userManagementService
          .fetchUserEmailById(newAppointment.patientId);
      String physioEmail = await userManagementService
          .fetchUserEmailById(newAppointment.physioId);

      EventAttendee patientAttendee = EventAttendee()..email = patientEmail;
      EventAttendee physioAttendee = EventAttendee()..email = physioEmail;

      attendees.add(patientAttendee);
      attendees.add(physioAttendee);

      await appointmentCollection
          .add(newAppointment.toMap())
          .then((value) async {
        String eventId = await googleCalendarService.insertEvent(
            appointment.title,
            appointment.startTime,
            appointment.endTime,
            attendees,
            authClient);
        await appointmentCollection
            .where('id', isEqualTo: appointment.id)
            .get()
            .then((snapshot) async {
          snapshot.docs.first.reference.update({'eventId': eventId});
          await appointmentInPendingCollection
              .where('id', isEqualTo: appointment.id)
              .get()
              .then((snapshot) {
            snapshot.docs.first.reference
                .update({'eventId': eventId, 'status': TextConstant.NEW});
          });
        });
        print("Appointment Added");
        await addAppointmentReferenceToUserById(
            appointment.patientId, appointment.id);
        await addAppointmentReferenceToUserById(
            appointment.physioId, appointment.id);
      }).catchError((error) {
        print("Failed to add appointment: $error");
      });
    } else {
      print('null authClient');
    }
  }

  Future<void> checkAndAddAppointmentFromGCalendar() async {
    final authClient = await loadServiceAccountClient();
    if (authClient != null) {
      List<Event> eventList =
          await googleCalendarService.getEventsFromCalendar(authClient);
      List<Appointment> appointmentList =
          await fetchAllAppointmentListStartBy14DaysAgo();

      List<Appointment> newAppointmentsToAdd = [];

      for (Event event in eventList) {
        bool isEventNotInAppointments = appointmentList.every((appointment) =>
            appointment.startTime.toLocal() !=
            event.start!.dateTime!.toLocal());

        bool isConflictAppointment = false;
        if (event.attendees != null) {
          List<String> emailList =
              event.attendees!.map((attendee) => attendee.email!).toList();
          int patientId =
              await userManagementService.getUserIdByEmail(emailList[0]);
          int physioId =
              await userManagementService.getUserIdByEmail(emailList[1]);

          appointmentList.any((appointment) {
            return appointment.startTime == event.start!.dateTime!.toLocal() &&
                (appointment.patientId != patientId &&
                    appointment.physioId != physioId &&
                    appointment.eventId != event.id);
          });
        }
        if (isEventNotInAppointments || isConflictAppointment) {
          QuerySnapshot querySnapshot = await appointmentInPendingCollection
              .orderBy('id', descending: true)
              .limit(1)
              .get();
          int currentMaxId =
              querySnapshot.docs.isEmpty ? 0 : querySnapshot.docs.first['id'];
          int newId = currentMaxId + 1;

          String title = '';
          if (event.summary != null) {
            title = event.summary!;
          } else {
            title = '[Appointment]';
          }
          DateTime date = DateTime(
              event.start!.dateTime!.toLocal().year,
              event.start!.dateTime!.toLocal().month,
              event.start!.dateTime!.toLocal().day);
          DateTime startTime = event.start!.dateTime!.toLocal();
          DateTime endTime = event.end!.dateTime!.toLocal();
          int durationInSecond = endTime.difference(startTime).inSeconds;
          String eventId = event.id!;
          List<String> emailList = [];
          int patientId = -1;
          int physioId = -1;
          if (event.attendees != null) {
            emailList =
                event.attendees!.map((attendee) => attendee.email!).toList();
            patientId =
                await userManagementService.getUserIdByEmail(emailList[0]);
            physioId =
                await userManagementService.getUserIdByEmail(emailList[1]);
          }

          Appointment newAppointment = new Appointment(
              id: -1,
              title: title,
              date: date,
              startTime: startTime,
              endTime: endTime,
              durationInSecond: durationInSecond,
              patientId: patientId,
              physioId: physioId,
              eventId: eventId);
          newAppointment.id = newId;
          await appointmentCollection
              .add(newAppointment.toMap())
              .then((value) async {
            if (patientId != -1) {
              await addAppointmentReferenceToUserById(patientId, newId);
            }

            if (physioId != -1) {
              await addAppointmentReferenceToUserById(physioId, newId);
            }
            print("Appointment Added");
          }).catchError((error) {
            print("Failed to add appointment: $error");
          });

          AppointmentInPending newAppointmentInPending =
              new AppointmentInPending(
                  id: -1,
                  title: title,
                  date: date,
                  startTime: startTime,
                  endTime: endTime,
                  durationInSecond: durationInSecond,
                  status: TextConstant.NEW,
                  isApproved: true,
                  patientId: patientId,
                  physioId: physioId,
                  eventId: eventId);
          newAppointmentInPending.id = newId;
          await appointmentInPendingCollection
              .add(newAppointmentInPending.toMap())
              .then((value) {
            print("Appointment In Pending Added");
          }).catchError((error) {
            print("Failed to add appointment in pending: $error");
          });
        }
      }

      appointmentList.addAll(newAppointmentsToAdd);
    } else {
      print('null authClient');
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

    final scopes = [Calendar.CalendarApi.calendarScope];

    try {
      final authClient = await clientViaServiceAccount(credentials, scopes);
      return authClient;
    } catch (e) {
      print('Error loading service account client: $e');
      return null;
    }
  }

  Future<void> updateAppointmentRecord(AppointmentInPending appointment) async {
    final authClient = await getAuthClientUsingGoogleSignIn();
    if (authClient != null) {
      Appointment updatedAppointment = Appointment(
        id: appointment.id,
        title: appointment.title,
        date: appointment.date,
        startTime: appointment.startTime,
        endTime: appointment.endTime,
        durationInSecond: appointment.durationInSecond,
        patientId: appointment.patientId,
        physioId: appointment.physioId,
        eventId: appointment.eventId,
      );

      await appointmentCollection
          .where('id', isEqualTo: appointment.id)
          .get()
          .then((snapshot) {
        snapshot.docs.first.reference.update(updatedAppointment.toMap());
      });
      await googleCalendarService.updateEventWithNewTime(appointment.eventId,
          appointment.startTime, appointment.endTime, authClient);
    }
  }

  Future<void> removeAppointmentRecord(int id) async {
    await appointmentCollection
        .where('id', isEqualTo: id)
        .get()
        .then((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        Appointment appointment =
            Appointment.fromSnapshot(snapshot.docs.first as DocumentSnapshot);

        final authClient = await getAuthClientUsingGoogleSignIn();
        if (authClient != null) {
          googleCalendarService.deleteEvent(appointment.eventId, authClient);
          snapshot.docs.first.reference.delete();
        } else {
          print('null authClient');
        }
      }
    });
  }

  Future<List<Appointment>> fetchAllAppointmentList() async {
    List<Appointment> appointmentList = [];
    QuerySnapshot querySnapshot = await appointmentCollection.get();
    querySnapshot.docs.forEach((snapshot) {
      appointmentList.add(Appointment.fromSnapshot(snapshot));
    });
    appointmentList.sort((a, b) => a.startTime.compareTo(b.startTime));
    return appointmentList;
  }

  Future<List<Appointment>> fetchAllAppointmentListStartBy14DaysAgo() async {
    List<Appointment> appointmentList = [];
    DateTime todayDateWWithoutTime =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
            .add(Duration(days: -14));
    QuerySnapshot querySnapshot = await appointmentCollection.get();
    querySnapshot.docs.forEach((snapshot) {
      Appointment appointment = Appointment.fromSnapshot(snapshot);
      if (appointment.startTime.isAfter(todayDateWWithoutTime)) {
        appointmentList.add(appointment);
      }
    });
    appointmentList.sort((a, b) => a.startTime.compareTo(b.startTime));
    return appointmentList;
  }

  Future<List<Appointment>> fetchAppointmentListByPatientId(int id) async {
    List<Appointment> appointmentList = [];
    QuerySnapshot querySnapshot =
        await appointmentCollection.where('patientId', isEqualTo: id).get();
    querySnapshot.docs.forEach((snapshot) {
      appointmentList.add(Appointment.fromSnapshot(snapshot));
    });
    appointmentList.sort((a, b) => b.startTime.compareTo(a.startTime));
    return appointmentList;
  }

  Future<Appointment?> fetchLatestAppointmentByPatientId(int id) async {
    List<Appointment> appointmentList = [];
    QuerySnapshot querySnapshot =
        await appointmentCollection.where('patientId', isEqualTo: id).get();

    querySnapshot.docs.forEach((snapshot) {
      appointmentList.add(Appointment.fromSnapshot(snapshot));
    });

    appointmentList.sort((a, b) => b.startTime.compareTo(a.startTime));

    return appointmentList.isNotEmpty ? appointmentList.first : null;
  }

  Future<List<Appointment>> fetchAppointmentListByPhysioId(int id) async {
    List<Appointment> appointmentList = [];
    QuerySnapshot querySnapshot =
        await appointmentCollection.where('physioId', isEqualTo: id).get();
    querySnapshot.docs.forEach((snapshot) {
      appointmentList.add(Appointment.fromSnapshot(snapshot));
    });
    appointmentList.sort((a, b) => b.startTime.compareTo(a.startTime));
    return appointmentList;
  }

  Future<List<Appointment>> fetchAppointmentListByPhysioIdInToday(
      int id) async {
    List<Appointment> appointmentList = [];
    DateTime todayDateWithoutTime =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    QuerySnapshot querySnapshot =
        await appointmentCollection.where('physioId', isEqualTo: id).get();
    querySnapshot.docs.forEach((snapshot) {
      Appointment appointment = Appointment.fromSnapshot(snapshot);
      if (appointment.startTime.isAfter(todayDateWithoutTime) &&
          appointment.startTime
              .isBefore(todayDateWithoutTime.add(Duration(days: 1)))) {
        appointmentList.add(appointment);
      }
    });
    appointmentList.sort((a, b) => b.startTime.compareTo(a.startTime));
    return appointmentList;
  }

  Future<Appointment?> fetchAppointmentById(int id) async {
    Appointment? appointment;
    QuerySnapshot querySnapshot =
        await appointmentCollection.where('id', isEqualTo: id).get();
    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot doc = querySnapshot.docs.first;
      appointment = Appointment.fromSnapshot(doc);
    }
    return appointment;
  }

  Future<void> addAppointmentReferenceToUserById(
      int userId, int appointmentId) async {
    QuerySnapshot userSnapshot =
        await userCollection.where('id', isEqualTo: userId).get();

    if (userSnapshot.docs.isNotEmpty) {
      DocumentSnapshot userDoc = userSnapshot.docs.first;
      DocumentReference userRef = userDoc.reference;

      CollectionReference userAppointmentCollection =
          userRef.collection('appointments');
      UserAppointment appointment =
          UserAppointment(appointmentId: appointmentId);
      await userAppointmentCollection.add(appointment.toMap()).then((value) {
        print("Appointment Reference Added");
      }).catchError((error) {
        print("Failed to add appointment reference: $error");
      });
    }
  }

  Future<void> deleteAppointmentReferenceFromUserById(
      int userId, int appointmentId) async {
    QuerySnapshot userSnapshot =
        await userCollection.where('id', isEqualTo: userId).get();

    if (userSnapshot.docs.isNotEmpty) {
      DocumentSnapshot userDoc = userSnapshot.docs.first;
      DocumentReference userRef = userDoc.reference;

      CollectionReference userAppointmentCollection =
          userRef.collection('appointments');

      await userAppointmentCollection
          .where('appointmentId', isEqualTo: appointmentId)
          .get()
          .then((snapshot) {
        snapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      }).then((value) {
        print("Appointment Reference Deleted");
      }).catchError((error) {
        print("Failed to delete appointment reference: $error");
      });
    }
  }

  Future<List<UserModel>> fetchAvailablePhysioListAtTime(
      DateTime startTime, DateTime endTime) async {
    List<UserModel> availablePhysioList = [];
    List<UserModel> physioList = [];

    QuerySnapshot userSnapshot =
        await userCollection.where('role', isEqualTo: 'physio').get();

    if (userSnapshot.docs.isNotEmpty) {
      userSnapshot.docs.forEach((doc) {
        physioList.add(UserModel.fromSnapshot(doc));
      });
    }

    for (UserModel physio in physioList) {
      QuerySnapshot appointmentSnapshot = await appointmentCollection
          .where('physioId', isEqualTo: physio.id)
          .get();
      bool isAvailable = true;
      if (appointmentSnapshot.docs.isNotEmpty) {
        appointmentSnapshot.docs.forEach((doc) {
          Appointment appointment = Appointment.fromSnapshot(doc);
          if (appointment.startTime.isAtSameMomentAs(startTime) &&
              appointment.endTime.isAtSameMomentAs(endTime)) {
            isAvailable = false;
          }
        });
      }

      DateTime date = DateTime(startTime.year, startTime.month, startTime.day);
      isAvailable = await checkPhysioAvailabilityByDateAndTime(
          physio.id, date, startTime, endTime);
      if (isAvailable) {
        availablePhysioList.add(physio);
      }
    }
    return availablePhysioList;
  }

  Future<bool> checkPhysioAvailabilityByDateAndTime(
      int physioId, DateTime date, DateTime startTime, DateTime endTime) async {
    QuerySnapshot querySnapshot = await leaveCollection
        .where('physioId', isEqualTo: physioId)
        .where('date', isEqualTo: date)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      List<Leave> leaveList =
          querySnapshot.docs.map((doc) => Leave.fromSnapshot(doc)).toList();
      for (Leave leave in leaveList) {
        if (leave.isFullDay) {
          return false;
        } else {
          if (startTime.isAtSameMomentAs(leave.startTime) ||
              (startTime.isAfter(leave.startTime) &&
                  startTime.isBefore(leave.endTime))) {
            return false;
          }
        }
      }
    }
    return true;
  }

  Future<void> changeAppointmentStatusToConflict(int appointmentId) async {
    await appointmentInPendingCollection
        .where('id', isEqualTo: appointmentId)
        .get()
        .then((snapshot) {
      snapshot.docs.first.reference.update({'status': TextConstant.CONFLICT});
    });

    QuerySnapshot querySnapshot = await appointmentInPendingCollection
        .where('id', isEqualTo: appointmentId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      AppointmentInPending appointmentInPending =
          AppointmentInPending.fromSnapshot(querySnapshot.docs.first);

      String patientName = await userManagementService
          .getUsernameById(appointmentInPending.patientId);
      await notificationService.addAppointmentRequestNotiToAdmin(
          TextConstant.CONFLICT, patientName);
    } else {
      print('no appointment in pending');
    }
  }

  Future<void> fetchAppointmentByDateTimeAndChangeStatus(Leave leave) async {
    DateTime startTime = leave.startTime;
    DateTime endTime = leave.endTime;

    QuerySnapshot querySnapshot = await appointmentCollection.get();

    querySnapshot.docs.forEach((snapshot) {
      Appointment appointment = Appointment.fromSnapshot(snapshot);

      if (leave.isFullDay) {
        if (appointment.date.isAtSameMomentAs(leave.date)) {
          changeAppointmentStatusToConflict(appointment.id);
        }
      } else if (appointment.startTime.isAtSameMomentAs(startTime) &&
          appointment.endTime.isAtSameMomentAs(endTime)) {
        changeAppointmentStatusToConflict(appointment.id);
      } else if (appointment.startTime.isAfter(leave.startTime) &&
          appointment.startTime.isBefore(leave.endTime)) {
        changeAppointmentStatusToConflict(appointment.id);
      }
    });
  }

  //Delete all pending appointment record by patientId
  Future<void> deleteAllAppointmentRecordByPatientId(int patientId) async {
    QuerySnapshot querySnapshot = await appointmentCollection
        .where('patientId', isEqualTo: patientId)
        .get();

    List<QueryDocumentSnapshot> documents = querySnapshot.docs;

    for (QueryDocumentSnapshot document in documents) {
      await removeAppointmentRecord(document['id']);
    }
  }

  //Delete all pending appointment record by physioId
  Future<void> deleteAllAppointmentRecordByPhysioId(int physioId) async {
    QuerySnapshot querySnapshot = await appointmentCollection
        .where('physioId', isEqualTo: physioId)
        .get();

    List<QueryDocumentSnapshot> documents = querySnapshot.docs;

    for (QueryDocumentSnapshot document in documents) {
      await removeAppointmentRecord(document['id']);
    }
  }
}
