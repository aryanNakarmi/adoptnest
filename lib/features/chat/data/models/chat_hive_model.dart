import 'package:adoptnest/core/constants/hive_table_constant.dart';
import 'package:adoptnest/features/chat/domain/entities/chat_entity.dart';
import 'package:hive/hive.dart';

part 'chat_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.chatTypeId)
class ChatHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String? userFullName;

  @HiveField(3)
  final String? userEmail;

  @HiveField(4)
  final String? userProfilePicture;

  @HiveField(5)
  final String? lastMessage;

  @HiveField(6)
  final String? lastMessageAt;

  @HiveField(7)
  final String createdAt;

  ChatHiveModel({
    required this.id,
    required this.userId,
    this.userFullName,
    this.userEmail,
    this.userProfilePicture,
    this.lastMessage,
    this.lastMessageAt,
    required this.createdAt,
  });

  factory ChatHiveModel.fromEntity(ChatEntity entity) {
    return ChatHiveModel(
      id: entity.id,
      userId: entity.userId,
      userFullName: entity.userFullName,
      userEmail: entity.userEmail,
      userProfilePicture: entity.userProfilePicture,
      lastMessage: entity.lastMessage,
      lastMessageAt: entity.lastMessageAt?.toIso8601String(),
      createdAt: entity.createdAt.toIso8601String(),
    );
  }

  ChatEntity toEntity() {
    return ChatEntity(
      id: id,
      userId: userId,
      userFullName: userFullName,
      userEmail: userEmail,
      userProfilePicture: userProfilePicture,
      lastMessage: lastMessage,
      lastMessageAt:
          lastMessageAt != null ? DateTime.tryParse(lastMessageAt!) : null,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }
}
