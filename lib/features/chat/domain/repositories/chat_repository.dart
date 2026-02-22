import 'package:adoptnest/core/error/failures.dart';
import 'package:adoptnest/features/chat/domain/entities/chat_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class IChatRepository {
  Future<Either<Failure, Map<String, dynamic>>> getMyChat();
  Future<Either<Failure, MessageEntity>> sendMessage(String content);
  Future<Either<Failure, bool>> markAsRead(String chatId);
  Future<Either<Failure, List<MessageEntity>>> getCachedMessages();
}
