// lib/doctor/features/chat/domain/usecases/delete_message_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:grad_project/doctor/features/chat/domain/repositories/chat_repository.dart';

class DeleteMessageUseCase {
  const DeleteMessageUseCase(this._repository);

  final ChatRepository _repository;

  Future<Either<Failure, void>> call(String messageId) {
    return _repository.deleteMessage(messageId);
  }
}
