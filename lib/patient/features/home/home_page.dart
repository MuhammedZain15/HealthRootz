import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';

import 'package:grad_project/patient/features/patient/viewmodel/patient_cubit.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_state.dart';
import 'package:grad_project/shared/widgets/responsive_layout.dart';

import 'package:grad_project/core/services/device_service.dart';
import 'package:grad_project/core/services/vital_service.dart';
import 'package:grad_project/core/models/vital_model.dart';
import 'package:grad_project/patient/features/home/home_components.dart';
import 'package:grad_project/patient/features/home/widgets.dart';
import 'package:grad_project/patient/features/patient/utils/patient_auth_redirect.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onNavigateToAlerts;

  const HomePage({super.key, this.onNavigateToAlerts});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _emgActivity = 'Normal';
  String _emgStatus = 'Stable';
  String _emgTime = '--';

  String _oxygenValue = '--';
  String _oxygenStatus = 'Healthy range';
  String _oxygenTime = '--';

  String _heartRateValue = '--';
  String _heartRateStatus = 'Resting';
  String _heartRateTime = '--';

  @override
  void initState() {
    super.initState();
    _loadLatestVitals();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _formatTime(String? createdAt) {
    if (createdAt == null) return '--';
    try {
      return TimeOfDay.fromDateTime(DateTime.parse(createdAt)).format(context);
    } catch (_) {
      return createdAt;
    }
  }

  Future<void> _loadLatestVitals() async {
    try {
      final patientState = context.read<PatientCubit>().state;
      final patientId = patientState is PatientLoaded
          ? patientState.patient.id
          : null;

      final resp = await VitalService().getAllVitals();
      if (resp.success && resp.data != null && resp.data!.isNotEmpty) {
        var vitals = resp.data!;
        
        // Filter by current patient ID to make sure we show this patient's vitals
        if (patientId != null) {
          vitals = vitals.where((v) => v.patientId == patientId).toList();
        }

        if (vitals.isNotEmpty) {
          vitals.sort((a, b) {
            final aTime = a.createdAt ?? '';
            final bTime = b.createdAt ?? '';
            try {
              return DateTime.parse(bTime).compareTo(DateTime.parse(aTime));
            } catch (_) {
              return 0;
            }
          });

          // Find the latest non-null record for each vital sign
          VitalModel? latestHeartRateVital;
          VitalModel? latestOxygenVital;

          for (var v in vitals) {
            if (latestHeartRateVital == null && v.heartRate != null) {
              latestHeartRateVital = v;
            }
            if (latestOxygenVital == null && v.oxygenLevel != null) {
              latestOxygenVital = v;
            }
            if (latestHeartRateVital != null && latestOxygenVital != null) {
              break; // Found all
            }
          }

          setState(() {
            _emgActivity = 'Normal';
            _emgStatus = 'Stable';
            _emgTime = latestHeartRateVital != null ? _formatTime(latestHeartRateVital.createdAt) : '--';

            if (latestOxygenVital != null && latestOxygenVital.oxygenLevel != null) {
              _oxygenValue = '${latestOxygenVital.oxygenLevel}%';
              _oxygenStatus = latestOxygenVital.oxygenLevel! >= 95 ? 'Healthy range' : 'Needs attention';
              _oxygenTime = _formatTime(latestOxygenVital.createdAt);
            } else {
              _oxygenValue = '--%';
              _oxygenStatus = 'No data';
              _oxygenTime = '--';
            }

            if (latestHeartRateVital != null && latestHeartRateVital.heartRate != null) {
              _heartRateValue = '${latestHeartRateVital.heartRate} bpm';
              _heartRateStatus = (latestHeartRateVital.heartRate! >= 60 && latestHeartRateVital.heartRate! <= 100)
                  ? 'Resting'
                  : 'Elevated';
              _heartRateTime = _formatTime(latestHeartRateVital.createdAt);
            } else {
              _heartRateValue = '-- bpm';
              _heartRateStatus = 'No data';
              _heartRateTime = '--';
            }
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _startMeasurement() async {
    final patientState = context.read<PatientCubit>().state;
    final patientId = patientState is PatientLoaded
        ? patientState.patient.id
        : null;
    final code = (Random().nextInt(900000) + 100000).toString();
    final deviceId = patientId ?? '6a26e7c80115b7ebce33d2f4';

    // Start all sensors (EMG/BloodPressure and Oximeter)
    final startResp = await DeviceService.instance.startDevice(
      deviceId,
      patientId: patientId,
      code: code,
    );

    await DeviceService.instance.startDevice(
      'oximeter-0001',
      patientId: patientId,
      code: code,
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

    // Show 25-second countdown loading dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => MeasurementCountdownDialog(
        onComplete: () async {},
      ),
    );

    if (!mounted) return;

    // Wait a bit for the backend to process and save the new readings
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Retry fetching vitals to ensure new data is captured
    for (int i = 0; i < 3; i++) {
      await _loadLatestVitals();
      if (!mounted) return;
      // If we got data, break early
      if (_heartRateValue != '-- bpm' || _oxygenValue != '--%') break;
      await Future.delayed(const Duration(seconds: 2));
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Measurement completed. Vitals updated!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PatientCubit, PatientState>(
      listener: (context, state) {
        PatientAuthRedirect.handlePatientError(context, state);
        if (state is PatientLoaded) {
          _loadLatestVitals();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ResponsiveLayout(
              mobile: _buildMobileLayout(context),
              tablet: _buildTabletDesktopLayout(context),
              desktop: _buildTabletDesktopLayout(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => const HomeHeader();

  // Section title is provided by `SectionTitle` in `home_components.dart`.

  Widget _buildReadings(BuildContext context) {
    return ReadingsSection(
      emgActivity: _emgActivity,
      emgStatus: _emgStatus,
      oxygenValue: _oxygenValue,
      oxygenStatus: _oxygenStatus,
      heartRateValue: _heartRateValue,
      heartRateStatus: _heartRateStatus,
      onStartMeasurement: _startMeasurement,
    );
  }

  Widget _buildQuickActions(BuildContext context, {int crossAxisCount = 2}) =>
      QuickActionsSection(onNavigateToAlerts: widget.onNavigateToAlerts);

  Widget _buildRecentMeasurements(BuildContext context) =>
      RecentMeasurementsSection(
        heartRateValue: _heartRateValue,
        heartRateTime: _heartRateTime,
        emgValue: _emgActivity,
        emgTime: _emgTime,
        oxygenValue: _oxygenValue,
        oxygenTime: _oxygenTime,
      );

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _buildHeader(),
        const SizedBox(height: 32),
        _buildReadings(context),
        const SizedBox(height: 32),
        _buildQuickActions(context),
        const SizedBox(height: 32),
        _buildRecentMeasurements(context),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTabletDesktopLayout(BuildContext context) {
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
                  _buildReadings(context),
                  const SizedBox(height: 32),
                  _buildRecentMeasurements(context),
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
