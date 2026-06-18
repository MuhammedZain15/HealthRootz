import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_cubit.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_state.dart';
import '../models/patient_booking_model.dart';
import '../view_models/patient_booking_view_model.dart';

class PatientBookingCubit extends Cubit<PatientBookingModel> {
  final PatientBookingViewModel _viewModel = PatientBookingViewModel();
  final PatientCubit? _patientCubit;

  PatientBookingCubit([this._patientCubit]) : super(PatientBookingModel.initial());

  /// Starts booking without a doctor-selection step (date → slots → reason).
  Future<void> initializeBooking() async {
    final resolvedId =
        _resolvePatientIdFromCubit() ?? await _viewModel.resolvePatientId();
    emit(
      PatientBookingModel.initial().copyWith(
        patientId: resolvedId,
        clearError: true,
      ),
    );
  }

  Future<void> initializeDoctor({
    required String doctorName,
    required String specialty,
    String? patientId,
  }) async {
    final resolvedId = patientId ?? _resolvePatientIdFromCubit() ?? await _viewModel.resolvePatientId();
    emit(
      state.copyWith(
        doctorName: doctorName,
        specialty: specialty,
        patientId: resolvedId,
        clearError: true,
      ),
    );
  }

  Future<void> selectDate(int index) async {
    emit(
      state.copyWith(
        isLoadingSlots: true,
        clearError: true,
        resetSlots: true,
      ),
    );
    final (updated, _) = await _viewModel.loadSlots(state, index);
    emit(updated);
  }

  void selectSlot(int index) {
    emit(state.copyWith(selectedSlotIndex: index));
  }

  void setReason(String reason) {
    emit(state.copyWith(reason: reason));
  }

  Future<bool> confirmBooking() async {
    emit(state.copyWith(isBooking: true, clearError: true));
    final (updated, _) = await _viewModel.createAppointment(state);
    emit(updated);
    return updated.isSuccess;
  }

  String formatSelectedDate() {
    final d = state.selectedDate;
    if (d == null) return '';
    return _viewModel.formatDisplayDate(d);
  }

  String? _resolvePatientIdFromCubit() {
    final patientState = _patientCubit?.state;
    if (patientState is PatientLoaded) {
      return patientState.patient.id;
    }
    return null;
  }
}

// commit update
 