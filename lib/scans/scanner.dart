import 'package:flutter/material.dart';
import 'package:tesia_app/scans/Results_page.dart';
import 'dart:io';
import 'dart:ui';
import 'package:lottie/lottie.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tesia_app/l10n/app_localizations.dart';
import 'package:tesia_app/shared/colors.dart';
import 'package:tesia_app/services/openai_mold_service.dart';
import 'package:tesia_app/services/notification_service.dart';
import 'package:tesia_app/core/locale_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tesia_app/shared/components/showsnackbar.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage>
    with TickerProviderStateMixin {
  bool isScanning = false;
  int planRemaining = 0;
  int totalPlan = 0;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;

  late final AnimationController _lottieController;
  final double _lottieStop = 0.5;
  final double _lottieSpeed = 0.7;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _subscribeToUserPoints();
  }

  void _subscribeToUserPoints() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _userSub?.cancel();
    _userSub = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snap) {
          if (!mounted) return;
          final data = snap.data();
          final pts =
              (data?['points'] is num) ? (data?['points'] as num).toInt() : 0;
          final ptsTotal =
              (data?['pointsTotal'] is num)
                  ? (data?['pointsTotal'] as num).toInt()
                  : null;
          setState(() {
            planRemaining = pts;

            totalPlan =
                ptsTotal ?? (totalPlan > 0 ? totalPlan : (pts > 0 ? pts : 40));
          });
        }, onError: (e) {});
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _lottieController.dispose();
    super.dispose();
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (planRemaining <= 0) {
      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              backgroundColor:
                  isDark ? Theme.of(context).colorScheme.surface : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                loc.planLimitReached,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              content: Text(
                loc.planLimitReachedMessage,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(loc.ok),
                ),
              ],
            ),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        showSnack(context, loc.pleaseSignIn, error: true);
        return;
      }

      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (file == null) return;
      setState(() => isScanning = true);

      final localeProvider = Provider.of<LocaleProvider>(
        context,
        listen: false,
      );
      final languageCode = localeProvider.locale.languageCode;

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          if (mounted) {
            showSnack(context, loc.pleaseSignIn, error: true);
            setState(() => isScanning = false);
          }
          return;
        }

        try {
          await user.getIdToken(true);
        } catch (e) {
          if (mounted) {
            showSnack(context, loc.authenticationExpired, error: true);
            setState(() => isScanning = false);
          }
          return;
        }

        final userId = user.uid;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final storagePath = 'users/$userId/scans/scan_$timestamp.jpg';

        final storageRef = FirebaseStorage.instance.ref().child(storagePath);
        if (kIsWeb) {
          final bytes = await file.readAsBytes();
          final metadata = SettableMetadata(contentType: 'image/jpeg');
          await storageRef.putData(bytes, metadata);
        } else {
          final localFile = File(file.path);
          final metadata = SettableMetadata(contentType: 'image/jpeg');
          await storageRef.putFile(localFile, metadata);
        }
        final imageUrl = await storageRef.getDownloadURL();

        final analysisResult =
            await OpenAIMoldService.analyzeMoldImageWithCloudFunction(
              imageUrl,
              languageCode,
            );

     
        try {
          await FirebaseFirestore.instance.runTransaction((tx) async {
            final docRef = FirebaseFirestore.instance
                .collection('users')
                .doc(userId);
            final snapshot = await tx.get(docRef);
            final current = (snapshot.data()?['points'] as num?)?.toInt() ?? 0;
            if (current <= 0) {
              throw FirebaseException(
                plugin: 'firestore',
                message: 'No points left',
              );
            }
            tx.update(docRef, {'points': current - 1});
          });

          if (mounted) {
            setState(
              () => planRemaining = (planRemaining > 0) ? planRemaining - 1 : 0,
            );
          }
        } catch (e) {
          if (mounted) {
            setState(() => isScanning = false);
            await showDialog(
              context: context,
              builder:
                  (_) => AlertDialog(
                    title: Text(loc.planLimitReached),
                    content: Text(loc.planLimitReachedMessage),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(loc.ok),
                      ),
                    ],
                  ),
            );
          }
          return;
        }

        if (userId != 'public') {
          final scansCol = FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('scans');
          final newDoc = await scansCol.add({
            'timestamp': FieldValue.serverTimestamp(),
            'moldType': analysisResult.moldType,
            'confidence': analysisResult.confidence,
            'imagePath': imageUrl,
            'description': analysisResult.description,
            'overviewText': analysisResult.overviewText,
            'habitatText': analysisResult.habitatText,
            'detectionStats': analysisResult.detectionStats,
            'healthRisks': analysisResult.healthRisks,
            'preventionMethods': analysisResult.preventionMethods,
          });

          try {
            await NotificationService.sendScanNotification(
              userId,
              moldType: analysisResult.moldType,
              severity:
                  (analysisResult.detectionStats?['severity'] ?? 'unknown')
                      .toString(),
              scansLeft: planRemaining,
              scansTotal: totalPlan,
              scanId: newDoc.id,
              imageUrl: imageUrl,
            );
          } catch (e) {}
        }

        if (mounted) setState(() => isScanning = false);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => ResultsPage(
                  moldType: analysisResult.moldType,
                  confidence: analysisResult.confidence,
                  imagePath: imageUrl,
                  description: analysisResult.description,
                  overviewText: analysisResult.overviewText,
                  habitatText: analysisResult.habitatText,
                  detectionStats: analysisResult.detectionStats,
                  healthRisks: analysisResult.healthRisks,
                  preventionMethods: analysisResult.preventionMethods,
                ),
          ),
        );
      } catch (e) {
        final err = e.toString();
        final userMsg =
            err.contains('OPENAI_API_KEY') ||
                    err.toLowerCase().contains('openai') &&
                        err.toLowerCase().contains('api key')
                ? loc.apiKeyNotConfigured
                : loc.failedToAnalyzeImage;

        if (mounted) {
          setState(() => isScanning = false);
          showSnack(context, userMsg, error: true);
        }
        return;
      }
    } catch (e) {
      setState(() => isScanning = false);
      final loc = AppLocalizations.of(context)!;
      showSnack(context, loc.failedToProcessImage(e.toString()), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurface,
            size: 20,
          ),
        ),
        title: Text(
          loc.moldScanner,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? Theme.of(context).colorScheme.surface
                            : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            isDark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 200,
                        child: Lottie.asset(
                          'assets/animations/moldScan.json',
                          controller: _lottieController,
                          fit: BoxFit.contain,
                          onLoaded: (composition) async {
                            final baseMs = composition.duration.inMilliseconds;
                            final playDuration = Duration(
                              milliseconds: (baseMs * _lottieSpeed).round(),
                            );
                            _lottieController.duration = Duration(
                              milliseconds: baseMs,
                            );
                            _lottieController.stop();
                            _lottieController.value = 0.0;
                            await _lottieController.animateTo(
                              _lottieStop,
                              duration: playDuration,
                              curve: Curves.linear,
                            );
                            _lottieController.stop();
                          },
                        ),
                      ),

                      const SizedBox(height: 8),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value:
                                        (totalPlan > 0)
                                            ? (planRemaining / totalPlan)
                                            : 0,
                                    strokeWidth: 4,
                                    backgroundColor:
                                        isDark
                                            ? Colors.grey[800]
                                            : Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      kTesiaColor,
                                    ),
                                  ),
                                  Text(
                                    '$planRemaining',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.scansLeft,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  width: 120,
                                  height: 6,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value:
                                          (totalPlan > 0)
                                              ? (planRemaining / totalPlan)
                                              : 0,
                                      backgroundColor:
                                          isDark
                                              ? Colors.grey[800]
                                              : Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        kTesiaColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),
                      Text(
                        loc.readyToScan,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc.getInstantMoldIdentification,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 12),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color:
                                    isDark
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.white.withOpacity(0.08),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      isDark
                                          ? Colors.black.withOpacity(0.2)
                                          : Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        isScanning
                                            ? null
                                            : () =>
                                                _pickImage(ImageSource.camera),
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      size: 18,
                                    ),
                                    label: Text(
                                      loc.camera,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kTesiaColor,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed:
                                        isScanning
                                            ? null
                                            : () =>
                                                _pickImage(ImageSource.gallery),
                                    icon: const Icon(
                                      Icons.photo_library,
                                      size: 18,
                                    ),
                                    label: Text(
                                      loc.gallery,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      side: BorderSide(
                                        color:
                                            isDark
                                                ? Colors.grey[700]!
                                                : Colors.grey[300]!,
                                      ),
                                      foregroundColor:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  loc.photoGuidelines,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? Theme.of(context).colorScheme.surface
                            : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            isDark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildGuidelineItem(
                        icon: Icons.wb_sunny_outlined,
                        title: loc.goodLighting,
                        subtitle: loc.goodLightingDescription,
                        color: Colors.orange[400]!,
                        isDark: isDark,
                      ),
                      Divider(
                        height: 20,
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                      ),
                      _buildGuidelineItem(
                        icon: Icons.straighten,
                        title: loc.optimalDistance,
                        subtitle: loc.optimalDistanceDescription,
                        color: Colors.green[400]!,
                        isDark: isDark,
                      ),
                      Divider(
                        height: 20,
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                      ),
                      _buildGuidelineItem(
                        icon: Icons.center_focus_strong,
                        title: loc.staySteady,
                        subtitle: loc.staySteadyDescription,
                        color: Colors.purple[400]!,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        isDark ? Colors.blue.withOpacity(0.1) : Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isDark
                              ? Colors.blue.withOpacity(0.3)
                              : Colors.blue[100]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: isDark ? Colors.blue[300] : Colors.blue[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          loc.aiPoweredAnalysis,
                          style: TextStyle(
                            color: isDark ? Colors.blue[200] : Colors.blue[700],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (isScanning)
            Container(
              color:
                  isDark
                      ? Colors.black.withOpacity(0.85)
                      : Colors.white.withOpacity(0.95),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? Theme.of(context).colorScheme.surface
                            : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color:
                            isDark
                                ? Colors.black.withOpacity(0.5)
                                : Colors.grey.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 84,
                        height: 84,
                        child: Lottie.asset(
                          'assets/animations/scanningprogress.json',
                          repeat: true,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        loc.analyzingImage,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        loc.processingWithAI,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
