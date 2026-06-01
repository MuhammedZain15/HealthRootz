// lib/doctor/features/chat/domain/usecases/get_messages_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:grad_project/doctor/features/chat/domain/repositories/chat_repository.dart';
import 'package:grad_project/doctor/features/chat/models/chat_model.dart';

class GetMessagesUseCase {
  const GetMessagesUseCase(this._repository);

  final ChatRepository _repository;

  Stream<Either<Failure, List<ChatMessage>>> call({
    required String doctorId,
    required String patientId,
  }) {
    return _repository.watchMessages(doctorId: doctorId, patientId: patientId);
  }
}
