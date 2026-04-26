import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/rescue_report_model.dart';
import 'notification_service.dart';

class RescueService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createRescueReport({
    required String userId,
    required String location,
    required List<String> conditions,
    required String description,
    required String phone,
    required String notes,
  }) async {
    final doc = _firestore.collection('rescue_reports').doc();

    final report = RescueReportModel(
      id: doc.id,
      location: location,
      conditions: conditions,
      description: description,
      phone: phone,
      notes: notes,
      status: 'Menunggu',
      createdAt: DateTime.now(),
    );

    await doc.set({
      ...report.toMap(),
      'userId': userId,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await NotificationService().createNotification(
      userId: userId,
      title: 'Laporan rescue berhasil disubmit',
      message:
          'Laporan rescue kamu untuk lokasi $location berhasil dikirim dan sedang menunggu ditinjau admin.',
      type: 'rescue_submit',
      rescueReportId: doc.id,
    );

    return doc.id;
  }

  Stream<List<RescueReportModel>> getUserReports(String userId) {
    return _firestore
        .collection('rescue_reports')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final reports = snapshot.docs
              .map((doc) => RescueReportModel.fromMap(doc.id, doc.data()))
              .toList();

          reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return reports;
        });
  }
}
