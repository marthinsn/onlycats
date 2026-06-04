import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class ProfileController extends ChangeNotifier {
  UserProfile _profile = const UserProfile(
    fullName: 'Nama Pengguna',
    username: 'namapengguna',
    bio: 'Pecinta kucing dari Jakarta 🐱',
    gender: 'Laki-laki',
    birthDate: '01/01/1998',
    email: 'pengguna@email.com',
    phone: '08123456789',
    city: 'Jakarta Selatan',
    instagram: '@namapengguna',
    twitter: '@username',
    facebook: 'Nama profil',
    housingType: 'Rumah dengan halaman',
    petExperience: 'Sudah berpengalaman',
    profileImagePath: null,
  );

  UserProfile get profile => _profile;

  void updateProfile(UserProfile newProfile) {
    _profile = newProfile;
    notifyListeners();
  }
}

final ProfileController profileController = ProfileController();
