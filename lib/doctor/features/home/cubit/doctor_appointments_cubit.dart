import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/doctor_appointments_list_model.dart';
import '../view_models/doctor_appointments_view_model.dart';

class DoctorAppointmentsCubit extends Cubit<DoctorAppointmentsListModel> {
  final DoctorAppointmentsViewModel _viewModel = DoctorAppointmentsViewModel();

  DoctorAppointmentsCubit() : super(DoctorAppointmentsListModel.initial());

  Future<void> loadAppointments() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    final (updated, _) = await _viewModel.fetchAppointments(state);
    emit(updated);
  }

  void setFilterIndex(int index) {
    emit(state.copyWith(selectedFilterIndex: index));
  }

  Future<void> approve(String id) async {
    await _update(id, 'approved');
  }

  Future<void> reject(String id) async {
    await _update(id, 'cancelled');
  }

  Future<void> markCompleted(String id) async {
    await _update(id, 'completed');
  }

  Future<void> deleteAppointment(String id) async {
    emit(state.copyWith(isUpdating: true, clearError: true));
    final (updated, _) = await _viewModel.deleteAppointment(state, id);
    emit(updated);
  }

  Future<void> _update(String id, String status) async {
    emit(state.copyWith(isUpdating: true, clearError: true));
    final (updated, _) = await _viewModel.updateStatus(state, id, status);
    emit(updated);
  }

  void clearMessages() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  Future<void> retry() => loadAppointments();
}
