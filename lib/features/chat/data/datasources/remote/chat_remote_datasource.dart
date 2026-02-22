import 'package:adoptnest/core/api/api_client.dart';
import 'package:adoptnest/core/api/api_endpoints.dart';
import 'package:adoptnest/features/chat/data/datasources/chat_datasource.dart';
import 'package:adoptnest/features/chat/data/models/chat_api_model.dart';
import 'package:adoptnest/features/chat/domain/entities/chat_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRemoteDatasourceProvider = Provider<ChatRemoteDatasource>((ref) {
  return ChatRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class ChatRemoteDatasource implements IChatRemoteDataSource {
  final ApiClient _apiClient;

  ChatRemoteDatasource({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<Map<String, dynamic>> getMyChat() async {
    final response = 
    await _apiClient.get(ApiEndpoints.myChat);
    final data = response.data['data'];

    final chat = ChatApiModel.fromJson(
      Map<String, dynamic>.from(data['chat']),
    ).toEntity();

    final messages = (data['messages'] as List)
        .map((m) => MessageApiModel.fromJson(
              Map<String, dynamic>.from(m),
            ).toEntity())
        .toList();

    final unreadCount = data['unreadCount'] ?? 0;

    return {
      'chat': chat,
      'messages': messages,
      'unreadCount': unreadCount,
    };
  }

  @override
  Future<MessageEntity> sendMessage(String content) async {
    final response = await _apiClient.post(ApiEndpoints.sendUserMessage,
    data: {'content': content},
    ); 
    
    return MessageApiModel.fromJson(
      Map<String, dynamic>.from(response.data['data']),
    ).toEntity();
  }

  @override
  Future<bool> markAsRead(String chatId) async {
    await _apiClient.put(ApiEndpoints.markChatAsRead(chatId));
    return true;
  }
}
