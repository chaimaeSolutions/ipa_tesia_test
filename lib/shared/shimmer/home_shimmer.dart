import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomePageShimmer extends StatelessWidget {
  const HomePageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    _buildShimmerBox(60, 60, 12, isDark),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShimmerBox(120, 16, 8, isDark),
                          const SizedBox(height: 8),
                          _buildShimmerBox(160, 12, 6, isDark),
                          const SizedBox(height: 8),
                          _buildShimmerBox(100, 30, 15, isDark),
                        ],
                      ),
                    ),
                    _buildShimmerBox(45, 45, 12, isDark),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
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
                              _buildShimmerBox(56, 28, 4, isDark),
                              const SizedBox(height: 12),
                              _buildShimmerBox(180, 20, 8, isDark),
                              const SizedBox(height: 18),
                              _buildShimmerBox(100, 16, 6, isDark),
                              const SizedBox(height: 8),
                              _buildShimmerBox(double.infinity, 4, 2, isDark),
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.centerRight,
                                child: _buildShimmerBox(80, 12, 4, isDark),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildShimmerBox(150, 170, 40, isDark),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildShimmerBox(100, 32, 16, isDark),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildShimmerBox(double.infinity, 40, 25, isDark),
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
                    _buildShimmerBox(150, 20, 8, isDark),
                    const Spacer(),
                    _buildShimmerBox(80, 16, 6, isDark),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildScanCardShimmer(isDark),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildScanCardShimmer(isDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _buildScanCardShimmer(isDark),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildScanCardShimmer(isDark),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
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

  Widget _buildScanCardShimmer(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : const Color(0xFF000000).withOpacity(0.06),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerBox(double.infinity, 80, 10, isDark),
          const SizedBox(height: 10),
          _buildShimmerBox(100, 14, 6, isDark),
          const SizedBox(height: 6),
          _buildShimmerBox(120, 12, 6, isDark),
        ],
      ),
    );
  }
}