import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:adoptnest/core/constants/hive_table_constant.dart';
import 'package:adoptnest/features/adopt/domain/entities/animal_post_entity.dart';

part 'animal_post_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.animalPostTypeId)
class AnimalPostHiveModel extends HiveObject {
  @HiveField(0)
  final String postId;

  @HiveField(1)
  final String species;

  @HiveField(2)
  final String gender;

  @HiveField(3)
  final String breed;

  @HiveField(4)
  final int age;

  @HiveField(5)
  final String location;

  @HiveField(6)
  final String? description;

  @HiveField(7)
  final List<String> photos;

  @HiveField(8)
  final String status;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime? updatedAt;

  AnimalPostHiveModel({
    String? postId,
    required this.species,
    required this.gender,
    required this.breed,
    required this.age,
    required this.location,
    this.description,
    required this.photos,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  }) : postId = postId ?? const Uuid().v4();

  AnimalPostEntity toEntity() {
    return AnimalPostEntity(
      postId: postId,
      species: species,
      gender: gender,
      breed: breed,
      age: age,
      location: location,
      description: description,
      photos: photos,
      status: _stringToStatus(status),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory AnimalPostHiveModel.fromEntity(AnimalPostEntity entity) {
    return AnimalPostHiveModel(
      postId: entity.postId,
      species: entity.species,
      gender: entity.gender,
      breed: entity.breed,
      age: entity.age,
      location: entity.location,
      description: entity.description,
      photos: entity.photos,
      status: entity.status.name,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
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

  static List<AnimalPostEntity> toEntityList(List<AnimalPostHiveModel> models) {
    return models.map((m) => m.toEntity()).toList();
  }
}
