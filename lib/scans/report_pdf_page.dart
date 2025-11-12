import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tesia_app/l10n/app_localizations.dart';
import 'package:tesia_app/shared/colors.dart';
import 'package:tesia_app/shared/components/showsnackbar.dart';

class ReportPdfPage extends StatefulWidget {
  final String moldType;
  final String confidence;
  final String imagePath;
  final String description;
  final String overviewText;
  final String habitatText;
  final Map<String, dynamic> detectionStats;
  final List<Map<String, String>> healthRisks;
  final List<String> preventionMethods;

  const ReportPdfPage({
    super.key,
    required this.moldType,
    required this.confidence,
    required this.imagePath,
    required this.description,
    required this.overviewText,
    required this.habitatText,
    required this.detectionStats,
    required this.healthRisks,
    required this.preventionMethods,
  });

  @override
  State<ReportPdfPage> createState() => _ReportPdfPageState();
}

class _ReportPdfPageState extends State<ReportPdfPage> {
  Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    final doc = pw.Document(version: PdfVersion.pdf_1_5, compress: true);

    final loc = AppLocalizations.of(context)!;

    final pdfTitle = loc.pdfScanReportTitle;
    final pdfSubtitle = '${widget.moldType} • ${widget.confidence}';
    final labelDescription = loc.pdfDescription;
    final labelOverview = loc.pdfOverview;
    final labelHabitat = loc.pdfHabitat;
    final labelDetectionStats = loc.pdfDetectionStatistics;
    final labelHealthRisks = loc.pdfHealthRisks;
    final labelPrevention = loc.pdfPreventionMethods;
    final labelNoneListed = loc.pdfNoneListed;
    final labelGenerated = loc.pdfGenerated;

    Uint8List? logoBytes;
    try {
      final data = await rootBundle.load('assets/logos/Tesia_nobg.png');
      logoBytes = data.buffer.asUint8List();
    } catch (_) {
      logoBytes = null;
    }

    Uint8List? capturedBytes;
    try {
      final path = widget.imagePath;
      if (path.isNotEmpty &&
          !path.startsWith('http') &&
          File(path).existsSync()) {
        capturedBytes = await File(path).readAsBytes();
      }
    } catch (_) {
      capturedBytes = null;
    }

    final title = pdfTitle;
    final subtitle = pdfSubtitle;

    final baseColor = PdfColor.fromInt(kTesiaColor.value);
    final headerStyle = pw.TextStyle(
      fontSize: 18,
      fontWeight: pw.FontWeight.bold,
      color: baseColor,
    );
    final sectionTitle = pw.TextStyle(
      fontSize: 13,
      fontWeight: pw.FontWeight.bold,
    );
    final bodyStyle = pw.TextStyle(fontSize: 11, height: 1.4);

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: format,
          margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 36),
          theme: pw.ThemeData.withFont(
            base: await PdfGoogleFonts.robotoRegular(),
            bold: await PdfGoogleFonts.robotoBold(),
          ),
        ),
        header:
            (ctx) => pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                if (logoBytes != null)
                  pw.Image(pw.MemoryImage(logoBytes), width: 80, height: 80),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'TESIA',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey800,
                      ),
                    ),
                    pw.Text(
                      'Scan Report',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        footer:
            (ctx) => pw.Container(
              padding: const pw.EdgeInsets.only(top: 8),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TESIA © ${DateTime.now().year}',
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                  ),
                  pw.Text(
                    'v1.0.0',
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
        build:
            (context) => <pw.Widget>[
              pw.SizedBox(height: 6),
              pw.Text(title, style: headerStyle),
              pw.SizedBox(height: 4),
              pw.Text(
                subtitle,
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
              ),
              pw.Divider(),
              pw.SizedBox(height: 8),

              if (capturedBytes != null) ...[
                pw.Container(
                  width: double.infinity,
                  height: 200,
                  child: pw.Image(
                    pw.MemoryImage(capturedBytes),
                    fit: pw.BoxFit.cover,
                  ),
                ),
                pw.SizedBox(height: 12),
              ],

              pw.Text(labelDescription, style: sectionTitle),
              pw.SizedBox(height: 6),
              pw.Text(
                widget.description,
                style: bodyStyle,
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 10),

              pw.Text(labelOverview, style: sectionTitle),
              pw.SizedBox(height: 6),
              pw.Text(
                widget.overviewText,
                style: bodyStyle,
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 10),

              pw.Text(labelHabitat, style: sectionTitle),
              pw.SizedBox(height: 6),
              pw.Text(
                widget.habitatText,
                style: bodyStyle,
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 10),

              pw.Text(labelDetectionStats, style: sectionTitle),
              pw.SizedBox(height: 6),
              pw.Bullet(
                text:
                    'Confidence: ${widget.confidence} • Severity: ${widget.detectionStats['severity'] ?? 'Unknown'}',
                style: bodyStyle,
              ),
              pw.SizedBox(height: 8),

              pw.Text(labelHealthRisks, style: sectionTitle),
              pw.SizedBox(height: 6),
              if (widget.healthRisks.isEmpty)
                pw.Text(labelNoneListed, style: bodyStyle)
              else
                for (final r in widget.healthRisks)
                  pw.Bullet(
                    text: '${r['title']}: ${r['details']}',
                    style: bodyStyle,
                  ),
              pw.SizedBox(height: 8),

              pw.Text(labelPrevention, style: sectionTitle),
              pw.SizedBox(height: 6),
              if (widget.preventionMethods.isEmpty)
                pw.Text(labelNoneListed, style: bodyStyle)
              else
                for (final p in widget.preventionMethods)
                  pw.Bullet(text: p, style: bodyStyle),

              pw.SizedBox(height: 12),
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Text(
                '$labelGenerated: ${DateTime.now().toLocal()}',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
            ],
      ),
    );

    return doc.save();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.pdfScanReportTitle ?? 'Scan Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              try {
                await Printing.layoutPdf(
                  onLayout: (format) => _buildPdf(format),
                );
              } catch (e) {
                if (mounted) {
                  final msgPrefix = loc?.printFailed ?? 'Print failed';
                  showSnack(
                    context,
                    '$msgPrefix: ${e.toString()}',
                    error: true,
                  );
                }
              }
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => _buildPdf(format),
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: true,
        initialPageFormat: PdfPageFormat.a4,
        maxPageWidth: 700,
        actions: [
          PdfPreviewAction(
            icon: const Icon(Icons.download_rounded),
            onPressed: (context, build, pageFormat) async {
              final bytes = await build(pageFormat);
              await Printing.sharePdf(
                bytes: bytes,
                filename: 'TESIA_ScanReport_${widget.moldType}.pdf',
              );
            },
          ),
        ],
      ),
    );
  }
}
