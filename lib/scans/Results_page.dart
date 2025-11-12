import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:tesia_app/l10n/app_localizations.dart';
import 'package:tesia_app/shared/colors.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:tesia_app/scans/report_pdf_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tesia_app/shared/components/showsnackbar.dart';
class ResultsPage extends StatefulWidget {
  final String moldType;
  final String confidence;
  final String imagePath;
  final String description;
  final String overviewText;
  final String habitatText;
  final Map<String, dynamic> detectionStats;
  final List<Map<String, String>> healthRisks;
  final List<String> preventionMethods;

  const ResultsPage({
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
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  int _selectedTab = 0;
  late List<String> _tabs;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _typeKey = GlobalKey();
  final GlobalKey _healthKey = GlobalKey();
  final GlobalKey _preventionKey = GlobalKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loc = AppLocalizations.of(context)!;
    _tabs = [loc.overview, loc.habitat, loc.images];
  }

  Future<void> _scrollToSection(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOut,
      alignment: 0.06,
    );
  }

  Widget _buildTabContent() {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = _tabs[_selectedTab];
    Widget body;

    if (title == loc.overview) {
      body = Text(
        widget.overviewText,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85),
          height: 1.5,
        ),
      );
    } else if (title == loc.habitat) {
      body = Text(
        widget.habitatText,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85),
          height: 1.5,
        ),
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _imageFromPath(
              widget.imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 180,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.sampleImageCaptured,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        body,
      ],
    );
  }

  String _buildHealthRisksPlainText() {
    final buf = StringBuffer();
    buf.writeln('Scan Result: ${widget.moldType}');
    buf.writeln('Confidence: ${widget.confidence}');
    buf.writeln('Severity: ${widget.detectionStats['severity']}');
    buf.writeln('\nHealth Risks:');
    for (var r in widget.healthRisks) {
      buf.writeln('- ${r['title']}: ${r['details']}');
    }
    return buf.toString();
  }

  String _buildPreventionPlainText() {
    final buf = StringBuffer();
    buf.writeln('Scan Result: ${widget.moldType}');
    buf.writeln('Confidence: ${widget.confidence}');
    buf.writeln('\nPrevention Methods:');
    for (var p in widget.preventionMethods) {
      buf.writeln('- $p');
    }
    return buf.toString();
  }

  String _buildFullReportPlainText() {
    final buf = StringBuffer();
    buf.writeln('Full Scan Report — ${widget.moldType}');
    buf.writeln('Confidence: ${widget.confidence}');
    buf.writeln('Severity: ${widget.detectionStats['severity']}');
    buf.writeln('\nOverview:\n${widget.overviewText}\n');
    buf.writeln('Habitat:\n${widget.habitatText}\n');
    buf.writeln('Health Risks:');
    for (var r in widget.healthRisks) {
      buf.writeln('- ${r['title']}: ${r['details']}');
    }
    buf.writeln('\nPrevention Methods:');
    for (var p in widget.preventionMethods) {
      buf.writeln('- $p');
    }
    return buf.toString();
  }

  Future<void> _copySectionText(
    BuildContext ctx,
    String label,
    String text,
  ) async {
    final loc = AppLocalizations.of(ctx)!;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    showSnack(context, loc.copiedToClipboard(label));
  }

  Future<void> _exportTextToPdf(
    BuildContext ctx,
    String title,
    String body,
  ) async {
    final loc = AppLocalizations.of(ctx)!;
    try {
      final doc = pw.Document();
      doc.addPage(
        pw.MultiPage(
          pageFormat: pdf.PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text(title, style: pw.TextStyle(fontSize: 20)),
              ),
              pw.SizedBox(height: 8),
              pw.Text(body, style: pw.TextStyle(fontSize: 12)),
            ];
          },
        ),
      );

      await Printing.layoutPdf(onLayout: (format) async => doc.save());
      if (!mounted) return;
      showSnack(context, loc.pdfExported);
    } catch (e) {
      if (!mounted) return;
      showSnack(context, loc.errorExportingPDF(e.toString()), error: true);
    }
  }

  Future<void> _searchMoldOnWeb(String moldType) async {
    final loc = AppLocalizations.of(context)!;
    final q = Uri.encodeComponent(moldType.trim());
    final webImageSearch = Uri.parse(
      'https://www.google.com/search?q=$q+mold&tbm=isch',
    );
    final webSearchFallback = Uri.parse(
      'https://www.google.com/search?q=$q+mold',
    );

    try {
      final launched = await launchUrl(
        webImageSearch,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        final fallback = await launchUrl(
          webSearchFallback,
          mode: LaunchMode.externalApplication,
        );
        if (!fallback) {
          await launchUrl(webSearchFallback, mode: LaunchMode.platformDefault);
        }
      }
    } catch (e) {
      if (!mounted) return;
      showSnack(
        context,
        loc.couldNotOpenWebLink ?? 'Error opening web result',
        error: true,
      );
    }
  }

  Future<void> _showShareOptions(BuildContext ctx) async {
    final loc = AppLocalizations.of(ctx)!;
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Theme.of(ctx).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy_outlined),
                title: Text(loc.shareSummary ?? 'Copy summary'),
                subtitle: Text(loc.shareSummaryDescription ?? 'Copy a text summary of the report'),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _copyReportToClipboard(ctx);
                },
              ),
            
            ],
          ),
        );
      },
    );
  }

  Future<void> _copyReportToClipboard(BuildContext ctx) async {
    final loc = AppLocalizations.of(ctx)!;
    final text = _buildFullReportPlainText();
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (!mounted) return;
      showSnack(context, loc.copiedToClipboard('report'));
    } catch (e) {
      if (!mounted) return;
      showSnack(context, loc.couldNotCopy ?? 'Could not copy', error: true);
    }
  }

 
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: isDark ? const Color(0xFF121212) : Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      loc.scanResults,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showShareOptions(context),
                    icon: Icon(
                      Icons.share,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildResultCard(),
                    const SizedBox(height: 18),
                    _buildStatsSection(),
                    const SizedBox(height: 18),
                    _buildTypeOfMoldSection(),
                    const SizedBox(height: 24),
                    Container(
                      key: _healthKey,
                      child: _buildHealthRisksSection(widget.healthRisks),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      key: _preventionKey,
                      child: _buildPreventionSection(),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ReportPdfPage(
                                          moldType: widget.moldType,
                                          confidence: widget.confidence,
                                          imagePath: widget.imagePath,
                                          description: widget.description,
                                          overviewText: widget.overviewText,
                                          habitatText: widget.habitatText,
                                          detectionStats: widget.detectionStats,
                                          healthRisks: widget.healthRisks,
                                          preventionMethods:
                                              widget.preventionMethods,
                                        ),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.download_outlined,
                                color: kTesiaColor,
                              ),
                              label: Text(
                                loc.downloadFullReportPDF,
                                style: TextStyle(color: kTesiaColor),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: kTesiaColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildScannerImage(),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _searchMoldOnWeb(widget.moldType),
                  child: Text(
                    widget.moldType,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 56,
                height: 56,
                child: DangerMeter(
                  percent: _parsePercent(
                    widget.detectionStats['severity'] ?? 'Unknown',
                  ),
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            widget.description,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: () => _searchMoldOnWeb(widget.moldType),
                  icon: Icon(
                    Icons.open_in_browser,
                    size: 16,
                    color: kTesiaColor,
                  ),
                  label: Text(
                    loc.viewOnWeb,
                    style: TextStyle(fontSize: 14, color: kTesiaColor),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: loc.typeOfMold,
                  icon: Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  onPressed: () => _scrollToSection(_typeKey),
                ),
                IconButton(
                  tooltip: loc.healthRisks,
                  icon: Icon(
                    Icons.warning_amber_outlined,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  onPressed: () => _scrollToSection(_healthKey),
                ),
                IconButton(
                  tooltip: loc.prevention,
                  icon: Icon(
                    Icons.shield_outlined,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  onPressed: () => _scrollToSection(_preventionKey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerImage() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cornerColor = kTesiaColor;

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _imageFromPath(
              widget.imagePath,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.06),
                  width: 1.5,
                ),
              ),
            ),
          ),

          ..._buildScannerCorners(cornerColor),

          Positioned(
            left: 8,
            right: 8,
            top: 96,
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    cornerColor.withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildScannerCorners(Color color) {
    return [
      Positioned(
        left: 6,
        top: 6,
        child: Container(
          width: 28,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
      Positioned(
        left: 6,
        top: 6,
        child: Container(
          width: 3,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
      Positioned(
        right: 6,
        top: 6,
        child: Container(
          width: 28,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
      Positioned(
        right: 6,
        top: 6,
        child: Container(
          width: 3,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
      Positioned(
        left: 6,
        bottom: 6,
        child: Container(
          width: 28,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
      Positioned(
        left: 6,
        bottom: 6,
        child: Container(
          width: 3,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
      Positioned(
        right: 6,
        bottom: 6,
        child: Container(
          width: 28,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
      Positioned(
        right: 6,
        bottom: 6,
        child: Container(
          width: 3,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    ];
  }

  Widget _buildStatsSection() {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: isDark ? Colors.white : kTesiaColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  loc.detectionStatistics,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: _parseAccuracy(widget.detectionStats['accuracy']),
                      strokeWidth: 8,
                      backgroundColor:
                          isDark ? Colors.grey[800] : Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? Colors.white : kTesiaColor,
                      ),
                    ),
                  ),
                  Text(
                    '${widget.detectionStats['accuracy'] ?? '92%'}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatItem(
                      loc.detectionAccuracy,
                      '${widget.detectionStats['accuracy']}',
                      Colors.green,
                    ),
                    const SizedBox(height: 8),
                   
                    const SizedBox(height: 8),
                    _buildStatItem(
                      loc.severityLevel,
                      widget.detectionStats['severity']?.toString() ??
                          'Unknown',
                      _getSeverityColor(widget.detectionStats['severity']),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _parseAccuracy(dynamic accuracy) {
    if (accuracy is String) {
      final match = RegExp(r'(\d+)').firstMatch(accuracy);
      if (match != null) {
        return int.parse(match.group(1)!).clamp(0, 100) / 100;
      }
    }
    return 0.92;
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeOfMoldSection() {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      key: _typeKey,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.typeOfMold,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      loc.quickFactsAboutMold,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                height: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    isDark
                        ? 'assets/images/results/microscope_dark.png'
                        : 'assets/images/results/microscope.png',
                    fit: BoxFit.contain,
                    errorBuilder:
                        (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: List.generate(3, (index) {
              final icons = [
                Icons.info_outline,
                Icons.home_outlined,
                Icons.image_outlined,
              ];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: index == 1 ? 4.0 : (index == 0 ? 0 : 8.0),
                  ),
                  child: InkWell(
                    onTap: () => setState(() => _selectedTab = index),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color:
                            _selectedTab == index
                                ? kTesiaColor
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              _selectedTab == index
                                  ? kTesiaColor
                                  : (isDark
                                      ? Colors.grey[700]!
                                      : Colors.grey.withOpacity(0.12)),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icons[index],
                            size: 20,
                            color:
                                _selectedTab == index
                                    ? Colors.white
                                    : Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _tabs[index],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color:
                                  _selectedTab == index
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.onSurface,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          _buildTabContent(),
        ],
      ),
    );
  }

  Widget _buildHealthRisksSection(List<Map<String, String>> items) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.healthRisks,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    loc.whatExposureCanCause,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const SizedBox(width: 8),
              IconButton(
                tooltip: loc.copyHealthRisks,
                icon: Icon(
                  Icons.copy,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed:
                    () => _copySectionText(
                      context,
                      loc.healthRisks,
                      _buildHealthRisksPlainText(),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Column(
            children:
                items.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry['title']!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    entry['details']!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.75),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.open_in_new,
                                size: 18,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                              onPressed: () => _showRiskDetails(context, entry),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 8),

          LayoutBuilder(
            builder: (ctx, constraints) {
              return Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    height: 44,
                    child: TextButton(
                      onPressed: () => _scrollToSection(_preventionKey),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.85),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      child: Text(loc.goToPrevention),
                    ),
                  ),

                  if (constraints.maxWidth > 520)
                    SizedBox(width: constraints.maxWidth - 320),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreventionSection() {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/results/prevention.png',
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          child: Center(
                            child: Icon(
                              Icons.broken_image,
                              color: isDark ? Colors.grey[600] : Colors.grey,
                            ),
                          ),
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            loc.preventionMethods,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.copy,
                            size: 18,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          tooltip: loc.copyPrevention,
                          onPressed:
                              () => _copySectionText(
                                context,
                                loc.preventionMethods,
                                _buildPreventionPlainText(),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      loc.practicalStepsToReduce,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: isDark ? Colors.grey[800] : Colors.grey[300],
          ),

          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                widget.preventionMethods.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  void _showRiskDetails(BuildContext context, Map<String, String> entry) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? Theme.of(context).colorScheme.surface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder:
          (ctx) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['title']!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  entry['details']!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(loc.close),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.yellow[700]!;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  int _parsePercent(dynamic input) {
    if (input is int) return input.clamp(0, 100);
    if (input is String) {
      final match = RegExp(r'(\d+)').firstMatch(input);
      if (match != null) return int.parse(match.group(1)!).clamp(0, 100);
      return switch (input.toLowerCase()) {
        'high' => 85,
        'medium' => 60,
        'low' => 30,
        _ => 50,
      };
    }
    return 50;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _imageFromPath(
    String path, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    final isUrl = path.startsWith('http') || path.startsWith('https');
    if (isUrl) {
      return CachedNetworkImage(
        imageUrl: path,
        width: width,
        height: height,
        fit: fit,
        placeholder:
            (context, url) => Container(
              width: width,
              height: height,
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        errorWidget:
            (context, url, error) => Container(
              width: width,
              height: height,
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[200],
              child: const Center(child: Icon(Icons.broken_image)),
            ),
      );
    } else {
      final file = File(path);
      if (!file.existsSync()) {
        return Container(
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[200],
          height: height ?? 180,
          child: Center(child: Icon(Icons.broken_image)),
        );
      }
      return Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
        errorBuilder:
            (context, error, stackTrace) => Container(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[200],
              height: height ?? 180,
              child: Center(child: Icon(Icons.broken_image)),
            ),
      );
    }
  }
}

class DangerMeter extends StatelessWidget {
  final int percent;
  final bool isDark;
  const DangerMeter({super.key, required this.percent, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DangerMeterPainter(percent.clamp(0, 100), isDark),
      child: const SizedBox.expand(),
    );
  }
}

class _DangerMeterPainter extends CustomPainter {
  final int percent;
  _DangerMeterPainter(this.percent, bool isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 3;
    final startAngle = 5 * math.pi / 4;
    final sweepAngle = 3 * math.pi / 2;

    final bgPaint =
        Paint()
          ..color = Colors.grey.shade300
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    final Color progressColor;
    if (percent >= 80) {
      progressColor = Colors.red;
    } else if (percent >= 50) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.green;
    }

    final progressPaint =
        Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;
    final progressSweep = sweepAngle * (percent / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweep,
      false,
      progressPaint,
    );

    final angle = startAngle + progressSweep;
    final needlePaint =
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
    final needleLength = radius - 4;
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(angle),
      center.dy + needleLength * math.sin(angle),
    );
    canvas.drawLine(center, needleEnd, needlePaint);

    final capPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, 4.0, Paint()..color = Colors.black54);
    canvas.drawCircle(center, 3.0, capPaint);
  }

  @override
  bool shouldRepaint(covariant _DangerMeterPainter old) =>
      old.percent != percent;
}
