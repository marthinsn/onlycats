import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cat_model.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  DocumentReference<Map<String, dynamic>> _favoriteDoc(String catId) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(catId);
  }

  Stream<bool> isFavorite(String catId) {
    return _favoriteDoc(catId).snapshots().map((doc) => doc.exists);
  }

  Stream<QuerySnapshot> getFavorites() {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> addFavorite(CatModel cat) async {
    await _favoriteDoc(cat.id).set({
      'catId': cat.id,
      'name': cat.name,
      'image': cat.image,
      'breed': cat.breed,
      'age': cat.age,
      'location': cat.location,
      'gender': cat.gender,
      'vaccinated': cat.vaccinated,
      'sterilized': cat.sterilized,
      'available': cat.available,
      'favorite': true,
      'color': cat.color,
      'weight': cat.weight,
      'size': cat.size,
      'description': cat.description,
      'shelterName': cat.shelterName,
      'shelterLocation': cat.shelterLocation,
      'shelterSince': cat.shelterSince,
      'personalities': cat.personalities,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite(String catId) async {
    await _favoriteDoc(catId).delete();
  }

  Future<void> toggleFavorite(CatModel cat, bool isFavorite) async {
    if (isFavorite) {
      await removeFavorite(cat.id);
    } else {
      await addFavorite(cat);
    }
  }
}
