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
      locationAddress: fields[2] as String,
      locationLat: fields[3] as double,
      locationLng: fields[4] as double,
      description: fields[5] as String?,
      imageUrl: fields[6] as String,
      reportedBy: fields[7] as String,
      status: fields[8] as String,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AnimalReportHiveModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.reportId)
      ..writeByte(1)
      ..write(obj.species)
      ..writeByte(2)
      ..write(obj.locationAddress)
      ..writeByte(3)
      ..write(obj.locationLat)
      ..writeByte(4)
      ..write(obj.locationLng)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.imageUrl)
      ..writeByte(7)
      ..write(obj.reportedBy)
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
      other is AnimalReportHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
