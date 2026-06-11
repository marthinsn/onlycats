import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'local_notification_service.dart';

class NotificationListenerService {
  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  static final Set<String> _shownNotificationIds = {};

  static void startListening(String userId) {
    debugPrint('NotificationListenerService: Start listening for $userId');
    stopListening();

    _subscription = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      debugPrint(
          'NotificationListenerService: Received snapshot with ${snapshot.docs.length} docs');

      if (snapshot.docs.isEmpty) {
        debugPrint(
            'NotificationListenerService: No unread notifications found for $userId');
      }

      for (final change in snapshot.docChanges) {
        debugPrint('NotificationListenerService: Change type: ${change.type}');
        if (change.type != DocumentChangeType.added) continue;

        final doc = change.doc;
        debugPrint(
            'NotificationListenerService: New notification found: ${doc.id}');

        if (_shownNotificationIds.contains(doc.id)) {
          debugPrint(
              'NotificationListenerService: Notification ${doc.id} already shown, skipping');
          continue;
        }

        _shownNotificationIds.add(doc.id);
        final data = doc.data();

        if (data == null) continue;

        final title = data['title'] ?? 'Notifikasi OnlyCats';
        final message = data['message'] ?? 'Ada update baru untuk akunmu.';

        LocalNotificationService.showNotification(
          title: title,
          body: message,
        );
      }
    }, onError: (error) {
      debugPrint('NotificationListenerService ERROR: $error');
    });
  }

  static void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }
}
