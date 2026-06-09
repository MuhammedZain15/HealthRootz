import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';

import 'package:grad_project/patient/features/patient/viewmodel/patient_cubit.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_state.dart';
import 'package:grad_project/shared/widgets/responsive_layout.dart';

import 'package:grad_project/core/services/device_service.dart';
import 'package:grad_project/core/services/vital_service.dart';
import 'package:grad_project/patient/features/home/home_components.dart';
import 'package:grad_project/patient/features/patient/utils/patient_auth_redirect.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onNavigateToAlerts;

  const HomePage({super.key, this.onNavigateToAlerts});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isMeasuringEmg = false;
  bool _isMeasuringOxy = false;

  String _emgValue = '--';
  String _emgTime = '--';
  String _oxValue = '--';
  String _oxTime = '--';

  DateTime? _lastVitalTime;

  @override
  void initState() {
    super.initState();
    _loadLatestVitals();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadLatestVitals() async {
    try {
      final resp = await VitalService().getAllVitals();
      if (resp.success && resp.data != null && resp.data!.isNotEmpty) {
        final vitals = resp.data!;
        vitals.sort((a, b) {
          final aTime = a.createdAt ?? '';
          final bTime = b.createdAt ?? '';
          try {
            return DateTime.parse(bTime).compareTo(DateTime.parse(aTime));
          } catch (_) {
            return 0;
          }
        });
        final latest = vitals.first;
        setState(() {
          _emgValue = latest.heartRate != null
              ? '${latest.heartRate} bpm'
              : '--';
          try {
            _emgTime = latest.createdAt != null
                ? TimeOfDay.fromDateTime(
                    DateTime.parse(latest.createdAt!),
                  ).format(context)
                : '--';
          } catch (_) {
            _emgTime = latest.createdAt ?? '--';
          }
          _oxValue = latest.oxygenLevel != null
              ? '${latest.oxygenLevel} %'
              : _oxValue;
          _oxTime = _emgTime;
          try {
            _lastVitalTime = latest.createdAt != null
                ? DateTime.parse(latest.createdAt!).toUtc()
                : null;
          } catch (_) {
            _lastVitalTime = null;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _startMeasurement(String deviceId, String sensorType) async {
    setState(() {
      if (sensorType == 'emg') _isMeasuringEmg = true;
      if (sensorType == 'oxygen') _isMeasuringOxy = true;
    });

    final patientState = context.read<PatientCubit>().state;
    final patientId = patientState is PatientLoaded
        ? patientState.patient.id
        : null;
    final code = (Random().nextInt(900000) + 100000).toString();

    final startResp = await DeviceService.instance.startDevice(
      deviceId,
      patientId: patientId,
      code: code,
    );
    if (!mounted) return;
    if (!startResp.success) {
      setState(() {
        _isMeasuringEmg = false;
        _isMeasuringOxy = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to start device: ${startResp.message ?? 'unknown'}',
          ),
        ),
      );
      return;
    }

    // Poll for new vitals (max ~20s)
    bool found = false;
    for (int attempt = 0; attempt < 10; attempt++) {
      await Future.delayed(const Duration(seconds: 2));
      try {
        final resp = await VitalService().getAllVitals();
        if (resp.success && resp.data != null && resp.data!.isNotEmpty) {
          final vitals = resp.data!;
          vitals.sort((a, b) {
            final aTime = a.createdAt ?? '';
            final bTime = b.createdAt ?? '';
            try {
              return DateTime.parse(bTime).compareTo(DateTime.parse(aTime));
            } catch (_) {
              return 0;
            }
          });
          final latest = vitals.first;
          DateTime? latestTime;
          try {
            latestTime = latest.createdAt != null
                ? DateTime.parse(latest.createdAt!).toUtc()
                : null;
          } catch (_) {
            latestTime = null;
          }

          final hasNew =
              latestTime != null &&
              (_lastVitalTime == null || latestTime.isAfter(_lastVitalTime!));
          final hasSensorValue =
              (sensorType == 'emg' && latest.heartRate != null) ||
              (sensorType == 'oxygen' && latest.oxygenLevel != null);

          if (hasNew && hasSensorValue) {
            setState(() {
              if (sensorType == 'emg') {
                _emgValue = latest.heartRate != null
                    ? '${latest.heartRate} bpm'
                    : _emgValue;
                try {
                  _emgTime = latest.createdAt != null
                      ? TimeOfDay.fromDateTime(
                          DateTime.parse(latest.createdAt!),
                        ).format(context)
                      : _emgTime;
                } catch (_) {}
              }
              if (sensorType == 'oxygen') {
                _oxValue = latest.oxygenLevel != null
                    ? '${latest.oxygenLevel} %'
                    : _oxValue;
                try {
                  _oxTime = latest.createdAt != null
                      ? TimeOfDay.fromDateTime(
                          DateTime.parse(latest.createdAt!),
                        ).format(context)
                      : _oxTime;
                } catch (_) {}
              }
              _lastVitalTime = latestTime ?? _lastVitalTime;
            });
            found = true;
            break;
          }
        }
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      _isMeasuringEmg = false;
      _isMeasuringOxy = false;
    });

    if (found) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('New reading received')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No new data received')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PatientCubit, PatientState>(
      listener: (context, state) {
        PatientAuthRedirect.handlePatientError(context, state);
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
      emgValue: _emgValue,
      emgTime: _emgTime,
      oxValue: _oxValue,
      oxTime: _oxTime,
      isMeasuringEmg: _isMeasuringEmg,
      isMeasuringOxy: _isMeasuringOxy,
      onStartEmg: () => _startMeasurement('6a26e7c80115b7ebce33d2f4', 'emg'),
      onStartOxy: () => _startMeasurement('oximeter-0001', 'oxygen'),
    );
  }

  Widget _buildQuickActions(BuildContext context, {int crossAxisCount = 2}) =>
      QuickActionsSection(onNavigateToAlerts: widget.onNavigateToAlerts);

  Widget _buildRecentMeasurements(BuildContext context) =>
      RecentMeasurementsSection(
        heartRateValue: _emgValue,
        heartRateTime: _emgTime,
        emgValue: _emgValue,
        emgTime: _emgTime,
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
