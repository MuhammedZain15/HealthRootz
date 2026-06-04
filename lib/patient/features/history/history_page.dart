import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/core/models/appointment_model.dart';
import 'package:grad_project/patient/features/appointments/cubit/patient_appointments_cubit.dart';
import 'package:grad_project/patient/features/appointments/cubit/patient_appointments_state.dart';
import 'package:grad_project/shared/widgets/responsive_layout.dart';
import './data/measurement_model.dart';
import './presentation/widgets/history_summary_cards.dart';
import './presentation/widgets/history_filter_tabs.dart';
import './presentation/widgets/history_list_item.dart';
import './presentation/widgets/appointment_history_list_item.dart';
import './presentation/pages/measurement_details_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<PatientAppointmentsCubit>().loadAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: ValueListenableBuilder<List<MeasurementRecord>>(
          valueListenable: MeasurementStore.records,
          builder: (context, records, _) {
            return BlocBuilder<PatientAppointmentsCubit, PatientAppointmentsState>(
              builder: (context, appointmentsState) {
                final appointments = appointmentsState is PatientAppointmentsLoaded
                    ? appointmentsState.appointments
                    : <AppointmentModel>[];

                final appointmentsCubit = context.read<PatientAppointmentsCubit>();
                final visitsCount = appointmentsCubit.visitsCount;
                final thisWeekCount = appointmentsCubit.thisWeekCount;

                final isLoadingAppointments =
                    appointmentsState is PatientAppointmentsLoading;
                final appointmentsError = appointmentsState is PatientAppointmentsError
                    ? appointmentsState.message
                    : null;

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'History',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'View all your sensor readings and appointments',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ResponsiveLayout(
                        mobile: HistorySummaryCards(
                          readingsCount: records.length,
                          visitsCount: visitsCount,
                          thisWeekCount: thisWeekCount,
                        ),
                        tablet: Row(
                          children: [
                            Expanded(
                              child: HistorySummaryCards(
                                readingsCount: records.length,
                                visitsCount: visitsCount,
                                thisWeekCount: thisWeekCount,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      HistoryFilterTabs(
                        selectedIndex: _selectedFilterIndex,
                        onTabChanged: (index) {
                          setState(() => _selectedFilterIndex = index);
                        },
                      ),
                      const SizedBox(height: 20),
                      if (isLoadingAppointments &&
                          _selectedFilterIndex != 1 &&
                          appointments.isEmpty)
                        const Expanded(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (appointmentsError != null &&
                          _selectedFilterIndex != 1)
                        Expanded(
                          child: _buildErrorState(
                            appointmentsError,
                            onRetry: () => context
                                .read<PatientAppointmentsCubit>()
                                .loadAppointments(),
                          ),
                        )
                      else
                        Expanded(
                          child: _buildFilteredContent(
                            context,
                            records: records,
                            appointments: appointments,
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilteredContent(
    BuildContext context, {
    required List<MeasurementRecord> records,
    required List<AppointmentModel> appointments,
  }) {
    if (_selectedFilterIndex == 1) {
      if (records.isEmpty) return _buildEmptyState('No sensor readings yet');
      return ResponsiveLayout(
        mobile: _buildSensorListView(records),
        tablet: _buildSensorGridView(records, 2),
        desktop: _buildSensorGridView(records, 3),
      );
    }

    if (_selectedFilterIndex == 2) {
      if (appointments.isEmpty) {
        return _buildEmptyState('No visits yet. Book an appointment from Home.');
      }
      return ResponsiveLayout(
        mobile: _buildAppointmentsListView(appointments),
        tablet: _buildAppointmentsGridView(appointments, 2),
        desktop: _buildAppointmentsGridView(appointments, 3),
      );
    }

    // All: appointments first (API), then sensor readings
    if (appointments.isEmpty && records.isEmpty) {
      return _buildEmptyState('No history yet');
    }

    return ResponsiveLayout(
      mobile: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          ...appointments.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AppointmentHistoryListItem(appointment: a),
            ),
          ),
          ...records.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: HistoryListItem(
                record: r,
                onTap: () => _navigateToDetails(context, r),
              ),
            ),
          ),
        ],
      ),
      tablet: _buildAppointmentsGridView(appointments, 2),
      desktop: _buildAppointmentsGridView(appointments, 3),
    );
  }

  Widget _buildSensorListView(List<MeasurementRecord> records) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: records.length,
      padding: const EdgeInsets.only(bottom: 20),
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final record = records[index];
        return HistoryListItem(
          record: record,
          onTap: () => _navigateToDetails(context, record),
        );
      },
    );
  }

  Widget _buildSensorGridView(List<MeasurementRecord> records, int crossAxisCount) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3.5,
      ),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return HistoryListItem(
          record: record,
          onTap: () => _navigateToDetails(context, record),
        );
      },
    );
  }

  Widget _buildAppointmentsListView(List<AppointmentModel> appointments) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: appointments.length,
      padding: const EdgeInsets.only(bottom: 20),
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return AppointmentHistoryListItem(appointment: appointments[index]);
      },
    );
  }

  Widget _buildAppointmentsGridView(
    List<AppointmentModel> appointments,
    int crossAxisCount,
  ) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.8,
      ),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        return AppointmentHistoryListItem(appointment: appointments[index]);
      },
    );
  }

  void _navigateToDetails(BuildContext context, MeasurementRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MeasurementDetailsPage(record: record)),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, {required VoidCallback onRetry}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red.shade700),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
