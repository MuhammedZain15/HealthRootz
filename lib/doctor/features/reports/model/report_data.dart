enum ExportFormat { pdf, csv }

class ReportData {
  final int heartRateAvg;
  final int heartRateMin;
  final int heartRateMax;
  final int heartRateAbnormal;
  final int emgAvg;
  final int emgMin;
  final int emgMax;
  final int emgAbnormal;
  final List<String> analysis;
  final String recommendation;
  final String doctorNotes;
  final String doctorName;
  final DateTime doctorNoteDate;

  const ReportData({
    required this.heartRateAvg,
    required this.heartRateMin,
    required this.heartRateMax,
    required this.heartRateAbnormal,
    required this.emgAvg,
    required this.emgMin,
    required this.emgMax,
    required this.emgAbnormal,
    required this.analysis,
    required this.recommendation,
    required this.doctorNotes,
    required this.doctorName,
    required this.doctorNoteDate,
  });
}

final Map<String, ReportData> fakeReportsData = {
  '1': ReportData(
    heartRateAvg: 72,
    heartRateMin: 60,
    heartRateMax: 96,
    heartRateAbnormal: 1,
    emgAvg: 45,
    emgMin: 35,
    emgMax: 70,
    emgAbnormal: 1,
    analysis: [
      'Patient vitals remain within acceptable ranges for most of the period',
      'One instance of elevated heart rate detected during evening hours',
      'EMG readings show consistent patterns with one minor spike',
      'Overall risk assessment: Low',
    ],
    recommendation:
        'Continue current treatment plan. Monitor evening heart rate trends. Schedule follow-up in 2 weeks.',
    doctorNotes:
        'Patient has shown steady progress over the monitoring period. Vital signs are generally stable with occasional fluctuations that appear to correlate with physical activity and stress levels. EMG readings indicate normal muscle function with no significant abnormalities detected. Recommended continuation of current medication regimen and routine exercise. Follow-up appointment scheduled for comprehensive evaluation.',
    doctorName: 'Dr. Thompson',
    doctorNoteDate: DateTime(2026, 1, 5),
  ),
  '2': ReportData(
    heartRateAvg: 95,
    heartRateMin: 72,
    heartRateMax: 118,
    heartRateAbnormal: 4,
    emgAvg: 78,
    emgMin: 52,
    emgMax: 110,
    emgAbnormal: 3,
    analysis: [
      'Heart rate elevated above baseline on multiple days',
      'EMG readings show increased muscle tension during late hours',
      'Potential correlation with reported stress levels',
      'Overall risk assessment: Moderate',
    ],
    recommendation:
        'Adjust activity schedule. Consider stress management plan. Recheck vitals in 1 week.',
    doctorNotes:
        'Patient reports feeling anxious with periodic palpitations. Heart rate readings indicate multiple episodes of tachycardia. Recommend lifestyle adjustments and monitoring. Discussed potential medication review if symptoms persist. Follow-up planned for next week.',
    doctorName: 'Dr. Anderson',
    doctorNoteDate: DateTime(2026, 1, 12),
  ),
  '3': ReportData(
    heartRateAvg: 68,
    heartRateMin: 58,
    heartRateMax: 85,
    heartRateAbnormal: 0,
    emgAvg: 50,
    emgMin: 38,
    emgMax: 72,
    emgAbnormal: 1,
    analysis: [
      'Heart rate stable throughout the period',
      'EMG readings show consistent muscle function',
      'One minor EMG spike on Dec 15 at 2:30 PM',
      'Overall risk assessment: Low',
    ],
    recommendation: 'Maintain current routine. No immediate changes required.',
    doctorNotes:
        'Patient maintains good overall health indicators. No significant concerns noted. Continue current wellness plan and routine check-ins.',
    doctorName: 'Dr. Chen',
    doctorNoteDate: DateTime(2026, 1, 18),
  ),
  '4': ReportData(
    heartRateAvg: 110,
    heartRateMin: 88,
    heartRateMax: 132,
    heartRateAbnormal: 5,
    emgAvg: 85,
    emgMin: 60,
    emgMax: 120,
    emgAbnormal: 4,
    analysis: [
      'Frequent elevated heart rate readings detected',
      'EMG shows repeated high-activity spikes',
      'Symptoms may correlate with limited recovery',
      'Overall risk assessment: Moderate to high',
    ],
    recommendation:
        'Immediate review recommended. Limit exertion and follow clinician guidance.',
    doctorNotes:
        'Multiple abnormal readings noted over the monitoring period. Recommend closer supervision and potential adjustment to treatment plan. Patient advised to reduce activity levels and report any worsening symptoms promptly.',
    doctorName: 'Dr. Rodriguez',
    doctorNoteDate: DateTime(2026, 2, 1),
  ),
};
