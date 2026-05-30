// lib/patient/features/chat/domain/usecases/send_message_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:grad_project/patient/features/chat/chat_model.dart';
import 'package:grad_project/patient/features/chat/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  const SendMessageUseCase(this._repository);

  final ChatRepository _repository;

  Future<Either<Failure, ChatMessage>> call({
    required String doctorId,
    required String patientId,
    required String senderId,
    required String text,
  }) {
    return _repository.sendMessage(
      doctorId: doctorId,
      patientId: patientId,
      senderId: senderId,
      text: text,
    );
  }
}
