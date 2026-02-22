import 'package:adoptnest/features/chat/data/models/chat_api_model.dart';
import 'package:adoptnest/features/chat/domain/entities/chat_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

final chatSocketServiceProvider = Provider<ChatSocketService>((ref) {
  return ChatSocketService();
});

class ChatSocketService {
  IO.Socket? _socket;

  // Change this to match your ApiEndpoints base URL (without /api/v1)
  static const String _socketUrl = 'http://10.0.2.2:5050';
  // Physical device: 'http://192.168.x.x:5050'

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect() async {
    if (_socket?.connected == true) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) return;

    _socket = IO.io(
      _socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setAuth({'token': token})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) => print('✅ Socket connected: ${_socket!.id}'));
    _socket!.onDisconnect((_) => print('❌ Socket disconnected'));
    _socket!.onConnectError((err) => print('⚠️ Socket error: $err'));
  }

  void joinChat(String chatId) => _socket?.emit('join_chat', chatId);
  void leaveChat(String chatId) => _socket?.emit('leave_chat', chatId);
  void emitTyping(String chatId) => _socket?.emit('typing', chatId);
  void emitStopTyping(String chatId) => _socket?.emit('stop_typing', chatId);

  void onNewMessage(void Function(MessageEntity message) callback) {
    _socket?.on('new_message', (data) {
      try {
        final message = MessageApiModel.fromJson(
          Map<String, dynamic>.from(data),
        ).toEntity();
        callback(message);
      } catch (e) {
        print('Error parsing new_message: $e');
      }
    });
  }

  void onMessagesRead(void Function(String chatId) callback) {
    _socket?.on('messages_read', (data) {
      try {
        callback(data['chatId']?.toString() ?? '');
      } catch (e) {
        print('Error parsing messages_read: $e');
      }
    });
  }

  void onAdminTyping(void Function() callback) {
    _socket?.on('user_typing', (_) => callback());
  }

  void onAdminStopTyping(void Function() callback) {
    _socket?.on('user_stop_typing', (_) => callback());
  }

  void removeAllListeners() => _socket?.clearListeners();

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
