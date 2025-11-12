import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProfilePageShimmer extends StatelessWidget {
  const ProfilePageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildShimmerBox(40, 40, 10, isDark),
                  _buildShimmerBox(80, 24, 8, isDark),
                  _buildShimmerBox(40, 40, 10, isDark),
                ],
              ),
              SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildShimmerCircle(88, isDark),
                  const SizedBox(width: 12),
                  _buildShimmerCircle(48, isDark),
                ],
              ),
              SizedBox(height: 16),

              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _buildShimmerBox(32, 32, 5, isDark),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildShimmerBox(80, 16, 8, isDark),
                                  SizedBox(height: 6),
                                  _buildShimmerBox(100, 12, 6, isDark),
                                ],
                              ),
                            ],
                          ),
                          _buildShimmerBox(40, 16, 8, isDark),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildShimmerBox(
                              double.infinity,
                              5,
                              3,
                              isDark,
                            ),
                          ),
                          SizedBox(width: 8),
                          _buildShimmerBox(30, 12, 6, isDark),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerBox(80, 16, 8, isDark),
                      SizedBox(height: 8),
                      _buildShimmerBox(double.infinity, 40, 5, isDark),
                      SizedBox(height: 24),

                      _buildShimmerBox(60, 16, 8, isDark),
                      SizedBox(height: 8),
                      _buildShimmerBox(double.infinity, 40, 5, isDark),
                      SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildShimmerBox(120, 16, 8, isDark),
                                SizedBox(height: 6),
                                _buildShimmerBox(200, 14, 7, isDark),
                              ],
                            ),
                          ),
                          _buildShimmerBox(24, 24, 12, isDark),
                        ],
                      ),
                      SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildShimmerBox(100, 16, 8, isDark),
                                SizedBox(height: 6),
                                _buildShimmerBox(180, 14, 7, isDark),
                              ],
                            ),
                          ),
                          _buildShimmerBox(24, 24, 12, isDark),
                        ],
                      ),
                      SizedBox(height: 32),

                      _buildShimmerBox(double.infinity, 50, 12, isDark),
                    ],
                  ),
                ),
              ),
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

  Widget _buildShimmerCircle(double size, bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      ),
    );
  }
}
