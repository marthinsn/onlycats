import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'local_notification_service.dart';

class NotificationListenerService {
  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  static final Set<String> _shownNotificationIds = {};

  static void startListening(String userId) {
    stopListening();

    _subscription = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
          for (final change in snapshot.docChanges) {
            if (change.type != DocumentChangeType.added) continue;

            final doc = change.doc;

            if (_shownNotificationIds.contains(doc.id)) continue;

            _shownNotificationIds.add(doc.id);

            final data = doc.data();

            final title = data?['title'] ?? 'Notifikasi OnlyCats';
            final message = data?['message'] ?? 'Ada update baru untuk akunmu.';

            LocalNotificationService.showNotification(
              title: title,
              body: message,
            );
          }
        });
  }

  static void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }
}
