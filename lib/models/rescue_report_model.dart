class RescueReportModel {
  final String id;
  final String location;
  final List<String> conditions;
  final String description;
  final String phone;
  final String notes;
  final String status;
  final DateTime createdAt;

  const RescueReportModel({
    required this.id,
    required this.location,
    required this.conditions,
    required this.description,
    required this.phone,
    required this.notes,
    required this.status,
    required this.createdAt,
  });

  factory RescueReportModel.fromMap(String id, Map<String, dynamic> map) {
    return RescueReportModel(
      id: id,
      location: map['location'] ?? '',
      conditions: List<String>.from(map['conditions'] ?? []),
      description: map['description'] ?? '',
      phone: map['phone'] ?? '',
      notes: map['notes'] ?? '',
      status: map['status'] ?? 'Menunggu',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'location': location,
      'conditions': conditions,
      'description': description,
      'phone': phone,
      'notes': notes,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
