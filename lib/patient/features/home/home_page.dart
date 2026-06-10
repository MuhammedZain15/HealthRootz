import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';

import 'package:grad_project/patient/features/patient/viewmodel/patient_cubit.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_state.dart';
import 'package:grad_project/shared/widgets/responsive_layout.dart';

import 'package:grad_project/core/services/device_service.dart';
import 'package:grad_project/core/models/vital_model.dart';
import 'package:grad_project/patient/features/history/cubit/patient_vitals_cubit.dart';
import 'package:grad_project/patient/features/history/cubit/patient_vitals_state.dart';
import 'package:grad_project/patient/features/home/home_components.dart';
import 'package:grad_project/patient/features/home/widgets.dart';
import 'package:grad_project/patient/features/patient/utils/patient_auth_redirect.dart';

/// Display strings derived from the latest vitals (single source of truth =
/// the shared [PatientVitalsCubit]).
class _VitalsDisplay {
  final String oxygenValue;
  final String oxygenStatus;
  final String oxygenTime;
  final String heartRateValue;
  final String heartRateStatus;
  final String heartRateTime;
  final String emgActivity;
  final String emgStatus;
  final String emgTime;

  const _VitalsDisplay({
    required this.oxygenValue,
    required this.oxygenStatus,
    required this.oxygenTime,
    required this.heartRateValue,
    required this.heartRateStatus,
    required this.heartRateTime,
    required this.emgActivity,
    required this.emgStatus,
    required this.emgTime,
  });
}

class HomePage extends StatefulWidget {
  final VoidCallback? onNavigateToAlerts;

  const HomePage({super.key, this.onNavigateToAlerts});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _formatTime(String? createdAt) {
    if (createdAt == null) return '--';
    try {
      return TimeOfDay.fromDateTime(DateTime.parse(createdAt)).format(context);
    } catch (_) {
      return createdAt;
    }
  }

  /// Pure mapping from the cubit's vitals list to display strings.
  /// No network call, no filter — the list comes straight from the cubit
  /// (already sorted newest-first), so Home and History show the same data.
  _VitalsDisplay _computeDisplay(List<VitalModel> vitals) {
    // Readings arrive as SEPARATE records (one may have only heartRate,
    // another only oxygenLevel, sometimes oxygenLevel: 0 as a placeholder).
    // So pick each vital's most recent VALID reading independently rather
    // than reading them all off a single "latest" record.
    VitalModel? hr;
    VitalModel? ox;
    for (final v in vitals) {
      // vitals is sorted newest-first, so the first match is the latest.
      if (hr == null && v.heartRate != null) hr = v;
      // 0 means "no SpO2 captured in this record" — keep looking.
      if (ox == null && v.oxygenLevel != null && v.oxygenLevel != 0) ox = v;
      if (hr != null && ox != null) break;
    }

    final oxLevel = ox?.oxygenLevel;
    final hrVal = hr?.heartRate;

    return _VitalsDisplay(
      oxygenValue: oxLevel != null ? '$oxLevel%' : '--%',
      oxygenStatus: oxLevel != null
          ? (oxLevel >= 95 ? 'Healthy range' : 'Needs attention')
          : 'No data',
      oxygenTime: ox != null ? _formatTime(ox.createdAt) : '--',
      heartRateValue: hrVal != null ? '$hrVal bpm' : '-- bpm',
      heartRateStatus: hrVal != null
          ? ((hrVal >= 60 && hrVal <= 100) ? 'Resting' : 'Elevated')
          : 'No data',
      heartRateTime: hr != null ? _formatTime(hr.createdAt) : '--',
      emgActivity: 'Normal',
      emgStatus: 'Stable',
      emgTime: hr != null ? _formatTime(hr.createdAt) : '--',
    );
  }

  Future<void> _startMeasurement() async {
    final patientState = context.read<PatientCubit>().state;
    final patientId = patientState is PatientLoaded
        ? patientState.patient.id
        : null;
    final code = (Random().nextInt(900000) + 100000).toString();
    final deviceId = patientId ?? '6a26e7c80115b7ebce33d2f4';

    debugPrint(
      '[Home.measure] START patientId=$patientId deviceId=$deviceId code=$code',
    );

    // ONE start call with the real patient ID — the backend records all
    // vitals (heartRate AND oxygenLevel) under this single patient session.
    // (The old second call to 'oximeter-0001' was wrong: that string isn't a
    // patient ObjectId, so the backend 500'd and SpO2 never got recorded.)
    final startResp = await DeviceService.instance.startDevice(
      deviceId,
      patientId: patientId,
      code: code,
    );
    debugPrint(
      '[Home.measure] startDevice($deviceId) success=${startResp.success} '
      'msg=${startResp.message}',
    );

    if (!mounted) return;
    if (!startResp.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to start device: ${startResp.message ?? 'unknown'}',
          ),
        ),
      );
      return;
    }

    if (!mounted) return;

    // Show countdown loading dialog (10s)
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => MeasurementCountdownDialog(
        onComplete: () async {},
      ),
    );

    if (!mounted) return;

    // Give the backend a moment to persist the new readings.
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Reload the SHARED cubit so both Home and History update. Retry a few
    // times in case the backend hasn't finished saving yet.
    final vitalsCubit = context.read<PatientVitalsCubit>();
    for (int i = 0; i < 3; i++) {
      debugPrint('[Home.measure] reload attempt ${i + 1}/3');
      await vitalsCubit.loadVitals();
      if (!mounted) return;
      final st = vitalsCubit.state;
      if (st is PatientVitalsLoaded && st.vitals.isNotEmpty) {
        debugPrint('[Home.measure] got ${st.vitals.length} vitals, stop retry');
        break;
      }
      await Future.delayed(const Duration(seconds: 2));
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Measurement completed. Vitals updated!')),
    );
  }

  /// Pull-to-refresh: genuinely re-fetches via the shared cubit (which both
  /// Home and History are bound to).
  Future<void> _onRefresh() async {
    debugPrint('[Home.refresh] pull-to-refresh -> loadVitals()');
    await context.read<PatientVitalsCubit>().loadVitals();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PatientCubit, PatientState>(
      listener: (context, state) {
        PatientAuthRedirect.handlePatientError(context, state);
        if (state is PatientLoaded) {
          // Patient identity resolved — refresh the shared vitals.
          context.read<PatientVitalsCubit>().loadVitals();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            color: Theme.of(context).colorScheme.primary,
            child: BlocBuilder<PatientVitalsCubit, PatientVitalsState>(
              builder: (context, vitalsState) {
                final vitals = vitalsState is PatientVitalsLoaded
                    ? vitalsState.vitals
                    : <VitalModel>[];
                final d = _computeDisplay(vitals);
                debugPrint(
                  '[Home.build] state=${vitalsState.runtimeType} '
                  'count=${vitals.length} hr=${d.heartRateValue} '
                  'spo2=${d.oxygenValue}',
                );
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: ResponsiveLayout(
                    mobile: _buildMobileLayout(context, d),
                    tablet: _buildTabletDesktopLayout(context, d),
                    desktop: _buildTabletDesktopLayout(context, d),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => const HomeHeader();

  Widget _buildReadings(BuildContext context, _VitalsDisplay d) {
    return ReadingsSection(
      emgActivity: d.emgActivity,
      emgStatus: d.emgStatus,
      oxygenValue: d.oxygenValue,
      oxygenStatus: d.oxygenStatus,
      heartRateValue: d.heartRateValue,
      heartRateStatus: d.heartRateStatus,
      onStartMeasurement: _startMeasurement,
    );
  }

  Widget _buildQuickActions(BuildContext context, {int crossAxisCount = 2}) =>
      QuickActionsSection(onNavigateToAlerts: widget.onNavigateToAlerts);

  Widget _buildRecentMeasurements(BuildContext context, _VitalsDisplay d) =>
      RecentMeasurementsSection(
        heartRateValue: d.heartRateValue,
        heartRateTime: d.heartRateTime,
        emgValue: d.emgActivity,
        emgTime: d.emgTime,
        oxygenValue: d.oxygenValue,
        oxygenTime: d.oxygenTime,
      );

  Widget _buildMobileLayout(BuildContext context, _VitalsDisplay d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _buildHeader(),
        const SizedBox(height: 32),
        _buildReadings(context, d),
        const SizedBox(height: 32),
        _buildQuickActions(context),
        const SizedBox(height: 32),
        _buildRecentMeasurements(context, d),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTabletDesktopLayout(BuildContext context, _VitalsDisplay d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _buildHeader(),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  _buildReadings(context, d),
                  const SizedBox(height: 32),
                  _buildRecentMeasurements(context, d),
                ],
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              flex: 2,
              child: _buildQuickActions(context, crossAxisCount: 1),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
