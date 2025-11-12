import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:tesia_app/Home/main_navigation.dart';
import 'package:tesia_app/l10n/app_localizations.dart';
import 'package:tesia_app/core/locale_provider.dart';
import 'package:tesia_app/services/kit_service.dart';
import 'package:tesia_app/core/theme_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/gestures.dart';
import 'package:tesia_app/services/kit_service_exception.dart';
import '../shared/colors.dart';
import 'signin_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SignUpScreen extends StatefulWidget {
  final String sessionToken;
  final String kitCode;

  const SignUpScreen({
    super.key,
    required this.sessionToken,
    required this.kitCode,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  bool _isLoading = false;

  bool _showLangSelector = false;

  final Map<String, Map<String, String>> _languages = {
    'en': {'flag': '🇺🇸', 'name': 'English'},
    'es': {'flag': '🇪🇸', 'name': 'Español'},
  };

  late TapGestureRecognizer _termsRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer =
        TapGestureRecognizer()
          ..onTap = () {
            _showTermsAndConditions();
          };
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _termsRecognizer.dispose();
    super.dispose();
  }

  void _showSnack(
    String message, {
    bool error = false,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor:
            error
                ? theme.colorScheme.error
                : theme.colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        content: Text(
          message,
          style: TextStyle(
            color:
                error ? theme.colorScheme.onError : theme.colorScheme.onSurface,
            fontSize: 14,
          ),
        ),
        action:
            (actionLabel != null && onAction != null)
                ? SnackBarAction(
                  label: actionLabel,
                  onPressed: onAction,
                  textColor: theme.colorScheme.primary,
                )
                : null,
      ),
    );
  }

  Future<void> _signUp() async {
    final localizations = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms) {
      _showSnack(localizations.pleaseAcceptTerms, error: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final localeProvider = Provider.of<LocaleProvider>(
        context,
        listen: false,
      );
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

      await KitService.completeSignup(
        sessionToken: widget.sessionToken,
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _emailController.text.trim().split('@').first,
        language: localeProvider.locale.languageCode,
        theme: themeProvider.themeMode.toString().split('.').last,
      );

      await KitService.clearSession(widget.kitCode);

      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack(localizations.accountCreatedSuccessfully);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SignInScreen()),
        );
      }
    } on KitServiceException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);

        String errorMessage;
        if (e.code == 'signup_failed' && e.serverMessage != null) {
          if (e.serverMessage!.toLowerCase().contains('email already')) {
            errorMessage = localizations.emailAlreadyRegistered(
              _emailController.text.trim(),
            );
          } else if (e.serverMessage!.toLowerCase().contains('session')) {
            errorMessage =
                localizations.kitAlreadyUsed ??
                'Session expired. Please scan QR code again.';
          } else {
            errorMessage = e.serverMessage!;
          }
        } else if (e.code == 'network_error') {
          errorMessage =
              localizations.networkError ??
              'Network error. Check your connection.';
        } else if (e.code == 'request_timed_out') {
          errorMessage =
              localizations.requestTimedOut ??
              'Request timed out. Check your connection.';
        } else {
          errorMessage =
              localizations.signUpFailed ?? 'Sign up failed. Please try again.';
        }
        _showSnack(errorMessage, error: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack(
          localizations.signUpFailed ?? 'Sign up failed. Please try again.',
          error: true,
        );
      }
    }
  }

  Future<void> _signUpWithGoogle() async {
    final localizations = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);

    try {
      String? email;
      UserCredential userCredential;

      final googleSignIn = GoogleSignIn(
        scopes: const ['email', 'profile', 'openid'],
        clientId:
            kIsWeb
                ? '229235939623-nvfelsk5755ucnmbd5h7pc1ho3cl1p6t.apps.googleusercontent.com'
                : null,
      );

      await googleSignIn.signOut().catchError((_) {});

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      email = googleUser.email;
      if (email.isEmpty) {
        if (kIsWeb) {
          await googleSignIn.signOut().catchError((_) {});
        } else {
          await googleSignIn.disconnect().catchError((_) {});
        }
        if (mounted) {
          _showSnack(
            localizations.failedToGetEmailFromGoogle ??
                'Failed to get email from Google',
            error: true,
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        if (kIsWeb) {
          await googleSignIn.signOut().catchError((_) {});
          if (mounted) {
            _showSnack(
              localizations.emailAlreadyRegistered(email) ??
                  'This email is already registered. Please sign in instead.',
              error: true,
            );
            setState(() => _isLoading = false);
          }
        } else {
          await googleSignIn.disconnect().catchError((_) {});
          if (mounted) {
            final shouldRetry = await _showAccountTakenDialog(email);
            setState(() => _isLoading = false);
            if (shouldRetry == true) {
              await _signUpWithGoogle();
            }
          }
        }
        return;
      }

      final googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null && googleAuth.accessToken == null) {
        if (kIsWeb) {
          await googleSignIn.signOut().catchError((_) {});
        } else {
          await googleSignIn.disconnect().catchError((_) {});
        }
        if (mounted) {
          _showSnack(
            localizations.googleAuthNoIdToken ?? 'Google authentication failed',
            error: true,
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      try {
        userCredential = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );
      } on FirebaseAuthException catch (e) {
        if (kIsWeb) {
          await googleSignIn.signOut().catchError((_) {});
        } else {
          await googleSignIn.disconnect().catchError((_) {});
        }

        if (e.code == 'account-exists-with-different-credential' ||
            e.code == 'email-already-in-use') {
          if (mounted) {
            _showSnack(
              localizations.emailAlreadyRegistered(email) ??
                  'This email is already registered',
              error: true,
            );
            setState(() => _isLoading = false);
          }
          return;
        } else if (e.code == 'invalid-credential') {
          if (mounted) {
            _showSnack(
              localizations.googleSignUpFailed ?? 'Google Sign-Up failed',
              error: true,
            );
            setState(() => _isLoading = false);
          }
          return;
        } else if (e.code == 'user-disabled') {
          if (mounted) {
            _showSnack(
              localizations.userDisabled ?? 'User account is disabled',
              error: true,
            );
            setState(() => _isLoading = false);
          }
          return;
        }

        if (mounted) {
          _showSnack(
            localizations.googleSignUpFailed ?? 'Google Sign-Up failed',
            error: true,
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      final user = userCredential.user!;

      final localeProvider = Provider.of<LocaleProvider>(
        context,
        listen: false,
      );
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

      try {
        await KitService.linkKitToUser(
          sessionToken: widget.sessionToken,
          uid: user.uid,
          language: localeProvider.locale.languageCode,
          theme: themeProvider.themeMode.toString().split('.').last,
        );
      } on KitServiceException catch (kitError) {
        try {
          await user.delete();
          if (kIsWeb) {
            await googleSignIn.signOut().catchError((_) {});
          } else {
            await GoogleSignIn().disconnect().catchError((_) {});
          }
        } catch (_) {}

        if (mounted) {
          String errorMsg;
          if (kitError.code == 'link_failed' &&
              kitError.serverMessage != null) {
            if (kitError.serverMessage!.contains('409') ||
                kitError.serverMessage!.toLowerCase().contains(
                  'already used',
                )) {
              errorMsg = 'Kit already used or email already registered.';
            } else if (kitError.serverMessage!.contains('404') ||
                kitError.serverMessage!.toLowerCase().contains(
                  'invalid session',
                )) {
              errorMsg = 'Invalid session. Please scan QR code again.';
            } else if (kitError.serverMessage!.contains('410') ||
                kitError.serverMessage!.toLowerCase().contains('expired')) {
              errorMsg = 'Session expired. Please scan QR code again.';
            } else {
              errorMsg = kitError.serverMessage!;
            }
          } else if (kitError.code == 'network_error') {
            errorMsg = 'Network error. Check your connection.';
          } else if (kitError.code == 'request_timed_out') {
            errorMsg = 'Request timed out. Please try again.';
          } else {
            errorMsg = localizations.googleSignUpFailed ?? 'Failed to link kit';
          }

          _showSnack(errorMsg, error: true);
          setState(() => _isLoading = false);
        }
        return;
      } catch (kitError) {
        try {
          await user.delete();
          if (kIsWeb) {
            await googleSignIn.signOut().catchError((_) {});
          } else {
            await GoogleSignIn().disconnect().catchError((_) {});
          }
        } catch (_) {}

        if (mounted) {
          _showSnack(
            localizations.signupFailed ??
                'Failed to complete signup. Please try again.',
            error: true,
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      await KitService.clearSession(widget.kitCode);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage;
        if (e.code == 'network-request-failed') {
          errorMessage = 'Network error. Check your connection.';
        } else if (e.code == 'too-many-requests') {
          errorMessage = 'Too many attempts. Please try again later.';
        } else {
          errorMessage =
              localizations.googleSignUpFailed ?? 'Google sign-up failed';
        }
        _showSnack(errorMessage, error: true);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage;
        if (e.toString().contains('DEVELOPER_ERROR')) {
          errorMessage = 'App configuration error. Contact support.';
        } else if (e.toString().toLowerCase().contains('network')) {
          errorMessage = 'Network error. Check your connection.';
        } else if (e.toString().contains('PlatformException')) {
          errorMessage = 'Google sign-in cancelled or failed.';
        } else {
          errorMessage = localizations.googleSignUpFailed ?? 'Sign up failed';
        }
        _showSnack(errorMessage, error: true);
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool?> _showAccountTakenDialog(String email) async {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  loc.providerAlreadyLinked ?? 'Account Already Registered',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.theEmailAddress ?? 'The email address:',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.email, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        email,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                loc.accountAlreadyRegistered ??
                    'is already registered. Please sign in with this account or choose a different Google account.',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: kTesiaColor,
                foregroundColor: Colors.white,
              ),
              icon: Icon(Icons.account_circle, size: 18),
              label: Text(
                loc.chooseDifferentAccount ?? 'Choose Different Account',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLangSelector() {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: _showLangSelector ? 160 : 44,
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kTesiaColor.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: kTesiaColor.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child:
              _showLangSelector
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 8),
                      ..._languages.entries.map((entry) {
                        final code = entry.key;
                        final flag = entry.value['flag']!;
                        return IconButton(
                          icon: Text(
                            flag,
                            style: const TextStyle(fontSize: 18),
                          ),
                          tooltip: entry.value['name'],
                          onPressed: () {
                            localeProvider.setLocale(Locale(code));
                            setState(() {
                              _showLangSelector = false;
                            });
                          },
                        );
                      }),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 18,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        onPressed:
                            () => setState(() => _showLangSelector = false),
                      ),
                    ],
                  )
                  : IconButton(
                    icon: Text(
                      _languages[localeProvider.locale.languageCode]?['flag'] ??
                          '🇺🇸',
                      style: const TextStyle(fontSize: 18),
                    ),
                    onPressed: () => setState(() => _showLangSelector = true),
                  ),
        ),
      ),
    );
  }

  Future<void> _showTermsAndConditions() async {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // helper that fetches terms text from Firestore with fallback
    Future<String> _loadTerms() async {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('AppInfo')
            .doc('terms')
            .get()
            .timeout(const Duration(seconds: 5));
        if (doc.exists) {
          final data = doc.data();
          if (data != null && data['text'] is String && (data['text'] as String).isNotEmpty) {
            return data['text'] as String;
          }
        }
      } catch (_) {
        // ignore - fallback below
      }
      return (loc.termsAndConditionsLong ?? loc.termsAndConditions) as String;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (context, sc) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 6,
                      width: 48,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      loc.termsAndConditions,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: FutureBuilder<String>(
                        future: _loadTerms(),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(kTesiaColor),
                              ),
                            );
                          }
                          final text = snap.data ??
                              ((loc.termsAndConditionsLong ?? loc.termsAndConditions) as String);
                          return SingleChildScrollView(
                            controller: sc,
                            child: Text(
                              text,
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface.withOpacity(0.9),
                                height: 1.45,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kTesiaColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(loc.close ?? 'Close'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor:
                  isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
              elevation: 0,
              pinned: true,
              floating: false,
              toolbarHeight: 64,
              automaticallyImplyLeading: false,
              forceElevated: false,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: Material(
                color:
                    isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.8, end: 1),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutBack,
                        builder:
                            (context, scale, child) => Transform.scale(
                              scale: scale,
                              alignment: Alignment.centerLeft,
                              child: Image.asset(
                                'assets/logos/Tesia_nobg.png',
                                height: 30,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                                isAntiAlias: true,
                              ),
                            ),
                      ),
                      _buildLangSelector(),
                    ],
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),

                  Text(
                    localizations.createAnAccount,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: kTesiaColor,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    height: 200,
                    child: Lottie.asset(
                      'assets/animations/registeraccount.json',
                      fit: BoxFit.contain,
                      repeat: false,
                      animate: true,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    localizations.joinUsToStartYourJourney,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 56,
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _signUpWithGoogle,
                            style: OutlinedButton.styleFrom(
                              backgroundColor:
                                  isDark
                                      ? const Color(0xFF2C2C2E)
                                      : Colors.white,
                              side: BorderSide(
                                color:
                                    isDark
                                        ? Colors.grey[700]!
                                        : Colors.grey[300]!,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor:
                                      isDark
                                          ? Colors.grey[800]
                                          : Colors.grey[100],
                                  child: Text(
                                    'G',
                                    style: TextStyle(
                                      color: kTesiaColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  localizations.continueWithGoogle,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      isDark
                                          ? Colors.grey[700]!.withOpacity(0.3)
                                          : Colors.grey[300]!.withOpacity(0.3),
                                      isDark
                                          ? Colors.grey[700]!.withOpacity(0.5)
                                          : Colors.grey[300]!.withOpacity(0.5),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Text(
                                localizations.or,
                                style: TextStyle(
                                  color:
                                      isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      isDark
                                          ? Colors.grey[700]!.withOpacity(0.5)
                                          : Colors.grey[300]!.withOpacity(0.5),
                                      isDark
                                          ? Colors.grey[700]!.withOpacity(0.3)
                                          : Colors.grey[300]!.withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Container(
                          decoration: BoxDecoration(
                            color:
                                isDark ? const Color(0xFF2C2C2E) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  isDark ? 0.2 : 0.05,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: localizations.enterYourEmail,
                              hintStyle: TextStyle(
                                color:
                                    isDark
                                        ? Colors.grey[500]
                                        : Colors.grey[500],
                                fontSize: 16,
                              ),
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: kTesiaColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor:
                                  isDark
                                      ? const Color(0xFF2C2C2E)
                                      : Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 20,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return localizations.pleaseEnterEmail;
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return localizations.pleaseEnterValidEmail;
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        Container(
                          decoration: BoxDecoration(
                            color:
                                isDark ? const Color(0xFF2C2C2E) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  isDark ? 0.2 : 0.05,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: localizations.password,
                              hintStyle: TextStyle(
                                color:
                                    isDark
                                        ? Colors.grey[500]
                                        : Colors.grey[500],
                                fontSize: 16,
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: kTesiaColor,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color:
                                      isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(
                                    () =>
                                        _isPasswordVisible =
                                            !_isPasswordVisible,
                                  );
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor:
                                  isDark
                                      ? const Color(0xFF2C2C2E)
                                      : Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 20,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return localizations.pleaseEnterPassword;
                              }
                              if (value.length < 8) {
                                return ((localizations.passwordTooShort
                                            as String?) ??
                                        'Password must be at least {min} characters')
                                    .replaceFirst('{min}', '8');
                              }
                              if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                return localizations.passwordRequiresUpper ??
                                    'Password must contain an uppercase letter';
                              }
                              if (!RegExp(r'[a-z]').hasMatch(value)) {
                                return localizations.passwordRequiresLower ??
                                    'Password must contain a lowercase letter';
                              }
                              if (!RegExp(r'[0-9]').hasMatch(value)) {
                                return localizations.passwordRequiresDigit ??
                                    'Password must contain a digit';
                              }
                              if (!RegExp(
                                r'[!@#$%^&*(),.?":{}|<>]',
                              ).hasMatch(value)) {
                                return localizations.passwordRequiresSpecial ??
                                    'Password must contain a special character';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        Container(
                          decoration: BoxDecoration(
                            color:
                                isDark ? const Color(0xFF2C2C2E) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  isDark ? 0.2 : 0.05,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: localizations.confirmPassword,
                              hintStyle: TextStyle(
                                color:
                                    isDark
                                        ? Colors.grey[500]
                                        : Colors.grey[500],
                                fontSize: 16,
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: kTesiaColor,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color:
                                      isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(
                                    () =>
                                        _isConfirmPasswordVisible =
                                            !_isConfirmPasswordVisible,
                                  );
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor:
                                  isDark
                                      ? const Color(0xFF2C2C2E)
                                      : Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 20,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return localizations.pleaseConfirmPassword;
                              }
                              if (value != _passwordController.text) {
                                return localizations.passwordsDoNotMatch;
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Checkbox(
                              value: _acceptTerms,
                              onChanged: (value) {
                                setState(() => _acceptTerms = value ?? false);
                              },
                              activeColor: kTesiaColor,
                              checkColor: Colors.white,
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  text: '${localizations.iAgreeToThe} ',
                                  style: TextStyle(
                                    color:
                                        isDark
                                            ? Colors.grey[300]
                                            : Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: localizations.termsAndConditions,
                                      style: const TextStyle(
                                        color: kTesiaColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      recognizer: _termsRecognizer,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kTesiaColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : Text(
                                      localizations.signUp,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              localizations.alreadyHaveAccount,
                              style: TextStyle(
                                color:
                                    isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignInScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                localizations.signIn,
                                style: const TextStyle(
                                  color: kTesiaColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
