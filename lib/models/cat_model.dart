class CatModel {
  final String id;
  final String name;
  final String breed;
  final String age;
  final String location;
  final String image;
  final String gender;
  final bool vaccinated;
  final bool sterilized;
  final bool available;
  final bool favorite;
  final String color;
  final String weight;
  final String size;
  final String description;
  final String shelterName;
  final String shelterLocation;
  final String shelterSince;
  final List<String> personalities;
  final double? latitude;
  final double? longitude;

  const CatModel({
    this.id = '',
    required this.name,
    required this.breed,
    required this.age,
    required this.location,
    required this.image,
    required this.gender,
    required this.vaccinated,
    required this.sterilized,
    required this.available,
    required this.favorite,
    required this.color,
    required this.weight,
    required this.size,
    required this.description,
    required this.shelterName,
    required this.shelterLocation,
    required this.shelterSince,
    required this.personalities,
    this.latitude,
    this.longitude,
  });

  factory CatModel.fromMap(String id, Map<String, dynamic> data) {
    return CatModel(
      id: id,
      name: data['name'] ?? '',
      breed: data['breed'] ?? '',
      age: data['age'] ?? '',
      location: data['location'] ?? '',
      image: data['image'] ?? data['adoptionPhotoUrl'] ?? '',
      gender: data['gender'] ?? 'male',
      vaccinated: data['vaccinated'] ?? false,
      sterilized: data['sterilized'] ?? false,
      available: data['available'] ?? true,
      favorite: data['favorite'] ?? false,
      color: data['color'] ?? '',
      weight: data['weight'] ?? '',
      size: data['size'] ?? '',
      description: data['description'] ?? '',
      shelterName: data['shelterName'] ?? 'OnlyCats Rescue',
      shelterLocation: data['shelterLocation'] ?? data['location'] ?? '',
      shelterSince: data['shelterSince'] ?? '',
      personalities: List<String>.from(data['personalities'] ?? []),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }
}
