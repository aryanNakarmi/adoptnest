import 'dart:async';

import 'package:adoptnest/features/chat/data/datasources/chat_socket_service.dart';
import 'package:adoptnest/features/chat/domain/entities/chat_entity.dart';
import 'package:adoptnest/features/chat/domain/usecases/chat_usecases.dart';
import 'package:adoptnest/features/chat/presentation/state/chat_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatViewModelProvider =
    NotifierProvider<ChatViewModel, ChatState>(() => ChatViewModel());

class ChatViewModel extends Notifier<ChatState> {
  late final GetMyChatUsecase _getMyChatUsecase;
  late final SendMessageUsecase _sendMessageUsecase;
  late final MarkAsReadUsecase _markAsReadUsecase;
  late final GetCachedMessagesUsecase _getCachedMessagesUsecase;
  late final ChatSocketService _socketService;

  Timer? _typingTimer;

  @override
  ChatState build() {
    _getMyChatUsecase = ref.read(getMyChatUsecaseProvider);
    _sendMessageUsecase = ref.read(sendMessageUsecaseProvider);
    _markAsReadUsecase = ref.read(markAsReadUsecaseProvider);
    _getCachedMessagesUsecase = ref.read(getCachedMessagesUsecaseProvider);
    _socketService = ref.read(chatSocketServiceProvider);

    ref.onDispose(() {
      _typingTimer?.cancel();
      _cleanupSocket();
    });

    return const ChatState();
  }

  // =================== Load chat ===================
  Future<void> loadChat() async {
    state = state.copyWith(status: ChatStatus.loading);

    final result = await _getMyChatUsecase();
    result.fold(
      (failure) async {
        // Try cached data on failure
        final cached = await _getCachedMessagesUsecase();
        cached.fold(
          (_) => state = state.copyWith(
            status: ChatStatus.error,
            errorMessage: failure.message,
          ),
          (messages) => state = state.copyWith(
            status: ChatStatus.loaded,
            messages: messages,
            isOffline: true,
            errorMessage: 'Showing cached messages. You are offline.',
          ),
        );
      },
      (data) async {
        final chat = data['chat'] as ChatEntity;
        final messages = data['messages'] as List<MessageEntity>;
        final unreadCount = data['unreadCount'] as int;

        state = state.copyWith(
          status: ChatStatus.loaded,
          chat: chat,
          messages: messages,
          unreadCount: unreadCount,
          isOffline: false,
        );

        // Mark as read since user is viewing
        _markAsReadUsecase(chat.id);

        // Connect socket and join room
        await _socketService.connect();
        _socketService.joinChat(chat.id);
        _setupSocketListeners(chat.id);
      },
    );
  }

  // =================== Socket listeners ===================
  void _setupSocketListeners(String chatId) {
    _socketService.removeAllListeners();

    // New message from admin
    _socketService.onNewMessage((message) {
      if (message.chatId == chatId) {
        final exists = state.messages.any((m) => m.id == message.id);
        if (!exists) {
          state = state.copyWith(
            messages: [...state.messages, message],
          );
          // Auto mark as read since chat is open
          _markAsReadUsecase(chatId);
        }
      }
    });

    // Admin read our messages → update read receipts
    _socketService.onMessagesRead((incomingChatId) {
      if (incomingChatId == chatId) {
        final updated = state.messages.map((m) {
          if (m.isFromUser && !m.isRead) {
            return MessageEntity(
              id: m.id,
              chatId: m.chatId,
              senderId: m.senderId,
              senderRole: m.senderRole,
              content: m.content,
              isRead: true,
              createdAt: m.createdAt,
            );
          }
          return m;
        }).toList();
        state = state.copyWith(messages: updated);
      }
    });

    // Admin typing
    _socketService.onAdminTyping(() {
      state = state.copyWith(isAdminTyping: true);
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 3), () {
        state = state.copyWith(isAdminTyping: false);
      });
    });

    _socketService.onAdminStopTyping(() {
      _typingTimer?.cancel();
      state = state.copyWith(isAdminTyping: false);
    });
  }

  // =================== Send message ===================
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || state.chat == null) return;

    state = state.copyWith(status: ChatStatus.sending);

    // Optimistic update
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = MessageEntity(
      id: tempId,
      chatId: state.chat!.id,
      senderId: '',
      senderRole: 'user',
      content: content.trim(),
      isRead: false,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      status: ChatStatus.loaded,
      messages: [...state.messages, optimistic],
    );

    final result = await _sendMessageUsecase(content.trim());
    result.fold(
      (failure) {
        // Remove optimistic on failure
        final updated = state.messages.where((m) => m.id != tempId).toList();
        state = state.copyWith(
          status: ChatStatus.error,
          messages: updated,
          errorMessage: failure.message,
        );
      },
      (sentMessage) {
        // Replace optimistic with real message
        final updated = state.messages.map((m) {
          return m.id == tempId ? sentMessage : m;
        }).toList();
        state = state.copyWith(
          status: ChatStatus.loaded,
          messages: updated,
        );
      },
    );
  }

  // =================== Typing ===================
  void onUserTyping() {
    if (state.chat == null) return;
    _socketService.emitTyping(state.chat!.id);
  }

  void onUserStopTyping() {
    if (state.chat == null) return;
    _socketService.emitStopTyping(state.chat!.id);
  }

  // =================== Cleanup ===================
  void _cleanupSocket() {
    if (state.chat != null) {
      _socketService.leaveChat(state.chat!.id);
    }
    _socketService.removeAllListeners();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
