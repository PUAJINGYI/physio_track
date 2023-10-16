import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:physio_track/notification/model/notification_model.dart';

class NotificationService {
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

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
}
