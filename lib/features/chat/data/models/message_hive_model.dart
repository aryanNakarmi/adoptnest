import 'package:adoptnest/core/constants/hive_table_constant.dart';
import 'package:adoptnest/features/chat/domain/entities/chat_entity.dart';
import 'package:hive/hive.dart';

part 'message_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.messageTypeId)
class MessageHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String chatId;

  @HiveField(2)
  final String senderId;

  @HiveField(3)
  final String senderRole;

  @HiveField(4)
  final String content;

  @HiveField(5)
  final bool isRead;

  @HiveField(6)
  final String createdAt;

  MessageHiveModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderRole,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory MessageHiveModel.fromEntity(MessageEntity entity) {
    return MessageHiveModel(
      id: entity.id,
      chatId: entity.chatId,
      senderId: entity.senderId,
      senderRole: entity.senderRole,
      content: entity.content,
      isRead: entity.isRead,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }

  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      chatId: chatId,
      senderId: senderId,
      senderRole: senderRole,
      content: content,
      isRead: isRead,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }
}
