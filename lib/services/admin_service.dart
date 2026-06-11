import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// Email dengan domain ini otomatis dianggap sebagai admin.
// Contoh: admin@admin.com, dhona@admin.com, username@admin.com
const String adminEmailDomain = '@admin.com';

// Daftar email admin tambahan.
// Pakai ini kalau ada email admin yang tidak memakai domain @admin.com.
const List<String> adminEmails = ['admin@onlycats.id'];

bool isAdminEmail(String? email) {
  if (email == null) return false;

  final normalizedEmail = email.trim().toLowerCase();

  return normalizedEmail.endsWith(adminEmailDomain) ||
      adminEmails.contains(normalizedEmail);
}

// Model ringkasan statistik
class AdminStats {
  final int totalCats;
  final int totalRescueReports;
  final int pendingRescue;
  final int inProgressRescue;
  final int doneRescue;
  final int totalAdoptions;
  final int pendingAdoptions;

  const AdminStats({
    required this.totalCats,
    required this.totalRescueReports,
    required this.pendingRescue,
    required this.inProgressRescue,
    required this.doneRescue,
    required this.totalAdoptions,
    required this.pendingAdoptions,
  });
}

// Model laporan rescue terbaru
class RecentRescue {
  final String id;
  final String location;
  final String status;
  final DateTime createdAt;

  const RecentRescue({
    required this.id,
    required this.location,
    required this.status,
    required this.createdAt,
  });
}

// Service
class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Mengambil semua statistik sekaligus
  Future<AdminStats> fetchStats() async {
    final results = await Future.wait([
      _db.collection('cats').get(),
      _db.collection('rescue_reports').get(),
      _db.collection('adoptions').get(),
    ]);

    final catsSnap = results[0];
    final rescueSnap = results[1];
    final adoptionSnap = results[2];

    final rescueDocs = rescueSnap.docs;

    final pending = rescueDocs.where((d) {
      final data = d.data();
      return data['status'] == 'Menunggu';
    }).length;

    final inProgress = rescueDocs.where((d) {
      final data = d.data();
      return data['status'] == 'Diproses';
    }).length;

    final done = rescueDocs.where((d) {
      final data = d.data();
      return data['status'] == 'Selesai';
    }).length;

    final adoptionDocs = adoptionSnap.docs;

    final pendingAdoption = adoptionDocs.where((d) {
      final data = d.data();
      return data['status'] == 'Menunggu';
    }).length;

    return AdminStats(
      totalCats: catsSnap.size,
      totalRescueReports: rescueSnap.size,
      pendingRescue: pending,
      inProgressRescue: inProgress,
      doneRescue: done,
      totalAdoptions: adoptionSnap.size,
      pendingAdoptions: pendingAdoption,
    );
  }

  /// 5 laporan rescue terbaru
  Future<List<RecentRescue>> fetchRecentRescues() async {
    final snap = await _db
        .collection('rescue_reports')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();

      return RecentRescue(
        id: doc.id,
        location: data['location'] ?? '-',
        status: data['status'] ?? 'Menunggu',
        createdAt: _parseCreatedAt(data['createdAt']),
      );
    }).toList();
  }

  /// Update kehadiran admin
  Future<void> updatePresence(String adminId) async {
    await _db.collection('admin_status').doc(adminId).set({
      'lastActive': FieldValue.serverTimestamp(),
      'isOnline': true,
    }, SetOptions(merge: true));
  }

  /// Memantau status online admin (apakah ada admin yang aktif dalam 10 menit terakhir)
  Stream<bool> streamAdminStatus() {
    return _db.collection('admin_status').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        debugPrint('Admin status collection is empty');
        return false;
      }

      final now = DateTime.now();
      bool anyAdminOnline = false;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final lastActive = data['lastActive'];
        if (lastActive is Timestamp) {
          final lastActiveDate = lastActive.toDate();
          final diff = now.difference(lastActiveDate).abs();
          
          debugPrint('Checking admin ${doc.id}: Last active at $lastActiveDate, current time $now, diff: ${diff.inMinutes} mins');
          
          if (diff.inMinutes < 10) {
            anyAdminOnline = true;
          }
        }
      }

      return anyAdminOnline;
    });
  }

  DateTime _parseCreatedAt(dynamic value) {
    if (value == null) return DateTime.now();

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return DateTime.now();
  }
}
