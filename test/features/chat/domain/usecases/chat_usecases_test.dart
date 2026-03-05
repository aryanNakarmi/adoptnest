import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:adoptnest/core/error/failures.dart';
import 'package:adoptnest/features/chat/domain/entities/chat_entity.dart';
import 'package:adoptnest/features/chat/domain/repositories/chat_repository.dart';
import 'package:adoptnest/features/chat/domain/usecases/chat_usecases.dart';

class MockChatRepository extends Mock implements IChatRepository {}

//helpers
MessageEntity makeMessage({
  String id = 'msg-1',
  String senderRole = 'user',
}) =>
    MessageEntity(
      id: id,
      chatId: 'chat-1',
      senderId: 'user-1',
      senderRole: senderRole,
      content: 'Hello!',
      isRead: false,
      createdAt: DateTime(2024, 1, 1),
    );

void main() {
  late MockChatRepository repository;

  setUp(() {
    repository = MockChatRepository();
  });

  // GetMyChatUsecase
  group('GetMyChatUsecase', () {
    late GetMyChatUsecase usecase;

    setUp(() => usecase = GetMyChatUsecase(repository: repository));

    test('returns chat map with chat and messages on success', () async {
      final chatData = {
        'chat': {'_id': 'chat-1', 'userId': 'user-1'},
        'messages': [],
        'unreadCount': 0,
      };
      when(() => repository.getMyChat())
          .thenAnswer((_) async => Right(chatData));

      final result = await usecase();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected success'),
        (data) {
          expect(data['chat'], isA<Map>());
          expect(data.keys, contains('messages'));
        },
      );
      verify(() => repository.getMyChat()).called(1);
    });

    test('returns ApiFailure when server error occurs', () async {
      const failure = ApiFailure(message: 'Unauthorized', statusCode: 401);
      when(() => repository.getMyChat())
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase();

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect((f as ApiFailure).statusCode, 401),
        (_) => fail('Expected failure'),
      );
    });

    test('returns NetworkFailure when offline', () async {
      const failure = NetworkFailure();
      when(() => repository.getMyChat())
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase();

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('Expected failure'),
      );
    });
  });

  // SendMessageUsecase
  group('SendMessageUsecase', () {
    late SendMessageUsecase usecase;

    setUp(() => usecase = SendMessageUsecase(repository: repository));

    test('returns MessageEntity on successful send', () async {
      final message = makeMessage();
      when(() => repository.sendMessage('Hello!'))
          .thenAnswer((_) async => Right(message));

      final result = await usecase('Hello!');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected success'),
        (msg) {
          expect(msg.content, 'Hello!');
          expect(msg.senderRole, 'user');
        },
      );
      verify(() => repository.sendMessage('Hello!')).called(1);
    });

    test('returns ApiFailure with 400 when content is empty', () async {
      const failure = ApiFailure(message: 'Message cannot be empty', statusCode: 400);
      when(() => repository.sendMessage(''))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase('');

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f.message, 'Message cannot be empty'),
        (_) => fail('Expected failure'),
      );
    });

    test('returns NetworkFailure when offline', () async {
      const failure = NetworkFailure();
      when(() => repository.sendMessage('Hello!'))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase('Hello!');

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('Expected failure'),
      );
    });

    test('passes correct content string to repository', () async {
      final message = makeMessage(id: 'msg-2');
      when(() => repository.sendMessage('Specific message'))
          .thenAnswer((_) async => Right(message));

      await usecase('Specific message');

      verify(() => repository.sendMessage('Specific message')).called(1);
      verifyNever(() => repository.sendMessage('Hello!'));
    });
  });

  // MarkAsReadUsecase
  group('MarkAsReadUsecase', () {
    late MarkAsReadUsecase usecase;

    setUp(() => usecase = MarkAsReadUsecase(repository: repository));

    test('returns true when messages marked as read successfully', () async {
      when(() => repository.markAsRead('chat-1'))
          .thenAnswer((_) async => const Right(true));

      final result = await usecase('chat-1');

      expect(result, const Right<Failure, bool>(true));
      verify(() => repository.markAsRead('chat-1')).called(1);
    });

    test('returns ApiFailure when chat not found', () async {
      const failure = ApiFailure(message: 'Chat not found', statusCode: 404);
      when(() => repository.markAsRead('bad-id'))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase('bad-id');

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect((f as ApiFailure).statusCode, 404),
        (_) => fail('Expected failure'),
      );
    });

    test('returns NetworkFailure when offline', () async {
      const failure = NetworkFailure();
      when(() => repository.markAsRead('chat-1'))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase('chat-1');

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('Expected failure'),
      );
    });

    test('passes correct chatId to repository', () async {
      when(() => repository.markAsRead('specific-chat-id'))
          .thenAnswer((_) async => const Right(true));

      await usecase('specific-chat-id');

      verify(() => repository.markAsRead('specific-chat-id')).called(1);
      verifyNever(() => repository.markAsRead('chat-1'));
    });
  });

  // GetCachedMessagesUsecase
  group('GetCachedMessagesUsecase', () {
    late GetCachedMessagesUsecase usecase;

    setUp(() => usecase = GetCachedMessagesUsecase(repository: repository));

    test('returns cached messages on success', () async {
      final messages = [makeMessage(id: 'msg-1'), makeMessage(id: 'msg-2')];
      when(() => repository.getCachedMessages())
          .thenAnswer((_) async => Right(messages));

      final result = await usecase();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected success'),
        (msgs) => expect(msgs.length, 2),
      );
      verify(() => repository.getCachedMessages()).called(1);
    });

    test('returns empty list when no cached messages exist', () async {
      when(() => repository.getCachedMessages())
          .thenAnswer((_) async => const Right([]));

      final result = await usecase();

      expect(result, const Right<Failure, List<MessageEntity>>([]));
    });

    test('returns LocalDatabaseFailure when cache read fails', () async {
      const failure = LocalDatabaseFailure();
      when(() => repository.getCachedMessages())
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase();

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<LocalDatabaseFailure>()),
        (_) => fail('Expected failure'),
      );
    });

    test('returns NetworkFailure when offline and no cache', () async {
      const failure = NetworkFailure();
      when(() => repository.getCachedMessages())
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase();

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('Expected failure'),
      );
    });
  });
}