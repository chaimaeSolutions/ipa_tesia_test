import 'package:flutter/material.dart';
import 'package:tesia_app/scans/Results_page.dart' hide DangerMeter;
import 'package:tesia_app/l10n/app_localizations.dart';
import 'package:tesia_app/shared/colors.dart';
import 'package:tesia_app/shared/shimmer/latest_scans_shimmer.dart';
import 'package:lottie/lottie.dart';
import 'package:tesia_app/scans/scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LatestScansPage extends StatefulWidget {
  const LatestScansPage({super.key});

  @override
  State<LatestScansPage> createState() => _LatestScansPageState();
}

class _LatestScansPageState extends State<LatestScansPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: Text(
          loc.latestScans,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      body:
          _isLoading
              ? const LatestScansShimmer()
              : _buildScanStream(context, loc, isDark),
    );
  }

  Widget _buildScanStream(
    BuildContext context,
    AppLocalizations loc,
    bool isDark,
  ) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Center(child: Text(loc.noScansYet));
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('scans')
              .orderBy('timestamp', descending: true)
              .limit(20)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LatestScansShimmer();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(context, isDark, loc);
        }

        final scans =
            snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return ScanItem(
                id: doc.id,
                moldType: data['moldType'] ?? 'Unknown',
                imagePath: data['imagePath'] ?? '',
                confidence: data['confidence'] ?? '0%',
                description: data['description'] ?? '',
                overviewText: data['overviewText'] ?? '',
                habitatText: data['habitatText'] ?? '',
                detectionStats: data['detectionStats'] ?? {},
                healthRisks: _parseHealthRisks(data['healthRisks']),
                preventionMethods: List<String>.from(
                  data['preventionMethods'] ?? [],
                ),
                dangerLevel: _calculateDangerLevel(
                  data['detectionStats'] ?? {},
                ),
              );
            }).toList();

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 260, 
          ),
          itemCount: scans.length,
          itemBuilder: (context, index) {
            final scan = scans[index];
            final percent = (scan.dangerLevel * 100).round();
            return _ScanCard(
              title: scan.moldType,
              subtitle: scan.description,
              imagePath: scan.imagePath,
              meterPercent: percent,
              confidence: scan.confidence, 
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ResultsPage(
                          moldType: scan.moldType,
                          confidence: scan.confidence,
                          imagePath: scan.imagePath,
                          description: scan.description,
                          overviewText: scan.overviewText,
                          habitatText: scan.habitatText,
                          detectionStats: scan.detectionStats,
                          healthRisks: scan.healthRisks,
                          preventionMethods: scan.preventionMethods,
                        ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  List<Map<String, String>> _parseHealthRisks(dynamic data) {
    if (data is List) {
      return data
          .map(
            (item) => {
              'title': (item['title'] ?? '').toString(),
              'details': (item['details'] ?? '').toString(),
            },
          )
          .cast<Map<String, String>>()
          .toList();
    }
    return [];
  }

  double _calculateDangerLevel(Map<String, dynamic> stats) {
    final severity = (stats['severity'] ?? 'Unknown').toString().toLowerCase();
    switch (severity) {
      case 'high':
        return 0.9;
      case 'medium':
        return 0.6;
      case 'low':
        return 0.3;
      default:
        return 0.5;
    }
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isDark,
    AppLocalizations loc,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 180,
              width: 180,
              child: Lottie.asset(
                'assets/animations/norecentscans.json',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              loc.noRecentScans,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              loc.getStartedByScanningMold,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScannerPage()),
                );
              },
              icon: const Icon(Icons.camera_alt, size: 18),
              label: Text(loc.takePicture),
              style: ElevatedButton.styleFrom(
                backgroundColor: kTesiaColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScanItem {
  final String id;
  final String moldType;
  final String imagePath;
  final String confidence;
  final String description;
  final String overviewText;
  final String habitatText;
  final Map<String, dynamic> detectionStats;
  final List<Map<String, String>> healthRisks;
  final List<String> preventionMethods;
  final double dangerLevel;

  ScanItem({
    required this.id,
    required this.moldType,
    required this.imagePath,
    required this.confidence,
    required this.description,
    required this.overviewText,
    required this.habitatText,
    required this.detectionStats,
    required this.healthRisks,
    required this.preventionMethods,
    required this.dangerLevel,
  });
}

class _ScanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final int meterPercent;
  final String confidence; 
  final VoidCallback? onTap;

  const _ScanCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.meterPercent,
    required this.confidence, 
    this.onTap,
  });

  Color _getDangerColor(int percent) {
    if (percent >= 70) return const Color(0xFFEF4444); 
    if (percent >= 40) return const Color(0xFFF59E0B); 
    return const Color(0xFF10B981); 
  }

  String _getDangerLabel(BuildContext context, int percent) {
    final loc = AppLocalizations.of(context)!;
    if (percent >= 70) return loc.highRisk;      
    if (percent >= 40) return loc.mediumRisk;    
    return loc.lowRisk;                          
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dangerColor = _getDangerColor(meterPercent);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:
                  isDark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.07),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: _imageFromPath(
                    context,
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 130,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.verified, size: 12, color: kTesiaColor),
                        const SizedBox(width: 4),
                        Text(
                          confidence,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle.isNotEmpty
                              ? subtitle
                              : 'Mold detection result',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: dangerColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getDangerLabel(context, meterPercent),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: dangerColor,
                            ),
                          ),
                       
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFromPath(
    BuildContext context,
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
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2A2A2A)
                      : Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: kTesiaColor,
                ),
              ),
            ),
        errorWidget:
            (errorContext, url, error) => Container(
              color:
                  Theme.of(errorContext).brightness == Brightness.dark
                      ? const Color(0xFF2A2A2A)
                      : Colors.grey[200],
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color:
                      Theme.of(errorContext).brightness == Brightness.dark
                          ? Colors.grey[600]
                          : Colors.grey,
                  size: 32,
                ),
              ),
            ),
      );
    } else {
      return Container(
        color:
            Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2A2A2A)
                : Colors.grey[200],
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[600]
                    : Colors.grey,
            size: 32,
          ),
        ),
      );
    }
  }
}
