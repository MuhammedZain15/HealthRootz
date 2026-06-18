class BookingDateOption {
  final DateTime date;
  final String dayLabel;
  final String dateLabel;

  const BookingDateOption({
    required this.date,
    required this.dayLabel,
    required this.dateLabel,
  });

  String get apiDate => '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

class PatientBookingModel {
  final String? doctorName;
  final String? specialty;
  final String? patientId;
  final List<BookingDateOption> dateOptions;
  final int selectedDateIndex;
  final List<String> availableSlots;
  final int selectedSlotIndex;
  final String reason;
  final bool isLoadingSlots;
  final bool isBooking;
  final bool isSuccess;
  final String? errorMessage;

  const PatientBookingModel({
    this.doctorName,
    this.specialty,
    this.patientId,
    this.dateOptions = const [],
    this.selectedDateIndex = -1,
    this.availableSlots = const [],
    this.selectedSlotIndex = -1,
    this.reason = '',
    this.isLoadingSlots = false,
    this.isBooking = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  factory PatientBookingModel.initial() {
    return PatientBookingModel(
      dateOptions: _generateWeekdays(),
    );
  }

  static List<BookingDateOption> _generateWeekdays() {
    final now = DateTime.now();
    return List.generate(5, (i) {
      final d = now.add(Duration(days: i + 1));
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return BookingDateOption(
        date: DateTime(d.year, d.month, d.day),
        dayLabel: days[d.weekday - 1],
        dateLabel: '${d.day}',
      );
    });
  }

  PatientBookingModel copyWith({
    String? doctorName,
    String? specialty,
    String? patientId,
    List<BookingDateOption>? dateOptions,
    int? selectedDateIndex,
    List<String>? availableSlots,
    int? selectedSlotIndex,
    String? reason,
    bool? isLoadingSlots,
    bool? isBooking,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
    bool resetSlots = false,
  }) {
    return PatientBookingModel(
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      patientId: patientId ?? this.patientId,
      dateOptions: dateOptions ?? this.dateOptions,
      selectedDateIndex: selectedDateIndex ?? this.selectedDateIndex,
      availableSlots: resetSlots ? const [] : (availableSlots ?? this.availableSlots),
      selectedSlotIndex:
          resetSlots ? -1 : (selectedSlotIndex ?? this.selectedSlotIndex),
      reason: reason ?? this.reason,
      isLoadingSlots: isLoadingSlots ?? this.isLoadingSlots,
      isBooking: isBooking ?? this.isBooking,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool get canContinue =>
      selectedDateIndex >= 0 &&
      selectedSlotIndex >= 0 &&
      selectedSlotIndex < availableSlots.length;

  String? get selectedSlotLabel {
    if (selectedSlotIndex < 0 || selectedSlotIndex >= availableSlots.length) {
      return null;
    }
    return availableSlots[selectedSlotIndex];
  }

  BookingDateOption? get selectedDate {
    if (selectedDateIndex < 0 || selectedDateIndex >= dateOptions.length) {
      return null;
    }
    return dateOptions[selectedDateIndex];
  }
}

// commit update
 