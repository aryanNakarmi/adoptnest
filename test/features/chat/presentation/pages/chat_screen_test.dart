import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adoptnest/features/chat/domain/entities/chat_entity.dart';
import 'package:adoptnest/features/chat/presentation/pages/chat_screen.dart';
import 'package:adoptnest/features/chat/presentation/state/chat_state.dart';
import 'package:adoptnest/features/chat/presentation/view_model/chat_view_model.dart';

class FakeChatViewModel extends ChatViewModel {
  final ChatState _fakeState;
  FakeChatViewModel(this._fakeState);

  @override
  ChatState build() => _fakeState;

  @override
  Future<void> loadChat() async {}

  @override
  Future<void> sendMessage(String content) async {}

  @override
  void onUserTyping() {}

  @override
  void onUserStopTyping() {}

  @override
  void clearError() {}
}

MessageEntity makeMsg({
  String id = 'msg-1',
  String role = 'user',
  String content = 'Hello!',
}) =>
    MessageEntity(
      id: id,
      chatId: 'chat-1',
      senderId: 'user-1',
      senderRole: role,
      content: content,
      isRead: false,
      createdAt: DateTime(2024, 1, 1, 10, 0),
    );

Widget buildChatScreen(ChatState state) {
  return ProviderScope(
    overrides: [
      chatViewModelProvider.overrideWith(() => FakeChatViewModel(state)),
    ],
    child: const MaterialApp(home: ChatScreen()),
  );
}

void main() {
  group('ChatScreen Widget Tests', () {
    testWidgets('TW-16: shows loading indicator when status is loading',
        (tester) async {
      await tester.pumpWidget(
          buildChatScreen(const ChatState(status: ChatStatus.loading)));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('TW-17: shows empty state when no messages', (tester) async {
      await tester.pumpWidget(
          buildChatScreen(const ChatState(status: ChatStatus.loaded)));
      await tester.pump();

      expect(find.text('No messages yet'), findsOneWidget);
    });

    testWidgets('TW-18: shows offline banner when isOffline is true',
        (tester) async {
      await tester.pumpWidget(buildChatScreen(
          const ChatState(status: ChatStatus.loaded, isOffline: true)));
      await tester.pump();

      expect(find.textContaining('offline'), findsWidgets);
    });

    testWidgets('TW-19: renders message list when messages exist',
        (tester) async {
      final messages = [
        makeMsg(id: '1', content: 'Hello!'),
        makeMsg(id: '2', role: 'admin', content: 'Hi there!'),
      ];
      await tester.pumpWidget(buildChatScreen(
          ChatState(status: ChatStatus.loaded, messages: messages)));
      await tester.pump();

      expect(find.text('Hello!'), findsOneWidget);
      expect(find.text('Hi there!'), findsOneWidget);
    });

    testWidgets('TW-20: send button is present in input bar', (tester) async {
      await tester.pumpWidget(
          buildChatScreen(const ChatState(status: ChatStatus.loaded)));
      await tester.pump();

      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });

    testWidgets('TW-21: text field is disabled when offline', (tester) async {
      await tester.pumpWidget(buildChatScreen(
          const ChatState(status: ChatStatus.loaded, isOffline: true)));
      await tester.pump();

      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.enabled, isFalse);
    });

    testWidgets('TW-22: header shows AdoptNest Support title', (tester) async {
      await tester.pumpWidget(
          buildChatScreen(const ChatState(status: ChatStatus.loaded)));
      await tester.pump();

      expect(find.text('AdoptNest Support'), findsOneWidget);
    });
  });
}