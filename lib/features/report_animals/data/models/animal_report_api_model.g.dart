// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal_report_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnimalReportApiModel _$AnimalReportApiModelFromJson(
        Map<String, dynamic> json) =>
    AnimalReportApiModel(
      id: json['_id'] as String?,
      species: json['species'] as String,
      location: json['location'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String,
      status: json['status'] as String,
      reportedBy: AnimalReportApiModel._reportedByFromJson(json['reportedBy']),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AnimalReportApiModelToJson(
        AnimalReportApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'species': instance.species,
      'location': instance.location,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'status': instance.status,
      'reportedBy': instance.reportedBy,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
