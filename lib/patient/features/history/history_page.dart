import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/core/models/appointment_model.dart';
import 'package:grad_project/core/models/vital_model.dart';
import 'package:grad_project/patient/features/appointments/cubit/patient_appointments_cubit.dart';
import 'package:grad_project/patient/features/appointments/cubit/patient_appointments_state.dart';
import 'package:grad_project/patient/features/history/cubit/patient_vitals_cubit.dart';
import 'package:grad_project/patient/features/history/cubit/patient_vitals_state.dart';
import 'package:grad_project/shared/widgets/responsive_layout.dart';
import 'package:intl/intl.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/core/models/report_model.dart';
import 'package:grad_project/core/services/report_service.dart';
import './presentation/pages/report_detail_page.dart';
import './presentation/widgets/history_summary_cards.dart';
import './presentation/widgets/history_list_item.dart';
import './presentation/widgets/appointment_history_list_item.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // 0 = All, 1 = Sensors, 2 = Visits, 3 = Reports
  int _selectedFilterIndex = 0;

  // ── Reports state ─────────────────────────────────────────────────────────
  final ReportService _reportService = ReportService.instance;
  List<ApiReport> _reports = [];
  bool _isReportsLoading = false;
  String? _reportsError;
  bool _reportsFetched = false;
  
  late final PatientVitalsCubit _vitalsCubit;

  // ── Lazy-load reports only when tab is first opened ───────────────────────
  void _onTabChanged(int index) {
    setState(() => _selectedFilterIndex = index);
    if (index == 3 && !_reportsFetched) {
      _loadReports();
    }
  }

  Future<void> _loadReports() async {
    setState(() {
      _isReportsLoading = true;
      _reportsError = null;
    });
    try {
      final reports = await _reportService.getReports();
      if (mounted) {
        setState(() {
          _reports = reports;
          _reportsFetched = true;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _reportsError = e.toString());
    } finally {
      if (mounted) setState(() => _isReportsLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _vitalsCubit = PatientVitalsCubit()..loadVitals();
    context.read<PatientAppointmentsCubit>().loadAppointments();
  }

  @override
  void dispose() {
    _vitalsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: BlocBuilder<PatientVitalsCubit, PatientVitalsState>(
          bloc: _vitalsCubit,
          builder: (context, vitalsState) {
            final vitals = vitalsState is PatientVitalsLoaded ? vitalsState.vitals : <VitalModel>[];
            final isVitalsLoading = vitalsState is PatientVitalsLoading;
            final vitalsError = vitalsState is PatientVitalsError ? vitalsState.message : null;

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
                          readingsCount: vitals.length,
                          visitsCount: visitsCount,
                          thisWeekCount: thisWeekCount,
                        ),
                        tablet: Row(
                          children: [
                            Expanded(
                              child: HistorySummaryCards(
                                readingsCount: vitals.length,
                                visitsCount: visitsCount,
                                thisWeekCount: thisWeekCount,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _HistoryFilterTabsWithReports(
                        selectedIndex: _selectedFilterIndex,
                        onTabChanged: _onTabChanged,
                      ),
                      const SizedBox(height: 20),
                      if ((isLoadingAppointments && _selectedFilterIndex != 1 && appointments.isEmpty) ||
                          (isVitalsLoading && _selectedFilterIndex != 2 && vitals.isEmpty))
                        const Expanded(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (appointmentsError != null && _selectedFilterIndex != 1)
                        Expanded(
                          child: _buildErrorState(
                            appointmentsError,
                            onRetry: () => context.read<PatientAppointmentsCubit>().loadAppointments(),
                          ),
                        )
                      else if (vitalsError != null && _selectedFilterIndex != 2)
                        Expanded(
                          child: _buildErrorState(
                            vitalsError,
                            onRetry: () => _vitalsCubit.loadVitals(),
                          ),
                        )
                      else
                        Expanded(
                          child: _buildFilteredContent(
                            context,
                            vitals: vitals,
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
    required List<VitalModel> vitals,
    required List<AppointmentModel> appointments,
  }) {
    if (_selectedFilterIndex == 1) {
      if (vitals.isEmpty) return _buildEmptyState('No sensor readings yet');
      return ResponsiveLayout(
        mobile: _buildSensorListView(vitals),
        tablet: _buildSensorGridView(vitals, 2),
        desktop: _buildSensorGridView(vitals, 3),
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

    if (_selectedFilterIndex == 3) {
      if (_isReportsLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_reportsError != null) {
        return _ReportsErrorView(
          message: _reportsError!,
          onRetry: _loadReports,
        );
      }
      if (_reports.isEmpty) {
        return _ReportsEmptyView();
      }
      return ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: _reports.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final report = _reports[index];
          return _ReportCard(
            report: report,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReportDetailPage(report: report),
                ),
              );
            },
          );
        },
      );
    }

    // All: appointments first (API), then sensor readings
    if (appointments.isEmpty && vitals.isEmpty) {
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
          ...vitals.map(
            (v) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: HistoryListItem(
                vital: v,
                onTap: () {}, // Detail page removed for snapshot view
              ),
            ),
          ),
        ],
      ),
      tablet: _buildAppointmentsGridView(appointments, 2),
      desktop: _buildAppointmentsGridView(appointments, 3),
    );
  }

  Widget _buildSensorListView(List<VitalModel> vitals) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: vitals.length,
      padding: const EdgeInsets.only(bottom: 20),
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final vital = vitals[index];
        return HistoryListItem(
          vital: vital,
          onTap: () {}, // Detail page removed for snapshot view
        );
      },
    );
  }

  Widget _buildSensorGridView(List<VitalModel> vitals, int crossAxisCount) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.0, // adjusted for the new layout
      ),
      itemCount: vitals.length,
      itemBuilder: (context, index) {
        final vital = vitals[index];
        return HistoryListItem(
          vital: vital,
          onTap: () {},
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

// ── Extended filter tabs (adds "Reports" tab) ─────────────────────────────

class _HistoryFilterTabsWithReports extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChanged;

  const _HistoryFilterTabsWithReports({
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = ['All', 'Sensors', 'Visits', 'Reports'];
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final selected = selectedIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.skyBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.grey[600],
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Report card ───────────────────────────────────────────────────────────

class _ReportCard extends StatelessWidget {
  final ApiReport report;
  final VoidCallback onTap;

  const _ReportCard({required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.description_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 12, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 4),
                      Text(
                        '${df.format(report.startDate)} → ${df.format(report.endDate)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  if (report.aiRecommendation.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'AI recommendation available',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF7C3AED),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}

// ── Empty / Error views ───────────────────────────────────────────────────

class _ReportsEmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.description_outlined,
                size: 36, color: Color(0xFFD1D5DB)),
          ),
          const SizedBox(height: 16),
          const Text(
            'No reports yet',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your doctor will generate reports\nthat appear here.',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ReportsErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ReportsErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_outlined,
              size: 48, color: Color(0xFFD1D5DB)),
          const SizedBox(height: 14),
          const Text(
            'Could not load reports',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.skyBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
