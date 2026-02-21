// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal_post_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnimalPostHiveModelAdapter extends TypeAdapter<AnimalPostHiveModel> {
  @override
  final int typeId = 2;

  @override
  AnimalPostHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnimalPostHiveModel(
      postId: fields[0] as String?,
      species: fields[1] as String,
      gender: fields[2] as String,
      breed: fields[3] as String,
      age: fields[4] as int,
      location: fields[5] as String,
      description: fields[6] as String?,
      photos: (fields[7] as List).cast<String>(),
      status: fields[8] as String,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AnimalPostHiveModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.postId)
      ..writeByte(1)
      ..write(obj.species)
      ..writeByte(2)
      ..write(obj.gender)
      ..writeByte(3)
      ..write(obj.breed)
      ..writeByte(4)
      ..write(obj.age)
      ..writeByte(5)
      ..write(obj.location)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.photos)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalPostHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
