import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:tesia_app/core/locale_provider.dart';
import 'package:tesia_app/core/theme_provider.dart';
import 'package:tesia_app/l10n/app_localizations.dart';
import 'package:tesia_app/shared/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tesia_app/Profile/profile_page.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tesia_app/authentication/signin_screen.dart';
import 'package:tesia_app/Profile/privacy_security_page.dart';
import 'package:tesia_app/shared/components/showsnackbar.dart';
import 'package:tesia_app/shared/components/account_removal.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _googleAccountLinked = false;
  String? _linkedEmail;
  StreamSubscription<User?>? _authSub;
  bool _isLinking = false;
  String? _statusMessage;
  Color? _statusColor;

  final Map<String, Map<String, String>> _languages = {
    'en': {'flag': '🇺🇸', 'name': 'English'},
    'es': {'flag': '🇪🇸', 'name': 'Español'},
  };

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        showSnack(
          context,
          loc.couldNotOpenLink ?? 'Could not open link',
          error: true,
        );
      }
    }
  }

  void _handleGoogleAccountLink() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final loc = AppLocalizations.of(context)!;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color:
                              _googleAccountLinked
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child:
                            _googleAccountLinked
                                ? Lottie.asset(
                                  'assets/animations/google.json',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.contain,
                                  repeat: false,
                                )
                                : Lottie.asset(
                                  'assets/animations/google.json',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.contain,
                                ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              _googleAccountLinked
                                  ? (loc.accountLinked ?? 'Account Linked')
                                  : (loc.linkGoogleAccount ??
                                      'Link Google Account'),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Text(
                        _googleAccountLinked
                            ? (loc.googleAccountLinkedDialogDescription ??
                                'Your Google account is successfully linked! You can now sync your data across devices and enjoy seamless backup.')
                            : (loc.connectGoogleAccountDescription ??
                                'Connect your Google account to sync your TESIA data across all your devices and enable automatic backup of your mold detection history.'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          height: 1.5,
                        ),
                      ),

                      if (_googleAccountLinked) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.cloud_done,
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      loc.syncActive ?? 'Sync Active',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      loc.syncingData ??
                                          'Your data is being synced',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (_isLinking) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _googleAccountLinked
                                      ? (loc.unlinkingAccount ?? 'Unlinking...')
                                      : (loc.linkingAccount ?? 'Linking...'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (_statusMessage != null) ...[
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _statusColor?.withOpacity(0.1) ??
                                Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  _statusColor?.withOpacity(0.3) ??
                                  Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _statusColor == Colors.green
                                    ? Icons.check_circle
                                    : _statusColor == Colors.red
                                    ? Icons.error
                                    : Icons.info,
                                color: _statusColor ?? Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _statusMessage!,
                                  style: TextStyle(
                                    color: _statusColor ?? Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed:
                                  _isLinking
                                      ? null
                                      : () {
                                        setState(() {
                                          _statusMessage = null;
                                          _statusColor = null;
                                        });
                                        Navigator.pop(context);
                                      },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                loc.cancel ?? 'Cancel',
                                style: TextStyle(
                                  color:
                                      _isLinking
                                          ? theme.colorScheme.onSurface
                                              .withOpacity(0.3)
                                          : theme.colorScheme.onSurface
                                              .withOpacity(0.7),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _isLinking
                                      ? null
                                      : () async {
                                        if (_googleAccountLinked) {
                                          await _unlinkGoogleAccount(
                                            setDialogState,
                                          );
                                          return;
                                        }

                                        final linked = await _linkGoogleAccount(
                                          setDialogState,
                                        );
                                        if (linked && mounted) {
                                          await Future.delayed(
                                            const Duration(seconds: 2),
                                          );
                                          if (mounted) Navigator.pop(context);
                                        }
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _googleAccountLinked
                                        ? Colors.red.shade400
                                        : kTesiaColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                _googleAccountLinked
                                    ? (loc.unlinkAccount ?? 'Unlink Account')
                                    : (loc.linkAccount ?? 'Link Account'),
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
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _linkGoogleAccount([
    Function(void Function())? setDialogState,
  ]) async {
    final loc = AppLocalizations.of(context)!;

    void updateStatus(String? msg, Color? color, bool loading) {
      setState(() {
        _isLinking = loading;
        _statusMessage = msg;
        _statusColor = color;
      });
      setDialogState?.call(() {
        _isLinking = loading;
        _statusMessage = msg;
        _statusColor = color;
      });
    }

    updateStatus(null, null, true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        updateStatus(loc.notSignedIn ?? 'Not signed in', Colors.red, false);
        return false;
      }

      final currentEmail = currentUser.email?.toLowerCase().trim();
      if (currentEmail == null || currentEmail.isEmpty) {
        updateStatus(
          loc.noSignedInUser ?? 'Current account has no email',
          Colors.red,
          false,
        );
        return false;
      }

      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

      try {
        await googleSignIn.disconnect();
      } catch (_) {}

      try {
        await googleSignIn.signOut();
      } catch (_) {}

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        updateStatus(
          loc.googleSignInCancelled ?? 'Google sign-in cancelled',
          Colors.orange,
          false,
        );
        return false;
      }

      final googleEmail = googleUser.email.toLowerCase().trim();

      if (googleEmail != currentEmail) {
        try {
          await googleSignIn.disconnect();
        } catch (_) {}

        updateStatus(
          '${loc.emailMismatch ?? "Email mismatch"}\n${loc.currentAccount ?? "Current"}: $currentEmail\n${loc.googleAccount ?? "Google"}: $googleEmail',
          Colors.red,
          false,
        );

        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          final retry = await showDialog<bool>(
            context: context,
            builder: (ctx) {
              final theme = Theme.of(ctx);
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(loc.tryAgain ?? 'Try Again?'),

                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(loc.cancel ?? 'Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kTesiaColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(loc.tryAgain ?? 'Try Again'),
                  ),
                ],
              );
            },
          );

          if (retry == true) {
            return await _linkGoogleAccount(setDialogState);
          }
        }
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await currentUser.linkWithCredential(credential);
      await currentUser.reload();

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
              'photoURL': googleUser.photoUrl,
              'googleLinked': true,
              'googleEmail': googleUser.email,
              'updatedAt': FieldValue.serverTimestamp(),
            });
      } catch (_) {}

      await _updateLinkedStatus();
      updateStatus(
        loc.googleAccountLinked ?? '✓ Google account linked successfully!',
        Colors.green,
        false,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      String msg = loc.linkFailed ?? 'Link failed';

      if (e.code == 'credential-already-in-use') {
        msg =
            loc.googleAccountAlreadyLinked ??
            'This Google account is already linked to another user.';
      } else if (e.code == 'provider-already-linked') {
        msg =
            loc.googleAccountAlreadyLinkedToYou ??
            'You already linked a Google account.';
      } else if (e.code == 'invalid-credential') {
        msg =
            loc.invalidGoogleCredential ??
            'Invalid Google credentials. Please try again.';
      } else if (e.code == 'account-exists-with-different-credential') {
        msg =
            loc.credentialAlreadyInUse ??
            'This Google email already has an account in our system.';
      }

      updateStatus(msg, Colors.red, false);
      return false;
    } catch (e) {
      updateStatus(
        loc.unexpectedError ?? 'An unexpected error occurred',
        Colors.red,
        false,
      );
      return false;
    }
  }

  Future<void> _unlinkGoogleAccount([
    Function(void Function())? setDialogState,
  ]) async {
    final loc = AppLocalizations.of(context)!;

    void updateStatus(String? msg, Color? color, bool loading) {
      setState(() {
        _isLinking = loading;
        _statusMessage = msg;
        _statusColor = color;
      });
      setDialogState?.call(() {
        _isLinking = loading;
        _statusMessage = msg;
        _statusColor = color;
      });
    }

    updateStatus(null, null, true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      updateStatus(loc.notSignedIn ?? 'Not signed in', Colors.red, false);
      return;
    }

    try {
      final hasPassword = user.providerData.any(
        (p) => p.providerId == 'password',
      );

      if (!hasPassword) {
        updateStatus(
          loc.checkingPasswordRequirement ?? 'Checking password requirement...',
          Colors.blue,
          true,
        );

        final ok = await _ensurePasswordLinked(user);
        if (!ok) {
          updateStatus(
            loc.unlinkRequiresPassword ??
                'You must set a password before unlinking Google.',
            Colors.orange,
            false,
          );
          return;
        }
      }

      updateStatus(
        loc.unlinkingGoogleAccount ?? 'Unlinking Google account...',
        Colors.blue,
        true,
      );

      await user.unlink('google.com');

      final GoogleSignIn gsi = GoogleSignIn(scopes: ['email', 'profile']);

      try {
        await gsi.disconnect();
      } catch (_) {
        try {
          await gsi.signOut();
        } catch (_) {}
      }

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
              'googleLinked': false,
              'googleEmail': FieldValue.delete(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
      } catch (_) {}

      await _updateLinkedStatus();
      updateStatus(
        loc.googleAccountUnlinked ?? '✓ Google account unlinked successfully!',
        Colors.green,
        false,
      );

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String msg = e.message ?? (loc.linkFailed ?? 'Unlink failed');

      if (e.code == 'no-such-provider') {
        msg =
            loc.googleAccountNotLinked ??
            'No Google account is linked to this user.';
      } else if (e.code == 'requires-recent-login') {
        msg =
            loc.recentSignInRequiredLink ??
            'Please sign in again before unlinking.';
      }

      updateStatus(msg, Colors.red, false);
    } catch (e) {
      updateStatus(
        loc.unexpectedError ?? 'An unexpected error occurred',
        Colors.red,
        false,
      );
    }
  }

  void _handleHelpSupport({AppLocalizations? loc}) async {
    final usedLoc = loc ?? AppLocalizations.of(context)!;
    String email = 'support@tesia.com';
    String phone = '+15551234567';
    String faqLink = 'https://tesia.com/faq';

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('AppInfo')
              .doc('contact')
              .get();
      if (doc.exists) {
        final data = doc.data()!;
        email = data['email'] as String? ?? email;
        phone = data['phone'] as String? ?? phone;
        faqLink = data['faq'] as String? ?? faqLink;
      }
    } catch (e) {}

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                usedLoc.helpSupport,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.email_outlined),
                title: Text(usedLoc.emailSupport),
                subtitle: Text(email),
                onTap: () => _launchURL('mailto:$email'),
              ),
              ListTile(
                leading: Icon(Icons.phone_outlined),
                title: Text(usedLoc.phoneSupport),
                subtitle: Text(phone),
                onTap: () => _launchURL('tel:$phone'),
              ),
              ListTile(
                leading: Icon(Icons.help_outline),
                title: Text(usedLoc.faq),
                subtitle: Text(usedLoc.frequentlyAskedQuestions),
                onTap: () => _launchURL(faqLink),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleRateApp({AppLocalizations? loc}) {
    final usedLoc = loc ?? AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Lottie.asset(
                      'assets/animations/rateus.json',
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          usedLoc.enjoyingTesia,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Text(
                    usedLoc.rateAppDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            usedLoc.later,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            String rateLink =
                                'https://play.google.com/store/apps/details?id=com.tesia.app';
                            try {
                              final doc =
                                  await FirebaseFirestore.instance
                                      .collection('AppInfo')
                                      .doc('contact')
                                      .get();
                              if (doc.exists && doc.data() != null) {
                                final data = doc.data()!;
                                rateLink =
                                    (data['rateUrl'] as String?) ??
                                    (data['rateLink'] as String?) ??
                                    rateLink;
                              } else {
                                final cfg =
                                    await FirebaseFirestore.instance
                                        .collection('AppInfo')
                                        .doc('config')
                                        .get();
                                if (cfg.exists && cfg.data() != null) {
                                  final c = cfg.data()!;
                                  rateLink =
                                      (c['rateUrl'] as String?) ??
                                      (c['rateLink'] as String?) ??
                                      rateLink;
                                }
                              }
                            } catch (e) {}

                            _launchURL(rateLink);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                usedLoc.rateNow,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handlePrivacySecurity(BuildContext context, AppLocalizations loc) async {
    String summaryTitle = loc.privacySummaryTitle;
    String summaryBody = loc.privacySummaryBody;
    String keyPoints = loc.keyPoints;
    List<String> keyPointsList = [
      loc.minimalDataCollection,
      loc.strongEncryption,
      loc.googleSignInOptional,
      loc.requestDataDeletion,
    ];
    String moreDetails = loc.moreDetails;
    String moreDetailsDesc = loc.moreDetailsDescription;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('AppInfo')
          .doc('privacySummary')
          .get()
          .timeout(const Duration(seconds: 5));
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
                
        final currentLocale = Localizations.localeOf(context).languageCode;
        final isEs = currentLocale == 'es';
                
        summaryTitle = (isEs ? data['title_es'] : data['title_en']) as String? ?? summaryTitle;
        summaryBody = (isEs ? data['intro_es'] : data['intro_en']) as String? ?? summaryBody;
        keyPoints = (isEs ? data['keyPointsLabel_es'] : data['keyPointsLabel_en']) as String? ?? keyPoints;
        
        
        final List? pointsList = isEs ? data['keyPoints_es'] : data['keyPoints_en'];
        
        if (pointsList != null && pointsList.isNotEmpty) {
          keyPointsList = pointsList.map((e) => e.toString()).toList();
        } else {
        }
        
        moreDetails = (isEs ? data['moreDetailsLabel_es'] : data['moreDetailsLabel_en']) as String? ?? moreDetails;
        moreDetailsDesc = (isEs ? data['moreDetails_es'] : data['moreDetails_en']) as String? ?? moreDetailsDesc;
        
      } else {
      }
    } catch (e) {    }

    if (!context.mounted) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final primary = kTesiaColor;
        final onSurface = theme.colorScheme.onSurface;
        final onSurfaceMuted = onSurface.withOpacity(0.7);

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.64,
          minChildSize: 0.34,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            loc.privacyAndSecurity,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: onSurface,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: loc.openFullPdf,
                          icon: Icon(Icons.picture_as_pdf, color: primary),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PrivacySecurityPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              summaryTitle,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              summaryBody,
                              style: TextStyle(
                                fontSize: 14,
                                color: onSurfaceMuted,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 18),

                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: isDark ? Colors.grey[900] : Colors.white,
                                border: Border.all(
                                  color:
                                      isDark
                                          ? Colors.grey[800]!
                                          : const Color(0xFFE6EAF0),
                                ),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(width: 8),
                                      Text(
                                        keyPoints,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ...keyPointsList.map((point) => 
                                    _buildBullet(point, primary, onSurface)
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) =>
                                                    const PrivacySecurityPage(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        loc.openFullPdf,
                                        style: TextStyle(
                                          color: primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),

                            Text(
                              moreDetails,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              moreDetailsDesc,
                              style: TextStyle(
                                fontSize: 14,
                                color: onSurfaceMuted,
                                height: 1.45,
                              ),
                            ),

                            const SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: onSurface,
                                side: BorderSide(
                                  color:
                                      isDark
                                          ? Colors.grey[800]!
                                          : const Color(0xFFD6DCE6),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                loc.close,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PrivacySecurityPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                loc.viewPdf,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : null,
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
          },
        );
      },
    );
  }
  Widget _buildBullet(String text, Color primary, Color onSurface) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.5,
                color: onSurface.withOpacity(0.9),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _updateLinkedStatus();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((_) {
      _updateLinkedStatus();
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _updateLinkedStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _googleAccountLinked = false;
          _linkedEmail = null;
        });
      }
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

    if (mounted) {
      setState(() {
        _googleAccountLinked = googleProvider != null;
        _linkedEmail = googleProvider?.email ?? user.email;
      });
    }
  }

  Future<bool> _ensurePasswordLinked(User user) async {
    if (user.providerData.any((p) => p.providerId == 'password')) {
      return true;
    }
    final email = user.email;
    if (email == null || email.isEmpty) return false;

    final TextEditingController passCtrl = TextEditingController();
    final TextEditingController confirmCtrl = TextEditingController();
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    String? passError;
    String? confirmError;
    bool obscurePass = true;
    bool obscureConfirm = true;

    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              loc.setPassword ?? 'Set a password',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        loc.setPasswordExplanation ??
                            'To unlink Google you must set a password for this account so you can sign in after unlinking.',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.75),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: passCtrl,
                        obscureText: obscurePass,
                        decoration: InputDecoration(
                          labelText: loc.password ?? 'Password',
                          errorText: passError,
                          errorMaxLines: 2,
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePass
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                            onPressed:
                                () =>
                                    setState(() => obscurePass = !obscurePass),
                          ),
                        ),
                        onChanged: (value) {
                          if (passError != null) {
                            setState(() => passError = null);
                          }
                        },
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: confirmCtrl,
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          labelText: loc.confirmPassword ?? 'Confirm password',
                          errorText: confirmError,
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                            onPressed:
                                () => setState(
                                  () => obscureConfirm = !obscureConfirm,
                                ),
                          ),
                        ),
                        onChanged: (value) {
                          if (confirmError != null) {
                            setState(() => confirmError = null);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.colorScheme.onSurface,
                                side: BorderSide(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.08),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(loc.cancel ?? 'Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kTesiaColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                final pass = passCtrl.text.trim();
                                final conf = confirmCtrl.text.trim();
                                bool ok = true;
                                String? pErr;
                                String? cErr;

                                if (pass.length < 8) {
                                  ok = false;
                                  pErr = loc.passwordTooShort(8);
                                } else if (!RegExp(r'[A-Z]').hasMatch(pass)) {
                                  ok = false;
                                  pErr = loc.passwordRequiresUpper;
                                } else if (!RegExp(r'[a-z]').hasMatch(pass)) {
                                  ok = false;
                                  pErr = loc.passwordRequiresLower;
                                } else if (!RegExp(r'[0-9]').hasMatch(pass)) {
                                  ok = false;
                                  pErr = loc.passwordRequiresDigit;
                                } else if (!RegExp(
                                  r'[!@#$%^&*(),.?":{}|<>]',
                                ).hasMatch(pass)) {
                                  ok = false;
                                  pErr = loc.passwordRequiresSpecial;
                                }

                                if (pass != conf) {
                                  ok = false;
                                  cErr =
                                      loc.passwordsDoNotMatch ??
                                      'Passwords do not match';
                                }

                                if (!ok) {
                                  setState(() {
                                    passError = pErr;
                                    confirmError = cErr;
                                  });
                                  return;
                                }

                                Navigator.of(context).pop(true);
                              },
                              child: Text(loc.setPassword ?? 'Set Password'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    if (res != true) return false;

    final password = passCtrl.text.trim();
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.linkWithCredential(credential);
      await user.reload();
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'updatedAt': FieldValue.serverTimestamp()});
      } catch (_) {}
      return true;
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String msg;
        switch (e.code) {
          case 'weak-password':
            msg = loc.passwordTooShort(8);
            break;
          case 'invalid-email':
            msg = loc.invalidEmailAddress;
            break;
          case 'email-already-in-use':
            msg = loc.emailAlreadyInUse;
            break;
          default:
            msg = e.message ?? loc.failedToLinkPassword;
        }
        showSnack(context, msg, error: true);
      }
      return false;
    } catch (e) {
      if (mounted) showSnack(context, loc.failedToLinkPassword, error: true);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          loc.settings,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? theme.colorScheme.surface : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color:
                          isDark
                              ? Colors.black.withOpacity(0.3)
                              : const Color(0xFF000000).withOpacity(0.06),
                      spreadRadius: 0,
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                        left: 8,
                        right: 8,
                        bottom: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: _buildQuickAction(
                              icon: Icons.person_outline,
                              label: loc.profile,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfilePage(),
                                  ),
                                );
                              },
                            ),
                          ),
                          Flexible(
                            child: _buildQuickAction(
                              icon: Icons.language,
                              label:
                                  _languages[Provider.of<LocaleProvider>(
                                    context,
                                  ).locale.languageCode]?['name'] ??
                                  loc.english,
                              onTap: () => _showLanguageDialog(loc),
                            ),
                          ),
                          Flexible(
                            child: _buildQuickAction(
                              icon: _getThemeIcon(
                                Provider.of<ThemeProvider>(context).themeMode,
                              ),
                              label: loc.theme,
                              onTap: () => _showThemeSelectorModal(loc),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? theme.colorScheme.surface : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color:
                          isDark
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
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 16),
                      child: Text(
                        loc.account,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    _buildSettingsTile(
                      icon: Icons.link,
                      label: loc.linkGoogleAccount,
                      subtitle:
                          _googleAccountLinked
                              ? '${loc.linked}: ${_linkedEmail ?? loc.googleAccount} • ${loc.syncActive}'
                              : loc.syncYourDataWithGoogle,
                      onTap: _handleGoogleAccountLink,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? theme.colorScheme.surface : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color:
                          isDark
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
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 16),
                      child: Text(
                        loc.security,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    _buildSettingsTile(
                      icon: Icons.security,
                      label: loc.privacyAndSecurity,
                      subtitle: loc.manageYourPrivacySettings,
                      onTap: () => _handlePrivacySecurity(context, loc),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? theme.colorScheme.surface : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color:
                          isDark
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
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 16),
                      child: Text(
                        loc.app,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    _buildSettingsTile(
                      icon: Icons.help_outline,
                      label: loc.helpSupport,
                      subtitle: loc.getHelpAndContactSupport,
                      onTap: _handleHelpSupport,
                    ),
                    _divider(),
                    _buildSettingsTile(
                      icon: Icons.info_outline,
                      label: loc.about,
                      subtitle: loc.appVersionAndInformation,
                      onTap: () {
                        _showAboutDialog(loc);
                      },
                    ),
                    _divider(),
                    _buildSettingsTile(
                      icon: Icons.star_outline,
                      label: loc.rateApp,
                      subtitle: loc.rateUsOnTheAppStore,
                      onTap: _handleRateApp,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? theme.colorScheme.surface : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color:
                          isDark
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
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 16),
                      child: Text(
                        loc.dangerZone,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    _buildSettingsTile(
                      icon: Icons.logout,
                      label: loc.signOut,
                      subtitle: loc.signOutOfYourAccount,
                      onTap: () {
                        _showSignOutDialog(context, loc);
                      },
                      textColor: Colors.red,
                    ),
                    _divider(),
                    _buildSettingsTile(
                      icon: Icons.delete_outline,
                      label: loc.deleteAccount,
                      subtitle: loc.permanentlyDeleteYourAccount,
                      onTap: () {
                        _showDeleteAccountDialog(context, loc);
                      },
                      textColor: Colors.red,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : const Color(0xFFE8EBF0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isDark ? Colors.grey.shade300 : const Color(0xFF6B7280),
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
      default:
        return Icons.brightness_auto;
    }
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? subtitle,
    Color? textColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : const Color(0xFFE8EBF0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color:
              textColor ??
              (isDark ? Colors.grey.shade300 : const Color(0xFF6B7280)),
          size: 22,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor ?? theme.colorScheme.onSurface,
        ),
      ),
      subtitle:
          subtitle != null
              ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color:
                      isDark ? Colors.grey.shade400 : const Color(0xFF6B7280),
                ),
              )
              : null,
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? Colors.grey.shade500 : const Color(0xFF9CA3AF),
        size: 22,
      ),
      onTap: onTap,
    );
  }

  Widget _divider() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 70, right: 12),
      child: Divider(
        height: 1,
        color: isDark ? Colors.grey.shade700 : const Color(0xFFE5E8ED),
        thickness: 1,
      ),
    );
  }

  void _showLanguageDialog(AppLocalizations loc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  loc.selectLanguage,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              ..._languages.entries.map((entry) {
                final code = entry.key;
                final flag = entry.value['flag']!;
                final name = entry.value['name']!;
                final localeProvider = Provider.of<LocaleProvider>(
                  context,
                  listen: false,
                );
                final isSelected = localeProvider.locale.languageCode == code;

                return ListTile(
                  leading: Text(flag, style: const TextStyle(fontSize: 22)),
                  title: Text(name),
                  trailing:
                      isSelected
                          ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).primaryColor,
                          )
                          : null,
                  onTap: () {
                    localeProvider.setLocale(Locale(code));
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showThemeSelectorModal(AppLocalizations loc) {
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
                loc.selectTheme,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return Column(
                    children: [
                      RadioListTile<ThemeMode>(
                        value: ThemeMode.light,
                        groupValue: themeProvider.themeMode,
                        onChanged: (mode) {
                          if (mode != null) themeProvider.setTheme(mode);
                          Navigator.pop(context);
                        },
                        title: Text(loc.light),
                        secondary: Icon(Icons.light_mode),
                      ),
                      RadioListTile<ThemeMode>(
                        value: ThemeMode.dark,
                        groupValue: themeProvider.themeMode,
                        onChanged: (mode) {
                          if (mode != null) themeProvider.setTheme(mode);
                          Navigator.pop(context);
                        },
                        title: Text(loc.dark),
                        secondary: Icon(Icons.dark_mode),
                      ),
                      RadioListTile<ThemeMode>(
                        value: ThemeMode.system,
                        groupValue: themeProvider.themeMode,
                        onChanged: (mode) {
                          if (mode != null) themeProvider.setTheme(mode);
                          Navigator.pop(context);
                        },
                        title: Text(loc.system),
                        secondary: Icon(Icons.brightness_auto),
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

    Future<void> _showAboutDialog(AppLocalizations loc) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = kTesiaColor;
    final onSurface = theme.colorScheme.onSurface;

    String appName = 'TESIA';
    String subtitle = loc.privacySecurityAndAppInfo;
    String aboutTitle = loc.aboutTesia;
    String aboutDescription = loc.aboutTesiaDescription;
    String whatWeOfferTitle = loc.whatWeOffer;
    List<String> features = [
      loc.aiMoldDetection,
      loc.detailedReportsAndSync,
      loc.privacyFirstApproach,
      loc.multiLanguageSupport,
    ];
    String versionLabel = loc.version;
    String versionNumber = '1.0.0';
    String supportLabel = loc.support;
    String supportEmail = 'support@tesia.com';
    String websiteUrl = 'https://tesia.com';
    String copyrightText = loc.copyright;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('AppInfo')
          .doc('about')
          .get()
          .timeout(const Duration(seconds: 5));

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final currentLocale = Localizations.localeOf(context).languageCode;
        final isEs = currentLocale == 'es';

        appName = (data['appName'] as String?) ?? appName;
        subtitle = (isEs ? data['subtitle_es'] : data['subtitle_en']) as String? ?? subtitle;
        aboutTitle = (isEs ? data['aboutTitle_es'] : data['aboutTitle_en']) as String? ?? aboutTitle;
        aboutDescription = (isEs ? data['aboutDescription_es'] : data['aboutDescription_en']) as String? ?? aboutDescription;
        whatWeOfferTitle = (isEs ? data['featuresTitle_es'] : data['featuresTitle_en']) as String? ?? whatWeOfferTitle;

        final List? featuresList = isEs ? data['features_es'] : data['features_en'];
        if (featuresList != null && featuresList.isNotEmpty) {
          features = featuresList.map((e) => e.toString()).toList();
        }

        versionLabel = (isEs ? data['versionLabel_es'] : data['versionLabel_en']) as String? ?? versionLabel;
        versionNumber = (data['version'] as String?) ?? versionNumber;
        supportLabel = (isEs ? data['supportLabel_es'] : data['supportLabel_en']) as String? ?? supportLabel;
        supportEmail = (data['supportEmail'] as String?) ?? (data['email'] as String?) ?? supportEmail;
        websiteUrl = (data['website'] as String?) ?? (data['websiteUrl'] as String?) ?? websiteUrl;

        if (data['copyrightText'] is String && (data['copyrightText'] as String).trim().isNotEmpty) {
          copyrightText = data['copyrightText'] as String;
        } else if (data['releaseYear'] != null || data['year'] != null) {
          final year = (data['releaseYear'] ?? data['year']).toString();
          copyrightText = 'TESIA © $year';
        }
      }
    } catch (e) {
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 40,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: theme.colorScheme.surface,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.78,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? Colors.grey[900]
                                : primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/logos/Tesia_nobg.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: onSurface.withOpacity(0.7),
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: onSurface.withOpacity(0.6),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          aboutTitle,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          aboutDescription,
                          style: TextStyle(
                            fontSize: 14,
                            color: onSurface.withOpacity(0.85),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 14),

                        Text(
                          whatWeOfferTitle,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: features.map((feature) => _AboutBullet(feature)).toList(),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              versionLabel,
                              style: TextStyle(
                                fontSize: 13,
                                color: onSurface.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              versionNumber,
                              style: TextStyle(
                                fontSize: 13,
                                color: onSurface.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              supportLabel,
                              style: TextStyle(
                                fontSize: 13,
                                color: onSurface.withOpacity(0.7),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _launchURL('mailto:$supportEmail'),
                              child: Text(
                                supportEmail,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        Center(
                          child: Text(
                            copyrightText,
                            style: TextStyle(
                              fontSize: 12,
                              color: onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: onSurface,
                          side: BorderSide(
                            color:
                                isDark
                                    ? Colors.grey[700]!
                                    : const Color(0xFFD6DCE6),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          loc.close,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _launchURL(websiteUrl);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          loc.visitWebsite,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSignOutDialog(BuildContext context, AppLocalizations loc) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: theme.colorScheme.error,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        loc.signOut,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.signOutConfirmation,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            loc.cancel,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            try {
                              await FirebaseAuth.instance.signOut();
                            } catch (e) {}
                            if (!mounted) return;
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const SignInScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.error,
                            foregroundColor: theme.colorScheme.onError,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            loc.signOut,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AppLocalizations loc) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_forever,
                        color: theme.colorScheme.error,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        loc.deleteAccount,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.deleteAccountConfirmation,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loc.lossOfDetectionHistory),
                        Text(loc.lossOfSettings),
                        Text(loc.lossOfCloudSync),
                        Text(loc.unableToRecover),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            loc.cancel,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            performAccountRemoval(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.error,
                            foregroundColor: theme.colorScheme.onError,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            loc.deleteAccount,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AboutBullet extends StatelessWidget {
  final String text;

  const _AboutBullet(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.5,
                color: onSurface.withOpacity(0.9),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
