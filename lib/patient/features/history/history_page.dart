import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/core/models/report_model.dart';
import 'package:grad_project/core/services/report_service.dart';
import 'package:grad_project/shared/widgets/responsive_layout.dart';
import './data/measurement_model.dart';
import './presentation/pages/report_detail_page.dart';
import './presentation/widgets/history_summary_cards.dart';
import './presentation/widgets/history_list_item.dart';
import './presentation/pages/measurement_details_page.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: ValueListenableBuilder<List<MeasurementRecord>>(
          valueListenable: MeasurementStore.records,
          builder: (context, records, _) {
            final filteredRecords = _getFilteredRecords(records);

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ────────────────────────────────────────────
                  const Text(
                    "History",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "View all your readings, visits and medical reports",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Summary cards (hide on Reports tab) ───────────────
                  if (_selectedFilterIndex != 3) ...[
                    ResponsiveLayout(
                      mobile: HistorySummaryCards(
                        readingsCount: records.length,
                        visitsCount: 3,
                        thisWeekCount: 7,
                      ),
                      tablet: Row(
                        children: [
                          Expanded(
                            child: HistorySummaryCards(
                              readingsCount: records.length,
                              visitsCount: 3,
                              thisWeekCount: 7,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Filter tabs ───────────────────────────────────────
                  _HistoryFilterTabsWithReports(
                    selectedIndex: _selectedFilterIndex,
                    onTabChanged: _onTabChanged,
                  ),
                  const SizedBox(height: 20),

                  // ── Content ───────────────────────────────────────────
                  Expanded(
                    child: _selectedFilterIndex == 3
                        ? _buildReportsTab()
                        : filteredRecords.isEmpty
                            ? _buildEmptyState()
                            : ResponsiveLayout(
                                mobile: _buildListView(filteredRecords),
                                tablet: _buildGridView(filteredRecords, 2),
                                desktop: _buildGridView(filteredRecords, 3),
                              ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Reports tab ───────────────────────────────────────────────────────────

  Widget _buildReportsTab() {
    if (_isReportsLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.skyBlue),
      );
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

    return RefreshIndicator(
      onRefresh: _loadReports,
      color: AppColors.skyBlue,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: _reports.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final report = _reports[index];
          return _ReportCard(
            report: report,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReportDetailPage(report: report),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Measurement list/grid ─────────────────────────────────────────────────

  Widget _buildListView(List<MeasurementRecord> filteredRecords) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: filteredRecords.length,
      padding: const EdgeInsets.only(bottom: 20),
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final record = filteredRecords[index];
        return HistoryListItem(
          record: record,
          onTap: () => _navigateToDetails(context, record),
        );
      },
    );
  }

  Widget _buildGridView(
    List<MeasurementRecord> filteredRecords,
    int crossAxisCount,
  ) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3.5,
      ),
      itemCount: filteredRecords.length,
      itemBuilder: (context, index) {
        final record = filteredRecords[index];
        return HistoryListItem(
          record: record,
          onTap: () => _navigateToDetails(context, record),
        );
      },
    );
  }

  void _navigateToDetails(BuildContext context, MeasurementRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MeasurementDetailsPage(record: record)),
    );
  }

  List<MeasurementRecord> _getFilteredRecords(
      List<MeasurementRecord> records) {
    if (_selectedFilterIndex == 0) return records;
    if (_selectedFilterIndex == 1) return records;
    if (_selectedFilterIndex == 2) return [];
    return records;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No data found",
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
