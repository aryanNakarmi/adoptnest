import 'package:equatable/equatable.dart';

class ChatEntity extends Equatable {
  final String id;
  final String userId;
  final String? userFullName;
  final String? userEmail;
  final String? userProfilePicture;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final DateTime createdAt;

  const ChatEntity({
    required this.id,
    required this.userId,
    this.userFullName,
    this.userEmail,
    this.userProfilePicture,
    this.lastMessage,
    this.lastMessageAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, lastMessage, lastMessageAt];
}

class MessageEntity extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String senderRole;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  const MessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderRole,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  bool get isFromUser => senderRole == 'user';
  bool get isFromAdmin => senderRole == 'admin';

  @override
  List<Object?> get props => [id, chatId, content, isRead, createdAt];
}
