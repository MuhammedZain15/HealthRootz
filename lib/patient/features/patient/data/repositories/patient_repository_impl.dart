import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:grad_project/core/network/api_client.dart';
import 'package:grad_project/core/network/api_constants.dart';

import '../models/patient_model.dart';
import '../utils/patient_response_parser.dart';
import 'patient_repository.dart';

/// Concrete implementation of [PatientRepository] using [ApiClient] (Dio).
///
/// Every method follows the same pattern:
///   1. Call the Dio endpoint.
///   2. Unwrap the response envelope.
///   3. Return [Right] on success, [Left] with [ServerFailure] on error.
class PatientRepositoryImpl implements PatientRepository {
  final Dio _dio = ApiClient.instance.dio;

  // ─── GET /patients/me ──────────────────────────────────────────────

  @override
  Future<Either<ServerFailure, PatientModel>> getMe() async {
    try {
      final response = await _dio.get(ApiConstants.patientMe);
      return _parsePatientResponse(
        response.data,
        endpoint: 'GET ${ApiConstants.patientMe}',
      );
    } on DioException catch (e) {
      return Left(ServerFailure(_extractError(e)));
    }
  }

  // ─── GET /patients/ ────────────────────────────────────────────────

  @override
  Future<Either<ServerFailure, List<PatientModel>>> getPatients() async {
    try {
      final response = await _dio.get(ApiConstants.patients);
      final list = _unwrapList(response.data);
      final patients = list
          .whereType<Map>()
          .map((e) => PatientModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return Right(patients);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractError(e)));
    }
  }

  // ─── GET /patients/:id ─────────────────────────────────────────────

  @override
  Future<Either<ServerFailure, PatientModel>> getPatientById(
      String id) async {
    try {
      final response = await _dio.get(ApiConstants.patientById(id));
      return _parsePatientResponse(
        response.data,
        endpoint: 'GET ${ApiConstants.patientById(id)}',
      );
    } on DioException catch (e) {
      return Left(ServerFailure(_extractError(e)));
    }
  }

  // ─── GET /patients/:id/details ─────────────────────────────────────

  @override
  Future<Either<ServerFailure, PatientModel>> getPatientDetails(
      String id) async {
    try {
      final response =
          await _dio.get('${ApiConstants.patientById(id)}/details');
      return _parsePatientResponse(
        response.data,
        endpoint: 'GET ${ApiConstants.patientById(id)}/details',
      );
    } on DioException catch (e) {
      return Left(ServerFailure(_extractError(e)));
    }
  }

  // ─── POST /patients/ ───────────────────────────────────────────────

  @override
  Future<Either<ServerFailure, PatientModel>> createPatient(
      Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(ApiConstants.patients, data: body);
      return _parsePatientResponse(
        response.data,
        endpoint: 'POST ${ApiConstants.patients}',
      );
    } on DioException catch (e) {
      return Left(ServerFailure(_extractError(e)));
    }
  }

  // ─── PUT /patients/:id ─────────────────────────────────────────────

  @override
  Future<Either<ServerFailure, PatientModel>> updatePatient(
      String id, Map<String, dynamic> body) async {
    try {
      final response =
          await _dio.put(ApiConstants.patientById(id), data: body);
      return _parsePatientResponse(
        response.data,
        endpoint: 'PUT ${ApiConstants.patientById(id)}',
      );
    } on DioException catch (e) {
      return Left(ServerFailure(_extractError(e)));
    }
  }

  // ─── POST /patients/:id/notes ──────────────────────────────────────

  @override
  Future<Either<ServerFailure, Unit>> addDoctorNote(
      String id, String text) async {
    try {
      await _dio.post(
        ApiConstants.addNote(id),
        data: {'text': text},
      );
      return const Right(unit);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractError(e)));
    }
  }

  // ─── DELETE /patients/:id ──────────────────────────────────────────

  @override
  Future<Either<ServerFailure, Unit>> deletePatient(String id) async {
    try {
      await _dio.delete(ApiConstants.patientById(id));
      return const Right(unit);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractError(e)));
    }
  }

  // ─── DELETE /patients?confirm=true ─────────────────────────────────

  @override
  Future<Either<ServerFailure, Unit>> deleteAllPatients() async {
    try {
      await _dio.delete(
        ApiConstants.patients,
        queryParameters: {'confirm': 'true'},
      );
      return const Right(unit);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractError(e)));
    }
  }

  // ─── Private Helpers ───────────────────────────────────────────────

  Either<ServerFailure, PatientModel> _parsePatientResponse(
    dynamic body, {
    required String endpoint,
  }) {
    PatientResponseParser.logRawResponse(endpoint, body);

    final patient = PatientModel.tryFromJson(body);
    if (patient != null) {
      return Right(patient);
    }

    if (body is Map) {
      final keys = Map<String, dynamic>.from(body).keys.join(', ');
      return Left(
        ServerFailure(
          'Patient data missing in API response (keys: $keys). '
          'Expected patient fields under data, patient, user, or result.',
        ),
      );
    }

    return const Left(
      ServerFailure('Invalid patient API response format'),
    );
  }

  /// Unwraps a `{ "data": [...] }` envelope or returns the list as-is.
  List<dynamic> _unwrapList(dynamic body) {
    if (body is List) return body;
    if (body is Map) {
      final map = Map<String, dynamic>.from(body);
      if (map['data'] is List) return map['data'] as List;
    }
    return [];
  }

  /// Extracts a human-readable error message from a [DioException].
  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      return data['message']?.toString() ?? e.message ?? 'Unknown error';
    }
    return e.message ?? 'Network error';
  }
}
