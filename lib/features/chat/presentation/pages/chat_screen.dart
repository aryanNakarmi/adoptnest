import 'dart:async';

import 'package:adoptnest/features/chat/domain/entities/chat_entity.dart';
import 'package:adoptnest/features/chat/presentation/state/chat_state.dart';
import 'package:adoptnest/features/chat/presentation/view_model/chat_view_model.dart';
import 'package:adoptnest/features/chat/presentation/widgets/message_bubble.dart';
import 'package:adoptnest/features/chat/presentation/widgets/typing_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _typingDebounce;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatViewModelProvider.notifier).loadChat();
    });
    _messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _typingDebounce?.cancel();
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final vm = ref.read(chatViewModelProvider.notifier);
    if (_messageController.text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      vm.onUserTyping();
    }
    _typingDebounce?.cancel();
    _typingDebounce = Timer(const Duration(seconds: 2), () {
      if (_isTyping) {
        _isTyping = false;
        vm.onUserStopTyping();
      }
    });
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (animated) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      }
    });
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;
    _messageController.clear();
    _isTyping = false;
    ref.read(chatViewModelProvider.notifier).onUserStopTyping();
    await ref.read(chatViewModelProvider.notifier).sendMessage(content);
    _scrollToBottom();
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(date.year, date.month, date.day);
    if (msgDate == today) return 'Today';
    if (msgDate == yesterday) return 'Yesterday';
    return DateFormat('MMMM d, yyyy').format(date);
  }

  List<Map<String, dynamic>> _buildGroups(List<MessageEntity> messages) {
    final result = <Map<String, dynamic>>[];
    String? lastLabel;
    for (final msg in messages) {
      final label = _getDateLabel(msg.createdAt);
      result.add({
        'message': msg,
        'showDivider': label != lastLabel,
        'dateLabel': label,
      });
      lastLabel = label;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatViewModelProvider);

    ref.listen<ChatState>(chatViewModelProvider, (prev, next) {
      if (next.messages.length != (prev?.messages.length ?? 0)) {
        _scrollToBottom();
      }
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(chatViewModelProvider.notifier).clearError();
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Column(
        children: [
          // Chat header (replaces AppBar title since AppBar is transparent)
          _buildHeader(chatState),

          // Offline banner
          if (chatState.isOffline)
            Container(
              width: double.infinity,
              color: Colors.orange.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.wifi_off_rounded,
                      size: 14, color: Colors.orange.shade800),
                  const SizedBox(width: 6),
                  Text(
                    'You are offline — showing cached messages',
                    style:
                        TextStyle(fontSize: 12, color: Colors.orange.shade800),
                  ),
                ],
              ),
            ),

          // Messages
          Expanded(child: _buildBody(chatState)),

          // Input bar
          _buildInputBar(chatState),
        ],
      ),
    );
  }

  // Solid header that sits below the transparent AppBar
  Widget _buildHeader(ChatState chatState) {
    return Container(
      
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + kToolbarHeight,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFDC2626),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.support_agent,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AdoptNest Support',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: chatState.isOffline ? Colors.grey : Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    chatState.isAdminTyping
                        ? 'Admin is typing...'
                        : chatState.isOffline
                            ? 'Offline'
                            : 'We reply within a few hours',
                    style: TextStyle(
                      fontSize: 12,
                      color: chatState.isAdminTyping
                          ? const Color(0xFFDC2626)
                          : Colors.grey.shade500,
                      fontStyle: chatState.isAdminTyping
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ChatState chatState) {
    if (chatState.status == ChatStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(
            color: Color(0xFFDC2626), strokeWidth: 2.5),
      );
    }

    if (chatState.status == ChatStatus.error && chatState.messages.isEmpty) {
      return _buildErrorState(chatState);
    }

    if (chatState.messages.isEmpty) {
      return _buildEmptyState();
    }

    return _buildMessagesList(chatState);
  }

  Widget _buildMessagesList(ChatState chatState) {
    final groups = _buildGroups(chatState.messages);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: groups.length + (chatState.isAdminTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (chatState.isAdminTyping && index == groups.length) {
          return const TypingIndicator();
        }
        final item = groups[index];
        return MessageBubble(
          message: item['message'] as MessageEntity,
          showDateDivider: item['showDivider'] as bool,
          dateDividerLabel: item['dateLabel'] as String,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(36),
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                size: 36, color: Color(0xFFDC2626)),
          ),
          const SizedBox(height: 16),
          const Text(
            'No messages yet',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            'Send us a message and our team\nwill get back to you soon.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13, color: Colors.grey.shade500, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ChatState chatState) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 52, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              chatState.errorMessage ?? 'Failed to load chat',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(chatViewModelProvider.notifier).loadChat(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(ChatState chatState) {
    final isSending = chatState.status == ChatStatus.sending;
    final isOffline = chatState.isOffline;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  enabled: !isOffline,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: isOffline
                        ? 'Cannot send messages while offline'
                        : 'Type your message...',
                    hintStyle:
                        TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: (isSending || isOffline) ? null : _sendMessage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (isSending || isOffline)
                      ? Colors.grey.shade400
                      : const Color(0xFFDC2626),
                  shape: BoxShape.circle,
                  boxShadow: (isSending || isOffline)
                      ? []
                      : [
                          BoxShadow(
                            color: const Color(0xFFDC2626).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: isSending
                    ? const Padding(
                        padding: EdgeInsets.all(11),
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}