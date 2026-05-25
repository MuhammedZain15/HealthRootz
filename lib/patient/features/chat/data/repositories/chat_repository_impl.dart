// lib/patient/features/chat/data/repositories/chat_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:grad_project/patient/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:grad_project/patient/features/chat/domain/repositories/chat_repository.dart';
import 'package:grad_project/patient/features/chat/chat_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._remoteDataSource);

  final ChatRemoteDataSource _remoteDataSource;

  static String _dioMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return e.message ?? fallback;
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(String patientId) async {
    try {
      final messages = await _remoteDataSource.getMessages(patientId);
      return Right(messages);
    } on DioException catch (e) {
      return Left(Failure(_dioMessage(e, 'Failed to load messages.')));
    } catch (_) {
      return const Left(Failure('Failed to load messages.'));
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String patientId,
    required String text,
  }) async {
    try {
      final message = await _remoteDataSource.sendMessage(
        patientId: patientId,
        text: text,
      );
      return Right(message);
    } on DioException catch (e) {
      return Left(Failure(_dioMessage(e, 'Failed to send message.')));
    } catch (_) {
      return const Left(Failure('Failed to send message.'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String messageId) async {
    try {
      await _remoteDataSource.markAsRead(messageId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(Failure(_dioMessage(e, 'Failed to mark message as read.')));
    } catch (_) {
      return const Left(Failure('Failed to mark message as read.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMessage(String messageId) async {
    try {
      await _remoteDataSource.deleteMessage(messageId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(Failure(_dioMessage(e, 'Failed to delete message.')));
    } catch (_) {
      return const Left(Failure('Failed to delete message.'));
    }
  }
}
