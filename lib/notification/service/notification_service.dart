import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:physio_track/notification/model/notification_model.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../constant/TextConstant.dart';
import '../../user_management/service/user_management_service.dart';

class NotificationService {
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  UserManagementService userManagementService = UserManagementService();

  Future<void> addNotification(
      String userId, String title, String message, int fromId) async {
    final CollectionReference notificationCollection =
        usersCollection.doc(userId).collection('notifications');
    QuerySnapshot querySnapshot = await notificationCollection
        .orderBy('id', descending: true)
        .limit(1)
        .get();
    int currentMaxId =
        querySnapshot.docs.isEmpty ? 0 : querySnapshot.docs.first['id'];
    int newId = currentMaxId + 1;

    Notifications newNotification = Notifications(
      id: newId,
      date: DateTime.now(),
      title: title,
      message: message,
      isRead: false,
      fromId: fromId,
    );

    newNotification.id = newId;
    await notificationCollection.add(newNotification.toMap()).then((value) {
      print("Notification Added");
    }).catchError((error) {
      print("Failed to add notification: $error");
    });
  }

  Future<void> addNotificationFromAdmin(
      String userId, String title, String message) async {
    final CollectionReference notificationCollection =
        usersCollection.doc(userId).collection('notifications');
    QuerySnapshot querySnapshot = await notificationCollection
        .orderBy('id', descending: true)
        .limit(1)
        .get();
    int currentMaxId =
        querySnapshot.docs.isEmpty ? 0 : querySnapshot.docs.first['id'];
    int newId = currentMaxId + 1;

    Notifications newNotification = Notifications(
      id: newId,
      date: DateTime.now(),
      title: title,
      message: message,
      isRead: false,
      fromId: 0,
    );

    newNotification.id = newId;
    await notificationCollection.add(newNotification.toMap()).then((value) {
      print("Notification Added");
    }).catchError((error) {
      print("Failed to add notification: $error");
    });
  }

  Future<void> addAppointmentRequestNotiToAdmin(
      String requestType, String patientName) async {
    String title = '';
    String msg = '';
    String adminEmail = dotenv.get('ADMIN_EMAIL2');
    String adminUid = await userManagementService.getUidByEmail(adminEmail);

    final CollectionReference notificationCollection =
        usersCollection.doc(adminUid).collection('notifications');
    QuerySnapshot querySnapshot = await notificationCollection
        .orderBy('id', descending: true)
        .limit(1)
        .get();
    int currentMaxId =
        querySnapshot.docs.isEmpty ? 0 : querySnapshot.docs.first['id'];
    int newId = currentMaxId + 1;

    if (requestType == TextConstant.NEW) {
      title = 'New Appointment Request';
      msg = '$patientName has requested a new appointment';
    } else if (requestType == TextConstant.UPDATED) {
      title = 'Appointment Update Request';
      msg = '$patientName has requested to update an appointment';
    } else if (requestType == TextConstant.CANCELLED) {
      title = 'Appointment Cancellation Request';
      msg = '$patientName has requested to cancel an appointment';
    } else if (requestType == TextConstant.CONFLICT) {
      title = 'Appointment Conflict';
      msg =
          'The appointment slot booked by $patientName has conflict due to the physiotherapist is taking leave. Please asssign other available physiotherapists for that appointment slot to resolve the conflict.';
    }

    Notifications newNotification = Notifications(
      id: newId,
      date: DateTime.now(),
      title: title,
      message: msg,
      isRead: false,
      fromId: 0,
    );

    newNotification.id = newId;
    await notificationCollection.add(newNotification.toMap()).then((value) {
      print("Notification Added");
    }).catchError((error) {
      print("Failed to add notification: $error");
    });
  }

  Future<List<Notifications>> fetchNotificationList(String userId) async {
    List<Notifications> notificationList = [];
    List<Notifications> readNotifications = [];
    List<Notifications> unreadNotifications = [];

    QuerySnapshot notificationQuerySnapshot =
        await usersCollection.doc(userId).collection('notifications').get();

    if (notificationQuerySnapshot.docs.isNotEmpty) {
      notificationList = notificationQuerySnapshot.docs
          .map((doc) => Notifications.fromSnapshot(doc))
          .toList();

      for (var notification in notificationList) {
        if (notification.isRead) {
          readNotifications.add(notification);
        } else {
          unreadNotifications.add(notification);
        }
      }

      unreadNotifications.sort((a, b) => b.date.compareTo(a.date));
      readNotifications.sort((a, b) => b.date.compareTo(a.date));
      notificationList = [...unreadNotifications, ...readNotifications];

      print('Notification List: $notificationList');
    } else {
      print('Notification List not found');
    }

    return notificationList;
  }

  Future<void> updateNotificationStatus(
      String userId, int notificationId) async {
    try {
      QuerySnapshot notificationSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('id', isEqualTo: notificationId)
          .limit(1)
          .get();

      if (notificationSnapshot.size > 0) {
        await notificationSnapshot.docs[0].reference.update({'isRead': true});
        print('Notification Record Updated');
      } else {
        print('Notification Record not found');
        throw Exception('Notification Record not found');
      }
    } catch (error) {
      print('Error updating notification record: $error');
      throw Exception('Error updating notification record');
    }
  }

  // update all notification status to read by userId
  Future<void> updateAllNotificationStatus(String userId) async {
    try {
      QuerySnapshot notificationSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      if (notificationSnapshot.size > 0) {
        for (var notification in notificationSnapshot.docs) {
          await notification.reference.update({'isRead': true});
        }
        print('All Notification Records Updated');
      } else {
        print('All Notification Records not found');
        throw Exception('All Notification Records not found');
      }
    } catch (error) {
      print('Error updating all notification records: $error');
      throw Exception('Error updating all notification records');
    }
  }

  Future<Notifications?> fetchNotificationById(
      String userId, int notificationId) async {
    QuerySnapshot notificationQuerySnapshot = await usersCollection
        .doc(userId)
        .collection('notifications')
        .where('id', isEqualTo: notificationId)
        .get();

    if (notificationQuerySnapshot.docs.isNotEmpty) {
      Notifications notification =
          Notifications.fromSnapshot(notificationQuerySnapshot.docs.first);
      print('Notification: $notification');
      return notification;
    } else {
      print('Notification not found');
      return null;
    }
  }

  Future<void> sendWhatsAppMessage(int userId, String message) async {
    try {
      String? phoneNumber =
          await userManagementService.fetchPhoneNumberByUserId(userId);

      if (phoneNumber.length > 2 && phoneNumber != '') {
        String number = formatPhoneNumber(phoneNumber);
        final url = dotenv.get('WHATSAPP_API_KEY', fallback: '') +
            number +
            dotenv.get('WHATSAPP_WITH_TEXT', fallback: '') +
            Uri.encodeComponent(message);

        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw Exception('Could not launch $url');
        }
      } else {
        throw Exception('Phone number not found');
      }
    } catch (e) {
      print(
          'Error: $e'); 
    }
  }

  String formatPhoneNumber(String phoneNumber) {
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[-\s]'), '');

    if (phoneNumber.startsWith('60')) {
      phoneNumber = phoneNumber;
    } else if (!phoneNumber.startsWith('0')) {
      phoneNumber = '60' + phoneNumber;
    } else {
      phoneNumber = '6' + phoneNumber;
    }

    return phoneNumber;
  }
}
