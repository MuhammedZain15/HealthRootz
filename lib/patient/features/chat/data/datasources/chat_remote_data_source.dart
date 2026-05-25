// lib/patient/features/chat/data/datasources/chat_remote_data_source.dart
import 'package:dio/dio.dart';
import 'package:grad_project/core/network/api_constants.dart';
import 'package:grad_project/patient/features/chat/chat_model.dart';
import 'package:grad_project/patient/features/chat/data/datasources/patient_chat_auth.dart';

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
  ChatRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? _createAuthedDio();

  final Dio _dio;

  static Dio _createAuthedDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: const <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await PatientChatAuth.requireToken();
            options.headers['Authorization'] = 'Bearer $token';
            return handler.next(options);
          } on PatientChatAuthException catch (e) {
            return handler.reject(PatientChatAuth.toDioException(e));
          }
        },
      ),
    );

    return dio;
  }

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
    throw DioException(
      requestOptions: response.requestOptions,
      message: 'Invalid send message response.',
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
