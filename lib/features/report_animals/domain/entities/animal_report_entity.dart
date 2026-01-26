class AnimalReportEntity {
  final String id;
  final String species;
  final String location;
  final String description;
  final String imageUrl;
  final String status;
  final DateTime createdAt;

  AnimalReportEntity({
    required this.id,
    required this.species,
    required this.location,
    required this.description,
    required this.imageUrl,
    required this.status,
    required this.createdAt,
  });
}
