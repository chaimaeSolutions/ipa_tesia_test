import 'package:flutter/material.dart';
import 'package:tesia_app/onboarding_screens/guide_page.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:tesia_app/Profile/profile_page.dart';
import 'package:tesia_app/Profile/settings_page.dart';
import 'package:tesia_app/scans/scanner.dart';
import 'package:tesia_app/scans/Results_page.dart' hide DangerMeter;
import 'package:lottie/lottie.dart';
import 'package:tesia_app/Home/latest_scans.dart';
import 'package:tesia_app/shared/colors.dart';
import 'package:tesia_app/shared/shimmer/home_shimmer.dart';
import 'package:tesia_app/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePageContent();
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  bool _isLoading = true;
  String _displayName = 'User';
  String _email = 'user@example.com';
  String? _kitCode;
  String? _photoUrl;
  int _points = 0;
  int _pointsTotal = 40;

  List<Map<String, dynamic>> _latestScans = [];
  bool _scansLoading = true;

  final Map<String, String> _resolvedUrlCache = {};

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _scansSub;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadLatestScans();
  }

  Future<void> _loadData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      await _userSub?.cancel();

      _userSub = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen(
            (doc) {
              if (!mounted) return;
              final data = doc.data();
              setState(() {
                _displayName =
                    data?['displayName'] ??
                    user.email?.split('@').first ??
                    'User';
                _email = data?['email'] ?? user.email ?? 'user@example.com';
                _kitCode = data?['kitCode']?.toString();
                _photoUrl = (data?['photoURL'] as String?) ?? user.photoURL;
                _points =
                    (data?['points'] is num)
                        ? (data?['points'] as num).toInt()
                        : 0;
                _pointsTotal =
                    (data?['pointsTotal'] is num)
                        ? (data?['pointsTotal'] as num).toInt()
                        : _pointsTotal;
                _isLoading = false;
              });
            },
            onError: (err) {
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get()
                  .then((userDoc) {
                    final data = userDoc.data();
                    if (!mounted) return;
                    setState(() {
                      _displayName =
                          data?['displayName'] ??
                          user.email?.split('@').first ??
                          'User';
                      _email =
                          data?['email'] ?? user.email ?? 'user@example.com';
                      _kitCode = data?['kitCode']?.toString();
                      _photoUrl =
                          (data?['photoURL'] as String?) ?? user.photoURL;
                      _points =
                          (data?['points'] is num)
                              ? (data?['points'] as num).toInt()
                              : 0;

                      _isLoading = false;
                    });
                  })
                  .catchError((e) {
                    if (mounted) setState(() => _isLoading = false);
                  });
            },
          );
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String?> _resolveStorageUrlIfNeeded(String? path) async {
    if (path == null || path.isEmpty) return null;

    if (path.startsWith('http://') || path.startsWith('https://')) return path;

    if (_resolvedUrlCache.containsKey(path)) return _resolvedUrlCache[path];

    try {
      Reference ref;
      if (path.startsWith('gs://') || path.contains('/o/')) {
        ref = FirebaseStorage.instance.refFromURL(path);
      } else {
        ref = FirebaseStorage.instance.ref(path);
      }
      final url = await ref.getDownloadURL();
      _resolvedUrlCache[path] = url;
      return url;
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadLatestScans() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) setState(() => _scansLoading = false);
        return;
      }

      await _scansSub?.cancel();

      _scansSub = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('scans')
          .orderBy('timestamp', descending: true)
          .limit(4)
          .snapshots()
          .listen(
            (snapshot) async {
              if (!mounted) return;

              final docs = snapshot.docs;
              final scans = <Map<String, dynamic>>[];
              for (final doc in docs) {
                final data = Map<String, dynamic>.from(doc.data());
                data['id'] = doc.id;
                final rawImage = (data['imagePath'] ?? '') as String;

                final resolved = await _resolveStorageUrlIfNeeded(rawImage);
                if (resolved != null) {
                  data['resolvedImage'] = resolved;
                } else {
                  data['resolvedImage'] = rawImage;
                }
                scans.add(data);
              }

              if (!mounted) return;
              setState(() {
                _latestScans = scans;
                _scansLoading = false;
              });
            },
            onError: (err) {
              if (mounted) setState(() => _scansLoading = false);
            },
          );
    } catch (e) {
      if (mounted) setState(() => _scansLoading = false);
    }
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _scansSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const HomePageShimmer();
    }

    return _buildHomePage(context);
  }

  Widget _buildHomePage(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color:
                              isDark
                                  ? Colors.grey[800]
                                  : const Color(0xFFE8EBF0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child:
                              _photoUrl != null && _photoUrl!.isNotEmpty
                                  ? CachedNetworkImage(
                                    imageUrl: _photoUrl!,
                                    fit: BoxFit.cover,
                                    placeholder:
                                        (context, url) => Container(
                                          color:
                                              isDark
                                                  ? Colors.grey[800]
                                                  : const Color(0xFFE8EBF0),
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                    errorWidget:
                                        (context, url, error) => Container(
                                          color:
                                              isDark
                                                  ? Colors.grey[800]
                                                  : const Color(0xFFE8EBF0),
                                          child: Icon(
                                            Icons.person,
                                            color:
                                                isDark
                                                    ? Colors.grey[400]
                                                    : const Color(0xFF6B7280),
                                            size: 35,
                                          ),
                                        ),
                                  )
                                  : Container(
                                    color:
                                        isDark
                                            ? Colors.grey[800]
                                            : const Color(0xFFE8EBF0),
                                    child: Icon(
                                      Icons.person,
                                      color:
                                          isDark
                                              ? Colors.grey[400]
                                              : const Color(0xFF6B7280),
                                      size: 35,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _displayName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _email,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfilePage(),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors:
                                            isDark
                                                ? [
                                                  Colors.white.withOpacity(0.1),
                                                  Colors.white.withOpacity(
                                                    0.05,
                                                  ),
                                                ]
                                                : [
                                                  const Color(
                                                    0xFFFFFFFF,
                                                  ).withOpacity(0.9),
                                                  const Color(
                                                    0xFFF0F3F7,
                                                  ).withOpacity(0.9),
                                                ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color:
                                            isDark
                                                ? Colors.white.withOpacity(0.2)
                                                : const Color(0xFFE5E8ED),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              isDark
                                                  ? Colors.black.withOpacity(
                                                    0.05,
                                                  )
                                                  : const Color(
                                                    0xFF000000,
                                                  ).withOpacity(0.04),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          size: 16,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          loc.account,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsPage(),
                            ),
                          );
                        },
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? Colors.grey[800]
                                    : const Color(0xFFE8EBF0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.settings,
                            color:
                                isDark
                                    ? Theme.of(context).colorScheme.onSurface
                                    : const Color(0xFF6B7280),
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? Theme.of(context).colorScheme.surface
                                : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color:
                                isDark
                                    ? Colors.black.withOpacity(0.3)
                                    : const Color(0xFF000000).withOpacity(0.06),
                            spreadRadius: 0,
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
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
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Image.asset(
                                          'assets/logos/Tesia_nobg.png',
                                          width: 56,
                                          height: 28,
                                          fit: BoxFit.contain,
                                          filterQuality: FilterQuality.high,
                                          isAntiAlias: true,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.circle,
                                                    size: 28,
                                                    color: Colors.cyan,
                                                  ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          loc.advancedAiAnalysis,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      _kitCode != null && _kitCode!.isNotEmpty
                                          ? _kitCode!
                                          : loc.unknown,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    LinearProgressIndicator(
                                      value:
                                          (_pointsTotal > 0)
                                              ? (_points / _pointsTotal)
                                              : 0,
                                      backgroundColor:
                                          isDark
                                              ? Colors.grey[800]
                                              : const Color(0xFFE8EBF0),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isDark
                                            ? Colors.blue
                                            : const Color(0xFF3B82F6),
                                      ),
                                      minHeight: 4,
                                    ),
                                    const SizedBox(height: 6),

                                    Row(
                                      children: [
                                        const Spacer(),
                                        Text(
                                          loc.scansCompleted(
                                            _points,
                                            _pointsTotal,
                                          ),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              Container(
                                width: 150,
                                height: 170,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Lottie.asset(
                                  'assets/animations/Scanning.json',
                                  width: 80,
                                  height: 120,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),
                       Row(
                            children: [
                              Expanded(
                                child: TextButton.icon(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      
                                      builder: (context) => const GuidePage(),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.menu_book,
                                    size: 16,
                                    color: isDark
                                        ? Colors.white.withOpacity(0.8)
                                        : Colors.black.withOpacity(0.7),
                                  ),
                                  label: Text(
                                    loc.readGuide,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.9)
                                          : Colors.black.withOpacity(0.8),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    backgroundColor: isDark
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.15),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const ScannerPage(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.camera_alt, size: 16),
                                  label: Text(
                                    loc.takePicture,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kTesiaColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    elevation: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Text(
                            loc.yourLatestScans,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LatestScansPage(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 8,
                              ),
                              child: Text(
                                loc.seeMore,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    _scansLoading
                        ? _buildScansShimmer(context)
                        : _latestScans.isNotEmpty
                        ? _buildLatestScansList(context, loc)
                        : _buildNoScansView(context, loc, isDark),

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

  Widget _buildScansShimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLatestScansList(BuildContext context, AppLocalizations loc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          mainAxisExtent: 220.0, 
        ),
        itemCount: _latestScans.length,
        itemBuilder: (context, index) {
          final scan = _latestScans[index];
          return _buildLatestScanCard(context, scan, isDark);
        },
      ),
    );
  }


  Widget _buildCompactCard(
    BuildContext context,
    String imagePath,
    String moldType,
    String confidence,
    String severity,
    int dangerPercent,
    bool isDark,
    double imageHeight,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          child: SizedBox(
            height: 110, 
            width: double.infinity,
            child:
                imagePath.isNotEmpty
                    ? CachedNetworkImage(
                      imageUrl: imagePath,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported,
                              color:
                                  isDark ? Colors.grey[600] : Colors.grey[400],
                            ),
                          ),
                    )
                    : Container(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      child: Icon(
                        Icons.image_not_supported,
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ),
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, 
              children: [
                Text(
                  moldType,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        confidence,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 38,
                      height: 38,
                      child: DangerMeter(percent: dangerPercent),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLatestScanCard(
    BuildContext context,
    Map<String, dynamic> scan,
    bool isDark, {
    bool fullWidth = false,
  }) {
    final moldType = scan['moldType'] ?? 'Unknown';
    final confidence = scan['confidence'] ?? '0%';
    final imagePath =
        (scan['resolvedImage'] ?? scan['imagePath'] ?? '') as String;
    final severity = scan['severity'] ?? 'Medium';
    final dangerPercent = _calculateDangerPercent(scan);

    final cardWidth = fullWidth ? double.infinity : 160.0;
    final imageHeight = fullWidth ? 140.0 : 75.0;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => ResultsPage(
                  moldType: moldType,
                  confidence: confidence,
                  imagePath: imagePath,
                  description: scan['description'] ?? 'Scan result',
                  overviewText: scan['overviewText'] ?? '',
                  habitatText: scan['habitatText'] ?? '',
                  detectionStats: Map<String, dynamic>.from(
                    scan['detectionStats'] ?? {},
                  ),
                  healthRisks:
                      (scan['healthRisks'] is List)
                          ? (scan['healthRisks'] as List)
                              .map<Map<String, String>>((item) {
                                if (item is Map) {
                                  final m = Map<String, dynamic>.from(item);
                                  return {
                                    'title': (m['title'] ?? '').toString(),
                                    'details': (m['details'] ?? '').toString(),
                                  };
                                }

                                return {'title': '', 'details': ''};
                              })
                              .toList()
                          : <Map<String, String>>[],
                  preventionMethods: List<String>.from(
                    scan['preventionMethods'] ?? [],
                  ),
                ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(
          color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color:
                  isDark
                      ? Colors.black.withOpacity(0.3)
                      : const Color(0xFF000000).withOpacity(0.06),
              spreadRadius: 0,
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child:
            fullWidth
                ? _buildFullWidthCard(
                  context,
                  imagePath,
                  moldType,
                  confidence,
                  severity,
                  dangerPercent,
                  isDark,
                )
                : _buildCompactCard(
                  context,
                  imagePath,
                  moldType,
                  confidence,
                  severity,
                  dangerPercent,
                  isDark,
                  imageHeight,
                ),
      ),
    );
  }

 
  Widget _buildFullWidthCard(
    BuildContext context,
    String imagePath,
    String moldType,
    String confidence,
    String severity,
    int dangerPercent,
    bool isDark,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
          child: SizedBox(
            width: 110,
            height: 110,
            child:
                imagePath.isNotEmpty
                    ? CachedNetworkImage(
                      imageUrl: imagePath,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported,
                              color:
                                  isDark ? Colors.grey[600] : Colors.grey[400],
                            ),
                          ),
                    )
                    : Container(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      child: Icon(
                        Icons.image_not_supported,
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  moldType,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      confidence,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            severity == 'High'
                                ? Colors.red.withOpacity(0.1)
                                : severity == 'Medium'
                                ? Colors.orange.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        severity,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color:
                              severity == 'High'
                                  ? Colors.red
                                  : severity == 'Medium'
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),

        Container(
          width: 64,
          padding: const EdgeInsets.only(right: 12),
          alignment: Alignment.center,
          child: SizedBox(
            width: 48,
            height: 48,
            child: DangerMeter(percent: dangerPercent),
          ),
        ),
      ],
    );
  }

  int _calculateDangerPercent(Map<String, dynamic> scan) {
    final stats = scan['detectionStats'] as Map<String, dynamic>? ?? {};
    final severity = (stats['severity'] ?? 'Unknown').toString().toLowerCase();
    switch (severity) {
      case 'high':
        return 90;
      case 'medium':
        return 60;
      case 'low':
        return 30;
      default:
        return 50;
    }
  }

  Widget _buildNoScansView(
    BuildContext context,
    AppLocalizations loc,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Card(
        elevation: isDark ? 2 : 1,
        shadowColor:
            isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              SizedBox(
                height: 110,
                width: 110,
                child: Lottie.asset(
                  'assets/animations/norecentscans.json',
                  fit: BoxFit.contain,
                  repeat: false,
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.noRecentScans,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.getStartedByScanningMold,
                      style: TextStyle(
                        fontSize: 14,
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
        ),
      ),
    );
  }
}

class DangerMeter extends StatelessWidget {
  final int percent;
  const DangerMeter({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DangerMeterPainter(percent.clamp(0, 100)),
      child: const SizedBox.expand(),
    );
  }
}

class _DangerMeterPainter extends CustomPainter {
  final int percent;
  _DangerMeterPainter(this.percent);

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
