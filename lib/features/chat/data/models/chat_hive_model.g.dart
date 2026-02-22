// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatHiveModelAdapter extends TypeAdapter<ChatHiveModel> {
  @override
  final int typeId = 3;

  @override
  ChatHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatHiveModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      userFullName: fields[2] as String?,
      userEmail: fields[3] as String?,
      userProfilePicture: fields[4] as String?,
      lastMessage: fields[5] as String?,
      lastMessageAt: fields[6] as String?,
      createdAt: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ChatHiveModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.userFullName)
      ..writeByte(3)
      ..write(obj.userEmail)
      ..writeByte(4)
      ..write(obj.userProfilePicture)
      ..writeByte(5)
      ..write(obj.lastMessage)
      ..writeByte(6)
      ..write(obj.lastMessageAt)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
