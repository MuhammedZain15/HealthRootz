// lib/patient/features/chat/domain/usecases/get_messages_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:grad_project/patient/features/chat/domain/repositories/chat_repository.dart';
import 'package:grad_project/patient/features/chat/chat_model.dart';

class GetMessagesUseCase {
  const GetMessagesUseCase(this._repository);

  final ChatRepository _repository;

  Future<Either<Failure, List<ChatMessage>>> call(String patientId) {
    return _repository.getMessages(patientId);
  }
}
