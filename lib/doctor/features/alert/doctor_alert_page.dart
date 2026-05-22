import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/doctor/features/alert/cubit/doctor_alerts_cubit.dart';
import 'package:grad_project/doctor/features/alert/model/alert_model.dart';
import 'package:grad_project/doctor/features/alert/models/doctor_alerts_list_model.dart';
import 'package:grad_project/doctor/features/alert/widgets/alert_card.dart';
import 'package:grad_project/doctor/features/alert/widgets/summary_card.dart';

class DoctorAlertPage extends StatefulWidget {
  const DoctorAlertPage({super.key});

  @override
  State<DoctorAlertPage> createState() => _DoctorAlertPageState();
}

class _DoctorAlertPageState extends State<DoctorAlertPage> {
  late final DoctorAlertsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = DoctorAlertsCubit();
    Future.microtask(_cubit.loadAlerts);
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
      child: BlocConsumer<DoctorAlertsCubit, DoctorAlertsListModel>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
            _cubit.clearMessages();
          }
        },
        builder: (context, state) {
          final list = state.filteredAlerts;
          final filters = state.buildFilterLabels();

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alerts Center',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D1B34),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Monitor all patient alerts and critical events',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        SummaryCard(
                          count: '${state.countBySeverity(AlertSeverity.critical)}',
                          label: 'Critical Alerts',
                          countColor: const Color(0xFFD32F2F),
                          backgroundColor: const Color(0xFFFFF0F0),
                          borderColor: const Color(0xFFFFCCC7),
                        ),
                        const SizedBox(width: 12),
                        SummaryCard(
                          count: '${state.countBySeverity(AlertSeverity.warning)}',
                          label: 'Warning Alerts',
                          countColor: const Color(0xFFF57F17),
                          backgroundColor: const Color(0xFFFFFBE6),
                          borderColor: const Color(0xFFFFE58F),
                        ),
                        const SizedBox(width: 12),
                        SummaryCard(
                          count: '${state.countBySeverity(AlertSeverity.resolved)}',
                          label: 'Resolved',
                          countColor: const Color(0xFF4A628A),
                          backgroundColor: const Color(0xFFF0F5FF),
                          borderColor: const Color(0xFFD6E4FF),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(filters.length, (index) {
                          final selected = state.selectedFilterIndex == index;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(filters[index]),
                              selected: selected,
                              onSelected: state.isLoading
                                  ? null
                                  : (_) => _cubit.setFilterIndex(index),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Showing ${list.length} of ${state.alerts.length} alerts',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (state.errorMessage != null) ...[
                      Text(
                        state.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      TextButton(
                        onPressed: _cubit.retry,
                        child: const Text('Retry'),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Expanded(
                      child: state.isLoading && state.alerts.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : list.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No alerts found',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: _cubit.loadAlerts,
                                  child: ListView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount: list.length,
                                    itemBuilder: (context, index) {
                                      final alert = list[index];
                                      return AlertCard(
                                        alert: alert,
                                        isBusy: state.isUpdating,
                                        onMarkSolved: () =>
                                            _cubit.markResolved(alert.id),
                                      );
                                    },
                                  ),
                                ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
