import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
            'title': title,
            'message': message,
            'type': type,
            'isRead': false,
            'timestamp': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  static Future<void> createWelcomeNotification(String userId) async {
    await createNotification(
      userId: userId,
      title: 'welcome_notification_title',
      message: 'welcome_notification_message',
      type: 'info',
    );
  }

  static Stream<QuerySnapshot> getUserNotificationsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  static Future<void> markAsRead(String userId, String notificationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  static Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('notifications')
              .where('isRead', isEqualTo: false)
              .get();

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  static Future<void> deleteNotification(
    String userId,
    String notificationId,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  static Future<void> deleteAllNotifications(String userId) async {
    try {
      final batch = _firestore.batch();
      final snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('notifications')
              .get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Error deleting all notifications: $e');
    }
  }

  static Future<void> sendScanNotification(
    String userId, {
    required String moldType,
    required String severity,
    required int scansLeft,
    int? scansTotal,
    String? scanId,
    String? imageUrl,
  }) async {
    final sev = (severity ?? 'unknown').toString().toLowerCase();
    String type = 'info';
    if (sev == 'high') type = 'warning';
    if (sev == 'medium') type = 'warning';

    final titleKey = 'scan_result_title';
    final messageKey =
        sev == 'high'
            ? 'scan_result_message_high'
            : (sev == 'medium'
                ? 'scan_result_message_medium'
                : 'scan_result_message');

    await _firestore.collection('users').doc(userId).collection('notifications').add({
      'titleKey': titleKey,
      'messageKey': messageKey,
      'type': type,
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
      'meta': {
        'moldType': moldType,
        'severity': severity,
        'scansLeft': scansLeft,
        if (scansTotal != null) 'scansTotal': scansTotal,
        if (scanId != null) 'scanId': scanId,
        if (imageUrl != null) 'imageUrl': imageUrl,
      },
      'title': 'Scan result: $moldType',
      'message':
          sev == 'high'
              ? 'High severity detected for $moldType. Act fast. Scans left: $scansLeft.'
              : (sev == 'medium'
                  ? '$moldType detected (medium severity). Scans left: $scansLeft.'
                  : '$moldType detected. Scans left: $scansLeft.'),
    });
  }
}
