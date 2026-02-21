import 'package:equatable/equatable.dart';

enum AnimalPostStatus {
  available,
  adopted,
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
