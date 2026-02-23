import 'package:equatable/equatable.dart';
import 'location_value.dart';

export 'location_value.dart';

enum AnimalReportStatus {
  pending,
  approved,
  rejected,
}

class AnimalReportEntity extends Equatable {
  final String? reportId;
  final String species;
  final LocationValue location;
  final String? description;
  final String imageUrl;
  final String reportedBy;
  final AnimalReportStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AnimalReportEntity({
    this.reportId,
    required this.species,
    required this.location,
    this.description,
    required this.imageUrl,
    required this.reportedBy,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        reportId,
        species,
        location,
        description,
        imageUrl,
        reportedBy,
        status,
        createdAt,
        updatedAt,
      ];
}
