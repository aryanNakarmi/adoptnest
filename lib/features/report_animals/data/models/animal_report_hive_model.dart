import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:adoptnest/core/constants/hive_table_constant.dart';
import 'package:adoptnest/features/report_animals/domain/entities/animal_report_entity.dart';

part 'animal_report_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.animalReportTypeId)
class AnimalReportHiveModel extends HiveObject {
  
  @HiveField(0)
  final String reportId;

  @HiveField(1)
  final String species;

  @HiveField(2)
  final String location;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final String imageUrl;

  @HiveField(5)
  final String reportedBy;

  @HiveField(6)
  final String reportedByName;

  @HiveField(7)
  final String status; 

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime? updatedAt;

  AnimalReportHiveModel({
    String? reportId,
    required this.species,
    required this.location,
    this.description,
    required this.imageUrl,
    required this.reportedBy,
    required this.reportedByName,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  }) : reportId = reportId ?? const Uuid().v4();

 
  AnimalReportEntity toEntity() {
    return AnimalReportEntity(
      reportId: reportId,
      species: species,
      location: location,
      description: description,
      imageUrl: imageUrl,
      reportedBy: reportedBy,
      reportedByName: reportedByName,
      status: _stringToStatus(status), // Convert String to Enum
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory AnimalReportHiveModel.fromEntity(AnimalReportEntity entity) {
    return AnimalReportHiveModel(
      reportId: entity.reportId,
      species: entity.species,
      location: entity.location,
      description: entity.description,
      imageUrl: entity.imageUrl,
      reportedBy: entity.reportedBy,
      reportedByName: entity.reportedByName,
      status: entity.status.name, 
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static AnimalReportStatus _stringToStatus(String statusString) {
    switch (statusString) {
      case 'pending':
        return AnimalReportStatus.pending;
      case 'approved':
        return AnimalReportStatus.approved;
      case 'rejected':
        return AnimalReportStatus.rejected;
      default:
        return AnimalReportStatus.pending;
    }
  }


  static List<AnimalReportEntity> toEntityList(
    List<AnimalReportHiveModel> models,
  ) {
    return models.map((model) => model.toEntity()).toList();
  }

  static List<AnimalReportHiveModel> fromEntityList(
    List<AnimalReportEntity> entities,
  ) {
    return entities.map((entity) => AnimalReportHiveModel.fromEntity(entity)).toList();
  }
}