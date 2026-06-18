import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/core/services/vital_service.dart';
import 'patient_vitals_state.dart';

class PatientVitalsCubit extends Cubit<PatientVitalsState> {
  final VitalService _vitalService;

  PatientVitalsCubit({VitalService? vitalService})
      : _vitalService = vitalService ?? VitalService(),
        super(PatientVitalsInitial());

  Future<void> loadVitals() async {
    debugPrint('[VitalsCubit] loadVitals() called -> emit Loading');
    emit(PatientVitalsLoading());
    final response = await _vitalService.getAllVitals();
    if (response.success && response.data != null) {
      // Sort vitals by creation date descending
      final vitals = response.data!;
      vitals.sort((a, b) {
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return DateTime.parse(b.createdAt!).compareTo(DateTime.parse(a.createdAt!));
      });
      debugPrint('[VitalsCubit] emit Loaded count=${vitals.length}');
      emit(PatientVitalsLoaded(vitals));
    } else {
      debugPrint('[VitalsCubit] emit Error: ${response.message}');
      emit(PatientVitalsError(response.message ?? 'Failed to load vitals'));
    }
  }
}

// commit update
 