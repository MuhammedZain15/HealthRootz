import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:grad_project/doctor/features/patients/model/patient_model.dart';
import 'package:grad_project/doctor/features/reports/model/report_data.dart';

class PdfGeneratorService {
  Future<void> generateAndDownloadPdf(
    ReportData data,
    Patient patient,
    DateTime start,
    DateTime end,
  ) async {
    final pdf = pw.Document();
    final df = DateFormat('dd/MM/yyyy');
    final font = await PdfGoogleFonts.interRegular();
    final boldFont = await PdfGoogleFonts.interBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (pw.Context context) {
          return [
            _buildHeader(patient, start, end, df),
            pw.SizedBox(height: 20),
            _buildVitalsSection(data),
            pw.SizedBox(height: 20),
            _buildAiAnalysisSection(data),
            pw.SizedBox(height: 20),
            _buildDoctorNotesSection(data, df),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Report_${patient.name}_${df.format(start)}.pdf',
    );
  }

  pw.Widget _buildHeader(
    Patient patient,
    DateTime start,
    DateTime end,
    DateFormat df,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Medical Report',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Patient Name: ${patient.name}',
              style: const pw.TextStyle(fontSize: 14),
            ),
            pw.Text(
              'Period: ${df.format(start)} - ${df.format(end)}',
              style: const pw.TextStyle(fontSize: 14),
            ),
          ],
        ),
        pw.Divider(),
      ],
    );
  }

  pw.Widget _buildVitalsSection(ReportData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Vital Signs',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            pw.Expanded(
              child: _buildMetricBox(
                'Heart Rate',
                '${data.heartRateAvg} bpm',
                'Min: ${data.heartRateMin} / Max: ${data.heartRateMax}',
                PdfColors.red100,
                PdfColors.red800,
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: _buildMetricBox(
                'EMG',
                '${data.emgAvg} µV',
                'Min: ${data.emgMin} / Max: ${data.emgMax}',
                PdfColors.blue100,
                PdfColors.blue800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildMetricBox(
    String title,
    String value,
    String sub,
    PdfColor bg,
    PdfColor text,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: text),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(color: text, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: text,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(sub, style: pw.TextStyle(color: text, fontSize: 10)),
        ],
      ),
    );
  }

  pw.Widget _buildAiAnalysisSection(ReportData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.purple50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.purple200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'AI Analysis & Conclusions',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          ...data.analysis.map((line) => pw.Bullet(text: line)),
          pw.SizedBox(height: 12),
          pw.Text(
            'Recommendation:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(data.recommendation),
        ],
      ),
    );
  }

  pw.Widget _buildDoctorNotesSection(ReportData data, DateFormat df) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "Doctor's Notes",
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(data.doctorNotes),
          pw.SizedBox(height: 12),
          pw.Text(
            '${data.doctorName} - ${df.format(data.doctorNoteDate)}',
            style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
