import 'package:flutter/material.dart';
import 'package:grad_project/app_colors.dart';

class DoctorNotesScreen extends StatefulWidget {
  const DoctorNotesScreen({super.key});

  @override
  State<DoctorNotesScreen> createState() => _DoctorNotesScreenState();
}

class _DoctorNotesScreenState extends State<DoctorNotesScreen> {
  String _selectedCategory = "All";

  final List<String> _categories = [
    "All",
    "Cardiology",
    "Neurology",
    "General Health",
  ];

  final List<Map<String, dynamic>> _notes = [
    {
      "doctor": "Dr. Sarah Johnson",
      "specialty": "Cardiologist",
      "title": "Heart Rate Monitoring",
      "priority": "High",
      "content":
          "Patient showing elevated heart rate during physical activity. Recommend continuing EMG...",
      "date": "Jan 26, 2025",
      "time": "2:30 PM",
      "category": "Cardiology",
    },
    {
      "doctor": "Dr. Michael Chen",
      "specialty": "Neurologist",
      "title": "EMG Results Review",
      "priority": "Medium",
      "content":
          "Recent EMG readings show improvement in muscle activity patterns. Continue current...",
      "date": "Jan 25, 2025",
      "time": "10:15 AM",
      "category": "Neurology",
    },
    {
      "doctor": "Dr. Emily Rodriguez",
      "specialty": "General Physician",
      "title": "Medication Adjustment",
      "priority": "High",
      "content":
          "Adjusted dosage of current medication. Please take 1 tablet daily with breakfast. Monitor for...",
      "date": "Jan 24, 2025",
      "time": "11:00 AM",
      "category": "General Health",
    },
    {
      "doctor": "Dr. Sarah Johnson",
      "specialty": "Cardiologist",
      "title": "Blood Pressure Check",
      "priority": "Normal",
      "content":
          "Blood pressure readings are within normal range. Continue monitoring daily and maintain...",
      "date": "Jan 22, 2025",
      "time": "3:45 PM",
      "category": "Cardiology",
    },
    {
      "doctor": "Dr. Michael Chen",
      "specialty": "Neurologist",
      "title": "Physical Therapy Recommendation",
      "priority": "Medium",
      "content": "Recommend starting physical therapy sessions...",
      "date": "Jan 20, 2025",
      "time": "09:00 AM",
      "category": "Neurology",
    },
  ];

  List<Map<String, dynamic>> get _filteredNotes {
    if (_selectedCategory == "All") {
      return _notes;
    }
    // Matching category name loosely or strictly depending on needs.
    // Here we map display category to data category if needed,
    // but names match exactly in this case.
    return _notes
        .where((note) => note['category'] == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppColors.skyBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Doctor Notes",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            "${_notes.length} medical notes",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Category Filter
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.skyBlue
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.skyBlue
                                    : const Color(0xFFE2E8F0),
                              ),
                              //  boxShadow: isSelected
                              //      ? [
                              //          BoxShadow(
                              //            color: AppColors.skyBlue.withOpacity(0.3),
                              //            blurRadius: 8,
                              //            offset: const Offset(0, 4),
                              //          )
                              //        ]
                              //      : [],
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Notes List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filteredNotes.length,
                itemBuilder: (context, index) {
                  final note = _filteredNotes[index];
                  return _buildNoteCard(note);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> note) {
    Color badgeColor;
    Color badgeTextColor;
    IconData? badgeIcon;

    switch (note['priority']) {
      case 'High':
        badgeColor = const Color(0xFFFEE2E2); // Light Red
        badgeTextColor = const Color(0xFFDC2626); // Red
        badgeIcon = Icons.error_outline;
        break;
      case 'Medium':
        badgeColor = const Color(0xFFFFEDD5); // Light Orange
        badgeTextColor = const Color(0xFFD97706); // Orange
        badgeIcon = Icons.description_outlined;
        break;
      case 'Normal':
        badgeColor = const Color(0xFFDBEAFE); // Light Blue
        badgeTextColor = const Color(0xFF2563EB); // Blue
        badgeIcon = Icons.description_outlined;
        break;
      default:
        badgeColor = const Color(0xFFF1F5F9);
        badgeTextColor = const Color(0xFF64748B);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.skyBlue.withOpacity(0.1),
                    child: Text(
                      note['doctor'].substring(0, 1),
                      style: TextStyle(
                        color: AppColors.skyBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note['doctor'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        note['specialty'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  note['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    if (badgeIcon != null) ...[
                      Icon(badgeIcon, size: 14, color: badgeTextColor),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      note['priority'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: badgeTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            note['content'],
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    note['date'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              Text(
                note['time'],
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
