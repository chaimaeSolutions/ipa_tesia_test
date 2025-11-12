import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tesia_app/l10n/app_localizations.dart';
import 'package:tesia_app/shared/colors.dart';
import 'package:tesia_app/Profile/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WelcomePopup extends StatefulWidget {
  final VoidCallback? onCompleteProfile;
  final VoidCallback? onIgnore;

  const WelcomePopup({super.key, this.onCompleteProfile, this.onIgnore});

  @override
  State<WelcomePopup> createState() => _WelcomePopupState();
}

class _WelcomePopupState extends State<WelcomePopup> {
  bool _isLinking = false;
  String? _statusMessage;
  Color? _statusColor;
  bool _checkingLinked = true;
  bool _alreadyLinked = false;
  String? _linkedEmail;

  @override
  void initState() {
    super.initState();
    _loadLinkedStatus();
  }

  Future<void> _loadLinkedStatus() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _checkingLinked = false;
        _alreadyLinked = false;
      });
      return;
    }

    try {
      await user.reload();
    } catch (_) {}

    UserInfo? googleProvider;
    for (final p in user.providerData) {
      if (p.providerId == 'google.com') {
        googleProvider = p;
        break;
      }
    }

    setState(() {
      _alreadyLinked = googleProvider != null;
      _linkedEmail = googleProvider?.email ?? user.email;
      _checkingLinked = false;
    });
  } catch (e) {
    setState(() {
      _checkingLinked = false;
      _alreadyLinked = false;
    });
  }
}
  Future<void> _linkGoogleAccount() async {
  setState(() {
    _isLinking = true;
    _statusMessage = null;
    _statusColor = null;
  });

  final loc = AppLocalizations.of(context)!;

  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        final msg =
            loc.noSignedInUser ??
            'No signed-in user found. Please sign in first.';
        setState(() {
          _statusMessage = msg;
          _statusColor = Colors.red;
          _isLinking = false;
        });
      }
      return;
    }

    final currentEmail = currentUser.email?.toLowerCase().trim();
    if (currentEmail == null || currentEmail.isEmpty) {
      setState(() {
        _statusMessage = loc.noSignedInUser ?? 'Current account has no email';
        _statusColor = Colors.red;
        _isLinking = false;
      });
      return;
    }

    setState(() {
      _statusMessage = loc.linkingAccount ?? 'Linking Google account...';
      _statusColor = Colors.blue;
    });

    final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

    try {
      await googleSignIn.disconnect();
    } catch (_) {}
    
    try {
      await googleSignIn.signOut();
    } catch (_) {}

    final googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      setState(() {
        _statusMessage =
            loc.googleSignInCancelled ?? 'Google sign-in cancelled';
        _statusColor = Colors.orange;
        _isLinking = false;
      });
      return;
    }

    final googleEmail = googleUser.email.toLowerCase().trim();

    if (googleEmail != currentEmail) {
      try {
        await googleSignIn.disconnect();
      } catch (_) {}
      
      if (mounted) {
        setState(() {
          _statusMessage =
              '${loc.emailMismatch ?? "Email mismatch"}\n${loc.currentAccount ?? "Current"}: $currentEmail\n${loc.googleAccount ?? "Google"}: $googleEmail\n}';
          _statusColor = Colors.red;
          _isLinking = false;
        });
        
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          final retry = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(loc.tryAgain ?? 'Try Again?'),
             
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(loc.cancel ?? 'Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(loc.tryAgain ?? 'Try Again'),
                ),
              ],
            ),
          );
          
          if (retry == true) {
            _linkGoogleAccount(); 
          }
        }
      }
      return;
    }

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await currentUser.linkWithCredential(credential);
    await currentUser.reload();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update({
          'photoURL': googleUser.photoUrl,
          'googleLinked': true,
          'googleEmail': googleUser.email,
          'updatedAt': FieldValue.serverTimestamp(),
        });

    if (mounted) {
      final successMsg =
          loc.googleAccountLinkedSuccess ??
          '✓ Google account linked successfully!';
      setState(() {
        _statusMessage = successMsg;
        _statusColor = Colors.green;
        _alreadyLinked = true;
        _linkedEmail = googleUser.email;
      });

      await _loadLinkedStatus();

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);
    }
  } on FirebaseAuthException catch (e) {
    String message;

    switch (e.code) {
      case 'provider-already-linked':
        message =
            loc.providerAlreadyLinked ??
            'This account already has Google linked.';
        break;
      case 'credential-already-in-use':
        message =
            loc.credentialAlreadyInUse ??
            'This Google account is already linked to another user.';
        break;
      case 'email-already-in-use':
        message =
            loc.googleEmailAlreadyInUse ??
            'This Google email is already associated with another account.';
        break;
      case 'invalid-credential':
        message =
            loc.invalidGoogleCredential ??
            'Invalid Google credentials. Please try again.';
        break;
      default:
        message =
            e.message ??
            (loc.failedToLinkGoogleAccount ??
                'Failed to link Google account.');
    }

    if (mounted) {
      setState(() {
        _statusMessage = message;
        _statusColor = Colors.red;
      });
    }
  } catch (e) {
    if (mounted) {
      final err = loc.unexpectedError ?? 'An unexpected error occurred';
      setState(() {
        _statusMessage = err;
        _statusColor = Colors.red;
      });
    }
  } finally {
    if (mounted) setState(() => _isLinking = false);
  }
}
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.5 : 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: _isLinking ? null : widget.onIgnore,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    isDark
                                        ? Colors.grey[800]
                                        : Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color:
                                    _isLinking
                                        ? (isDark
                                            ? Colors.grey[700]
                                            : Colors.grey[400])
                                        : (isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600]),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 180,
                        width: 150,
                        child: Lottie.asset(
                          'assets/animations/welcome.json',
                          fit: BoxFit.contain,
                          repeat: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        loc.welcomeToTesia,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: kTesiaColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        loc.getStartedMessage,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed:
                              _isLinking
                                  ? null
                                  : (widget.onCompleteProfile ??
                                      () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const ProfilePage(),
                                          ),
                                        );
                                      }),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kTesiaColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            disabledBackgroundColor: kTesiaColor.withOpacity(
                              0.5,
                            ),
                          ),
                          icon: const Icon(Icons.person_add, size: 20),
                          label: Text(
                            loc.completeProfile,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child:
                            _checkingLinked
                                ? Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        kTesiaColor,
                                      ),
                                    ),
                                  ),
                                )
                                : (_alreadyLinked
                                    ? OutlinedButton.icon(
                                      onPressed: null,
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: Colors.green.shade700,
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        backgroundColor:
                                            isDark
                                                ? Colors.green.withOpacity(0.08)
                                                : Colors.green.withOpacity(
                                                  0.04,
                                                ),
                                      ),
                                      icon: Icon(
                                        Icons.check_circle,
                                        size: 20,
                                        color: Colors.green.shade700,
                                      ),
                                      label: Text(
                                        _linkedEmail != null
                                            ? (loc.linkedWith(_linkedEmail!) ??
                                                'Linked: $_linkedEmail')
                                            : (loc.googleLinked ??
                                                'Google Linked'),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green.shade700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                    : OutlinedButton.icon(
                                      onPressed:
                                          _isLinking
                                              ? null
                                              : _linkGoogleAccount,
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color:
                                              _isLinking
                                                  ? Colors.grey
                                                  : kTesiaColor,
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        backgroundColor:
                                            isDark
                                                ? kTesiaColor.withOpacity(0.1)
                                                : kTesiaColor.withOpacity(0.05),
                                      ),
                                      icon:
                                          _isLinking
                                              ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                        kTesiaColor,
                                                      ),
                                                ),
                                              )
                                              : CircleAvatar(
                                                radius: 10,
                                                backgroundColor:
                                                    isDark
                                                        ? Colors.grey[800]
                                                        : Colors.grey[100],
                                                child: Text(
                                                  'G',
                                                  style: TextStyle(
                                                    color: kTesiaColor,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                      label: Text(
                                        _isLinking
                                            ? (loc.linking ?? 'Linking...')
                                            : (loc.linkGoogleAccount ??
                                                'Link Google'),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              _isLinking
                                                  ? Colors.grey
                                                  : kTesiaColor,
                                        ),
                                      ),
                                    )),
                      ),

                      if (_statusMessage != null) ...[
                        const SizedBox(height: 12),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _statusColor?.withOpacity(0.1) ??
                                Colors.grey.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color:
                                  _statusColor?.withOpacity(0.3) ??
                                  Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              if (_isLinking)
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      _statusColor ?? kTesiaColor,
                                    ),
                                  ),
                                )
                              else
                                Icon(
                                  _statusColor == Colors.green
                                      ? Icons.check_circle
                                      : _statusColor == Colors.red
                                      ? Icons.error
                                      : Icons.info,
                                  color: _statusColor ?? Colors.grey,
                                  size: 18,
                                ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _statusMessage!,
                                  style: TextStyle(
                                    color: _statusColor ?? Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: _isLinking ? null : widget.onIgnore,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          loc.ignoreForNow ?? 'Ignore for now',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                _isLinking
                                    ? (isDark
                                        ? Colors.grey[700]
                                        : Colors.grey[400])
                                    : (isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600]),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
