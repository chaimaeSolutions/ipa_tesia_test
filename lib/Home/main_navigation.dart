import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tesia_app/Home/home.dart';
import 'package:tesia_app/history/scan_history.dart';
import 'package:tesia_app/Profile/notifications_page.dart';
import 'package:tesia_app/l10n/app_localizations.dart';
import 'package:tesia_app/core/first_signin_service.dart';
import 'package:tesia_app/shared/components/welcome_popup.dart';
import 'package:tesia_app/Profile/profile_page.dart';
import 'package:tesia_app/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _checkFirstSignIn();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onNavItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _checkFirstSignIn() async {
    final isFirstSignIn = await FirstSignInService.isFirstSignIn();
    if (isFirstSignIn && mounted) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await NotificationService.createWelcomeNotification(user.uid);
      }

      await FirstSignInService.markFirstSignInComplete();
      _showWelcomePopup();
    }
  }

  void _showWelcomePopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => WelcomePopup(
            onCompleteProfile: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
              FirstSignInService.markSignInComplete();
            },
            onIgnore: () {
              Navigator.of(context).pop();
              FirstSignInService.markSignInComplete();
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: const [
          KeepAlivePage(child: HomePageContent()),
          KeepAlivePage(child: ScanHistoryPage()),
          KeepAlivePage(child: NotificationsPage()),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final double navBarHeight = (64.0 + bottomInset).clamp(64.0, 90.0);

    return SafeArea(
      minimum: const EdgeInsets.only(left: 14, right: 14, top: 8, bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              height: navBarHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      isDark
                          ? [
                            Colors.grey[900]!.withOpacity(0.8),
                            Colors.grey[850]!.withOpacity(0.7),
                          ]
                          : [
                            Colors.white.withOpacity(0.18),
                            Colors.white.withOpacity(0.10),
                          ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color:
                      isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.white.withOpacity(0.14),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        isDark
                            ? Colors.black.withOpacity(0.3)
                            : Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildNavItem(Icons.home_filled, loc.home, 0, navBarHeight),
                  _buildNavItem(Icons.bar_chart, loc.history, 1, navBarHeight),
                  _buildNavItem(
                    Icons.notifications_outlined,
                    loc.notifications,
                    2,
                    navBarHeight,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    double navBarHeight,
  ) {
    final bool isActive = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final double baseIconBox =
        isActive ? (navBarHeight * 0.62) : (navBarHeight * 0.54);

    final double iconBoxSize = math.min(baseIconBox, navBarHeight * 0.58);
    final double iconSize = isActive ? 22.0 : 20.0;

    final double verticalPadding = math.max(
      4.0,
      (navBarHeight - iconBoxSize - 12.0) / 4.0,
    );

    return Expanded(
      child: GestureDetector(
        onTap: () => _onNavItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          padding: EdgeInsets.symmetric(
            horizontal: 6,
            vertical: verticalPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints.tightFor(
                  width: iconBoxSize,
                  height: iconBoxSize,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color:
                        isActive
                            ? (isDark
                                ? Colors.white.withOpacity(0.15)
                                : Colors.white.withOpacity(0.22))
                            : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    color:
                        isDark
                            ? (isActive ? Colors.white : Colors.white70)
                            : (isActive ? Colors.black87 : Colors.black54),
                    size: iconSize,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                width: isActive ? 28 : 0,
                height: 4,
                decoration: BoxDecoration(
                  color:
                      isActive
                          ? (isDark ? Colors.white : Colors.black87)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KeepAlivePage extends StatefulWidget {
  final Widget child;
  const KeepAlivePage({super.key, required this.child});

  @override
  State<KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
