import 'package:cloud_firestore/cloud_firestore.dart';

class CatService {
  final CollectionReference<Map<String, dynamic>> _col = FirebaseFirestore
      .instance
      .collection('cats');

  // READ: stream semua kucing
  Stream<List<CatFirestoreModel>> streamAll() {
    return _col
        .orderBy('name')
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => CatFirestoreModel.fromDoc(d)).toList(),
        );
  }

  // CREATE
  Future<void> addCat(Map<String, dynamic> data) async {
    await _col.add({
      ...data,
      'status': data['available'] == true ? 'tersedia' : 'tidak tersedia',
      'favorite': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // UPDATE
  Future<void> updateCat(String id, Map<String, dynamic> data) async {
    await _col.doc(id).update({
      ...data,
      'status': data['available'] == true ? 'tersedia' : 'tidak tersedia',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // DELETE
  Future<void> deleteCat(String id) async {
    await _col.doc(id).delete();
  }
}

// Model dengan Firestore id
class CatFirestoreModel {
  final String id;
  final String name;
  final String breed;
  final String age;
  final String location;
  final String image;
  final String adoptionPhotoUrl;
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
  final bool favorite;
  final List<String> personalities;

  CatFirestoreModel({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.location,
    required this.image,
    required this.adoptionPhotoUrl,
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
    required this.favorite,
    required this.personalities,
  });

  factory CatFirestoreModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};

    final imageUrl = (d['image'] ?? d['adoptionPhotoUrl'] ?? '').toString();

    return CatFirestoreModel(
      id: doc.id,
      name: d['name'] ?? '',
      breed: d['breed'] ?? '',
      age: d['age'] ?? '',
      location: d['location'] ?? '',
      image: imageUrl,
      adoptionPhotoUrl: (d['adoptionPhotoUrl'] ?? imageUrl).toString(),
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
      favorite: d['favorite'] ?? false,
      personalities: List<String>.from(d['personalities'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'breed': breed,
    'age': age,
    'location': location,
    'image': image,
    'adoptionPhotoUrl': adoptionPhotoUrl,
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
    'favorite': favorite,
    'personalities': personalities,
    'status': available ? 'tersedia' : 'tidak tersedia',
  };
}
