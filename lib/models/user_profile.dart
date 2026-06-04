class UserProfile {
  final String fullName;
  final String username;
  final String bio;
  final String gender;
  final String birthDate;
  final String email;
  final String phone;
  final String city;
  final String instagram;
  final String twitter;
  final String facebook;
  final String housingType;
  final String petExperience;
  final String? profileImagePath;

  const UserProfile({
    required this.fullName,
    required this.username,
    required this.bio,
    required this.gender,
    required this.birthDate,
    required this.email,
    required this.phone,
    required this.city,
    required this.instagram,
    required this.twitter,
    required this.facebook,
    required this.housingType,
    required this.petExperience,
    this.profileImagePath,
  });

  UserProfile copyWith({
    String? fullName,
    String? username,
    String? bio,
    String? gender,
    String? birthDate,
    String? email,
    String? phone,
    String? city,
    String? instagram,
    String? twitter,
    String? facebook,
    String? housingType,
    String? petExperience,
    String? profileImagePath,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      instagram: instagram ?? this.instagram,
      twitter: twitter ?? this.twitter,
      facebook: facebook ?? this.facebook,
      housingType: housingType ?? this.housingType,
      petExperience: petExperience ?? this.petExperience,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}
