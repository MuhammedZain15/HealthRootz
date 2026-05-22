import 'doctor_appointment_item.dart';

class DoctorAppointmentsListModel {
  final List<DoctorAppointmentItem> appointments;
  final int selectedFilterIndex;
  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;
  final String? successMessage;

  const DoctorAppointmentsListModel({
    this.appointments = const [],
    this.selectedFilterIndex = 0,
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
    this.successMessage,
  });

  factory DoctorAppointmentsListModel.initial() {
    return const DoctorAppointmentsListModel();
  }

  DoctorAppointmentsListModel copyWith({
    List<DoctorAppointmentItem>? appointments,
    int? selectedFilterIndex,
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return DoctorAppointmentsListModel(
      appointments: appointments ?? this.appointments,
      selectedFilterIndex: selectedFilterIndex ?? this.selectedFilterIndex,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  static const List<String> filterKeys = [
    'all',
    'pending',
    'approved',
    'completed',
    'cancelled',
  ];

  List<DoctorAppointmentItem> get filteredAppointments {
    if (selectedFilterIndex == 0) return appointments;
    final key = filterKeys[selectedFilterIndex];
    return appointments
        .where((a) => a.statusKey == key || _statusMatches(a.statusKey, key))
        .toList();
  }

  static bool _statusMatches(String status, String filter) {
    if (filter == 'cancelled') {
      return status == 'cancelled' || status == 'rejected';
    }
    return status == filter;
  }

  List<String> buildFilterLabels() {
    int count(String key) {
      if (key == 'all') return appointments.length;
      return appointments.where((a) => _statusMatches(a.statusKey, key)).length;
    }

    return [
      'All (${count('all')})',
      'Pending (${count('pending')})',
      'Approved (${count('approved')})',
      'Completed (${count('completed')})',
      'Cancelled (${count('cancelled')})',
    ];
  }
}
