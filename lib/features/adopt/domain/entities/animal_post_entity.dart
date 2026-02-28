import 'package:equatable/equatable.dart';

enum AnimalPostStatus {
  available,
  adopted,
}

class AdoptionRequestEntity extends Equatable {
  final String userId;
  final String fullName;
  final String email;
  final String? profilePicture;
  final DateTime requestedAt;

  const AdoptionRequestEntity({
    required this.userId,
    required this.fullName,
    required this.email,
    this.profilePicture,
    required this.requestedAt,
  });

  @override
  List<Object?> get props => [userId, fullName, email, profilePicture, requestedAt];
}

class AnimalPostEntity extends Equatable {
  final String? postId;
  final String species;
  final String gender;
  final String breed;
  final int age;
  final String location;
  final String? description;
  final List<String> photos;
  final AnimalPostStatus status;
  final AdoptedByEntity? adoptedBy;
  final List<AdoptionRequestEntity> adoptionRequests;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AnimalPostEntity({
    this.postId,
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
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        postId,
        species,
        gender,
        breed,
        age,
        location,
        description,
        photos,
        status,
        adoptedBy,
        adoptionRequests,
        createdAt,
        updatedAt,
      ];
}

class AdoptedByEntity extends Equatable {
  final String id;
  final String fullName;
  final String email;

  const AdoptedByEntity({
    required this.id,
    required this.fullName,
    required this.email,
  });

  @override
  List<Object?> get props => [id, fullName, email];
}
