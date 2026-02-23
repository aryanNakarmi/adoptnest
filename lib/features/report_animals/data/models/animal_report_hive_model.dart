import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:adoptnest/core/constants/hive_table_constant.dart';
import 'package:adoptnest/features/report_animals/domain/entities/animal_report_entity.dart';
import 'package:adoptnest/features/report_animals/domain/entities/location_value.dart';

part 'animal_report_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.animalReportTypeId)
class AnimalReportHiveModel extends HiveObject {
  @HiveField(0)
  final String reportId;

  @HiveField(1)
  final String species;

  @HiveField(2)
  final String locationAddress;

  @HiveField(3)
  final double locationLat;

  @HiveField(4)
  final double locationLng;

  @HiveField(5)
  final String? description;

  @HiveField(6)
  final String imageUrl;

  @HiveField(7)
  final String reportedBy;

  @HiveField(8)
  final String status;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime? updatedAt;

  AnimalReportHiveModel({
    String? reportId,
    required this.species,
    required this.locationAddress,
    required this.locationLat,
    required this.locationLng,
    this.description,
    required this.imageUrl,
    required this.reportedBy,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  }) : reportId = reportId ?? const Uuid().v4();

  AnimalReportEntity toEntity() => AnimalReportEntity(
        reportId: reportId,
        species: species,
        location: LocationValue(
          address: locationAddress,
          lat: locationLat,
          lng: locationLng,
        ),
        description: description,
        imageUrl: imageUrl,
        reportedBy: reportedBy,
        status: _stringToStatus(status),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory AnimalReportHiveModel.fromEntity(AnimalReportEntity entity) =>
      AnimalReportHiveModel(
        reportId: entity.reportId,
        species: entity.species,
        locationAddress: entity.location.address,
        locationLat: entity.location.lat,
        locationLng: entity.location.lng,
        description: entity.description,
        imageUrl: entity.imageUrl,
        reportedBy: entity.reportedBy,
        status: entity.status.name,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );

  static AnimalReportStatus _stringToStatus(String s) {
    switch (s) {
      case 'approved':
        return AnimalReportStatus.approved;
      case 'rejected':
        return AnimalReportStatus.rejected;
      default:
        return AnimalReportStatus.pending;
    }
  }

  static List<AnimalReportEntity> toEntityList(List<AnimalReportHiveModel> models) =>
      models.map((m) => m.toEntity()).toList();
}
