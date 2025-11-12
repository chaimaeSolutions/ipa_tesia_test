import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FilterChipsShimmer extends StatelessWidget {
  const FilterChipsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final widths = [80.0, 100.0, 90.0, 110.0];
        return _buildShimmerBox(widths[index], 42, 20, isDark);
      },
    );
  }

  Widget _buildShimmerBox(
    double width,
    double height,
    double borderRadius,
    bool isDark,
  ) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ScanCardsShimmer extends StatelessWidget {
  const ScanCardsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildCardShimmer(isDark);
      },
    );
  }

  Widget _buildCardShimmer(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
          _buildShimmerBox(80, 80, 10, isDark),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildShimmerBox(120, 16, 6, isDark),
                    const Spacer(),
                    _buildShimmerBox(60, 12, 4, isDark),
                  ],
                ),
                const SizedBox(height: 8),
                _buildShimmerBox(double.infinity, 12, 4, isDark),
                const SizedBox(height: 4),
                _buildShimmerBox(180, 12, 4, isDark),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildShimmerBox(60, 24, 10, isDark),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildShimmerBox(40, 10, 4, isDark),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _buildShimmerBox(36, 36, 18, isDark),
                            const SizedBox(width: 8),
                            _buildShimmerBox(50, 14, 4, isDark),
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
    );
  }

  Widget _buildShimmerBox(
    double width,
    double height,
    double borderRadius,
    bool isDark,
  ) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}