// lib/patient/features/chat/domain/repositories/chat_repository.dart
import 'package:dartz/dartz.dart';
import 'package:grad_project/patient/features/chat/chat_model.dart';

class Failure {
  final String message;
  const Failure(this.message);
}

abstract class ChatRepository {
  Future<Either<Failure, List<ChatMessage>>> getMessages(String patientId);
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String patientId,
    required String text,
  });
  Future<Either<Failure, void>> markAsRead(String messageId);
  Future<Either<Failure, void>> deleteMessage(String messageId);
}
