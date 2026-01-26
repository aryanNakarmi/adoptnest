// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal_report_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnimalReportHiveModelAdapter extends TypeAdapter<AnimalReportHiveModel> {
  @override
  final int typeId = 1;

  @override
  AnimalReportHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnimalReportHiveModel(
      reportId: fields[0] as String?,
      species: fields[1] as String,
      location: fields[2] as String,
      description: fields[3] as String?,
      imageUrl: fields[4] as String,
      reportedBy: fields[5] as String,
      reportedByName: fields[6] as String,
      status: fields[7] as String,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AnimalReportHiveModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.reportId)
      ..writeByte(1)
      ..write(obj.species)
      ..writeByte(2)
      ..write(obj.location)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.reportedBy)
      ..writeByte(6)
      ..write(obj.reportedByName)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalReportHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
