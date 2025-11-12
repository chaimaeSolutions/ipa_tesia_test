import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:tesia_app/shared/colors.dart';
import 'package:tesia_app/l10n/app_localizations.dart';
import 'package:tesia_app/shared/components/showsnackbar.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  Future<Uint8List> _fetchPdf(Locale? locale) async {
    final bool isEs = (locale?.languageCode ?? '').toLowerCase() == 'es';
    final fileName = isEs ? 'privacy_es.pdf' : 'privacy_en.pdf';

    try {
      final ref = FirebaseStorage.instance.ref('privacy/$fileName');
      final bytes = await ref.getData();

      if (bytes == null || bytes.isEmpty) {
        throw Exception('PDF file is empty');
      }

      return bytes;
    } catch (e) {
      throw Exception('Failed to load privacy policy: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final currentLocale = Localizations.localeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.privacyAndSecurity ?? 'Privacy & Security'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              try {
                final bytes = await _fetchPdf(currentLocale);
                await Printing.layoutPdf(
                  onLayout: (format) => Future.value(bytes),
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
      body: FutureBuilder<Uint8List>(
        future: _fetchPdf(currentLocale),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(kTesiaColor),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    loc?.failedToLoadPrivacyPolicy ??
                        'Failed to load privacy policy',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final bytes = snapshot.data!;

          return PdfPreview(
            build: (format) => Future.value(bytes),
            allowSharing: true,
            canChangeOrientation: false,
            canChangePageFormat: false,
            maxPageWidth: 700,
            actions: [
              PdfPreviewAction(
                icon: const Icon(Icons.download_rounded),
                onPressed: (context, build, pageFormat) async {
                  await Printing.sharePdf(
                    bytes: bytes,
                    filename: 'TESIA_Privacy_Security.pdf',
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
