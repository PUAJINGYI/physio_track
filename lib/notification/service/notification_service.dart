import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:physio_track/notification/model/notification_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
      // Separate notifications into read and unread
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

      // Sort the read notifications to put them at the end
      unreadNotifications.sort((a, b) => b.date.compareTo(a.date));
      readNotifications.sort((a, b) => b.date.compareTo(a.date));
      // Combine read and unread notifications
      notificationList = [...unreadNotifications, ...readNotifications];

      print('Notification List: $notificationList');
    } else {
      // Notification records not found
      print('Notification List not found');
    }

    return notificationList;
  }

  // update notification isRead status
  Future<void> updateNotificationStatus(
      String userId, int notificationId) async {
    try {
      QuerySnapshot notificationSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('id', isEqualTo: notificationId) // Query based on the id field
          .limit(1)
          .get();

      if (notificationSnapshot.size > 0) {
        // Notification record found, update the isRead field
        await notificationSnapshot.docs[0].reference.update({'isRead': true});
        print('Notification Record Updated');
      } else {
        // Notification record not found
        print('Notification Record not found');
        throw Exception('Notification Record not found');
      }
    } catch (error) {
      // Handle any errors that occur during the update operation
      print('Error updating notification record: $error');
      throw Exception('Error updating notification record');
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
      // Notification record found, create a Notification object
      Notifications notification =
          Notifications.fromSnapshot(notificationQuerySnapshot.docs.first);
      print('Notification: $notification');
      return notification;
    } else {
      print('Notification not found');
      return null;
    }
  }

  Future<String> translateText(String text, BuildContext context) async {
    // https://api.mymemory.translated.net/get?q=Hello%20World!&langpair=en|zh
    String locale = EasyLocalization.of(context)!.currentLocale!.languageCode;
    if (locale == 'en') {
      return text;
    } else {
      String? translatedText;
      final emailAddresses = [
        dotenv.get('EMAIL_ACC1'),
        dotenv.get('EMAIL_ACC2'),
        dotenv.get('EMAIL_ACC3'),
        dotenv.get('EMAIL_ACC4')
      ];
      for (final email in emailAddresses) {
        String urlString = dotenv.get('TRANSLATE_API') +
            Uri.encodeComponent(text) +
            dotenv.get('TRANSLATE_API_LANG') +
            locale +
            dotenv.get('TRANSLATE_EMAIL') +
            email;
        final url = Uri.parse(
          urlString,
        );
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonData = json.decode(response.body);
          translatedText = jsonData['responseData']['translatedText'];
          break;
        }
      }

      if (translatedText != null) {
        return translatedText;
      } else {
        throw Exception('Failed to load translation for all email addresses');
      }
    }
  }
}
