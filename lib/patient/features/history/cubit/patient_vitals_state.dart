import 'package:equatable/equatable.dart';
import 'package:grad_project/core/models/vital_model.dart';

abstract class PatientVitalsState extends Equatable {
  const PatientVitalsState();

  @override
  List<Object?> get props => [];
}

class PatientVitalsInitial extends PatientVitalsState {}

class PatientVitalsLoading extends PatientVitalsState {}

class PatientVitalsLoaded extends PatientVitalsState {
  final List<VitalModel> vitals;

  const PatientVitalsLoaded(this.vitals);

  @override
  List<Object?> get props => [vitals];
}

class PatientVitalsError extends PatientVitalsState {
  final String message;

  const PatientVitalsError(this.message);

  @override
  List<Object?> get props => [message];
}

// commit update
 