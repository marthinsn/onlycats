class CatModel {
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

  const CatModel({
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
  });
}
