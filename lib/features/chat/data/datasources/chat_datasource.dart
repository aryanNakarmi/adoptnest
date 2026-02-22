import 'package:adoptnest/features/chat/data/models/message_hive_model.dart';
import 'package:adoptnest/features/chat/domain/entities/chat_entity.dart';

abstract interface class IChatLocalDataSource {
  Future<List<MessageEntity>> getCachedMessages(String chatId);
  Future<void> cacheMessages(String chatId, List<MessageEntity> messages);
  Future<void> cacheChat(ChatEntity chat);
  Future<ChatEntity?> getCachedChat();
  Future<void> clearCache();
}

abstract interface class IChatRemoteDataSource {
  Future<Map<String, dynamic>> getMyChat();
  Future<MessageEntity> sendMessage(String content);
  Future<bool> markAsRead(String chatId);
}
