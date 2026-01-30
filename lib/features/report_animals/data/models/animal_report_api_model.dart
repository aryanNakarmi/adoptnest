import 'package:adoptnest/features/report_animals/domain/entities/animal_report_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'animal_report_api_model.g.dart';

@JsonSerializable()
class AnimalReportApiModel {
  @JsonKey(name: '_id')
  final String? id;

  final String species;
  final String location;
  final String? description;
  final String imageUrl;
  final String status;

  /// reportedBy can be String OR populated object
  @JsonKey(fromJson: _reportedByFromJson)
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

  Map<String, dynamic> toJson() => _$AnimalReportApiModelToJson(this);

  factory AnimalReportApiModel.fromJson(Map<String, dynamic> json) =>
      _$AnimalReportApiModelFromJson(json);

  AnimalReportEntity toEntity() {
    return AnimalReportEntity(
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
  }

  factory AnimalReportApiModel.fromEntity(AnimalReportEntity entity) {
    return AnimalReportApiModel(
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
  }

  static List<AnimalReportEntity> toEntityList(
    List<AnimalReportApiModel> models,
  ) {
    return models.map((model) => model.toEntity()).toList();
  }

  static String _reportedByFromJson(dynamic value) {
    if (value is String) return value;
    if (value is Map && value.containsKey('_id')) {
      return value['_id'];
    }
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
