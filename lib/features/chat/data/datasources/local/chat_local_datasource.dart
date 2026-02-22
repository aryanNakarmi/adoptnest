import 'package:adoptnest/core/constants/hive_table_constant.dart';
import 'package:adoptnest/core/services/hive/hive_service.dart';
import 'package:adoptnest/features/chat/data/datasources/chat_datasource.dart';
import 'package:adoptnest/features/chat/data/models/chat_hive_model.dart';
import 'package:adoptnest/features/chat/data/models/message_hive_model.dart';
import 'package:adoptnest/features/chat/domain/entities/chat_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatLocalDatasourceProvider = Provider<ChatLocalDatasource>((ref) {
  return ChatLocalDatasource(hiveService: ref.read(hiveServiceProvider));
});

class ChatLocalDatasource implements IChatLocalDataSource {
  final HiveService _hiveService;

  ChatLocalDatasource({required HiveService hiveService})
      : _hiveService = hiveService;

  @override
  Future<List<MessageEntity>> getCachedMessages(String chatId) async {
    return _hiveService.getCachedMessages(chatId);
  }

  @override
  Future<void> cacheMessages(
      String chatId, List<MessageEntity> messages) async {
    await _hiveService.cacheMessages(chatId, messages);
  }

  @override
  Future<void> cacheChat(ChatEntity chat) async {
    await _hiveService.cacheChat(chat);
  }

  @override
  Future<ChatEntity?> getCachedChat() async {
    return _hiveService.getCachedChat();
  }

  @override
  Future<void> clearCache() async {
    await _hiveService.clearChatCache();
  }
}
