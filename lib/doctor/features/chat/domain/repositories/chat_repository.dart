// lib/doctor/features/chat/domain/repositories/chat_repository.dart
import 'package:dartz/dartz.dart';
import 'package:grad_project/doctor/features/chat/models/chat_model.dart';

class Failure {
  final String message;
  const Failure(this.message);
}

abstract class ChatRepository {
  Stream<Either<Failure, List<ChatMessage>>> watchMessages({
    required String doctorId,
    required String patientId,
  });

  Stream<Either<Failure, List<ChatUser>>> watchChatList({
    required String doctorId,
  });

  Future<Either<Failure, ChatMessage>> sendMessage({
    required String doctorId,
    required String patientId,
    required String senderId,
    required String text,
  });

  Future<Either<Failure, void>> markAsRead({
    required String doctorId,
    required String patientId,
    required String messageId,
  });

  Future<Either<Failure, void>> deleteMessage({
    required String doctorId,
    required String patientId,
    required String messageId,
  });
}
