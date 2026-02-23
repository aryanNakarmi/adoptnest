import 'package:adoptnest/features/report_animals/domain/entities/animal_report_entity.dart';
import 'package:adoptnest/features/report_animals/domain/entities/location_value.dart';

class AnimalReportApiModel {
  final String? id;
  final String species;
  final LocationValue location;
  final String? description;
  final String imageUrl;
  final String status;
  final String reportedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AnimalReportApiModel({
    this.id,
    required this.species,
    required this.location,
    this.description,
    required this.imageUrl,
    required this.status,
    required this.reportedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory AnimalReportApiModel.fromJson(Map<String, dynamic> json) {
    return AnimalReportApiModel(
      id: json['_id'] as String?,
      species: json['species'] as String,
      location: LocationValue.fromJson(json['location'] as Map<String, dynamic>),
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String,
      status: json['status'] as String? ?? 'pending',
      reportedBy: _reportedByFromJson(json['reportedBy']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) '_id': id,
        'species': species,
        'location': location.toJson(),
        if (description != null) 'description': description,
        'imageUrl': imageUrl,
        'status': status,
        'reportedBy': reportedBy,
      };

  AnimalReportEntity toEntity() => AnimalReportEntity(
        reportId: id,
        species: species,
        location: location,
        description: description,
        imageUrl: imageUrl,
        reportedBy: reportedBy,
        status: _stringToStatus(status),
        createdAt: createdAt ?? DateTime.now(),
        updatedAt: updatedAt,
      );

  factory AnimalReportApiModel.fromEntity(AnimalReportEntity entity) =>
      AnimalReportApiModel(
        id: entity.reportId,
        species: entity.species,
        location: entity.location,
        description: entity.description,
        imageUrl: entity.imageUrl,
        reportedBy: entity.reportedBy,
        status: entity.status.name,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );

  static String _reportedByFromJson(dynamic value) {
    if (value is String) return value;
    if (value is Map && value.containsKey('_id')) return value['_id'] as String;
    return '';
  }

  static AnimalReportStatus _stringToStatus(String status) {
    switch (status) {
      case 'approved':
        return AnimalReportStatus.approved;
      case 'rejected':
        return AnimalReportStatus.rejected;
      default:
        return AnimalReportStatus.pending;
    }
  }
}
