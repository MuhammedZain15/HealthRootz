// lib/doctor/features/chat/domain/usecases/send_message_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:grad_project/doctor/features/chat/domain/repositories/chat_repository.dart';
import 'package:grad_project/doctor/features/chat/models/chat_model.dart';

class SendMessageUseCase {
  const SendMessageUseCase(this._repository);

  final ChatRepository _repository;

  Future<Either<Failure, ChatMessage>> call({
    required String patientId,
    required String text,
  }) {
    return _repository.sendMessage(patientId: patientId, text: text);
  }
}
