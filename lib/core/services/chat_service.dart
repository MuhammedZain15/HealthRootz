import 'package:dio/dio.dart';

import '../models/chat_message_model.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';
import '../network/api_response.dart';

/// Handles Chat endpoints: get messages, send message, mark as read.
class ChatService {
  final Dio _dio = ApiClient.instance.dio;

  // ─── Get Messages ──────────────────────────────────────────────────

  Future<ApiResponse<List<ChatMessageModel>>> getMessages(
      String patientId) async {
    try {
      final response = await _dio.get(ApiConstants.chatMessages(patientId));
      final List data = response.data is List ? response.data : response.data['data'] ?? [];
      final messages =
          data.map((e) => ChatMessageModel.fromJson(e)).toList();
      return ApiResponse(success: true, data: messages);
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  // ─── Send Message ──────────────────────────────────────────────────

  Future<ApiResponse<ChatMessageModel>> sendMessage({
    required String patientId,
    required String doctorId,
    required String sender, // "doctor" or "patient"
    required String text,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.chat,
        data: {
          'patientId': patientId,
          'doctorId': doctorId,
          'sender': sender,
          'text': text,
        },
      );
      return ApiResponse(
        success: true,
        data: ChatMessageModel.fromJson(response.data),
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  // ─── Mark Messages as Read ─────────────────────────────────────────

  Future<ApiResponse<void>> markAsRead(String patientId) async {
    try {
      await _dio.put(ApiConstants.markAsRead(patientId));
      return ApiResponse(success: true);
    } on DioException catch (e) {
      return ApiResponse(success: false, message: _extractError(e));
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────

  String _extractError(DioException e) {
    if (e.response?.data is Map) {
      return (e.response!.data as Map)['message']?.toString() ??
          e.message ??
          'Unknown error';
    }
    return e.message ?? 'Network error';
  }
}
