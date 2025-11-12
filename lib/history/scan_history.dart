import 'package:flutter/material.dart';
import 'package:tesia_app/l10n/app_localizations.dart';
import 'package:tesia_app/scans/scanner.dart';
import 'package:tesia_app/scans/Results_page.dart';
import 'package:tesia_app/shared/colors.dart';
import 'package:tesia_app/shared/shimmer/scan_history_shimmer.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class ScanHistoryPage extends StatefulWidget {
  const ScanHistoryPage({super.key});

  @override
  _ScanHistoryPageState createState() => _ScanHistoryPageState();
}

class _ScanHistoryPageState extends State<ScanHistoryPage> {
  List<ScanRecord> _cachedScans = [];

  final Map<String, String> _resolvedUrlCache = {};

  String selectedDanger = 'All';
  int selectedConfidence = 0;
  String query = '';
  bool _isLoading = true;
  bool _hasLoadedOnce = false;
  String selectedFilter = 'All';

  List<String> _availableFilters = ['All'];
  final TextEditingController _modalFilterSearchController =
      TextEditingController();

  List<String> _moldTypeList() {
    if (_availableFilters.length > 1) return _availableFilters;
    final names =
        _cachedScans
            .map((s) => s.moldType.trim())
            .where((t) => t.isNotEmpty)
            .toSet()
            .toList();
    names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return ['All', ...names];
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }




  Future<void> _loadData() async {
    if (!_hasLoadedOnce) {
      setState(() => _isLoading = true);
    }

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasLoadedOnce = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasLoadedOnce = true;
        });
      }
    }
  }

  
  List<ScanRecord> _getFilteredHistory(
    AppLocalizations loc,
    List<ScanRecord> scanHistory,
  ) {
    List<ScanRecord> base = scanHistory;

    if (selectedFilter != 'All') {
      final moldTypeKey = _getMoldTypeKey(selectedFilter);
      base =
          base
              .where(
                (r) => r.moldType.toLowerCase() == moldTypeKey.toLowerCase(),
              )
              .toList();
    }

    if (selectedDanger != 'All') {
      final want = selectedDanger.toLowerCase();
      base =
          base.where((r) {
            final sev =
                (r.detectionStats['severity'] ?? '').toString().toLowerCase();
            return sev == want;
          }).toList();
    }

    if (selectedConfidence > 0) {
      base =
          base.where((r) {
            final match = RegExp(r'(\d+)').firstMatch(r.confidence);
            if (match == null) return false;
            final val = int.tryParse(match.group(1)!) ?? 0;
            return val >= selectedConfidence;
          }).toList();
    }

    if (query.trim().isEmpty) return base;
    final q = query.toLowerCase();
    return base
        .where(
          (r) =>
              r.moldType.toLowerCase().contains(q) ||
              r.description.toLowerCase().contains(q),
        )
        .toList();
  }

  String _getMoldTypeKey(String filterLabel) => filterLabel;

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filterOptions =
        _availableFilters.isNotEmpty ? _availableFilters : _moldTypeList();
    return Container(
      color: isDark ? const Color(0xFF121212) : Colors.grey[50],
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      loc.scanHistory,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _showFilterMenu(context, loc, filterOptions);
                    },
                    icon: Icon(Icons.filter_list_outlined, color: kTesiaColor),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  TextField(
                    onChanged: (v) => setState(() => query = v),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: loc.searchByMoldOrNotes,
                      hintStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      filled: true,
                      fillColor:
                          isDark
                              ? Theme.of(context).colorScheme.surface
                              : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: kTesiaColor, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 42,
                    child:
                        _isLoading
                            ? const FilterChipsShimmer()
                            : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: filterOptions.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(width: 8),
                              itemBuilder: (context, i) {
                                final f = filterOptions[i];
                                final sel = f == selectedFilter;
                                
                                return FilterChip(
                                  label: Text(f),
                                  selected: sel,
                                  onSelected: (_) {
                                    setState(() => selectedFilter = f);
                                  },
                                  selectedColor: kTesiaColor,
                                  backgroundColor:
                                      isDark
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.surface
                                          : Colors.grey[100],
                                  checkmarkColor: Colors.white,
                                  showCheckmark: true,
                                  labelStyle: TextStyle(
                                    color:
                                        sel
                                            ? Colors.white
                                            : Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                    fontWeight:
                                        sel ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                color: kTesiaColor,
                child: _buildScanHistoryStream(loc),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterMenu(
    BuildContext context,
    AppLocalizations loc,
    List<String>? filterOptions,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    filterOptions ??= _moldTypeList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          minChildSize: 0.35,
          maxChildSize: 0.95,
          builder: (sheetCtx, scrollController) {
            String modalFilter = selectedFilter;
            String modalDanger = selectedDanger;
            int modalConfidence = selectedConfidence;
            String localSearch = '';

            return StatefulBuilder(
              builder: (sheetCtx2, setModalState) {
                return Container(
                  width: MediaQuery.of(ctx).size.width,
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? Theme.of(context).colorScheme.surface
                            : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0, bottom: 6),
                          child: Container(
                            width: 48,
                            height: 4,
                            decoration: BoxDecoration(
                              color:
                                  isDark ? Colors.grey[700] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            children: [
                              Text(
                                loc.filterBy,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _modalFilterSearchController,
                                onChanged:
                                    (v) => setModalState(
                                      () => localSearch = v.toLowerCase(),
                                    ),
                                decoration: InputDecoration(
                                  hintText: loc.searchByMoldOrNotes,
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color:
                                        isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                  ),
                                  filled: true,
                                  fillColor:
                                      isDark
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.surface
                                          : Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              Text(
                                loc.moldType ?? 'Mold type',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children:
                                    (filterOptions ?? _moldTypeList())
                                        .where(
                                          (f) =>
                                              localSearch.isEmpty ||
                                              f.toLowerCase().contains(
                                                localSearch,
                                              ),
                                        )
                                        .map((filter) {
                                          final isSel = filter == modalFilter;
                                          return FilterChip(
                                            label: Text(filter),
                                            selected: isSel,
                                            onSelected:
                                                (_) => setModalState(
                                                  () => modalFilter = filter,
                                                ),
                                            selectedColor: kTesiaColor,
                                            backgroundColor:
                                                isDark
                                                    ? Theme.of(
                                                      context,
                                                    ).colorScheme.surface
                                                    : Colors.grey[100],  labelStyle: TextStyle(
                                          color:
                                              isSel
                                                  ? Colors.white
                                                  : Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                        ),
                                            checkmarkColor: Colors.white,
                                          );
                                          
                                        })
                                        .toList(),
                              ),

                              const SizedBox(height: 16),
                              Text(
                                loc.dangerLevel ?? 'Danger',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children:
                                    ['All', loc.low, loc.medium, loc.high].map((
                                      d,
                                    ) {
                                      final label = d ?? 'All';
                                      final isSel = label == modalDanger;
                                      return ChoiceChip(
                                        label: Text(label),
                                        selected: isSel,
                                        onSelected:
                                            (_) => setModalState(
                                              () => modalDanger = label,
                                            ),
                                        selectedColor: kTesiaColor,
                                        backgroundColor:
                                            isDark
                                                ? Theme.of(
                                                  context,
                                                ).colorScheme.surface
                                                : Colors.grey[100],
                                        labelStyle: TextStyle(
                                          color:
                                              isSel
                                                  ? Colors.white
                                                  : Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                        ),
                                        checkmarkColor: Colors.white,
                                      );
                                    }).toList(),
                              ),

                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    loc.certainty ?? 'Certainty',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                  Text(
                                    modalConfidence == 0
                                        ? loc.any ?? 'Any'
                                        : '≥ ${modalConfidence}%',

                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color:
                                             isDark
                                                ? Colors.grey[100]
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                                  SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: kTesiaColor,
                                  inactiveTrackColor:
                                      isDark ? Colors.grey[800] : Colors.grey[300],
                                  trackHeight: 4,
                                  thumbColor: kTesiaColor,
                                  overlayColor: kTesiaColor.withOpacity(0.12),
                                  valueIndicatorColor: kTesiaColor,
                                  showValueIndicator: ShowValueIndicator.always,
                                  valueIndicatorTextStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                child: Slider(
                                  value: modalConfidence.toDouble(),
                                  min: 0,
                                  max: 100,
                                  divisions: 20,
                                  activeColor: kTesiaColor,
                                  label: modalConfidence == 0
                                      ? (loc.any ?? 'Any')
                                      : '${modalConfidence}%',
                                  onChanged: (v) => setModalState(
                                    () => modalConfidence = v.round(),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),
                              Text(
                                '${loc.any} • ${loc.low}/${loc.medium}/${loc.high}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                                ? Colors.grey[100]
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          color:
                              isDark
                                  ? Theme.of(context).colorScheme.surface
                                  : Colors.white,
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    setModalState(() {
                                      modalFilter = 'All';
                                      modalDanger = 'All';
                                      modalConfidence = 0;
                                      _modalFilterSearchController.clear();
                                    });
                                    if (mounted) {
                                      setState(() {
                                        selectedFilter = 'All';
                                        selectedDanger = 'All';
                                        selectedConfidence = 0;
                                      });
                                    }
                                    Navigator.pop(ctx);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: kTesiaColor),
                                    foregroundColor: kTesiaColor,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(loc.reset ?? 'Reset'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (mounted) {
                                      setState(() {
                                        selectedFilter = modalFilter;
                                        selectedDanger = modalDanger;
                                        selectedConfidence = modalConfidence;
                                      });
                                    }
                                    _modalFilterSearchController.clear();
                                    Navigator.pop(ctx);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kTesiaColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(loc.apply ?? 'Apply'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  void setStateOrModal({
    required Function(Function()) setModal,
    required Function(Function()) setModalState,
    required BuildContext ctx,
    required VoidCallback action,
  }) {
    action();

    if (mounted) setState(() {});
  }

Widget _buildCard(ScanRecord r, AppLocalizations loc, bool isDark) {
  final dangerColor = _getDangerColor(r.dangerLevel);
  final dangerText = _getDangerText(r.dangerLevel, loc);
  
  
  final severity = (r.detectionStats['severity'] ?? 'Unknown').toString();
  final severityDisplay = _getSeverityDisplay(severity, loc);

  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsPage(
            moldType: r.moldType,
            confidence: r.confidence,
            imagePath: r.imagePath,
            description: r.description,
            overviewText: r.overviewText,
            habitatText: r.habitatText,
            detectionStats: r.detectionStats,
            healthRisks: r.healthRisks,
            preventionMethods: r.preventionMethods,
          ),
        ),
      );
    },
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.04),
            blurRadius: isDark ? 12 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 80,
              height: 80,
              child: _buildOptimizedImage(r.imagePath, isDark),
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        r.moldType,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(r.date, loc),
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                Text(
                  r.description,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: kTesiaColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        r.confidence,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),

                    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          loc.danger,
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: CircularProgressIndicator(
                                      value: r.dangerLevel,
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        dangerColor,
                                      ),
                                      backgroundColor: isDark
                                          ? Colors.grey[800]
                                          : Colors.grey[200],
                                    ),
                                  ),
                                  
                                  Text(
                                    severityDisplay,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: dangerColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


String _getSeverityDisplay(String severity, AppLocalizations loc) {
  switch (severity.toLowerCase()) {
    case 'high':
      return loc.high.toUpperCase();
    case 'medium':
      return loc.medium.substring(0, 3).toUpperCase(); 
    case 'low':
      return loc.low.toUpperCase();
    default:
      return '?';
  }
}


Widget _buildOptimizedImage(String? imagePath, bool isDark) {
  if (imagePath == null || imagePath.isEmpty) {
    return _buildPlaceholder(isDark, Icons.image_not_supported);
  }

  
  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    return CachedNetworkImage(
      imageUrl: imagePath,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      memCacheWidth: 240, 
      memCacheHeight: 240,
      maxWidthDiskCache: 400, 
      maxHeightDiskCache: 400,
      placeholder: (_, __) => _buildPlaceholder(isDark, null),
      errorWidget: (_, __, ___) => _buildPlaceholder(isDark, Icons.broken_image),
    );
  }

  
  return FutureBuilder<String?>(
    future: _resolveStorageUrlIfNeeded(imagePath),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _buildPlaceholder(isDark, null);
      }

      final url = snapshot.data;
      if (url == null || url.isEmpty) {
        return _buildPlaceholder(isDark, Icons.broken_image);
      }

      return CachedNetworkImage(
        imageUrl: url,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        memCacheWidth: 240, 
        memCacheHeight: 240,
        maxWidthDiskCache: 400,
        maxHeightDiskCache: 400,
        placeholder: (_, __) => _buildPlaceholder(isDark, null),
        errorWidget: (_, __, ___) => _buildPlaceholder(isDark, Icons.broken_image),
      );
    },
  );
}


Widget _buildPlaceholder(bool isDark, IconData? icon) {
  return Container(
    color: isDark ? Colors.grey[800] : Colors.grey[200],
    child: icon != null
        ? Icon(
            icon,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
            size: 32,
          )
        : const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
  );
}


Future<String?> _resolveStorageUrlIfNeeded(String? path) async {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  
  
  if (_resolvedUrlCache.containsKey(path)) return _resolvedUrlCache[path];
  
  try {
    Reference ref;
    if (path.startsWith('gs://')) {
      ref = FirebaseStorage.instance.refFromURL(path);
    } else if (path.contains('/o/')) {
      ref = FirebaseStorage.instance.refFromURL(path);
    } else {
      ref = FirebaseStorage.instance.ref(path);
    }
    
    
    final url = await ref.getDownloadURL().timeout(
      const Duration(seconds: 5),
      onTimeout: () => throw TimeoutException('URL resolution timeout'),
    );
    
    _resolvedUrlCache[path] = url;
    return url;
  } catch (e) {
    return null;
  }
}

  Color _getDangerColor(double level) {
    if (level < 0.3) return Colors.green;
    if (level < 0.6) return Colors.orange;
    return Colors.red;
  }

  String _getDangerText(double level, AppLocalizations loc) {
    if (level < 0.3) return loc.low;
    if (level < 0.6) return loc.medium;
    return loc.high;
  }

  String _formatDate(DateTime date, AppLocalizations loc) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return loc.today;
    if (diff.inDays == 1) return loc.yesterday;
    if (diff.inDays < 7) return loc.daysAgo(diff.inDays);
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildEmptyState(AppLocalizations loc) {
    return ListView(
      children: [
        const SizedBox(height: 40),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 180,
              width: 180,
              child: Lottie.asset(
                'assets/animations/nohistory.json',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              loc.noScansYet,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Text(
                loc.noScansDescription,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScannerPage()),
                );
              },
              icon: const Icon(Icons.camera_alt, size: 16),
              label: Text(loc.takePicture),
              style: ElevatedButton.styleFrom(
                backgroundColor: kTesiaColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScanHistoryStream(AppLocalizations loc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return _buildEmptyState(loc);
    }
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('scans')
              .orderBy('timestamp', descending: true)
              .limit(40)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !_hasLoadedOnce) {
          return const ScanCardsShimmer();
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(loc);
        }
        final scans =
            snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return ScanRecord(
                id: doc.id,
                moldType: data['moldType'] ?? 'Unknown',
                description: data['description'] ?? '',
                date:
                    (data['timestamp'] as Timestamp?)?.toDate() ??
                    DateTime.now(),
                imagePath: data['imagePath'] ?? '',
                dangerLevel: _calculateDangerLevel(
                  data['detectionStats'] ?? {},
                ),
                confidence: data['confidence'] ?? '0%',
                overviewText: data['overviewText'] ?? '',
                habitatText: data['habitatText'] ?? '',
                detectionStats: data['detectionStats'] ?? {},
                healthRisks: _parseHealthRisks(data['healthRisks']),
                preventionMethods: List<String>.from(
                  data['preventionMethods'] ?? [],
                ),
              );
            }).toList();

        final newNames =
            scans
                .map((s) => s.moldType.trim())
                .where((t) => t.isNotEmpty)
                .toSet()
                .toList()
              ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        final newFilters = ['All', ...newNames];

        if (!listEquals(newFilters, _availableFilters)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              _availableFilters = newFilters;
            });
          });
        }

        _cachedScans = scans;

        final filtered = _getFilteredHistory(loc, scans);
        if (filtered.isEmpty) {
          return _buildEmptyState(loc);
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder:
              (context, index) => _buildCard(filtered[index], loc, isDark),
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
}

class ScanRecord {
  final String id;
  final String moldType;
  final String description;
  final DateTime date;
  final String imagePath;
  final double dangerLevel;
  final String confidence;
  final String overviewText;
  final String habitatText;
  final Map<String, dynamic> detectionStats;
  final List<Map<String, String>> healthRisks;
  final List<String> preventionMethods;

  ScanRecord({
    required this.id,
    required this.moldType,
    required this.description,
    required this.date,
    required this.imagePath,
    required this.dangerLevel,
    required this.confidence,
    required this.overviewText,
    required this.habitatText,
    required this.detectionStats,
    required this.healthRisks,
    required this.preventionMethods,
  });
}
