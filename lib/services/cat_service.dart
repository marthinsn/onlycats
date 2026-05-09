import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/cat_model.dart';

class CatService {
  final _col = FirebaseFirestore.instance.collection('cats');

  // ── READ: stream semua kucing ──────────────────────────────────────────────
  Stream<List<CatFirestoreModel>> streamAll() {
    return _col.orderBy('name').snapshots().map(
          (snap) => snap.docs
              .map((d) => CatFirestoreModel.fromDoc(d))
              .toList(),
        );
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────
  Future<void> addCat(Map<String, dynamic> data) async {
    await _col.add(data);
  }

  // ── UPDATE ─────────────────────────────────────────────────────────────────
  Future<void> updateCat(String id, Map<String, dynamic> data) async {
    await _col.doc(id).update(data);
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────
  Future<void> deleteCat(String id) async {
    await _col.doc(id).delete();
  }
}

// ── Model dengan Firestore id ──────────────────────────────────────────────────
class CatFirestoreModel {
  final String id;
  final String name;
  final String breed;
  final String age;
  final String location;
  final String gender;
  final String color;
  final String weight;
  final String size;
  final String description;
  final String shelterName;
  final String shelterLocation;
  final String shelterSince;
  final bool vaccinated;
  final bool sterilized;
  final bool available;
  final List<String> personalities;

  CatFirestoreModel({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.location,
    required this.gender,
    required this.color,
    required this.weight,
    required this.size,
    required this.description,
    required this.shelterName,
    required this.shelterLocation,
    required this.shelterSince,
    required this.vaccinated,
    required this.sterilized,
    required this.available,
    required this.personalities,
  });

  factory CatFirestoreModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CatFirestoreModel(
      id: doc.id,
      name: d['name'] ?? '',
      breed: d['breed'] ?? '',
      age: d['age'] ?? '',
      location: d['location'] ?? '',
      gender: d['gender'] ?? 'male',
      color: d['color'] ?? '',
      weight: d['weight'] ?? '',
      size: d['size'] ?? '',
      description: d['description'] ?? '',
      shelterName: d['shelterName'] ?? '',
      shelterLocation: d['shelterLocation'] ?? '',
      shelterSince: d['shelterSince'] ?? '',
      vaccinated: d['vaccinated'] ?? false,
      sterilized: d['sterilized'] ?? false,
      available: d['available'] ?? true,
      personalities: List<String>.from(d['personalities'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'breed': breed,
        'age': age,
        'location': location,
        'gender': gender,
        'color': color,
        'weight': weight,
        'size': size,
        'description': description,
        'shelterName': shelterName,
        'shelterLocation': shelterLocation,
        'shelterSince': shelterSince,
        'vaccinated': vaccinated,
        'sterilized': sterilized,
        'available': available,
        'personalities': personalities,
      };
}