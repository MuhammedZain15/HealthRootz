import 'package:flutter/material.dart';
import './data/measurement_model.dart';
import './presentation/widgets/history_summary_cards.dart';
import './presentation/widgets/history_filter_tabs.dart';
import './presentation/widgets/history_list_item.dart';
import './presentation/pages/measurement_details_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _selectedFilterIndex = 0;

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
                    "View all your sensor readings and appointments",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  HistorySummaryCards(
                    readingsCount: records.length,
                    visitsCount: 3, // Mock value
                    thisWeekCount: 7, // Mock value
                  ),
                  const SizedBox(height: 24),
                  HistoryFilterTabs(
                    selectedIndex: _selectedFilterIndex,
                    onTabChanged: (index) {
                      setState(() {
                        _selectedFilterIndex = index;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: filteredRecords.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: filteredRecords.length,
                            padding: const EdgeInsets.only(bottom: 20),
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final record = filteredRecords[index];
                              return HistoryListItem(
                                record: record,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MeasurementDetailsPage(
                                        record: record,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
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

  List<MeasurementRecord> _getFilteredRecords(List<MeasurementRecord> records) {
    if (_selectedFilterIndex == 0) return records; // All
    if (_selectedFilterIndex == 1)
      return records; // Sensors (All mocked as sensors currently)
    if (_selectedFilterIndex == 2) return []; // Visits (Empty mock)
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
