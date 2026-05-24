// lib/patient/features/chat/data/datasources/chat_remote_data_source.dart
import 'package:dio/dio.dart';
import 'package:grad_project/core/network/api_client.dart';
import 'package:grad_project/patient/features/chat/chat_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatMessage>> getMessages(String patientId);
  Future<ChatMessage> sendMessage({
    required String patientId,
    required String text,
  });
  Future<void> markAsRead(String messageId);
  Future<void> deleteMessage(String messageId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  ChatRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Map<String, Object?> _toJsonMap(Map<dynamic, dynamic> map) {
    return map.map((key, value) => MapEntry(key.toString(), value));
  }

  @override
  Future<List<ChatMessage>> getMessages(String patientId) async {
    final response = await _dio.get('/messages/$patientId');
    final body = response.data;
    final List<Object?> rawList =
        body is List
            ? body.cast<Object?>()
            : (body is Map && body['data'] is List)
            ? (body['data'] as List).cast<Object?>()
            : <Object?>[];

    return rawList
        .whereType<Map>()
        .map((item) => ChatMessage.fromJson(_toJsonMap(item)))
        .toList(growable: false);
  }

  @override
  Future<ChatMessage> sendMessage({
    required String patientId,
    required String text,
  }) async {
    final response = await _dio.post(
      '/messages',
      data: <String, Object?>{'patientId': patientId, 'text': text},
    );
    final body = response.data;
    if (body is Map && body['data'] is Map) {
      return ChatMessage.fromJson(_toJsonMap(body['data'] as Map));
    }
    if (body is Map) {
      return ChatMessage.fromJson(_toJsonMap(body));
    }
    return ChatMessage(
      text: text,
      isSender: true,
      timestamp: DateTime.now(),
      patientId: patientId,
      isRead: false,
    );
  }

  @override
  Future<void> markAsRead(String messageId) async {
    await _dio.put('/messages/$messageId/read');
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await _dio.delete('/messages/$messageId');
  }
}
