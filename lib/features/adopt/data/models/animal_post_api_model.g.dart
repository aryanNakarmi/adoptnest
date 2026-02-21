// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal_post_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnimalPostApiModel _$AnimalPostApiModelFromJson(Map<String, dynamic> json) =>
    AnimalPostApiModel(
      id: json['_id'] as String?,
      species: json['species'] as String,
      gender: json['gender'] as String,
      breed: json['breed'] as String,
      age: (json['age'] as num).toInt(),
      location: json['location'] as String,
      description: json['description'] as String?,
      photos:
          (json['photos'] as List<dynamic>).map((e) => e as String).toList(),
      status: json['status'] as String,
      adoptedBy: AnimalPostApiModel._adoptedByFromJson(json['adoptedBy']),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AnimalPostApiModelToJson(AnimalPostApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'species': instance.species,
      'gender': instance.gender,
      'breed': instance.breed,
      'age': instance.age,
      'location': instance.location,
      'description': instance.description,
      'photos': instance.photos,
      'status': instance.status,
      'adoptedBy': instance.adoptedBy,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

AdoptedByApiModel _$AdoptedByApiModelFromJson(Map<String, dynamic> json) =>
    AdoptedByApiModel(
      id: json['_id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$AdoptedByApiModelToJson(AdoptedByApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'fullName': instance.fullName,
      'email': instance.email,
    };
