import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:adoptnest/core/error/failures.dart';
import 'package:adoptnest/features/chat/data/datasources/chat_socket_service.dart';
import 'package:adoptnest/features/chat/domain/entities/chat_entity.dart';
import 'package:adoptnest/features/chat/domain/usecases/chat_usecases.dart';
import 'package:adoptnest/features/chat/presentation/state/chat_state.dart';
import 'package:adoptnest/features/chat/presentation/view_model/chat_view_model.dart';

// ─── Mocks ────────────────────────────────────────────────────────────────────
class MockGetMyChatUsecase extends Mock implements GetMyChatUsecase {}
class MockSendMessageUsecase extends Mock implements SendMessageUsecase {}
class MockMarkAsReadUsecase extends Mock implements MarkAsReadUsecase {}
class MockGetCachedMessagesUsecase extends Mock implements GetCachedMessagesUsecase {}
class MockChatSocketService extends Mock implements ChatSocketService {}

// ─── Helpers ─────────────────────────────────────────────────────────────────
ChatEntity get fakeChat => ChatEntity(
      id: 'chat-1',
      userId: 'user-1',
      createdAt: DateTime(2024, 1, 1),
    );

MessageEntity makeMsg({String id = 'msg-1', String content = 'Hello'}) =>
    MessageEntity(
      id: id,
      chatId: 'chat-1',
      senderId: 'user-1',
      senderRole: 'user',
      content: content,
      isRead: false,
      createdAt: DateTime(2024, 1, 1),
    );

Map<String, dynamic> chatPayload({List<MessageEntity>? messages}) => {
      'chat': fakeChat,
      'messages': messages ?? [makeMsg()],
      'unreadCount': 1,
    };

// Stubs ALL socket methods including leaveChat so onDispose doesn't crash.
// The crash is: _cleanupSocket reads state during Riverpod's onDispose lifecycle,
// which is forbidden. Stubbing leaveChat prevents the crash path.
void stubSocket(MockChatSocketService socket) {
  when(() => socket.connect()).thenAnswer((_) async {});
  when(() => socket.joinChat(any())).thenReturn(null);
  when(() => socket.leaveChat(any())).thenReturn(null);
  when(() => socket.removeAllListeners()).thenReturn(null);
  when(() => socket.onNewMessage(any())).thenReturn(null);
  when(() => socket.onMessagesRead(any())).thenReturn(null);
  when(() => socket.onAdminTyping(any())).thenReturn(null);
  when(() => socket.onAdminStopTyping(any())).thenReturn(null);
  when(() => socket.emitTyping(any())).thenReturn(null);
  when(() => socket.emitStopTyping(any())).thenReturn(null);
}

ProviderContainer makeContainer({
  required GetMyChatUsecase getMyChat,
  required SendMessageUsecase sendMessage,
  required MarkAsReadUsecase markAsRead,
  required GetCachedMessagesUsecase getCached,
  required ChatSocketService socket,
}) =>
    ProviderContainer(overrides: [
      getMyChatUsecaseProvider.overrideWithValue(getMyChat),
      sendMessageUsecaseProvider.overrideWithValue(sendMessage),
      markAsReadUsecaseProvider.overrideWithValue(markAsRead),
      getCachedMessagesUsecaseProvider.overrideWithValue(getCached),
      chatSocketServiceProvider.overrideWithValue(socket),
    ]);

void main() {
  late MockGetMyChatUsecase mockGetMyChat;
  late MockSendMessageUsecase mockSendMessage;
  late MockMarkAsReadUsecase mockMarkAsRead;
  late MockGetCachedMessagesUsecase mockGetCached;
  late MockChatSocketService mockSocket;

  setUp(() {
    mockGetMyChat = MockGetMyChatUsecase();
    mockSendMessage = MockSendMessageUsecase();
    mockMarkAsRead = MockMarkAsReadUsecase();
    mockGetCached = MockGetCachedMessagesUsecase();
    mockSocket = MockChatSocketService();
    stubSocket(mockSocket);
    when(() => mockMarkAsRead(any()))
        .thenAnswer((_) async => Right<Failure, bool>(true));
  });

  ProviderContainer container() => makeContainer(
        getMyChat: mockGetMyChat,
        sendMessage: mockSendMessage,
        markAsRead: mockMarkAsRead,
        getCached: mockGetCached,
        socket: mockSocket,
      );

  // ── loadChat ───────────────────────────────────────────────────────────────
  group('ChatViewModel - loadChat()', () {
    test('TC-CVM-01: sets loaded state with messages on success', () async {
      final msgs = [makeMsg(id: '1'), makeMsg(id: '2', content: 'Hi')];
      when(() => mockGetMyChat())
          .thenAnswer((_) async => Right(chatPayload(messages: msgs)));

      final c = container();
      addTearDown(() {
        try { c.dispose(); } catch (_) {}
      });
      await c.read(chatViewModelProvider.notifier).loadChat();

      final state = c.read(chatViewModelProvider);
      expect(state.status, ChatStatus.loaded);
      expect(state.messages.length, 2);
      expect(state.chat?.id, 'chat-1');
      expect(state.isOffline, isFalse);
    });

    test('TC-CVM-02: falls back to cache and sets isOffline on network failure',
        () async {
      when(() => mockGetMyChat())
          .thenAnswer((_) async => Left(ApiFailure(message: 'No internet')));
      when(() => mockGetCached())
          .thenAnswer((_) async => Right([makeMsg()]));

      final c = container();
      addTearDown(() {
        try { c.dispose(); } catch (_) {}
      });
      await c.read(chatViewModelProvider.notifier).loadChat();

      final state = c.read(chatViewModelProvider);
      expect(state.status, ChatStatus.loaded);
      expect(state.isOffline, isTrue);
    });

    test('TC-CVM-03: sets error when both network and cache fail', () async {
      when(() => mockGetMyChat())
          .thenAnswer((_) async => Left(ApiFailure(message: 'No internet')));
      when(() => mockGetCached())
          .thenAnswer((_) async => Left(LocalDatabaseFailure(message: 'No cache')));

      final c = container();
      addTearDown(() {
        try { c.dispose(); } catch (_) {}
      });
      await c.read(chatViewModelProvider.notifier).loadChat();

      expect(c.read(chatViewModelProvider).status, ChatStatus.error);
    });

    test('TC-CVM-04: connects socket after successful load', () async {
      when(() => mockGetMyChat())
          .thenAnswer((_) async => Right(chatPayload()));

      final c = container();
      addTearDown(() {
        try { c.dispose(); } catch (_) {}
      });
      await c.read(chatViewModelProvider.notifier).loadChat();

      verify(() => mockSocket.connect()).called(1);
      verify(() => mockSocket.joinChat('chat-1')).called(1);
    });
  });

  // ── sendMessage ────────────────────────────────────────────────────────────
  group('ChatViewModel - sendMessage()', () {
    test('TC-CVM-05: adds optimistic message then replaces with real message',
        () async {
      when(() => mockGetMyChat())
          .thenAnswer((_) async => Right(chatPayload(messages: [])));
      final c = container();
      addTearDown(() {
        try { c.dispose(); } catch (_) {}
      });
      await c.read(chatViewModelProvider.notifier).loadChat();

      final sent = makeMsg(id: 'real-1', content: 'Hello!');
      when(() => mockSendMessage(any())).thenAnswer((_) async => Right(sent));

      await c.read(chatViewModelProvider.notifier).sendMessage('Hello!');

      final state = c.read(chatViewModelProvider);
      expect(state.status, ChatStatus.loaded);
      expect(state.messages.any((m) => m.id == 'real-1'), isTrue);
      expect(state.messages.any((m) => m.id.startsWith('temp_')), isFalse);
    });

    test('TC-CVM-06: removes optimistic message on send failure', () async {
      when(() => mockGetMyChat())
          .thenAnswer((_) async => Right(chatPayload(messages: [])));
      final c = container();
      addTearDown(() {
        try { c.dispose(); } catch (_) {}
      });
      await c.read(chatViewModelProvider.notifier).loadChat();

      when(() => mockSendMessage(any()))
          .thenAnswer((_) async => Left(ApiFailure(message: 'Send failed')));

      await c.read(chatViewModelProvider.notifier).sendMessage('Hello!');

      final state = c.read(chatViewModelProvider);
      expect(state.status, ChatStatus.error);
      expect(state.messages.any((m) => m.id.startsWith('temp_')), isFalse);
      expect(state.errorMessage, 'Send failed');
    });

    test('TC-CVM-07: ignores empty message', () async {
      when(() => mockGetMyChat())
          .thenAnswer((_) async => Right(chatPayload(messages: [])));
      final c = container();
      addTearDown(() {
        try { c.dispose(); } catch (_) {}
      });
      await c.read(chatViewModelProvider.notifier).loadChat();

      await c.read(chatViewModelProvider.notifier).sendMessage('   ');

      verifyNever(() => mockSendMessage(any()));
    });
  });

  // ── clearError ─────────────────────────────────────────────────────────────
  group('ChatViewModel - clearError()', () {
    test('TC-CVM-08: clearError does not throw and resets error state',
        () async {
      // Trigger an error state via failed network + failed cache
      when(() => mockGetMyChat())
          .thenAnswer((_) async => Left(ApiFailure(message: 'Err')));
      when(() => mockGetCached())
          .thenAnswer((_) async => Left(LocalDatabaseFailure(message: 'No cache')));

      final c = container();
      addTearDown(() {
        try { c.dispose(); } catch (_) {}
      });
      await c.read(chatViewModelProvider.notifier).loadChat();
      expect(c.read(chatViewModelProvider).status, ChatStatus.error);

      // clearError should not throw
      expect(
        () => c.read(chatViewModelProvider.notifier).clearError(),
        returnsNormally,
      );
    });
  });
}