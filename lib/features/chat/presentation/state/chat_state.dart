import 'package:adoptnest/features/chat/domain/entities/chat_entity.dart';
import 'package:equatable/equatable.dart';

enum ChatStatus { initial, loading, loaded, sending, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final ChatEntity? chat;
  final List<MessageEntity> messages;
  final int unreadCount;
  final String? errorMessage;
  final bool isAdminTyping;
  final bool isOffline;

  const ChatState({
    this.status = ChatStatus.initial,
    this.chat,
    this.messages = const [],
    this.unreadCount = 0,
    this.errorMessage,
    this.isAdminTyping = false,
    this.isOffline = false,
  });

  ChatState copyWith({
    ChatStatus? status,
    ChatEntity? chat,
    List<MessageEntity>? messages,
    int? unreadCount,
    String? errorMessage,
    bool clearError = false,
    bool? isAdminTyping,
    bool? isOffline,
  }) {
    return ChatState(
      status: status ?? this.status,
      chat: chat ?? this.chat,
      messages: messages ?? this.messages,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isAdminTyping: isAdminTyping ?? this.isAdminTyping,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [
        status,
        chat,
        messages,
        unreadCount,
        errorMessage,
        isAdminTyping,
        isOffline,
      ];
}
