import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_cubit.dart';
import 'package:grad_project/doctor/features/patients/cubit/doctor_patient_detail_cubit.dart';
import 'package:grad_project/doctor/features/patients/models/doctor_patient_detail_model.dart';
import 'package:grad_project/doctor/features/patients/widgets/doctor_notes_widgets.dart';
import 'package:grad_project/doctor/features/patients/widgets/patient_info_widgets.dart';
import 'package:grad_project/doctor/features/patients/widgets/vital_signs_widgets.dart';
import 'package:grad_project/shared/widgets/custom_button.dart';
import 'package:grad_project/doctor/features/chat/doctor_chat_session.dart';
import 'package:grad_project/doctor/features/chat/models/chat_model.dart';
import 'package:grad_project/doctor/features/chat/views/chat_detail_page.dart';
import 'model/patient_model.dart';
import 'package:grad_project/core/cubit/auth_cubit.dart';
import 'package:grad_project/patient/features/home/appointment/select_date_time_screen.dart';
import 'package:grad_project/patient/features/home/appointment/cubit/patient_booking_cubit.dart';
import 'package:grad_project/patient/features/appointments/cubit/patient_appointments_cubit.dart';

import 'widgets/vital_signs_chart.dart';
import 'package:grad_project/shared/widgets/responsive_layout.dart';

class PatientDetailsPage extends StatefulWidget {
  final String patientId;
  final Patient? preview;

  const PatientDetailsPage({super.key, required this.patientId, this.preview});

  @override
  State<PatientDetailsPage> createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  late final DoctorPatientDetailCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = DoctorPatientDetailCubit(
      patientCubit: context.read<PatientCubit>(),
      patientId: widget.patientId,
      preview: widget.preview,
    );
    Future.microtask(_cubit.loadPatient);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<DoctorPatientDetailCubit, DoctorPatientDetailModel>(
        builder: (context, state) {
          if (state.isLoading && state.patient == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.errorMessage != null && state.patient == null) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _cubit.retry,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final patient = state.patient;
          if (patient == null) {
            return const Scaffold(
              body: Center(child: Text('Patient not found')),
            );
          }

          return _PatientDetailsBody(
            patient: patient,
            isRefreshing: state.isLoading,
            errorMessage: state.errorMessage,
            onRetry: _cubit.retry,
          );
        },
      ),
    );
  }
}

class _PatientDetailsBody extends StatelessWidget {
  final Patient patient;
  final bool isRefreshing;
  final String? errorMessage;
  final VoidCallback onRetry;

  const _PatientDetailsBody({
    required this.patient,
    required this.isRefreshing,
    this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final heartRateData = List<double>.filled(24, patient.heartRate.toDouble());
    final bloodPressureData = List<double>.filled(24, 115.0);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      patient.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isRefreshing)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  GestureDetector(
                    onTap: () => _openPatientChat(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.skyBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.chat_bubble,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (errorMessage != null)
              Material(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: TextStyle(color: Colors.orange.shade900),
                        ),
                      ),
                      TextButton(
                        onPressed: onRetry,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: ResponsiveLayout(
                mobile: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildPatientContent(
                      context,
                      patient,
                      heartRateData,
                      bloodPressureData,
                    ),
                  ),
                ),
                tablet: _buildTabletDesktopLayout(
                  context,
                  patient,
                  heartRateData,
                  bloodPressureData,
                ),
                desktop: _buildTabletDesktopLayout(
                  context,
                  patient,
                  heartRateData,
                  bloodPressureData,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletDesktopLayout(
    BuildContext context,
    Patient patient,
    List<double> heartRateData,
    List<double> bloodPressureData,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PatientHeader(patient: patient),
                    const SizedBox(height: 20),
                    CurrentVitalSignsSection(),
                    const SizedBox(height: 20),
                    const Text(
                      'EMG Sensor Reading',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    EmgReadingCard(value: patient.emgReading),
                    const SizedBox(height: 20),
                    VitalSignsChart(
                      heartRateData: heartRateData,
                      bloodPressureData: bloodPressureData,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PatientInformationSection(patient: patient),
                    const SizedBox(height: 20),
                    const RecentActivitySection(),
                    const SizedBox(height: 20),
                    DoctorNotesSection(patientId: patient.id),
                    const SizedBox(height: 20),
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPatientContent(
    BuildContext context,
    Patient patient,
    List<double> heartRateData,
    List<double> bloodPressureData,
  ) {
    return [
      PatientHeader(patient: patient),
      const SizedBox(height: 20),
      CurrentVitalSignsSection(),
      const SizedBox(height: 20),
      const Text(
        'EMG Sensor Reading',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 12),
      EmgReadingCard(value: patient.emgReading),
      const SizedBox(height: 20),
      VitalSignsChart(
        heartRateData: heartRateData,
        bloodPressureData: bloodPressureData,
      ),
      const SizedBox(height: 20),
      PatientInformationSection(patient: patient),
      const SizedBox(height: 20),
      const RecentActivitySection(),
      const SizedBox(height: 20),
      DoctorNotesSection(patientId: patient.id),
      const SizedBox(height: 20),
      _buildActionButtons(context),
    ];
  }

  void _openPatientChat(BuildContext context) {
    final patientCubit = context.read<PatientCubit>();
    DoctorChatSession.activePatientId = patient.id;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: patientCubit,
          child: ChatDetailPage(
            user: ChatUser(
              id: patient.id,
              name: patient.name,
              lastMessage: '',
              time: '',
            ),
          ),
        ),
      ),
    );
  }

  void _scheduleVisit(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final user = authCubit.state.user;
    final doctorName = user?.name ?? 'Doctor';
    final specialty = user?.specialty ?? 'General';
    final patientCubit = context.read<PatientCubit>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider<PatientBookingCubit>(
              create: (_) => PatientBookingCubit(patientCubit)
                ..initializeDoctor(
                  doctorName: doctorName,
                  specialty: specialty,
                  patientId: patient.id,
                ),
            ),
            BlocProvider.value(value: patientCubit),
            BlocProvider<PatientAppointmentsCubit>(
              create: (_) => PatientAppointmentsCubit(),
            ),
          ],
          child: const SelectDateTimeScreen(),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: "Chat",
            onPressed: () => _openPatientChat(context),
            color: AppColors.skyBlue,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: CustomButton(
            text: "Schedule Visit",
            onPressed: () => _scheduleVisit(context),
            filled: false,
            color: AppColors.skyBlue,
          ),
        ),
      ],
    );
  }
}
