import 'package:adoptnest/features/chat/domain/entities/chat_entity.dart';

class ChatApiModel {
  final String id;
  final Map<String, dynamic> userId;
  final String? lastMessage;
  final String? lastMessageAt;
  final String createdAt;

  ChatApiModel({
    required this.id,
    required this.userId,
    this.lastMessage,
    this.lastMessageAt,
    required this.createdAt,
  });

  factory ChatApiModel.fromJson(Map<String, dynamic> json) {
    return ChatApiModel(
      id: json['_id'] ?? '',
      userId: json['userId'] is Map
          ? Map<String, dynamic>.from(json['userId'])
          : {'_id': json['userId']?.toString() ?? ''},
      lastMessage: json['lastMessage'],
      lastMessageAt: json['lastMessageAt'],
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  ChatEntity toEntity() {
    return ChatEntity(
      id: id,
      userId: userId['_id']?.toString() ?? '',
      userFullName: userId['fullName']?.toString(),
      userEmail: userId['email']?.toString(),
      userProfilePicture: userId['profilePicture']?.toString(),
      lastMessage: lastMessage,
      lastMessageAt:
          lastMessageAt != null ? DateTime.tryParse(lastMessageAt!) : null,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }
}

class MessageApiModel {
  final String id;
  final String chatId;
  final Map<String, dynamic> senderId;
  final String senderRole;
  final String content;
  final bool isRead;
  final String createdAt;

  MessageApiModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderRole,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory MessageApiModel.fromJson(Map<String, dynamic> json) {
    return MessageApiModel(
      id: json['_id'] ?? '',
      chatId: json['chatId']?.toString() ?? '',
      senderId: json['senderId'] is Map
          ? Map<String, dynamic>.from(json['senderId'])
          : {'_id': json['senderId']?.toString() ?? ''},
      senderRole: json['senderRole'] ?? 'user',
      content: json['content'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      chatId: chatId,
      senderId: senderId['_id']?.toString() ?? '',
      senderRole: senderRole,
      content: content,
      isRead: isRead,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }
}
