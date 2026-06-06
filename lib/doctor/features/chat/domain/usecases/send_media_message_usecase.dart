import 'package:dartz/dartz.dart';
import 'package:grad_project/doctor/features/chat/domain/repositories/chat_repository.dart';
import 'package:grad_project/doctor/features/chat/models/chat_model.dart';

class SendMediaMessageUseCase {
  const SendMediaMessageUseCase(this._repository);

  final ChatRepository _repository;

  Future<Either<Failure, ChatMessage>> call({
    required String doctorId,
    required String patientId,
    required String senderId,
    required String fileUrl,
    required String fileType,
    required String fileName,
  }) {
    return _repository.sendMediaMessage(
      doctorId: doctorId,
      patientId: patientId,
      senderId: senderId,
      fileUrl: fileUrl,
      fileType: fileType,
      fileName: fileName,
    );
  }
}
