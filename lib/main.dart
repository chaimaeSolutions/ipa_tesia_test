import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tesia_app/l10n/app_localizations.dart';
import 'package:tesia_app/core/theme_provider.dart';
import 'package:tesia_app/core/locale_provider.dart';
import 'package:tesia_app/onboarding_screens/onboarding_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tesia_app/authentication/signin_screen.dart';
import 'package:tesia_app/Home/main_navigation.dart';
import 'package:tesia_app/services/session_cleanup_service.dart';
import 'package:tesia_app/shared/colors.dart';
import 'firebase_options.dart';

late Future<void> _firebaseInitFuture;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _firebaseInitFuture = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((_) {
    unawaited(SessionCleanupService.cleanupExpiredSessions());
    return null;
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'TESIA',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: kTesiaColor,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: kTesiaColor,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            locale: localeProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('es')],
            home: const AppInitializer(),
          );
        },
      ),
    );
  }
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  Future<Widget> _determineInitialScreen() async {
    try {
      await _firebaseInitFuture.timeout(const Duration(seconds: 6));
    } catch (e) {
    }

    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboardingComplete') ?? false;

    if (!onboardingComplete) {
      return const OnboardingScreen();
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return const MainNavigation();
    } else {
      return const SignInScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _determineInitialScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor:
                Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF121212)
                    : Colors.white,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/logos/Tesia_nobg.png',
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return const OnboardingScreen();
        }

        return snapshot.data ?? const OnboardingScreen();
      },
    );
  }
}

