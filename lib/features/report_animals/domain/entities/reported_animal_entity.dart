class ReportedAnimalEntity {
  final String id;
  final String species;
  final String location;
  final String? description;
  final String imagePath;
  final String reportedBy;
  final DateTime timestamp;
  final String rescuedStatus; // pending, in-progress, rescued

  ReportedAnimalEntity({
    required this.id,
    required this.species,
    required this.location,
    this.description,
    required this.imagePath,
    required this.reportedBy,
    required this.timestamp,
    required this.rescuedStatus,
  });
}