import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class NotificationsShimmer extends StatelessWidget {
  const NotificationsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _buildNotificationCardShimmer(isDark);
      },
    );
  }

  Widget _buildNotificationCardShimmer(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.04),
            blurRadius: isDark ? 12 : 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerBox(40, 40, 8, isDark), 
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildShimmerBox(150, 16, 4, isDark),
                    const Spacer(),
                    _buildShimmerBox(8, 8, 4, isDark), 
                  ],
                ),
                const SizedBox(height: 8),
                _buildShimmerBox(
                  double.infinity,
                  14,
                  4,
                  isDark,
                ), 
                const SizedBox(height: 4),
                _buildShimmerBox(200, 14, 4, isDark), 
                const SizedBox(height: 8),
                _buildShimmerBox(70, 12, 4, isDark), 
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
