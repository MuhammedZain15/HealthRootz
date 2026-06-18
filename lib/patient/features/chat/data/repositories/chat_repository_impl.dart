// lib/patient/features/chat/data/repositories/chat_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:grad_project/patient/features/chat/chat_model.dart';
import 'package:grad_project/patient/features/chat/data/datasources/chat_firestore_data_source.dart';
import 'package:grad_project/patient/features/chat/data/utils/chat_doctor_id.dart';
import 'package:grad_project/patient/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._firestoreDataSource);

  final ChatFirestoreDataSource _firestoreDataSource;

  @override
  Future<Either<Failure, String>> resolveDoctorId(String patientId) async {
    try {
      final doctorId = await _firestoreDataSource.resolveDoctorId(patientId);
      if (!isResolvableDoctorId(doctorId)) {
        return const Left(Failure(kDoctorAssignmentMissingMessage));
      }
      return Right(doctorId!);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

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
 