import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:tesia_app/authentication/signin_screen.dart';
import 'package:tesia_app/core/locale_provider.dart';
import 'package:tesia_app/core/theme_provider.dart';
import 'package:tesia_app/l10n/app_localizations.dart';
import 'package:tesia_app/onboarding_screens/guide_page.dart';
import 'package:tesia_app/shared/colors.dart';
import 'package:tesia_app/onboarding_screens/signup_gate_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _showGetStarted = false;
  bool _langExpanded = false;

  List<Map<String, dynamic>> get _pages {
    final loc = AppLocalizations.of(context)!;
    return [
      {
        'isCover': true,
        'title': 'TESIA',
        'subtitle': loc.onboardingCoverSubtitle,
        'image': 'assets/logos/Tesia_nobg.png',
      },
      {
        'title': loc.scanMold,
        'description': loc.scanMoldDescription,
        'image': 'assets/images/onboarding/onboarding1.png',
      },
      {
        'title': loc.aiAnalysis,
        'description': loc.aiAnalysisDescription,
        'image': 'assets/images/onboarding/onboarding2.png',
      },
      {
        'title': loc.fastResults,
        'description': loc.fastResultsDescription,
        'image': 'assets/images/onboarding/onboarding3.png',
      },
      {
        'title': loc.getStartedTitle,
        'description': loc.getStartedDescription,
        'image': 'assets/images/onboarding/onboarding4.png',
      },
    ];
  }

  final Map<String, Map<String, String>> _languages = {
    'en': {'flag': '🇺🇸', 'name': 'English'},
    'es': {'flag': '🇪🇸', 'name': 'Español'},
  };

  void _showThemeSelectorModal() {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                loc.changeTheme,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return Column(
                    children: [
                      _buildThemeOption(
                        context: context,
                        themeProvider: themeProvider,
                        mode: ThemeMode.light,
                        title: loc.light,
                        icon: Icons.light_mode,
                      ),
                      _buildThemeOption(
                        context: context,
                        themeProvider: themeProvider,
                        mode: ThemeMode.dark,
                        title: loc.dark,
                        icon: Icons.dark_mode,
                      ),
                      _buildThemeOption(
                        context: context,
                        themeProvider: themeProvider,
                        mode: ThemeMode.system,
                        title: loc.auto,
                        icon: Icons.brightness_auto,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required ThemeProvider themeProvider,
    required ThemeMode mode,
    required String title,
    required IconData icon,
  }) {
    final bool isSelected = themeProvider.themeMode == mode;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? kTesiaColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? kTesiaColor : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
                isSelected
                    ? kTesiaColor.withOpacity(0.15)
                    : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color:
                isSelected
                    ? kTesiaColor
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color:
                isSelected
                    ? (isDark ? Colors.white : kTesiaColor)
                    : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        trailing:
            isSelected
                ? Icon(Icons.check_circle, color: kTesiaColor, size: 24)
                : null,
        onTap: () {
          themeProvider.setTheme(mode);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildThemeSelector() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(top: 16, right: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: kTesiaColor.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: kTesiaColor.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: _showThemeSelectorModal,
        borderRadius: BorderRadius.circular(22),
        splashColor: kTesiaColor.withOpacity(0.2),
        highlightColor: kTesiaColor.withOpacity(0.1),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(
            () {
              switch (themeProvider.themeMode) {
                case ThemeMode.light:
                  return Icons.light_mode;
                case ThemeMode.dark:
                  return Icons.dark_mode;
                case ThemeMode.system:
                default:
                  return Icons.brightness_auto;
              }
            }(),
            color: isDark ? Colors.white : kTesiaColor,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildLangSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLangCode = localeProvider.locale.languageCode;
    final lang = _languages[currentLangCode] ?? _languages['en']!;
    final loc = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kTesiaColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: kTesiaColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _langExpanded = !_langExpanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: kTesiaColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.language_rounded,
                      color: isDark ? Colors.white : kTesiaColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.language,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              lang['flag']!,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              lang['name']!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  AnimatedRotation(
                    turns: _langExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: kTesiaColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isDark ? Colors.white : kTesiaColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            height: _langExpanded ? (_languages.length * 60.0) : 0,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  if (_langExpanded)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: kTesiaColor.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ..._languages.entries.map((entry) {
                    final code = entry.key;
                    final flag = entry.value['flag']!;
                    final name = entry.value['name']!;
                    final selected = currentLangCode == code;

                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _langExpanded ? 1.0 : 0.0,
                      child: InkWell(
                        onTap: () {
                          if (!selected) {
                            Locale locale = Locale(code);
                            Provider.of<LocaleProvider>(
                              context,
                              listen: false,
                            ).setLocale(locale);
                          }
                          setState(() => _langExpanded = false);
                        },
                        child: Container(
                          height: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color:
                                selected
                                    ? kTesiaColor.withOpacity(0.08)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color:
                                      selected
                                          ? kTesiaColor.withOpacity(0.15)
                                          : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child:
                                      selected
                                          ? Icon(
                                            Icons.check_rounded,
                                            color:
                                                isDark
                                                    ? Colors.white
                                                    : kTesiaColor,
                                            size: 20,
                                          )
                                          : Text(
                                            flag,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              Expanded(
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    color:
                                        selected
                                            ? (isDark
                                                ? Colors.white
                                                : kTesiaColor)
                                            : Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                    fontWeight:
                                        selected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ),

                              if (selected)
                                Text(
                                  flag,
                                  style: const TextStyle(fontSize: 18),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverPage(Map<String, dynamic> page) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      height: screenHeight,
      constraints: BoxConstraints(minHeight: screenHeight),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDark
                  ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                  : [Colors.white, const Color(0xFFFAFAFA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: screenHeight * 0.1),
                            Text(
                              loc.welcomeTo,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w300,
                                color: isDark ? Colors.white : Colors.black,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 40),
                            Image.asset(
                              'assets/logos/Tesia_nobg.png',
                              height: 72,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 15),
                            Text(
                              page['subtitle']!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.8),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 40),
                            _buildLangSelector(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 24, bottom: 12),
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kTesiaColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              loc.getStarted,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Text(
                        loc.termsAndPrivacy,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 100,
              right: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? kTesiaColor.withOpacity(0.12) 
                          : kTesiaColor.withOpacity(0.05),
                  boxShadow:
                      isDark
                          ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ]
                          : null,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 200,
              left: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? kTesiaColor.withOpacity(0.08) 
                          : kTesiaColor.withOpacity(0.03),
                  boxShadow:
                      isDark
                          ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ]
                          : null,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Positioned(top: 0, right: 0, child: _buildThemeSelector()),
          ],
        ),
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => const SignInScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Widget _buildProgressBar({required int count, required int current}) {
    final loc = AppLocalizations.of(context)!;
    final List<IconData> stepIcons = [
      Icons.camera_alt,
      Icons.analytics,
      Icons.flash_on,
      Icons.task_alt,
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              loc.stepXofY(current + 1, count),
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              loc.percentComplete(((current + 1) / count * 100).round()),
              style: TextStyle(
                fontSize: 12,
                color: kTesiaColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (int i = 0; i < count; i++) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      i <= current ? kTesiaColor : Colors.grey.withOpacity(0.3),
                  boxShadow:
                      i <= current
                          ? [
                            BoxShadow(
                              color: kTesiaColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: Icon(
                  stepIcons[i],
                  color: i <= current ? Colors.white : Colors.grey.shade600,
                  size: 20,
                ),
              ),
              if (i < count - 1)
                Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color:
                          i < current
                              ? kTesiaColor
                              : Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (int i = 0; i < count; i++) ...[
              SizedBox(
                width: 40,
                child: Text(
                  '${i + 1}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: i <= current ? kTesiaColor : Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (i < count - 1)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildPageContent(Map<String, dynamic> page, int index) {
    final loc = AppLocalizations.of(context)!;
    final isCover = page['isCover'] == true;
    final isLast = index == _pages.length - 1;

    if (isCover) {
      return _buildCoverPage(page);
    }

    return Scaffold(
      backgroundColor:
          Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1A1A2E)
              : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1A1A2E)
                      : const Color(0xFFF5F7FA),
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Transform.scale(
                    scale: 1,
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      'assets/logos/Tesia_nobg.png',
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                  ),

                  if (!isLast)
                    TextButton(
                      onPressed: () {
                        _pageController.animateToPage(
                          _pages.length - 1,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
                        loc.skip,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          height: 260,
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF1A1A2E)
                                  : const Color(0xFFF5F7FA),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: AnimatedScale(
                              scale: _currentPage == index ? 1.2 : 1.0,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOut,
                              child: Image.asset(
                                page['image']!,
                                width: MediaQuery.of(context).size.width * 0.65,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),

                        Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              constraints: BoxConstraints(
                                minHeight:
                                    MediaQuery.of(context).size.height -
                                    260 -
                                    54,
                              ),
                              color: Colors.white,
                              padding: const EdgeInsets.only(
                                left: 32,
                                right: 32,
                                top: 55,
                                bottom: 100,
                              ),
                              child: Column(
                                children: [
                                  _buildProgressBar(
                                    count: _pages.length - 1,
                                    current: index - 1 < 0 ? 0 : index - 1,
                                  ),
                                  const SizedBox(height: 25),
                                  Text(
                                    page['title']!,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      height: 1.2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    page['description'] ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black.withOpacity(0.7),
                                      height: 1.5,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            ClipPath(
                              clipper: WaveClipper(),
                              child: Container(
                                height: 40,
                                width: double.infinity,
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFF1A1A2E)
                                        : const Color(0xFFF5F7FA),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.only(
                        left: 32,
                        right: 32,
                        bottom: 20,
                        top: 15,
                      ),
                      child: SafeArea(
                        top: false,
                        child: _buildButtonSection(index, isLast),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonSection(int index, bool isLast) {
    final loc = AppLocalizations.of(context)!;

    if (index == 1) {
      return Center(
        child: ElevatedButton(
          onPressed: isLast ? _completeOnboarding : _nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: kTesiaColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
          ),
          child: Text(
            isLast ? loc.takePicture : loc.next,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
      );
    } else if (isLast) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            child: OutlinedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const GuidePage(),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: kTesiaColor,
                side: BorderSide(color: kTesiaColor, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book_rounded, size: 20, color: kTesiaColor),
                  const SizedBox(width: 8),
                  Text(
                    loc.readGuide,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('onboardingComplete', true);

                if (!mounted) return;
             Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const SignupGatePage(
                  ),
                ),
              );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kTesiaColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    loc.takePicture,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          if (!isLast && _currentPage > 1)
            TextButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
              child: Text(
                loc.prev,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            const SizedBox(width: 48),

          const Spacer(),

          ElevatedButton(
            onPressed: isLast ? _completeOnboarding : _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: kTesiaColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
            child: Text(
              isLast ? loc.takePicture : loc.next,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient:
              _currentPage == 0
                  ? LinearGradient(
                    colors:
                        isDark
                            ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                            : [Colors.white, const Color(0xFFFAFAFA)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                  : null,
          color:
              _currentPage == 0
                  ? null
                  : (isDark
                      ? const Color(0xFF1A1A2E)
                      : const Color(0xFFF5F7FA)),
        ),
        child: PageView.builder(
          controller: _pageController,
          itemCount: _pages.length,
          onPageChanged: (int page) {
            setState(() {
              _currentPage = page;
              if (page == _pages.length - 1) {
                Future.delayed(const Duration(milliseconds: 700), () {
                  if (mounted) setState(() => _showGetStarted = true);
                });
              } else {
                _showGetStarted = false;
              }
            });
          },
          itemBuilder: (context, index) {
            return _buildPageContent(_pages[index], index);
          },
        ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 20);

    path.quadraticBezierTo(
      size.width / 4,
      size.height,
      size.width / 2,
      size.height - 10,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 20,
      size.width,
      size.height,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
