// lib/patient/features/chat/domain/usecases/mark_as_read_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:grad_project/patient/features/chat/domain/repositories/chat_repository.dart';

class MarkAsReadUseCase {
  const MarkAsReadUseCase(this._repository);

  final ChatRepository _repository;

  Future<Either<Failure, void>> call({
    required String doctorId,
    required String patientId,
    required String messageId,
  }) {
    return _repository.markAsRead(
      doctorId: doctorId,
      patientId: patientId,
      messageId: messageId,
    );
  }
}
