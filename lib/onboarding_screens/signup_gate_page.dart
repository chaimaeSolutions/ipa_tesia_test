import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tesia_app/authentication/signin_screen.dart';
import 'package:tesia_app/authentication/signup_screen.dart';
import 'package:tesia_app/l10n/app_localizations.dart';
import 'package:tesia_app/services/kit_service_exception.dart';
import 'package:tesia_app/shared/colors.dart';
import 'package:tesia_app/services/kit_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:tesia_app/shared/qr_scanner_screen.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class SignupGatePage extends StatefulWidget {
  const SignupGatePage({super.key});

  @override
  State<SignupGatePage> createState() => _SignupGatePageState();
}

class _SignupGatePageState extends State<SignupGatePage>
    with TickerProviderStateMixin {
  bool _verified = false;
  bool _showManualEntry = false;
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  String? _sessionToken;
  String? _cachedKitCode;
  bool _isCheckingCache = true;
  bool _isFormatting = false;
  Timer? _formatTimer;

  late AnimationController _scanQrController;
  late AnimationController _manualCodeController;

  @override
  void initState() {
    super.initState();
    _scanQrController = AnimationController(vsync: this);
    _manualCodeController = AnimationController(vsync: this);
    _codeFocusNode.addListener(() => setState(() {}));
    _codeController.addListener(_scheduleFormat);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkCachedSession());
  }

  void _scheduleFormat() {
    _formatTimer?.cancel();
    _formatTimer = Timer(Duration(milliseconds: 300), _formatManualCode);
  }

  void _formatManualCode() {
    setState(() => _isFormatting = true);
    final raw = _codeController.text;

    final only = raw.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();

    final truncated = only.length > 14 ? only.substring(0, 14) : only;

    final parts = <String>[];
    if (truncated.length >= 2) {
      parts.add(truncated.substring(0, 2));
      if (truncated.length > 2) {
        final a =
            truncated.length >= 6
                ? truncated.substring(2, 6)
                : truncated.substring(2);
        parts.add(a);
        if (truncated.length > 6) {
          final b =
              truncated.length >= 10
                  ? truncated.substring(6, 10)
                  : truncated.substring(6);
          parts.add(b);
          if (truncated.length > 10) {
            final c =
                truncated.length >= 14
                    ? truncated.substring(10, 14)
                    : truncated.substring(10);
            parts.add(c);
          }
        }
      }
    } else {
      parts.add(truncated);
    }

    final formatted = parts.join('-');

    if (formatted != raw) {
      final selIndex = formatted.length;
      _codeController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: selIndex),
      );
    }
    setState(() => _isFormatting = false);
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

  Future<void> _checkCachedSession() async {
    await Future.delayed(const Duration(milliseconds: 100));

    Timer? _timeoutTimer;
    try {
      _timeoutTimer = Timer(const Duration(seconds: 8), () {
        if (mounted) {
          setState(() => _isCheckingCache = false);
        }
      });

      if (Firebase.apps.isEmpty) {
        int waited = 0;
        const pollMs = 100;
        while (Firebase.apps.isEmpty && waited < 5000) {
          await Future.delayed(const Duration(milliseconds: pollMs));
          waited += pollMs;
        }
        if (Firebase.apps.isEmpty) {
          return;
        }
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) return;

      final storage = const FlutterSecureStorage();
      Map<String, String> allKeys = {};

      try {
        allKeys = await storage.readAll().timeout(const Duration(seconds: 5));
      } on TimeoutException catch (te) {
        return;
      } catch (e, st) {
        return;
      }

      for (final entry in allKeys.entries) {
        final key = entry.key;
        final value = entry.value;
        if (!key.startsWith('session_')) continue;

        try {
          final session = json.decode(value);
          final expiresAt = DateTime.parse(session['expiresAt'] as String);
          final verifiedAt =
              session['verifiedAt'] != null
                  ? DateTime.parse(session['verifiedAt'] as String)
                  : DateTime.fromMillisecondsSinceEpoch(0);

          if (DateTime.now().difference(verifiedAt).inHours > 1 ||
              expiresAt.isBefore(DateTime.now())) {
            try {
              await storage.delete(key: key);
            } catch (e) {
            }
            continue;
          }

          final token = session['token'] as String?;
          if (token == null) {
            await storage.delete(key: key);
            continue;
          }

          final code = key.replaceFirst('session_', '');
          if (!mounted) return;

          setState(() {
            _verified = true;
            _sessionToken = token;
            _cachedKitCode = code;
            _isCheckingCache = false;
          });

          _showSnack(
            AppLocalizations.of(context)?.sessionRestored ?? 'Session restored',
            error: false,
          );
          return;
        } catch (e, st) {
          try {
            await storage.delete(key: key);
          } catch (_) {}
        }
      }
    } catch (e, st) {
    } finally {
      _timeoutTimer?.cancel();
      if (mounted) {
        setState(() => _isCheckingCache = false);
      }
    }
  }

  void _showThemedLoading(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        final theme = Theme.of(context);
        final textColor = theme.textTheme.bodyLarge?.color;
        return Dialog(
          backgroundColor: theme.dialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18.0,
              vertical: 14.0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 14),
                Flexible(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _scanQrCode() async {
    final loc = AppLocalizations.of(context);

    final scannedCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QRScannerScreen()),
    );

    if (scannedCode == null || scannedCode.isEmpty) return;

    _showThemedLoading(
      AppLocalizations.of(context)?.verifyingQr ?? 'Verifying QR code...',
    );

    try {
      final result = await KitService.scanQr(scannedCode);
      if (!mounted) return;

      const storage = FlutterSecureStorage();
      await storage.write(
        key: 'session_$scannedCode',
        value: json.encode({
          'token': result['token'],
          'expiresAt': result['expiresAt'],
          'verifiedAt': DateTime.now().toIso8601String(),
        }),
      );

      Navigator.of(context).pop();
      setState(() {
        _verified = true;
        _sessionToken = result['token'];
        _cachedKitCode = scannedCode;
      });
      _showSnack(
        result.containsKey('cached')
            ? (loc?.sessionRestored ?? 'Session restored')
            : (loc?.kitVerifiedSuccessfully ?? 'Kit verified successfully'),
      );
      } on KitServiceException catch (e) {
    if (mounted) {
      Navigator.of(context).pop();
      
      String errorMessage;
      if (e.code == 'kit_not_found') {
        errorMessage = loc?.kitNotFound ?? 'Kit not found or invalid code';
      } else if (e.code == 'invalid_qr') {
        errorMessage = loc?.invalidQr ?? 'Invalid QR code (forgery detected)';
      } else if (e.code == 'already_reserved') {
        errorMessage = loc?.kitAlreadyReserved ?? 'Kit already reserved by another device';
      } else if (e.code == 'already_used') {
        errorMessage = loc?.kitAlreadyUsed ?? 'Kit already used or session expired';
      } else if (e.code == 'network_error') {
        errorMessage = loc?.networkError ?? 'Network error. Check your connection.';
      } else if (e.code == 'request_timed_out') {
        errorMessage = loc?.requestTimedOut ?? 'Request timed out. Please try again.';
      } else if (e.serverMessage != null && e.serverMessage!.isNotEmpty) {
        errorMessage = e.serverMessage!;
      } else {
        errorMessage = loc?.genericError ?? 'Something went wrong. Please try again.';
      }
      
      _showSnack(errorMessage, error: true);
    }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        _showSnack(
          loc?.genericError ?? 'Something went wrong. Please try again.',
          error: true,
        );
      }
    }
  }

  void _enterCodeManually() {
    setState(() {
      _showManualEntry = true;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      _codeFocusNode.requestFocus();
    });
  }

 Future<void> _verifyCode() async {
  _formatTimer?.cancel();
  _formatManualCode();
  await Future.delayed(Duration(milliseconds: 50));

  final loc = AppLocalizations.of(context);
  final code = _codeController.text.trim();

  final validFormat = RegExp(r'^TS-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$');
  if (!validFormat.hasMatch(code)) {
    _showSnack(
      loc?.invalidCodeFormat ?? 'Code must match format: TS-XXXX-XXXX-XXXX',
      error: true,
    );
    FocusScope.of(context).requestFocus(_codeFocusNode);
    return;
  }

  _showThemedLoading(loc?.verifyingCode ?? 'Verifying code...');

  try {
    final result = await KitService.scanQr(code);
    if (!mounted) return;
    
    const storage = FlutterSecureStorage();
    await storage.write(
      key: 'session_$code',
      value: json.encode({
        'token': result['token'],
        'expiresAt': result['expiresAt'],
        'verifiedAt': DateTime.now().toIso8601String(),
      }),
    );
    
    Navigator.of(context).pop();
    setState(() {
      _verified = true;
      _showManualEntry = false;
      _sessionToken = result['token'];
      _cachedKitCode = code;
    });
    _showSnack(
      result.containsKey('cached')
          ? (loc?.sessionRestored ?? 'Session restored')
          : (loc?.codeVerified ?? 'Code verified'),
    );
  } on KitServiceException catch (e) {
    if (mounted) {
      Navigator.of(context).pop();
      
      String errorMessage;
      if (e.code == 'kit_not_found') {
        errorMessage = loc?.kitNotFound ?? 'Kit not found or invalid code';
      } else if (e.code == 'invalid_qr') {
        errorMessage = loc?.invalidQr ?? 'Invalid QR code';
      } else if (e.code == 'already_reserved') {
        errorMessage = loc?.kitAlreadyReserved ?? 'Kit already reserved by another device';
      } else if (e.code == 'already_used') {
        errorMessage = loc?.kitAlreadyUsed ?? 'Kit already used. Please contact support if you believe this is an error.';
      } else if (e.code == 'network_error') {
        errorMessage = loc?.networkError ?? 'Network error. Check your connection.';
      } else if (e.code == 'request_timed_out') {
        errorMessage = loc?.requestTimedOut ?? 'Request timed out. Please try again.';
      } else if (e.serverMessage != null && e.serverMessage!.isNotEmpty) {
        errorMessage = e.serverMessage!;
      } else {
        errorMessage = loc?.genericError ?? 'Verification failed. Please try again.';
      }
      
      _showSnack(errorMessage, error: true);
    }
  } catch (e) {
    if (mounted) {
      Navigator.of(context).pop();
      _showSnack(
        loc?.genericError ?? 'Verification failed. Please try again.',
        error: true,
      );
    }
  }
}
  void _proceedToSignup() {
    final loc = AppLocalizations.of(context);
    if (_sessionToken == null || _cachedKitCode == null) {
      _showSnack(
        loc?.noSessionToken ??
            'No session token. Please scan or enter the kit code.',
        error: true,
      );
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (_) => SignUpScreen(
              sessionToken: _sessionToken!,
              kitCode: _cachedKitCode!,
            ),
      ),
    );
  }

  @override
  void dispose() {
    _formatTimer?.cancel();
    _codeController.dispose();
    _codeFocusNode.dispose();
    _scanQrController.dispose();
    _manualCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final outerBg = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F7FA);
    final innerBg = Colors.white;
    final innerPrimary = Colors.black.withOpacity(0.87);
    final innerSecondary = Colors.black.withOpacity(0.7);

    if (_isCheckingCache) {
      return Scaffold(
        backgroundColor: outerBg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: kTesiaColor),
              SizedBox(height: 16),
              Text(
                loc?.checkingSession ?? 'Checking your session...',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: outerBg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: outerBg,
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Center(
                      child: Text(
                        loc?.kitVerification ?? 'Kit verification',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        Container(
                          height: _showManualEntry ? 200 : 260,
                          color: outerBg,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: _buildLottieAnimation(),
                          ),
                        ),
                        Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              constraints: BoxConstraints(
                                minHeight:
                                    MediaQuery.of(context).size.height -
                                    (_showManualEntry ? 200 : 260) -
                                    54,
                              ),
                              color: innerBg,
                              padding: const EdgeInsets.only(
                                left: 32,
                                right: 32,
                                top: 55,
                                bottom: 100,
                              ),
                              child: Column(
                                children: [
                                  if (!_showManualEntry && !_verified) ...[
                                    Text(
                                      loc?.scanOrEnterCode ??
                                          'Scan the QR code on your kit or enter the code manually to sign up.',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: innerSecondary,
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 32),
                                    ElevatedButton.icon(
                                      icon: const Icon(
                                        Icons.qr_code_scanner,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        loc?.scanQr ?? 'Scan QR',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      onPressed: _scanQrCode,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kTesiaColor,
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size.fromHeight(50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    OutlinedButton.icon(
                                      icon: Icon(
                                        Icons.keyboard,
                                        color: kTesiaColor,
                                      ),
                                      label: Text(
                                        loc?.enterCode ?? 'Enter code manually',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: kTesiaColor,
                                        ),
                                      ),
                                      onPressed: _enterCodeManually,
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size.fromHeight(50),
                                        side: BorderSide(
                                          color: kTesiaColor,
                                          width: 2,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ] else if (_showManualEntry &&
                                      !_verified) ...[
                                    Text(
                                      loc?.enterCodeHint ??
                                          'Enter your kit code below',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: innerSecondary,
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 32),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: outerBg,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color:
                                              _codeFocusNode.hasFocus
                                                  ? kTesiaColor
                                                  : Colors.grey.withOpacity(
                                                    0.3,
                                                  ),
                                          width:
                                              _codeFocusNode.hasFocus ? 2 : 1,
                                        ),
                                      ),

                                      child: TextField(
                                        controller: _codeController,
                                        focusNode: _codeFocusNode,
                                        textCapitalization:
                                            TextCapitalization.characters,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              isDark
                                                  ? Colors.white
                                                  : Colors.black,
                                          letterSpacing: 2,
                                        ),

                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          hintText:
                                              loc?.kitCodePlaceholder ??
                                              'TS-XXXX-XXXX-XXXX',
                                          hintStyle: TextStyle(
                                            color: Colors.grey.withOpacity(0.5),
                                            letterSpacing: 2,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 16,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () {
                                              setState(() {
                                                _showManualEntry = false;
                                                _codeController.clear();
                                              });
                                            },
                                            style: OutlinedButton.styleFrom(
                                              minimumSize:
                                                  const Size.fromHeight(50),
                                              side: BorderSide(
                                                color: Colors.grey.withOpacity(
                                                  0.5,
                                                ),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Text(
                                              loc?.cancel ?? 'Cancel',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                color: innerSecondary,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: _verifyCode,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: kTesiaColor,
                                              foregroundColor: Colors.white,
                                              minimumSize:
                                                  const Size.fromHeight(50),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: Text(
                                              loc?.verify ?? 'Verify',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 32),
                                  if (_verified)
                                    Container(
                                      padding: const EdgeInsets.all(20),

                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: kTesiaColor,
                                            size: 48,
                                          ),
                                          const SizedBox(height: 12),

                                          Text(
                                            loc?.verifiedPrompt ??
                                                'Device verified. You can proceed to Sign Up.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: innerPrimary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: _proceedToSignup,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: kTesiaColor,
                                              foregroundColor: Colors.white,
                                              minimumSize:
                                                  const Size.fromHeight(50),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: Text(
                                              loc?.proceedToSignup ??
                                                  'Proceed to Sign Up',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            ClipPath(
                              clipper: WaveClipper(),
                              child: Container(
                                height: 40,
                                width: double.infinity,
                                color: outerBg,
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
                      color: innerBg,
                      padding: const EdgeInsets.only(
                        left: 32,
                        right: 32,
                        bottom: 20,
                        top: 15,
                      ),
                      child: SafeArea(
                        top: false,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              loc?.alreadyHaveAccount ??
                                  'Already have an account?',
                              style: TextStyle(color: innerSecondary),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const SignInScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                loc?.signIn ?? 'Sign in',
                                style: TextStyle(
                                  color: kTesiaColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildLottieAnimation() {
    if (_showManualEntry) {
      return Lottie.asset(
        'assets/animations/codemanually.json',
        controller: _manualCodeController,
        onLoaded: (composition) {
          _manualCodeController.duration = composition.duration;
          _manualCodeController.repeat();
        },
        fit: BoxFit.contain,
      );
    } else {
      return Lottie.asset(
        'assets/animations/scanqrcode.json',
        controller: _scanQrController,
        onLoaded: (composition) {
          _scanQrController.duration = composition.duration;
          _scanQrController.repeat();
        },
        fit: BoxFit.contain,
      );
    }
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
