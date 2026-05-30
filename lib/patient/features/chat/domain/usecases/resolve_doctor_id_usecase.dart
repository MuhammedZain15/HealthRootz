// lib/patient/features/chat/domain/usecases/resolve_doctor_id_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:grad_project/patient/features/chat/domain/repositories/chat_repository.dart';

class ResolveDoctorIdUseCase {
  const ResolveDoctorIdUseCase(this._repository);

  final ChatRepository _repository;

  Future<Either<Failure, String>> call(String patientId) {
    return _repository.resolveDoctorId(patientId);
  }
}
