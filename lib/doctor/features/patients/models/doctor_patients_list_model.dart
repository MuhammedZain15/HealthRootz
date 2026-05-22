import '../model/patient_model.dart';

/// State for the doctor patients list screen.
class DoctorPatientsListModel {
  final List<Patient> patients;
  final String searchQuery;
  final String statusFilter;
  final bool isLoading;
  final String? errorMessage;

  const DoctorPatientsListModel({
    this.patients = const [],
    this.searchQuery = '',
    this.statusFilter = 'All',
    this.isLoading = false,
    this.errorMessage,
  });

  factory DoctorPatientsListModel.initial() {
    return const DoctorPatientsListModel();
  }

  DoctorPatientsListModel copyWith({
    List<Patient>? patients,
    String? searchQuery,
    String? statusFilter,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DoctorPatientsListModel(
      patients: patients ?? this.patients,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  List<Patient> get filteredPatients {
    final q = searchQuery.toLowerCase();
    return patients.where((p) {
      final matchQuery =
          p.name.toLowerCase().contains(q) ||
          (p.email?.toLowerCase().contains(q) ?? false);
      final matchStatus =
          statusFilter == 'All' ||
          p.status.toLowerCase() == statusFilter.toLowerCase();
      return matchQuery && matchStatus;
    }).toList();
  }

  bool get isEmpty => !isLoading && patients.isEmpty && errorMessage == null;
}
