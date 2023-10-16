import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:physio_track/appointment/model/appointment_in_pending_model.dart';
import 'package:physio_track/appointment/model/appointment_model.dart';
import 'package:physio_track/appointment/model/user_appointment_model.dart';
import 'package:physio_track/appointment/service/appointment_service.dart';
import 'package:sendgrid_mailer/sendgrid_mailer.dart';

import '../../notification/service/notification_service.dart';
import '../../user_management/service/user_management_service.dart';

class AppointmentInPendingService {
  CollectionReference appointmentInPendingCollection =
      FirebaseFirestore.instance.collection('appointments_in_pending');
  CollectionReference appointmentCollection =
      FirebaseFirestore.instance.collection('appointments');
  CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  AppointmentService appointmentService = AppointmentService();
  UserManagementService userManagementService = UserManagementService();
  NotificationService notificationService = NotificationService();

  // add new pending appointment record
  Future<void> addPendingAppointmentRecord(
      AppointmentInPending appointment) async {
    QuerySnapshot querySnapshot = await appointmentInPendingCollection
        .orderBy('id', descending: true)
        .limit(1)
        .get();
    int currentMaxId =
        querySnapshot.docs.isEmpty ? 0 : querySnapshot.docs.first['id'];
    int newId = currentMaxId + 1;

    AppointmentInPending newAppointment = appointment;
    newAppointment.id = newId;
    await appointmentInPendingCollection
        .add(newAppointment.toMap())
        .then((value) async {
      print("Pending Appointment Added");
    }).catchError((error) {
      print("Failed to add pending appointment: $error");
    });
  }

  Future<void> addPendingAppointmentRecordByDetails(
      String title,
      DateTime date,
      DateTime startTime,
      DateTime endTime,
      int durationInSecond,
      int patientId,
      int physioId) async {
    QuerySnapshot querySnapshot = await appointmentInPendingCollection
        .orderBy('id', descending: true)
        .limit(1)
        .get();
    int currentMaxId =
        querySnapshot.docs.isEmpty ? 0 : querySnapshot.docs.first['id'];
    int newId = currentMaxId + 1;

    AppointmentInPending newAppointment = AppointmentInPending(
        id: newId,
        title: title,
        date: date,
        startTime: startTime,
        endTime: endTime,
        durationInSecond: durationInSecond,
        patientId: patientId,
        physioId: physioId,
        eventId: '0',
        status: 'New',
        isApproved: false);

    await appointmentInPendingCollection
        .add(newAppointment.toMap())
        .then((value) async {
      print("Pending Appointment Added");
    }).catchError((error) {
      print("Failed to add pending appointment: $error");
    });
  }

  Future<void> removeNewPendingAppointment(int appointmentId) async {
    AppointmentInPending? appointment =
        await fetchPendingAppointmentById(appointmentId);
    await appointmentInPendingCollection
        .where('id', isEqualTo: appointmentId)
        .get()
        .then((snapshot) {
      snapshot.docs.first.reference.delete();
    });
  }

  // updated pending appointment record
  Future<void> updatePendingAppointmentRecord(
      AppointmentInPending appointment) async {
    await appointmentInPendingCollection
        .where('id', isEqualTo: appointment.id)
        .get()
        .then((snapshot) {
      snapshot.docs.first.reference.update(appointment.toMap());
    });
  }

  Future<void> updatePendingAppointmentRecordByDetails(
      int appointmentId,
      DateTime date,
      DateTime startTime,
      DateTime endTime,
      int durationInSecond) async {
    QuerySnapshot querySnapshot = await appointmentInPendingCollection
        .where('id', isEqualTo: appointmentId)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot doc = querySnapshot.docs.first;
      DocumentReference docRef = doc.reference;
      await docRef.update({
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
        'durationInSecond': durationInSecond,
        'status': 'Updated',
        'isApproved': false,
      });
    }
  }

  // cancel pending appointment record
  Future<void> cancelPendingAppointmentRecord(int appointmentId) async {
    await appointmentInPendingCollection
        .where('id', isEqualTo: appointmentId)
        .get()
        .then((snapshot) {
      snapshot.docs.first.reference
          .update({'status': 'Cancelled', 'isApproved': false});
    });
  }

  // approve pending appointment record (add, update, cancel) 3 methods
  Future<bool> approveNewAppointmentRecord(int appointmentId) async {
    bool isApproved = false;
    await appointmentInPendingCollection
        .where('id', isEqualTo: appointmentId)
        .get()
        .then((snapshot) {
      snapshot.docs.first.reference
          .update({'status': 'New', 'isApproved': true});
    });
    AppointmentInPending? appointment =
        await fetchPendingAppointmentById(appointmentId);
    if (appointment != null) {
      appointmentService.addAppointmentRecord(appointment);
      sendEmailToNotifyApprove(appointment, 'New');
      String patientUid =
          await userManagementService.fetchUidByUserId(appointment.patientId);
      String physioUid =
          await userManagementService.fetchUidByUserId(appointment.physioId);

      notificationService.addNotificationFromAdmin(
          patientUid,
          'Appointment Booking Approved',
          'Dear patient, your recent appointment booking request for ${DateFormat('hh:mm a').format(appointment.startTime)}, ${DateFormat('dd MMM yyyy').format(appointment.startTime)} has been approved. Please remember to attend the appointment on that selected time slot. Thank you.');
      notificationService.addNotificationFromAdmin(
          physioUid,
          'Appointment Booking Approved',
          'Dear physio, there is a new appointment on ${DateFormat('hh:mm a').format(appointment.startTime)}, ${DateFormat('dd MMM yyyy').format(appointment.startTime)}');

      isApproved = true;
    }
    return isApproved;
  }

  Future<bool> checkIfNewAppointmentSlotExist(int appointmentId) async {
    bool isApproved = false;
    AppointmentInPending? appointment =
        await fetchPendingAppointmentById(appointmentId);

    if (appointment != null) {
      List<Appointment> getAppointmentList = await appointmentService
          .fetchAppointmentListByPhysioId(appointment.physioId);
      bool isConflict = false;
      for (Appointment existingAppointment in getAppointmentList) {
        if (existingAppointment.startTime
                .isAtSameMomentAs(appointment.startTime) &&
            existingAppointment.endTime.isAtSameMomentAs(appointment.endTime)) {
          isConflict = true;
          await rejectNewPendingAppointmentRecord(appointmentId);
          break;
        }
      }
      if (!isConflict) {
        await approveNewAppointmentRecord(appointmentId);
        isApproved = true;
      }
    }
    return isApproved;
  }

  Future<bool> checkIfUpdateAppointmentSlotExist(int appointmentId) async {
    bool isApproved = false;
    AppointmentInPending? appointment =
        await fetchPendingAppointmentById(appointmentId);

    Appointment? existingAppointment =
        await appointmentService.fetchAppointmentById(appointmentId);

    if (appointment != null && existingAppointment != null) {
      List<Appointment> getAppointmentList = await appointmentService
          .fetchAppointmentListByPhysioId(appointment.physioId);
      bool isConflict = false;
      for (Appointment existingAppointment in getAppointmentList) {
        if (existingAppointment.startTime
                .isAtSameMomentAs(appointment.startTime) &&
            existingAppointment.endTime.isAtSameMomentAs(appointment.endTime)) {
          isConflict = true;
          await rejectUpdatePendingAppointmentRecord(appointmentId);

          break;
        }
      }
      if (!isConflict) {
        await approveUpdatedAppointmentRecord(appointmentId);
        isApproved = true;
      }
    }
    return isApproved;
  }

  Future<void> approveUpdatedAppointmentRecord(int appointmentId) async {
    await appointmentInPendingCollection
        .where('id', isEqualTo: appointmentId)
        .get()
        .then((snapshot) {
      snapshot.docs.first.reference
          .update({'status': 'Updated', 'isApproved': true});
    });
    AppointmentInPending? appointment =
        await fetchPendingAppointmentById(appointmentId);
    if (appointment != null) {
      Appointment? oriAppointment =
          await appointmentService.fetchAppointmentById(appointmentId);
      await appointmentService.updateAppointmentRecord(appointment);
      sendEmailToNotifyApprove(appointment, 'Updated');

      if (oriAppointment != null) {
        String patientUid =
          await userManagementService.fetchUidByUserId(appointment.patientId);
      String physioUid =
          await userManagementService.fetchUidByUserId(appointment.physioId);

      notificationService.addNotificationFromAdmin(
          patientUid,
          'Appointment Update Approved',
          'Dear patient, your recent appointment update request from ${DateFormat('hh:mm a').format(oriAppointment.startTime)}, ${DateFormat('dd MMM yyyy').format(oriAppointment.startTime)} has been changed to  ${DateFormat('hh:mm a').format(appointment.startTime)}, ${DateFormat('dd MMM yyyy').format(appointment.startTime)}.');
      notificationService.addNotificationFromAdmin(
          physioUid,
          'Appointment Update Approved',
          'Dear physio, there is an appointment originally on ${DateFormat('hh:mm a').format(oriAppointment.startTime)}, ${DateFormat('dd MMM yyyy').format(oriAppointment.startTime)} has been changed to ${DateFormat('hh:mm a').format(appointment.startTime)}, ${DateFormat('dd MMM yyyy').format(appointment.startTime)}');
    
      }
    }
  }

  Future<void> approveCancelledAppointmentRecord(int appointmentId) async {
    AppointmentInPending? appointment =
        await fetchPendingAppointmentById(appointmentId);
    await appointmentInPendingCollection
        .where('id', isEqualTo: appointmentId)
        .get()
        .then((snapshot) {
      snapshot.docs.first.reference.delete();
    });

    appointmentService.removeAppointmentRecord(appointmentId);
    if (appointment != null) {
      sendEmailToNotifyApprove(appointment, 'Cancel');
      String patientUid =
          await userManagementService.fetchUidByUserId(appointment.patientId);
      String physioUid =
          await userManagementService.fetchUidByUserId(appointment.physioId);

      notificationService.addNotificationFromAdmin(
          patientUid,
          'Appointment Cancellation Approved',
          'Dear patient, your recent appointment cancellation request for ${DateFormat('hh:mm a').format(appointment.startTime)}, ${DateFormat('dd MMM yyyy').format(appointment.startTime)} has been approved. Thank you.');
      notificationService.addNotificationFromAdmin(
          physioUid,
          'Appointment Cancellation Approved',
          'Dear physio, the appointment on ${DateFormat('hh:mm a').format(appointment.startTime)}, ${DateFormat('dd MMM yyyy').format(appointment.startTime)} has been cancelled. Thank you.');

      appointmentService.deleteAppointmentReferenceFromUserById(
          appointment.patientId, appointmentId);
      appointmentService.deleteAppointmentReferenceFromUserById(
          appointment.physioId, appointmentId);
    }
  }

  // update the dateTime in here then send email
  Future<void> removeUpdatedPendingAppointmentRecordByUser(
      int appointmentId) async {
    AppointmentInPending? appointmentInPending =
        await fetchPendingAppointmentById(appointmentId);
    Appointment? appointment =
        await appointmentService.fetchAppointmentById(appointmentId);
    if (appointment != null && appointmentInPending != null) {
      DateTime date = appointmentInPending.date;
      DateTime startTime = appointmentInPending.startTime;
      DateTime endTime = appointmentInPending.endTime;

      await appointmentInPendingCollection
          .where('id', isEqualTo: appointmentId)
          .get()
          .then((snapshot) {
        snapshot.docs.first.reference.update({
          'status': 'New',
          'isApproved': true,
          'date': appointment.date,
          'startTime': appointment.startTime,
          'endTime': appointment.endTime,
          'durationInSecond': appointment.durationInSecond,
        });
      });

      String userId = await userManagementService
          .fetchUidByUserId(appointmentInPending.patientId);

      notificationService.addNotificationFromAdmin(
          userId,
          'Cancellation Appointment Update Request',
          "Dear patient, your recent appointment update for ${DateFormat('hh:mm a').format(startTime)}, ${DateFormat('dd MMM yyyy').format(startTime)} has been cancelled by your own. Therefore, your appointment time will still remain at ${DateFormat('hh:mm a').format(appointmentInPending.startTime)}, ${DateFormat('dd MMM yyyy').format(appointmentInPending.startTime)}. Thank you.");

      sendEmailToNotifyRemoveUpdatePending(
          appointmentInPending, true, date, startTime, endTime);
    }
  }

  Future<void> removeCancelPendingAppointmentRecordByUser(
      int appointmentId) async {
    AppointmentInPending? appointmentInPending =
        await fetchPendingAppointmentById(appointmentId);
    Appointment? appointment =
        await appointmentService.fetchAppointmentById(appointmentId);
    if (appointment != null && appointmentInPending != null) {
      DateTime date = appointmentInPending.date;
      DateTime startTime = appointmentInPending.startTime;
      DateTime endTime = appointmentInPending.endTime;

      await appointmentInPendingCollection
          .where('id', isEqualTo: appointmentId)
          .get()
          .then((snapshot) {
        snapshot.docs.first.reference.update({
          'status': 'New',
          'isApproved': true,
          'date': appointment.date,
          'startTime': appointment.startTime,
          'endTime': appointment.endTime,
          'durationInSecond': appointment.durationInSecond,
        });
      });

      String userId = await userManagementService
          .fetchUidByUserId(appointmentInPending.patientId);
      notificationService.addNotificationFromAdmin(
          userId,
          "Remove Appointment Cancellation Request",
          "Dear patient, the appointment cancellation request at ${DateFormat('hh:mm a').format(appointmentInPending.startTime)}, ${DateFormat('dd MMM yyyy').format(appointmentInPending.startTime)} has been removed. Therefore, your appointment time will still remain at the same time. Thank you.");
      sendEmailToNotifyRemoveUpdatePending(
          appointmentInPending, false, date, startTime, endTime);
    }
  }

  Future<void> rejectUpdatePendingAppointmentRecord(int appointmentId) async {
    AppointmentInPending? appointmentInPending =
        await fetchPendingAppointmentById(appointmentId);
    await appointmentInPendingCollection
        .where('id', isEqualTo: appointmentId)
        .get()
        .then((snapshot) {
      snapshot.docs.first.reference
          .update({'status': 'New', 'isApproved': true});
    });

    if (appointmentInPending != null) {
      Appointment? appointment = await appointmentService
          .fetchAppointmentById(appointmentInPending.id);

      if (appointment != null) {
        String userId = await userManagementService
            .fetchUidByUserId(appointmentInPending.patientId);
        notificationService.addNotificationFromAdmin(
            userId,
            "Appointment Update Rejection",
            'Dear patient, your recent appointment update for ${DateFormat('hh:mm a').format(appointmentInPending.startTime)}, ${DateFormat('dd MMM yyyy').format(appointmentInPending.startTime)} has been rejected. The appointment time will remain at  ${DateFormat('hh:mm a').format(appointment.startTime)}, ${DateFormat('dd MMM yyyy').format(appointment.startTime)}. Please cancel the current appointment and plan a new appointment at your earliest convenience in PhysioTrack app if you wish to reschedule your appointment. Thank you.');
      }
      sendEmailToNotifyRejection(appointmentInPending, false);
    }
  }

  // reject pending appointment record
  Future<void> rejectNewPendingAppointmentRecord(int appointmentId) async {
    AppointmentInPending? appointmentInPending =
        await fetchPendingAppointmentById(appointmentId);
    await appointmentInPendingCollection
        .where('id', isEqualTo: appointmentId)
        .get()
        .then((snapshot) {
      snapshot.docs.first.reference.delete();
    });

    if (appointmentInPending != null) {
      sendEmailToNotifyRejection(appointmentInPending, true);
      String userId = await userManagementService
          .fetchUidByUserId(appointmentInPending.patientId);
      notificationService.addNotificationFromAdmin(
          userId,
          "Appointment Booking Rejection",
          'Dear patient, your recent appointment booking for ${DateFormat('hh:mm a').format(appointmentInPending.startTime)}, ${DateFormat('dd MMM yyyy').format(appointmentInPending.startTime)} has been rejected. Please reschedule your appointment slot again. Thank you.');
    }
  }

  // send email to notify user
  void sendEmailToNotifyRejection(AppointmentInPending appointmentInPending,
      bool isRejectNewAppointment) async {
    String patientName = await userManagementService
        .getUsernameById(appointmentInPending.patientId);
    String patientEmail = await userManagementService
        .getEmailById(appointmentInPending.patientId);
    final mailer = Mailer(
      dotenv.get('SENDGRID_API_KEY', fallback: ''),
    );
    final toAddress = Address(patientEmail);
    //change to admin email
    final fromAddress = Address(dotenv.get('ADMIN_EMAIL', fallback: ''));

    Content content = Content('text/plain', '');
    String subject = '';

    if (isRejectNewAppointment) {
      content = Content('text/plain',
          'Dear ${patientName}, \n\nI hope this email finds you well. We regret to inform you that your recent appointment booking for ${DateFormat('hh:mm a').format(appointmentInPending.startTime)}, ${DateFormat('dd MMM yyyy').format(appointmentInPending.startTime)} has been rejected. Our medical team believes that rescheduling the appointment would better suit your medical needs. \n\nPlease plan a new appointment at your earliest convenience in PhysioTrack app. We apologize for any inconvenience and appreciate your understanding. \n\n\nRegards,\nPhysioTrack');
      subject = 'Appointment Booking Rejection';
    } else {
      Appointment? appointment = await appointmentService
          .fetchAppointmentById(appointmentInPending.id);
      if (appointment != null) {
        content = Content('text/plain',
            'Dear ${patientName}, \n\nI hope this email finds you well. We regret to inform you that your recent appointment update for ${DateFormat('hh:mm a').format(appointmentInPending.startTime)}, ${DateFormat('dd MMM yyyy').format(appointmentInPending.startTime)} has been rejected. The appointment time will remain at  ${DateFormat('hh:mm a').format(appointment.startTime)}, ${DateFormat('dd MMM yyyy').format(appointment.startTime)}\n\nPlease cancel the current appointment and plan a new appointment at your earliest convenience in PhysioTrack app if you wish to reschedule your appointment. We apologize for any inconvenience and appreciate your understanding. \n\n\nRegards,\nPhysioTrack');

        subject = 'Appointment Update Rejection';

        await appointmentInPendingCollection
            .where('id', isEqualTo: appointment.id)
            .get()
            .then((snapshot) {
          snapshot.docs.first.reference.update({
            'date': appointment.date,
            'startTime': appointment.startTime,
            'endTime': appointment.endTime,
            'durationInSecond': appointment.durationInSecond
          });
        });
      } else {
        return;
      }
    }

    final personalization = Personalization([toAddress]);

    final email =
        Email([personalization], fromAddress, subject, content: [content]);

    try {
      // Attempt to send the email
      final result = await mailer.send(email);

      if (result.isValue) {
        print('Email sent successfully');
      } else {
        print('Email sending failed: ${result.asError}');
      }
    } catch (e) {
      print('Error sending email: $e');
    }
  }

  void sendEmailToNotifyApprove(
      AppointmentInPending appointmentInPending, String approveType) async {
    String patientName = await userManagementService
        .getUsernameById(appointmentInPending.patientId);
    String patientEmail = await userManagementService
        .getEmailById(appointmentInPending.patientId);
    final mailer = Mailer(dotenv.get('SENDGRID_API_KEY', fallback: ''));
    final toAddress = Address(patientEmail);
    //change to admin email
    final fromAddress = Address(dotenv.get('ADMIN_EMAIL', fallback: ''));

    Content content = Content('text/plain', '');
    String subject = '';

    if (approveType == 'New') {
      content = Content('text/plain',
          'Dear ${patientName}, \n\nI hope this email finds you well. Your recent appointment booking request for ${DateFormat('hh:mm a').format(appointmentInPending.startTime)}, ${DateFormat('dd MMM yyyy').format(appointmentInPending.startTime)} has been approved. \n\nPlease remember to attend the appointment on that selected time slot. Thank you. \n\n\nRegards,\nPhysioTrack');
      subject = 'Appointment Booking Approved';
    } else if (approveType == 'Updated') {
      content = Content('text/plain',
          'Dear ${patientName}, \n\nI hope this email finds you well. Your recent appointment update request for ${DateFormat('hh:mm a').format(appointmentInPending.startTime)}, ${DateFormat('dd MMM yyyy').format(appointmentInPending.startTime)} has been approved. \n\nPlease remember to attend the appointment on that selected time slot. Thank you. \n\n\nRegards,\nPhysioTrack');
      subject = 'Appointment Update Approved';
    } else if (approveType == 'Cancel') {
      content = Content('text/plain',
          'Dear ${patientName}, \n\nI hope this email finds you well. Your recent appointment cancellation request for ${DateFormat('hh:mm a').format(appointmentInPending.startTime)}, ${DateFormat('dd MMM yyyy').format(appointmentInPending.startTime)} has been approved. \n\nThank you. \n\n\nRegards,\nPhysioTrack');
      subject = 'Appointment Cancellation Approved';
    }

    final personalization = Personalization([toAddress]);

    final email =
        Email([personalization], fromAddress, subject, content: [content]);

    try {
      // Attempt to send the email
      final result = await mailer.send(email);

      if (result.isValue) {
        print('Email sent successfully');
      } else {
        print('Email sending failed: ${result.asError}');
      }
    } catch (e) {
      print('Error sending email: $e');
    }
  }

  void sendEmailToNotifyRemoveUpdatePending(
      AppointmentInPending appointmentInPending,
      bool isRemoveUpdatePending,
      DateTime updateDate,
      DateTime updateStartTime,
      DateTime updateEndTime) async {
    try {
      String patientName = await userManagementService
          .getUsernameById(appointmentInPending.patientId);
      String patientEmail = await userManagementService
          .getEmailById(appointmentInPending.patientId);

      final mailer = Mailer(dotenv.get('SENDGRID_API_KEY', fallback: ''));

      final fromAddress = Address(dotenv.get('ADMIN_EMAIL', fallback: ''));
      final toAddress = Address(patientEmail);

      Content content;
      String subject;

      if (isRemoveUpdatePending) {
        content = Content(
          'text/plain',
          'Dear $patientName, \n\nI hope this email finds you well. Your recent appointment update for ${DateFormat('hh:mm a').format(updateStartTime)}, ${DateFormat('dd MMM yyyy').format(updateStartTime)} has been cancelled by your own. Therefore, your appointment time will still remain at ${DateFormat('hh:mm a').format(appointmentInPending.startTime)}, ${DateFormat('dd MMM yyyy').format(appointmentInPending.startTime)}.\nThank you. \n\n\nRegards,\nPhysioTrack',
        );
        subject = 'Cancellation Appointment Update Request';
      } else {
        content = Content(
          'text/plain',
          'Dear $patientName, \n\nI hope this email finds you well. You recently removed the appointment cancellation request at ${DateFormat('hh:mm a').format(appointmentInPending.startTime)}, ${DateFormat('dd MMM yyyy').format(appointmentInPending.startTime)}. Therefore, your appointment time will still remain at the same time. \n\nPlease remember to attend the appointment on that selected time slot. Thank you. \n\n\nRegards,\nPhysioTrack',
        );
        subject = 'Remove Appointment Cancellation Request';
      }

      final personalization = Personalization([toAddress]);
      final email =
          Email([personalization], fromAddress, subject, content: [content]);

      final result = await mailer.send(email);

      if (result.isValue) {
        print('Email sent successfully');
      } else {
        print('Email sending failed: ${result.asError}');
      }
    } catch (e) {
      print('Error sending email: $e');
    }
  }

  Future<Appointment?> fetchAndUpdateAppointment(int appointmentId) async {
    final appointment =
        await appointmentService.fetchAppointmentById(appointmentId);

    if (appointment == null) {
      return null;
    }

    await appointmentInPendingCollection
        .where('id', isEqualTo: appointment.id)
        .get()
        .then((snapshot) {
      snapshot.docs.first.reference.update({
        'date': appointment.date,
        'startTime': appointment.startTime,
        'endTime': appointment.endTime,
        'durationInSecond': appointment.durationInSecond,
      });
    });

    return appointment;
  }

  // fetch selected pending appointment record
  Future<AppointmentInPending?> fetchPendingAppointmentById(int id) async {
    try {
      final snapshot =
          await appointmentInPendingCollection.where('id', isEqualTo: id).get();
      if (snapshot.docs.isNotEmpty) {
        return AppointmentInPending.fromSnapshot(snapshot.docs.first);
      }
    } catch (e) {
      print('Error fetching appointment: $e');
    }
    return null;
  }

  // fetch all new pending appointment record (admin)
  Future<List<AppointmentInPending>>
      fetchAllNewAddedPendingAppointmentRecord() async {
    List<AppointmentInPending> appointmentList = [];
    QuerySnapshot querySnapshot = await appointmentInPendingCollection
        .where('status', isEqualTo: 'New')
        .where('isApproved', isEqualTo: false)
        .get();
    querySnapshot.docs.forEach((snapshot) {
      appointmentList.add(AppointmentInPending.fromSnapshot(snapshot));
    });
    return appointmentList;
  }

  // fetch all updated pending appointment record (admin)
  Future<List<AppointmentInPending>>
      fetchAllUpdatedPendingAppointmentRecord() async {
    List<AppointmentInPending> appointmentList = [];
    QuerySnapshot querySnapshot = await appointmentInPendingCollection
        .where('status', isEqualTo: 'Updated')
        .where('isApproved', isEqualTo: false)
        .get();
    querySnapshot.docs.forEach((snapshot) {
      appointmentList.add(AppointmentInPending.fromSnapshot(snapshot));
    });
    return appointmentList;
  }

  // fetch all cancelled pending appointment record (admin)
  Future<List<AppointmentInPending>>
      fetchAllCancelledPendingAppointmentRecord() async {
    List<AppointmentInPending> appointmentList = [];
    QuerySnapshot querySnapshot = await appointmentInPendingCollection
        .where('status', isEqualTo: 'Cancelled')
        .where('isApproved', isEqualTo: false)
        .get();
    querySnapshot.docs.forEach((snapshot) {
      appointmentList.add(AppointmentInPending.fromSnapshot(snapshot));
    });
    return appointmentList;
  }

  // fetch latest pending appointment record by patientId (user)
  Future<AppointmentInPending> fetchLatestPendingAppointmentRecordByPatientId(
      String uid) async {
    int id = 0;
    DocumentSnapshot snapshot = await userCollection.doc(uid).get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      id = data['id'];
    } else {
      throw Exception('User not found');
    }
    print(id);

    QuerySnapshot querySnapshot = await appointmentInPendingCollection
        .where('patientId', isEqualTo: id)
        .get();
    List<DocumentSnapshot> documents = querySnapshot.docs;
    DateTime currentTime = DateTime.now();
    documents = documents
        .where(
            (document) => (document['startTime'].toDate()).isAfter(currentTime))
        .toList();

    documents.sort((a, b) => b['id'].compareTo(a['id']));

    if (documents.isEmpty) {
      // throw Exception('No pending appointment records found for the user.');
      return AppointmentInPending(
          id: -1,
          title: '',
          date: DateTime(2000, 1, 1),
          startTime: DateTime(2000, 1, 1),
          endTime: DateTime(
            2000,
            1,
            1,
          ),
          durationInSecond: 0,
          status: '',
          isApproved: false,
          patientId: 0,
          physioId: 0,
          eventId: '');
    }

    var latestRecord = documents.first;

    return AppointmentInPending.fromSnapshot(latestRecord);
  }
}
