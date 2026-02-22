import 'package:adoptnest/core/error/failures.dart';
import 'package:adoptnest/core/usecases/app_usecase.dart';
import 'package:adoptnest/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:adoptnest/features/chat/domain/entities/chat_entity.dart';
import 'package:adoptnest/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// =================== Get My Chat ===================
final getMyChatUsecaseProvider = Provider<GetMyChatUsecase>((ref) {
  return GetMyChatUsecase(repository: ref.read(chatRepositoryProvider));
});

class GetMyChatUsecase implements UsecaseWithoutParams<Map<String, dynamic>> {
  final IChatRepository _repository;
  GetMyChatUsecase({required IChatRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call() =>
      _repository.getMyChat();
}

// =================== Send Message ===================
final sendMessageUsecaseProvider = Provider<SendMessageUsecase>((ref) {
  return SendMessageUsecase(repository: ref.read(chatRepositoryProvider));
});

class SendMessageUsecase implements UsecaseWithParams<MessageEntity, String> {
  final IChatRepository _repository;
  SendMessageUsecase({required IChatRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, MessageEntity>> call(String content) =>
      _repository.sendMessage(content);
}

// =================== Mark As Read ===================
final markAsReadUsecaseProvider = Provider<MarkAsReadUsecase>((ref) {
  return MarkAsReadUsecase(repository: ref.read(chatRepositoryProvider));
});

class MarkAsReadUsecase implements UsecaseWithParams<bool, String> {
  final IChatRepository _repository;
  MarkAsReadUsecase({required IChatRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(String chatId) =>
      _repository.markAsRead(chatId);
}

// =================== Get Cached Messages (offline) ===================
final getCachedMessagesUsecaseProvider =
    Provider<GetCachedMessagesUsecase>((ref) {
  return GetCachedMessagesUsecase(repository: ref.read(chatRepositoryProvider));
});

class GetCachedMessagesUsecase
    implements UsecaseWithoutParams<List<MessageEntity>> {
  final IChatRepository _repository;
  GetCachedMessagesUsecase({required IChatRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<MessageEntity>>> call() =>
      _repository.getCachedMessages();
}
