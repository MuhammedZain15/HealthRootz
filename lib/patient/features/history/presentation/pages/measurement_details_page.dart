import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:grad_project/app_colors.dart';
import '../../data/measurement_model.dart';
import '../widgets/measurement_chart.dart';
import '../widgets/measurement_detail_stats.dart';

class MeasurementDetailsPage extends StatelessWidget {
  final MeasurementRecord record;

  const MeasurementDetailsPage({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat("MMM d, yyyy");
    final tf = DateFormat("h:mm a");

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Back",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        titleSpacing: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ElevatedButton.icon(
              onPressed: () => _exportRecordPdf(record),
              icon: const Icon(Icons.file_download_outlined, size: 20),
              label: const Text("Download"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.skyBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: record.themeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          record.icon,
                          color: record.themeColor,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${df.format(record.dateTime)} • ${tf.format(record.dateTime)}",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  MeasurementDetailStats(record: record),
                ],
              ),
            ),
            const SizedBox(height: 20),
            MeasurementChart(record: record),
            const SizedBox(height: 30),
          ],
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
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "Medical Report",
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900,
                          ),
                        ),
                        pw.Text(
                          "Measurement Detail: ${record.title}",
                          style: pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [pw.Text("Date: $df"), pw.Text("Time: $tf")],
                    ),
                  ],
                ),
                pw.SizedBox(height: 32),
                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 24),
                pw.Text(
                  "Measurement Statistics",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    _buildPdfTableRow(
                      "Current Reading",
                      "${record.currentValue.toInt()} ${record.unit}",
                    ),
                    _buildPdfTableRow("Status", record.status),
                    _buildPdfTableRow(
                      "Average Value",
                      "${record.averageValue.toInt()} ${record.unit}",
                    ),
                    _buildPdfTableRow(
                      "Maximum Value",
                      "${record.maxValue.toInt()} ${record.unit}",
                    ),
                    _buildPdfTableRow(
                      "Minimum Value",
                      "${record.minValue.toInt()} ${record.unit}",
                    ),
                    _buildPdfTableRow("Duration", record.duration),
                  ],
                ),
                pw.SizedBox(height: 32),
                pw.Text(
                  "Recommendation",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(8),
                    ),
                  ),
                  child: pw.Text(
                    record.recommendation,
                    style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.5),
                  ),
                ),
                pw.Spacer(),
                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    "This is an automated health report generated by the GradProject App.",
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name:
          "${record.title}_Report_${DateFormat('yyyyMMdd').format(record.dateTime)}.pdf",
    );
  }

  pw.TableRow _buildPdfTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(value)),
      ],
    );
  }
}
