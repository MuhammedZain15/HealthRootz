// lib/doctor/features/chat/domain/usecases/watch_chat_list_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:grad_project/doctor/features/chat/domain/repositories/chat_repository.dart';
import 'package:grad_project/doctor/features/chat/models/chat_model.dart';

class WatchChatListUseCase {
  const WatchChatListUseCase(this._repository);

  final ChatRepository _repository;

  Stream<Either<Failure, List<ChatUser>>> call({
    required String doctorId,
    required Future<List<Map<String, dynamic>>> Function() fetchPatients,
  }) {
    return _repository.watchChatList(
      doctorId: doctorId,
      fetchPatients: fetchPatients,
    );
  }
}
