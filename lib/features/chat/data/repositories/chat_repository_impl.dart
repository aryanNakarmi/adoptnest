import 'package:adoptnest/core/error/failures.dart';
import 'package:adoptnest/core/services/connectivity/network_info.dart';
import 'package:adoptnest/features/chat/data/datasources/local/chat_local_datasource.dart';
import 'package:adoptnest/features/chat/data/datasources/remote/chat_remote_datasource.dart';
import 'package:adoptnest/features/chat/domain/entities/chat_entity.dart';
import 'package:adoptnest/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRepositoryProvider = Provider<IChatRepository>((ref) {
  return ChatRepositoryImpl(
    remoteDatasource: ref.read(chatRemoteDatasourceProvider),
    localDatasource: ref.read(chatLocalDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class ChatRepositoryImpl implements IChatRepository {
  final ChatRemoteDatasource _remoteDatasource;
  final ChatLocalDatasource _localDatasource;
  final NetworkInfo _networkInfo;

  ChatRepositoryImpl({
    required ChatRemoteDatasource remoteDatasource,
    required ChatLocalDatasource localDatasource,
    required NetworkInfo networkInfo,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMyChat() async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.getMyChat();

        // Cache chat and messages for offline use
        final chat = result['chat'] as ChatEntity;
        final messages = result['messages'] as List<MessageEntity>;
        await _localDatasource.cacheChat(chat);
        await _localDatasource.cacheMessages(chat.id, messages);

        return Right(result);
      } on DioException catch (e) {
        return Left(ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to load chat',
          statusCode: e.response?.statusCode,
        ));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      // Offline — return cached data
      try {
        final chat = await _localDatasource.getCachedChat();
        if (chat == null) {
          return const Left(
            LocalDatabaseFailure(message: 'No cached chat available'),
          );
        }
        final messages =
            await _localDatasource.getCachedMessages(chat.id);
        return Right({
          'chat': chat,
          'messages': messages,
          'unreadCount': 0,
        });
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage(String content) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection. Cannot send message.'),
      );
    }
    try {
      final message = await _remoteDatasource.sendMessage(content);
      return Right(message);
    } on DioException catch (e) {
      return Left(ApiFailure(
        message: e.response?.data['message'] ?? 'Failed to send message',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> markAsRead(String chatId) async {
    try {
      await _remoteDatasource.markAsRead(chatId);
      return const Right(true);
    } catch (_) {
      return const Right(true); // silently fail
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getCachedMessages() async {
    try {
      final chat = await _localDatasource.getCachedChat();
      if (chat == null) return const Right([]);
      final messages =
          await _localDatasource.getCachedMessages(chat.id);
      return Right(messages);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
