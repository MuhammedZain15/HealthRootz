import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


enum MeasurementType { bloodOxygen, heartRate }

class MeasurementRecord {
  final MeasurementType type;
  final num value;
  final String unit; // "%" or "BPM"
  final DateTime dateTime;
  final String status; // "Normal" / "High" / "Low"
  final String recommendation;

  const MeasurementRecord({
    required this.type,
    required this.value,
    required this.unit,
    required this.dateTime,
    required this.status,
    required this.recommendation,
  });

  String get title {
    switch (type) {
      case MeasurementType.bloodOxygen:
        return "Blood Oxygen";
      case MeasurementType.heartRate:
        return "Heart Rate";
    }
  }

  Color get themeColor {
    switch (type) {
      case MeasurementType.bloodOxygen:
        return const Color(0xFF22C55E); // green
      case MeasurementType.heartRate:
        return const Color(0xFFEF4444); // red
    }
  }

  IconData get icon {
    switch (type) {
      case MeasurementType.bloodOxygen:
        return Icons.bubble_chart;
      case MeasurementType.heartRate:
        return Icons.favorite;
    }
  }
}

/// Demo store (بعدها هنبدله بقاعدة بيانات / shared prefs / provider)
class MeasurementStore {
  static final ValueNotifier<List<MeasurementRecord>> records =
  ValueNotifier<List<MeasurementRecord>>([
    MeasurementRecord(
      type: MeasurementType.bloodOxygen,
      value: 98,
      unit: "%",
      dateTime: DateTime(2026, 1, 30, 14, 38),
      status: "Normal",
      recommendation:
      "Your blood oxygen level is healthy. Continue maintaining good respiratory health.",
    ),
    MeasurementRecord(
      type: MeasurementType.heartRate,
      value: 75,
      unit: "BPM",
      dateTime: DateTime(2026, 1, 25, 14, 19),
      status: "Normal",
      recommendation:
      "Your heart rate looks stable. Keep a balanced routine and stay hydrated.",
    ),
  ]);

  static void add(MeasurementRecord record) {
    final list = List<MeasurementRecord>.from(records.value);
    list.insert(0, record);
    records.value = list;
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: ValueListenableBuilder<List<MeasurementRecord>>(
          valueListenable: MeasurementStore.records,
          builder: (context, items, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  const Text(
                    "Measurement History",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "View all your past health measurements",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),

                  if (items.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          "No measurements yet",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final r = items[index];
                          return _HistoryCard(
                            record: r,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MeasurementDetailsPage(record: r),
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
}

class _HistoryCard extends StatelessWidget {
  final MeasurementRecord record;
  final VoidCallback onTap;

  const _HistoryCard({required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat("MMM d, yyyy");
    final tf = DateFormat("h:mm a");

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: Colors.black.withOpacity(0.04)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: record.themeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(record.icon, color: record.themeColor, size: 24),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        "${record.value}",
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          record.unit,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      _StatusChip(text: record.status),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${df.format(record.dateTime)}  •  ${tf.format(record.dateTime)}",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;

  const _StatusChip({required this.text});

  @override
  Widget build(BuildContext context) {
    final isNormal = text.toLowerCase() == "normal";
    final bg = isNormal ? const Color(0xFFEAF9EE) : const Color(0xFFFFF1F1);
    final fg = isNormal ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class MeasurementDetailsPage extends StatelessWidget {
  final MeasurementRecord record;

  const MeasurementDetailsPage({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final dt = DateFormat("MMM d, yyyy 'at' h:mm a").format(record.dateTime);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.arrow_back, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Back to History",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "${record.title} Details",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(color: Colors.black.withOpacity(0.04)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _RingValue(
                          color: record.themeColor,
                          valueText: "${record.value}",
                          unitText: record.unit,
                        ),
                        const SizedBox(width: 14),
                        _StatusChip(text: record.status),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Text(
                      dt,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: record.themeColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Health Recommendation",
                            style: TextStyle(
                              color: record.themeColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            record.recommendation,
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _exportRecordPdf(record),
                        icon: const Icon(Icons.download),
                        label: const Text(
                          "Export as PDF",
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportRecordPdf(MeasurementRecord record) async {
    final pdf = pw.Document();
    final df = DateFormat("MMM d, yyyy").format(record.dateTime);
    final tf = DateFormat("h:mm a").format(record.dateTime);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(28),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Health Measurement Report",
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 14),
                pw.Divider(),

                pw.SizedBox(height: 14),
                pw.Text("Type: ${record.title}", style: const pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 8),
                pw.Text("Measurement: ${record.value} ${record.unit}",
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text("Status: ${record.status}", style: const pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 8),
                pw.Text("Date: $df", style: const pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 8),
                pw.Text("Time: $tf", style: const pw.TextStyle(fontSize: 14)),

                pw.SizedBox(height: 18),
                pw.Text("Recommendation:",
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text(record.recommendation, style: const pw.TextStyle(fontSize: 12)),

                pw.Spacer(),
                pw.Divider(),
                pw.Text(
                  "Generated by your app",
                  style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: "${record.title} - $df.pdf",
    );
  }
}

class _RingValue extends StatelessWidget {
  final Color color;
  final String valueText;
  final String unitText;

  const _RingValue({
    required this.color,
    required this.valueText,
    required this.unitText,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.18), width: 10),
          ),
        ),
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 6),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                valueText,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                unitText,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
