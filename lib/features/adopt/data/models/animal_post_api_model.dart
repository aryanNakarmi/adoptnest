import 'package:adoptnest/features/adopt/domain/entities/animal_post_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'animal_post_api_model.g.dart';

@JsonSerializable()
class AnimalPostApiModel {
  @JsonKey(name: '_id')
  final String? id;

  final String species;
  final String gender;
  final String breed;
  final int age;
  final String location;
  final String? description;
  final List<String> photos;
  final String status;

  @JsonKey(fromJson: _adoptedByFromJson)
  final AdoptedByApiModel? adoptedBy;

  // Excluded from json_serializable — parsed manually in fromJson/toJson
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<AdoptionRequestApiModel> adoptionRequests;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  AnimalPostApiModel({
    this.id,
    required this.species,
    required this.gender,
    required this.breed,
    required this.age,
    required this.location,
    this.description,
    required this.photos,
    required this.status,
    this.adoptedBy,
    this.adoptionRequests = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory AnimalPostApiModel.fromJson(Map<String, dynamic> json) {
    final base = _$AnimalPostApiModelFromJson(json);
    final requests = _adoptionRequestsFromJson(json['adoptionRequests']);
    return AnimalPostApiModel(
      id: base.id,
      species: base.species,
      gender: base.gender,
      breed: base.breed,
      age: base.age,
      location: base.location,
      description: base.description,
      photos: base.photos,
      status: base.status,
      adoptedBy: base.adoptedBy,
      adoptionRequests: requests,
      createdAt: base.createdAt,
      updatedAt: base.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => _$AnimalPostApiModelToJson(this);

  static AdoptedByApiModel? _adoptedByFromJson(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return AdoptedByApiModel.fromJson(value);
    return null;
  }

  static List<AdoptionRequestApiModel> _adoptionRequestsFromJson(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .whereType<Map<String, dynamic>>()
          .map((e) => AdoptionRequestApiModel.fromJson(e))
          .toList();
    }
    return [];
  }

  AnimalPostEntity toEntity() {
    return AnimalPostEntity(
      postId: id,
      species: species,
      gender: gender,
      breed: breed,
      age: age,
      location: location,
      description: description,
      photos: photos,
      status: _stringToStatus(status),
      adoptedBy: adoptedBy?.toEntity(),
      adoptionRequests: adoptionRequests.map((r) => r.toEntity()).toList(),
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt,
    );
  }

  static AnimalPostStatus _stringToStatus(String status) {
    switch (status.toLowerCase()) {
      case 'adopted':
        return AnimalPostStatus.adopted;
      default:
        return AnimalPostStatus.available;
    }
  }

  static List<AnimalPostEntity> toEntityList(List<AnimalPostApiModel> models) {
    return models.map((m) => m.toEntity()).toList();
  }
}

@JsonSerializable()
class AdoptedByApiModel {
  @JsonKey(name: '_id')
  final String id;
  final String fullName;
  final String email;

  AdoptedByApiModel({
    required this.id,
    required this.fullName,
    required this.email,
  });

  factory AdoptedByApiModel.fromJson(Map<String, dynamic> json) =>
      _$AdoptedByApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$AdoptedByApiModelToJson(this);

  AdoptedByEntity toEntity() =>
      AdoptedByEntity(id: id, fullName: fullName, email: email);
}

class AdoptionRequestApiModel {
  final String userId;
  final String fullName;
  final String email;
  final String? profilePicture;
  final DateTime requestedAt;

  AdoptionRequestApiModel({
    required this.userId,
    required this.fullName,
    required this.email,
    this.profilePicture,
    required this.requestedAt,
  });

  factory AdoptionRequestApiModel.fromJson(Map<String, dynamic> json) {
    return AdoptionRequestApiModel(
      userId: json['userId'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profilePicture: json['profilePicture'] as String?,
      requestedAt: json['requestedAt'] != null
          ? DateTime.tryParse(json['requestedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  AdoptionRequestEntity toEntity() => AdoptionRequestEntity(
        userId: userId,
        fullName: fullName,
        email: email,
        profilePicture: profilePicture,
        requestedAt: requestedAt,
      );
}