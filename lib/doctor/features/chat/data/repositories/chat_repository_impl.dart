// lib/doctor/features/chat/data/repositories/chat_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:grad_project/doctor/features/chat/data/datasources/chat_firestore_data_source.dart';
import 'package:grad_project/doctor/features/chat/domain/repositories/chat_repository.dart';
import 'package:grad_project/doctor/features/chat/models/chat_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._firestoreDataSource);

  final ChatFirestoreDataSource _firestoreDataSource;

  @override
  Stream<Either<Failure, List<ChatMessage>>> watchMessages({
    required String doctorId,
    required String patientId,
  }) async* {
    try {
      yield* _firestoreDataSource
          .watchMessages(doctorId: doctorId, patientId: patientId)
          .map(Right.new);
    } catch (e) {
      yield Left(Failure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<ChatUser>>> watchChatList({
    required String doctorId,
    required Future<List<Map<String, dynamic>>> Function() fetchPatients,
  }) async* {
    try {
      yield* _firestoreDataSource
          .watchAllPatients(doctorId: doctorId, fetchPatients: fetchPatients)
          .map(Right.new);
    } catch (e) {
      yield Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String doctorId,
    required String patientId,
    required String senderId,
    required String text,
  }) async {
    try {
      final message = await _firestoreDataSource.sendMessage(
        doctorId: doctorId,
        patientId: patientId,
        senderId: senderId,
        text: text,
      );
      return Right(message);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMediaMessage({
    required String doctorId,
    required String patientId,
    required String senderId,
    required String fileUrl,
    required String fileType,
    required String fileName,
  }) async {
    try {
      final message = await _firestoreDataSource.sendMediaMessage(
        doctorId: doctorId,
        patientId: patientId,
        senderId: senderId,
        fileUrl: fileUrl,
        fileType: fileType,
        fileName: fileName,
      );
      return Right(message);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead({
    required String doctorId,
    required String patientId,
    required String messageId,
  }) async {
    try {
      await _firestoreDataSource.markAsRead(
        doctorId: doctorId,
        patientId: patientId,
        messageId: messageId,
      );
      return const Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMessage({
    required String doctorId,
    required String patientId,
    required String messageId,
  }) async {
    try {
      await _firestoreDataSource.deleteMessage(
        doctorId: doctorId,
        patientId: patientId,
        messageId: messageId,
      );
      return const Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}

// commit update
 