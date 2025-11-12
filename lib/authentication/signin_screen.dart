import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:tesia_app/l10n/app_localizations.dart';
import 'package:tesia_app/Home/main_navigation.dart';
import 'package:tesia_app/core/locale_provider.dart';
import 'package:tesia_app/onboarding_screens/signup_gate_page.dart';
import '../shared/colors.dart';
import 'forgot_password_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  bool _showLangSelector = false;
  final Map<String, Map<String, String>> _languages = {
    'en': {'flag': '🇺🇸', 'name': 'English'},
    'es': {'flag': '🇪🇸', 'name': 'Español'},
  };

  final _secureStore = const FlutterSecureStorage();
  static const int _kGoogleAllowedTtlSeconds = 600;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

  Future<void> _signIn() async {
    final localizations = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      final user = userCredential.user;
      if (user == null) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showSnack(localizations.signInFailed, error: true);
        }
        return;
      }

      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        final pendingEmail = data?['pendingEmail'] as String?;
        final currentEmail = user.email ?? '';

        if (pendingEmail != null &&
            pendingEmail.isNotEmpty &&
            pendingEmail != currentEmail) {
          await user.reload();
          final refreshedUser = FirebaseAuth.instance.currentUser;

          if (refreshedUser != null && !refreshedUser.emailVerified) {
            if (mounted) {
              setState(() => _isLoading = false);
              await _showPendingEmailDialog(pendingEmail, user);
            }
            return;
          }
        }
      }

      await _checkAndUpdateVerifiedEmail();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-credential':
          errorMessage = localizations.invalidCredentials;
          break;
        case 'user-not-found':
          errorMessage = localizations.noUserFound;
          break;
        case 'wrong-password':
          errorMessage = localizations.incorrectPassword;
          break;
        case 'invalid-email':
          errorMessage = localizations.invalidEmailAddress;
          break;
        case 'user-disabled':
          errorMessage = localizations.accountDisabled;
          break;
        case 'too-many-requests':
          errorMessage = localizations.tooManyFailedAttempts;
          break;
        case 'network-request-failed':
          errorMessage = localizations.networkError;
          break;
        default:
          errorMessage = localizations.signInFailed;
      }
      if (mounted) _showSnack(errorMessage, error: true);
    } catch (err, st) {
      if (mounted) _showSnack(localizations.signInFailed, error: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    final loc = AppLocalizations.of(context)!;

    try {
      if (kIsWeb) {
        final googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
          clientId:
              '229235939623-nvfelsk5755ucnmbd5h7pc1ho3cl1p6t.apps.googleusercontent.com',
        );

        try {
          await googleSignIn.signOut().catchError((_) {});

          final googleUser = await googleSignIn.signIn();

          if (googleUser == null) {
            if (mounted) setState(() => _isLoading = false);
            return;
          }

          final email = googleUser.email;
          if (email.isEmpty) {
            await googleSignIn.signOut().catchError((_) {});
            if (mounted) {
              _showSnack(
                loc.failedToGetEmailFromGoogle ??
                    'Failed to get email from Google',
                error: true,
              );
              setState(() => _isLoading = false);
            }
            return;
          }

          final querySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

          if (querySnapshot.docs.isEmpty) {
            await googleSignIn.signOut().catchError((_) {});
            if (mounted) {
              _showSnack(
                loc.noUserFound ?? 'No account found with this email.',
                error: true,
              );
              setState(() => _isLoading = false);
            }
            return;
          }

          final userData = querySnapshot.docs.first.data();
          if (userData['googleLinked'] != true) {
            await googleSignIn.signOut().catchError((_) {});
            if (mounted) {
              _showSnack(
                loc.googleSignInNotLinked ??
                    'This account was not created with Google Sign-In.',
                error: true,
              );
              setState(() => _isLoading = false);
            }
            return;
          }

          final googleAuth = await googleUser.authentication;

          final credential = GoogleAuthProvider.credential(
            idToken: googleAuth.idToken,
            accessToken: googleAuth.accessToken,
          );

          final userCredential = await FirebaseAuth.instance
              .signInWithCredential(credential);

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .update({'lastLoginAt': FieldValue.serverTimestamp()});

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigation()),
          );
          return;
        } catch (e) {
          await FirebaseAuth.instance.signOut().catchError((_) {});
          await googleSignIn.signOut().catchError((_) {});
          if (mounted) {
            _showSnack(
              '${loc.googleSignInFailed ?? 'Google Sign-In failed'}: ${e.toString()}',
              error: true,
            );
            setState(() => _isLoading = false);
          }
          return;
        }
      }

      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

      await googleSignIn.signOut().catchError((_) {});

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final email = googleUser.email;
      if (email.isEmpty) {
        await googleSignIn.disconnect().catchError((_) {});
        if (mounted) {
          _showSnack(
            loc.googleSignInFailed ?? 'Google sign-in failed',
            error: true,
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        await googleSignIn.disconnect().catchError((_) {});
        if (mounted) {
          _showSnack(
            loc.noUserFound ?? 'No account found with this email.',
            error: true,
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      final userData = querySnapshot.docs.first.data();
      if (userData['googleLinked'] != true) {
        await googleSignIn.disconnect().catchError((_) {});
        if (mounted) {
          _showSnack(
            loc.googleSignInNotPermitted ??
                'This account was created with email/password. Please use email/password to sign in.',
            error: true,
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null) {
        await googleSignIn.disconnect().catchError((_) {});
        if (mounted) {
          _showSnack(
            loc.googleAuthNoIdToken ?? 'Google authentication failed',
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

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .update({'lastLoginAt': FieldValue.serverTimestamp()});

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } catch (e) {
      await FirebaseAuth.instance.signOut().catchError((_) {});
      await GoogleSignIn().disconnect().catchError((_) {});

      if (mounted) {
        _showSnack(
          loc.signInFailed ?? 'Sign in failed: ${e.toString()}',
          error: true,
        );
        setState(() => _isLoading = false);
      }
    }
  }
  Future<void> _checkAndUpdateVerifiedEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await user.reload();
      final currentEmail = user.email ?? '';

      if (currentEmail.isEmpty || !user.emailVerified) return;

      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (!userDoc.exists) return;

      final data = userDoc.data();
      final pendingEmail = (data?['pendingEmail'] as String?) ?? '';

      if (pendingEmail.isNotEmpty && pendingEmail == currentEmail) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
              'email': currentEmail,
              'emailVerified': true,
              'pendingEmail': FieldValue.delete(),
              'pendingEmailRequestedAt': FieldValue.delete(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {}
  }

  String _getErrorMessage(String reason) {
    final localizations = AppLocalizations.of(context)!;
    switch (reason) {
      case 'google_not_linked':
        return localizations.googleSignInNotLinked;
      case 'cached':
        return localizations.googleSignInNotPermitted;
      case 'server_error':
        return localizations.googleSignInServerError;
      default:
        return localizations.signInFailed;
    }
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

  Future<void> _showPendingEmailDialog(String pendingEmail, User user) async {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.email_outlined, color: Colors.orange, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  loc.emailChangePendingVerification ??
                      'Email Change Pending Verification',
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
                loc.yourEmailChangeTo ?? 'Your email change to',
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
                        pendingEmail,
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
                loc.emailChangePendingVerification ??
                    'is still pending verification. Please check your inbox and click the verification link.',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
              },
              child: Text(loc.cancel, style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await user.verifyBeforeUpdateEmail(pendingEmail);

                  Navigator.pop(context);

                  if (mounted) {
                    _showSnack(
                      '${loc.verificationEmailResent ?? 'Verification email resent to'} $pendingEmail',
                    );
                  }

                  await FirebaseAuth.instance.signOut();
                } catch (e) {
                  Navigator.pop(context);
                  _showSnack(
                    '${loc.failedToResendEmail ?? 'Failed to resend email'}: ${e.toString()}',
                    error: true,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kTesiaColor,
                foregroundColor: Colors.white,
              ),
              icon: Icon(Icons.send, size: 18),
              label: Text(loc.resend),
            ),
          ],
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
                    localizations.welcomeBack,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: kTesiaColor,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    height: 150,
                    child: Lottie.asset(
                      'assets/animations/Login.json',
                      fit: BoxFit.contain,
                      repeat: true,
                      animate: true,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    localizations.signInToAccount,
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
                            onPressed: _isLoading ? null : _signInWithGoogle,
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
                                return localizations.passwordTooShort(8);
                              }
                              if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                return localizations.passwordRequiresUpper;
                              }
                              if (!RegExp(r'[a-z]').hasMatch(value)) {
                                return localizations.passwordRequiresLower;
                              }
                              if (!RegExp(r'[0-9]').hasMatch(value)) {
                                return localizations.passwordRequiresDigit;
                              }
                              if (!RegExp(
                                r'[!@#$%^&*(),.?":{}|<>]',
                              ).hasMatch(value)) {
                                return localizations.passwordRequiresSpecial;
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                localizations.forgotPassword,
                                style: const TextStyle(
                                  color: kTesiaColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signIn,
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
                                      localizations.signIn,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              localizations.dontHaveAccount,
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
                                    builder:
                                        (context) => const SignupGatePage(),
                                  ),
                                );
                              },
                              child: Text(
                                localizations.signUp,
                                style: TextStyle(
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
