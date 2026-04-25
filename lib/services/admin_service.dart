import 'package:cloud_firestore/cloud_firestore.dart';

// Daftar email yang dianggap admin 
const List<String> adminEmails = [
  'admin@onlycats.id',
  'test@mail.com', // email dummy login sesuai main.dart
];

bool isAdminEmail(String? email) =>
    email != null && adminEmails.contains(email.toLowerCase());

//  Model ringkasan statistik 
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
    final pending = rescueDocs.where((d) => d['status'] == 'Menunggu').length;
    final inProgress = rescueDocs
        .where((d) => d['status'] == 'Diproses')
        .length;
    final done = rescueDocs.where((d) => d['status'] == 'Selesai').length;

    final adoptionDocs = adoptionSnap.docs;
    final pendingAdoption = adoptionDocs
        .where((d) => d['status'] == 'Menunggu')
        .length;

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
        createdAt: data['createdAt'] != null
            ? DateTime.tryParse(data['createdAt']) ?? DateTime.now()
            : DateTime.now(),
      );
    }).toList();
  }
}
