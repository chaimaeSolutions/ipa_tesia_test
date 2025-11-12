import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:tesia_app/l10n/app_localizations.dart';
import 'package:tesia_app/core/locale_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../shared/colors.dart';
import 'signin_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isEmailSent = false;

  bool _showLangSelector = false;

  static const int _maxAttempts = 3;
  static const Duration _attemptWindow = Duration(minutes: 15);
  static const Duration _cooldown = Duration(seconds: 60);

  int _resetAttempts = 0;
  DateTime? _firstAttemptAt;
  DateTime? _lastResetAt;

  final Map<String, Map<String, String>> _languages = {
    'en': {'flag': '🇺🇸', 'name': 'English'},
    'es': {'flag': '🇪🇸', 'name': 'Español'},
  };

  @override
  void dispose() {
    _emailController.dispose();
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
            error ? theme.colorScheme.error : theme.colorScheme.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
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

  Future<void> _resetPassword() async {
    final localizations = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final now = DateTime.now();

    if (_lastResetAt != null && now.difference(_lastResetAt!) < _cooldown) {
      final wait = _cooldown - now.difference(_lastResetAt!);
      final secs = wait.inSeconds;
      String message;
      try {
        final dynamic tryAgain = localizations.tryAgainInSeconds;
        if (tryAgain is String) {
          message = tryAgain.replaceFirst('{seconds}', secs.toString());
        } else if (tryAgain is Function) {
          try {
            final result = tryAgain(secs);
            message =
                (result is String)
                    ? result
                    : 'Please wait $secs seconds before retrying.';
          } catch (_) {
            try {
              final result = tryAgain(secs.toString());
              message =
                  (result is String)
                      ? result
                      : 'Please wait $secs seconds before retrying.';
            } catch (_) {
              message = 'Please wait $secs seconds before retrying.';
            }
          }
        } else {
          message = 'Please wait $secs seconds before retrying.';
        }
      } catch (_) {
        message = 'Please wait $secs seconds before retrying.';
      }
      _showSnack(message, error: true);
      return;
    }

    if (_firstAttemptAt == null ||
        now.difference(_firstAttemptAt!) > _attemptWindow) {
      _firstAttemptAt = now;
      _resetAttempts = 0;
    }

    if (_resetAttempts >= _maxAttempts) {
      _showSnack(
        localizations.tooManyRequests ?? 'Too many attempts — try again later.',
        error: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();

    try {
      _resetAttempts++;
      _lastResetAt = now;

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      setState(() {
        _isLoading = false;
        _isEmailSent = true;
      });

      _showSnack(
        localizations.resetLinkSent ??
            'If an account exists, a reset link has been sent.',
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-email':
          message =
              localizations.pleaseEnterValidEmail ?? 'Invalid email address';
          break;
        case 'too-many-requests':
          message =
              localizations.tooManyRequests ??
              'Too many requests — try again later';
          break;
        case 'user-not-found':
          setState(() {
            _isLoading = false;
            _isEmailSent = true;
          });
          _showSnack(
            localizations.resetLinkSent ??
                'If an account exists, a reset link has been sent.',
          );
          return;
        case 'network-request-failed':
          message =
              localizations.networkError ??
              'Network error. Check your connection';
          break;
        default:
          message = localizations.resetFailed ?? 'Failed to send reset link';
      }

      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack(message, error: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack(
          localizations.resetFailed ?? 'Failed to send reset link',
          error: true,
        );
      }
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

  Widget _buildSuccessView(AppLocalizations localizations, bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 40),
        SizedBox(
          height: 200,
          child: Lottie.asset(
            'assets/animations/forgotpassword.json',
            fit: BoxFit.contain,
            repeat: false,
            animate: true,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          localizations.emailSent ?? 'Email sent',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: kTesiaColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          localizations.checkYourEmail ?? 'Check your email for the reset link',
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: kTesiaColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _emailController.text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kTesiaColor,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2E) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                size: 32,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              const SizedBox(height: 12),
              Text(
                localizations.resetInstructions ??
                    'Follow the instructions in the email to reset your password.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        TextButton(
          onPressed: () {
            setState(() {
              _isEmailSent = false;
            });
          },
          child: Text(
            localizations.resendEmail ?? 'Resend email',
            style: const TextStyle(
              color: kTesiaColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SignInScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: kTesiaColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              localizations.backToSignIn ?? 'Back to sign in',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: kTesiaColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResetForm(AppLocalizations localizations, bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(
            localizations.forgotPassword ?? 'Forgot password',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kTesiaColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: Lottie.asset(
              'assets/animations/forgotpassword.json',
              fit: BoxFit.contain,
              repeat: true,
              animate: true,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.forgotPasswordSubtitle ??
                'Enter your account email to receive a reset link.',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: localizations.enterYourEmail ?? 'Enter your email',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
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
                fillColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localizations.pleaseEnterEmail ??
                      'Please enter an email';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return localizations.pleaseEnterValidEmail ??
                      'Please enter a valid email';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
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
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Text(
                        localizations.sendResetLink ?? 'Send reset link',
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
              Icon(
                Icons.arrow_back_ios,
                size: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              const SizedBox(width: 4),
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
                  localizations.backToSignIn ?? 'Back to sign in',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
                  _isEmailSent
                      ? _buildSuccessView(localizations, isDark)
                      : _buildResetForm(localizations, isDark),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
