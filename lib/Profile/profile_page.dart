import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tesia_app/l10n/app_localizations.dart';
import 'package:tesia_app/shared/colors.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:tesia_app/authentication/signin_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tesia_app/shared/components/account_removal.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _newPwdCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();
  int _points = 0;
  int _pointsTotal = 40;

  bool _pwdVisible = false;
  bool _confirmVisible = false;
  bool _pwdSection = false;
  bool _dangerSection = false;
  bool _loading = true;
  bool _editMode = false;
  bool _saving = false;
  bool _changingPassword = false;
  Timer? _emailVerificationTimer;
  bool _waitingForEmailVerification = false;

  String? _avatarUrl;
  String? _kitCode;
  File? _pickedImg;
  Uint8List? _pickedBytes;
  final _imgPicker = ImagePicker();
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
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

  
  Future<String?> _promptForPassword(String email) async {
    final ctrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;
    final res = await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: dark ? theme.colorScheme.surface : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            loc.confirmPassword,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.reenterPasswordFor(email),
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: ctrl,
                  obscureText: true,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: loc.password,
                    labelStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                    filled: true,
                    fillColor:
                        dark
                            ? theme.colorScheme.surfaceContainerHighest
                            : Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: dark ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: dark ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: kTesiaColor,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: Icon(
                      Icons.lock_outline,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      size: 20,
                    ),
                  ),
                  validator:
                      (v) =>
                          (v == null || v.isEmpty)
                              ? loc.passwordRequired
                              : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              child: Text(
                loc.cancel,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(ctx, ctrl.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kTesiaColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                loc.continueLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        );
      },
    );
    return res;
  }

  Future<String?> _uploadScanFile(File file, {String? kitCode}) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;

    final ts = DateTime.now().toUtc();
    final prefix =
        '${ts.toIso8601String().replaceAll(RegExp(r'[:\-]'), '').split('.').first}';
    final rand = _uuid.v4().split('-').first;
    final filename = '${prefix}_$rand.jpg';
    final path = 'scans/${currentUser.uid}/$filename';

    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      await ref.putFile(file, metadata);
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('scans')
          .add({
            'url': url,
            'filename': filename,
            'storagePath': path,
            'kitCode': kitCode,
            'createdAt': FieldValue.serverTimestamp(),
          });

      return url;
    } catch (e) {
      return null;
    }
  }

  Future<String?> _uploadScanFileFromBytes(
    Uint8List bytes, {
    String? kitCode,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;

    final ts = DateTime.now().toUtc();
    final prefix =
        '${ts.toIso8601String().replaceAll(RegExp(r'[:\-]'), '').split('.').first}';
    final rand = _uuid.v4().split('-').first;
    final filename = '${prefix}_$rand.jpg';
    final path = 'scans/${currentUser.uid}/$filename';

    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      await ref.putData(bytes, metadata);
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('scans')
          .add({
            'url': url,
            'filename': filename,
            'storagePath': path,
            'kitCode': kitCode,
            'createdAt': FieldValue.serverTimestamp(),
          });

      return url;
    } catch (e) {
      return null;
    }
  }

  Future<void> _selectImageSource() async {
    final loc = AppLocalizations.of(context)!;
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera_alt, color: kTesiaColor),
                    title: Text(loc.camera ?? 'Camera'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _grabImage(ImageSource.camera, asAvatar: true);
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.photo_library,
                      color: kTesiaColor,
                    ),
                    title: Text(loc.gallery ?? 'Gallery'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _grabImage(ImageSource.gallery, asAvatar: true);
                    },
                  ),
                  if (_avatarUrl != null || _pickedImg != null)
                    ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: Text(loc.removePhoto ?? 'Remove Photo'),
                      onTap: () {
                        Navigator.pop(ctx);
                        _clearAvatar();
                      },
                    ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _grabImage(ImageSource src, {bool asAvatar = true}) async {
    final loc = AppLocalizations.of(context)!;
    try {
      final chosen = await _imgPicker.pickImage(
        source: src,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (chosen != null) {
        if (kIsWeb) {
          final bytes = await chosen.readAsBytes();
          setState(() {
            _pickedBytes = bytes;
            _pickedImg = null;
          });
          if (asAvatar) {
            await _pushAvatar();
          } else {
            final url = await _uploadScanFileFromBytes(bytes, kitCode: null);
            if (url != null) {
              _showSnack(loc.imageStored);
              setState(() => _pickedBytes = null);
            } else {
              _showSnack(loc.uploadFailed, error: true);
            }
          }
          return;
        }

        setState(() => _pickedImg = File(chosen.path));
        if (asAvatar) {
          await _pushAvatar();
        } else {
          final url = await _uploadScanFile(_pickedImg!);
          if (url != null) {
            _showSnack(loc.imageStored);
            setState(() => _pickedImg = null);
          } else {
            _showSnack(loc.uploadFailed, error: true);
          }
        }
      }
    } catch (err) {
      if (mounted) {
        _showSnack(loc.failedToPickImage, error: true);
      }
    }
  }

  Future<void> _pushAvatar() async {
    final loc = AppLocalizations.of(context)!;
    if (!kIsWeb && _pickedImg == null) return;
    if (kIsWeb && _pickedBytes == null) return;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showSnack(loc.notSignedIn, error: true);
      return;
    }

    try {
      await currentUser.reload();
    } catch (e) {
      _showSnack(loc.refreshfailed, error: true);
      return;
    }

    try {
      setState(() => _saving = true);
      final profilePath = 'avatars/${currentUser.uid}/profile.jpg';
      final ref = FirebaseStorage.instance.ref().child(profilePath);
      final metadata = SettableMetadata(contentType: 'image/jpeg');

      if (kIsWeb) {
        await ref.putData(_pickedBytes!, metadata);
      } else {
        await ref.putFile(_pickedImg!, metadata);
      }

      final link = await ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
            'photoURL': link,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        setState(() {
          _avatarUrl = link;
          _pickedImg = null;
          _pickedBytes = null;
          _saving = false;
        });
        _showSnack(loc.profilePictureUpdated);
      }
    } catch (err) {
      if (mounted) {
        setState(() => _saving = false);
        _showSnack(loc.uploadFailed, error: true);
      }
    }
  }

  Future<void> _clearAvatar() async {
    final loc = AppLocalizations.of(context)!;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      setState(() => _saving = true);

      if (_avatarUrl != null) {
        try {
          final profilePath = 'avatars/${currentUser.uid}/profile.jpg';
          final storeLoc = FirebaseStorage.instance.ref().child(profilePath);
          await storeLoc.delete();
        } catch (err) {}
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'photoURL': null});

      if (mounted) {
        setState(() {
          _avatarUrl = null;
          _pickedImg = null;
          _saving = false;
        });
        _showSnack(loc.profilePictureRemoved);
      }
    } catch (err) {
      if (mounted) {
        setState(() => _saving = false);
        _showSnack(loc.removeFailed, error: true);
      }
    }
  }

  List<String> _getLinkedProviders() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    return user.providerData.map((p) => p.providerId).toList();
  }

  bool _hasPasswordProvider() => _getLinkedProviders().contains('password');

  bool _hasGoogleProvider() => _getLinkedProviders().contains('google.com');

  Future<String?> _chooseReauthMethod() async {
    final providers = _getLinkedProviders();
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;

    if (providers.length == 1) {
      return providers.first;
    }

    final choice = await showDialog<String>(
      context: context,
      barrierDismissible: false,

      builder:
          (ctx) => AlertDialog(
            backgroundColor: dark ? theme.colorScheme.surface : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              loc.verifyIdentity,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            content: Text(
              loc.verifyIdentityContent,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.4,
              ),
            ),
            actions: [
              if (_hasPasswordProvider())
                Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 8),
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(ctx, 'password'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kTesiaColor,
                      side: const BorderSide(color: kTesiaColor, width: 1.5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.lock_outline, size: 18),
                    label: Text(
                      loc.password,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (_hasGoogleProvider())
                Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 8),
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(ctx, 'google.com'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kTesiaColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.g_mobiledata, size: 18),
                    label: Text(
                      loc.google,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
    );
    return choice;
  }

  Future<void> _reauthenticateUser(String provider) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('Not signed in');

    if (provider == 'password') {
      final pw = await _promptForPassword(currentUser.email ?? '');
      if (pw == null || pw.isEmpty)
        throw Exception('Password re-auth cancelled');

      try {
        final cred = EmailAuthProvider.credential(
          email: currentUser.email ?? '',
          password: pw,
        );
        await currentUser.reauthenticateWithCredential(cred);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
          throw FirebaseAuthException(
            code: 'wrong-password',
            message: 'Incorrect password',
          );
        } else if (e.code == 'user-not-found') {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'Account not found',
          );
        }
        rethrow;
      }
    } else if (provider == 'google.com') {
      try {
        final googleUser =
            await GoogleSignIn(scopes: ['email', 'profile']).signIn();
        if (googleUser == null) throw Exception('Google sign-in cancelled');

        final googleAuth = await googleUser.authentication;
        if (googleAuth.accessToken == null || googleAuth.idToken == null) {
          throw Exception('Google auth tokens unavailable');
        }

        final cred = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken!,
          idToken: googleAuth.idToken!,
        );
        await currentUser.reauthenticateWithCredential(cred);
      } catch (e) {
        throw Exception('Google re-auth failed: ${e.toString()}');
      }
    } else {
      throw Exception('Unknown provider: $provider');
    }
  }

  void _startEmailVerificationCheck() {
    _emailVerificationTimer?.cancel();
    setState(() => _waitingForEmailVerification = true);

    int checkCount = 0;
    const maxChecks = 120;

    _emailVerificationTimer = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) async {
      checkCount++;

      if (!mounted) {
        timer.cancel();
        return;
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        timer.cancel();
        if (mounted) setState(() => _waitingForEmailVerification = false);
        return;
      }

      try {
        await currentUser.reload();
        final refreshedUser = FirebaseAuth.instance.currentUser;

        if (refreshedUser == null) {
          timer.cancel();
          if (mounted) setState(() => _waitingForEmailVerification = false);
          return;
        }

        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(refreshedUser.uid)
                .get();

        final data = userDoc.data();
        final pendingEmail = data?['pendingEmail'] as String?;
        final currentEmail = refreshedUser.email ?? '';

        if (pendingEmail != null &&
            pendingEmail == currentEmail &&
            refreshedUser.emailVerified) {
          timer.cancel();
          if (mounted) setState(() => _waitingForEmailVerification = false);

          await FirebaseFirestore.instance
              .collection('users')
              .doc(refreshedUser.uid)
              .update({
                'email': currentEmail,
                'emailVerified': true,
                'pendingEmail': FieldValue.delete(),
                'pendingEmailRequestedAt': FieldValue.delete(),
                'updatedAt': FieldValue.serverTimestamp(),
              });

          if (mounted) {
            setState(() {
              _emailCtrl.text = currentEmail;
            });
            _showSnack(
              AppLocalizations.of(context)!.emailVerifiedSuccessfully ??
                  ' Email successfully verified and updated!',
            );
          }
          return;
        }

        if (checkCount >= maxChecks) {
          timer.cancel();
          if (mounted) {
            setState(() => _waitingForEmailVerification = false);
            _showSnack(
                  AppLocalizations.of(context)!.emailChangeTimedOut ?? 'Email verification timed out. Please try again.',
              error: true,
            );
          }
        }
      } catch (e) {}
    });
  }


Future<void> _commitChanges() async {
  final loc = AppLocalizations.of(context)!;
  if (!_formKey.currentState!.validate()) return;

  setState(() => _saving = true);

  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    setState(() => _saving = false);
    _showSnack(loc.notSignedIn, error: true);
    return;
  }

  final newDisplayName = _displayNameCtrl.text.trim();
  final newEmail = _emailCtrl.text.trim().toLowerCase();
  final currentEmail = currentUser.email ?? '';

  try {
    if (newEmail.isNotEmpty && newEmail != currentEmail) {
      final providers = currentUser.providerData.map((p) => p.providerId).toList();
      final hasGoogleProvider = providers.contains('google.com');

      if (hasGoogleProvider) {
        setState(() => _saving = false);
        _showSnack(loc.emailChangeGoogleProvider, error: true);
        return;
      }

      try {
        final chosenProvider = await _chooseReauthMethod();
        if (chosenProvider == null) {
          setState(() => _saving = false);
          _showSnack(loc.emailchangecanceled, error: true);
          return;
        }

        await _reauthenticateUser(chosenProvider);

        await currentUser.verifyBeforeUpdateEmail(newEmail);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'pendingEmail': newEmail,
          'pendingEmailRequestedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          setState(() => _saving = false);
          
        await showDialog(
  context: context,
  barrierDismissible: false,
  builder: (ctx) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: EdgeInsets.zero,
      title: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: Row(
          children: [
            Icon(Icons.email, color: kTesiaColor, size: isSmallScreen ? 20 : 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                loc.verifyBeforeUpdateEmailTitle ?? 'Verify Your New Email',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      content: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.verificationEmailSent(newEmail) ??
                  'We\'ve sent a verification email to $newEmail.',
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 14,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.emailVerificationStepsTitle ?? 'Next Steps:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 13 : 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildStep(
                    '1. ${loc.checkYourInbox ?? "Check your inbox"}',
                    isSmallScreen,
                  ),
                  SizedBox(height: 4),
                  _buildStep(
                    '2. ${loc.clickTheVerificationLink ?? "Click the verification link"}',
                    isSmallScreen,
                  ),
                  SizedBox(height: 4),
                  _buildStep(
                    '3. ${loc.signInAgainWithNewEmail ?? "Sign in again with your new email"}',
                    isSmallScreen,
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: isSmallScreen ? 16 : 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      loc.waitingForEmailVerification ??
                          'Waiting for email verification...',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 11 : 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _signOutAndRedirect();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 20,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  loc.understood ?? 'Understood',
                  style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  },
);

        }
        return;

      } on FirebaseAuthException catch (authErr) {
        String msg;
        switch (authErr.code) {
          case 'invalid-email':
            msg = loc.invalidEmailAddress;
            break;
          case 'email-already-in-use':
            msg = loc.emailAlreadyInUse;
            break;
          case 'requires-recent-login':
            msg = loc.recentSignInRequiredEmail ?? 'Please sign in again to change your email';
            break;
          default:
            msg = authErr.message ?? loc.failedToUpdateEmail;
        }
        if (mounted) {
          setState(() => _saving = false);
          _showSnack(msg, error: true);
        }
        return;
      }
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update({
      'displayName': newDisplayName,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      setState(() {
        _saving = false;
        _editMode = false;
      });
      _showSnack(loc.profileUpdated);
    }
  } catch (err) {
    if (mounted) {
      setState(() => _saving = false);
      _showSnack('${loc.updatedfailed}: ${err.toString()}', error: true);
    }
  }
}
Widget _buildStep(String text, bool isSmall) {
  return Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(
      text,
      style: TextStyle(
        fontSize: isSmall ? 12 : 13,
        height: 1.4,
      ),
    ),
  );
}
Future<void> _signOutAndRedirect() async {
  try {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
      (route) => false,
    );
  } catch (e) {
    if (mounted) {
      _showSnack(AppLocalizations.of(context)!.signOutFailed, error: true);
    }
  }
}



Future<void> _fetchProfile() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return;

  try {
    await currentUser.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;
    if (refreshedUser == null) return;

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(refreshedUser.uid);
    final snap = await userDocRef.get();

    if (snap.exists && mounted) {
      final raw = snap.data();
      final currentEmail = refreshedUser.email ?? '';
      final pendingEmail = (raw?['pendingEmail'] as String?) ?? '';
      final storedEmail = (raw?['email'] as String?) ?? '';

      if (pendingEmail.isNotEmpty &&
          currentEmail.isNotEmpty &&
          pendingEmail == currentEmail &&
          refreshedUser.emailVerified &&
          storedEmail != currentEmail) {
        
        try {
          await userDocRef.update({
            'email': currentEmail,
            'emailVerified': true,
            'pendingEmail': FieldValue.delete(),
            'pendingEmailRequestedAt': FieldValue.delete(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          if (mounted) {
            _showSnack(
              AppLocalizations.of(context)!.emailVerifiedSuccessfully ??
                  'Email successfully verified and updated!',
            );
          }
        } catch (e) {
        }
      }

      setState(() {
        _displayNameCtrl.text = raw?['displayName'] ?? '';
        _emailCtrl.text = raw?['email'] ?? currentEmail;
        _avatarUrl = raw?['photoURL'];
        _kitCode = raw?['kitCode']?.toString();
        _points = (raw?['points'] is num) ? (raw?['points'] as num).toInt() : 0;
        _pointsTotal = (raw?['pointsTotal'] is num) ? (raw?['pointsTotal'] as num).toInt() : _pointsTotal;
        _loading = false;
      });
    }
  } catch (err) {
    if (mounted) setState(() => _loading = false);
  }
}


  Future<void> _changePassword() async {
    if (!_hasPasswordProvider()) {
      _showSnack(
        AppLocalizations.of(context)!.googlePasswordChangeNotAvailable,
        error: true,
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final newPwd = _newPwdCtrl.text;
    if (newPwd.isEmpty) {
      _showSnack(
        AppLocalizations.of(context)!.pleaseEnterNewPassword,
        error: true,
      );
      return;
    }

    setState(() => _changingPassword = true);

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      await currentUser.updatePassword(newPwd);

      if (mounted) {
        _newPwdCtrl.clear();
        _confirmPwdCtrl.clear();
        setState(() {
          _changingPassword = false;
          _pwdSection = false;
        });
        _showSnack(AppLocalizations.of(context)!.passwordUpdatedSuccessfully);
      }
    } on FirebaseAuthException catch (authErr) {
      if (authErr.code == 'requires-recent-login') {
        try {
          final chosenProvider = await _chooseReauthMethod();
          if (chosenProvider == null) {
            if (mounted) {
              setState(() => _changingPassword = false);
              _showSnack(
                AppLocalizations.of(context)!.reauthCancelled,
                error: true,
              );
            }
            return;
          }

          await _reauthenticateUser(chosenProvider);
          await currentUser.updatePassword(newPwd);

          if (mounted) {
            _newPwdCtrl.clear();
            _confirmPwdCtrl.clear();
            setState(() {
              _changingPassword = false;
              _pwdSection = false;
            });
            _showSnack(
              AppLocalizations.of(context)!.passwordUpdatedSuccessfully,
            );
          }
        } catch (e) {
          if (mounted) {
            setState(() => _changingPassword = false);
            _showSnack(AppLocalizations.of(context)!.reauthFailed, error: true);
          }
        }
      } else {
        String msg;
        if (authErr.code == 'weak-password') {
          msg = AppLocalizations.of(context)!.passwordTooWeak;
        } else {
          msg = authErr.message ?? AppLocalizations.of(context)!.authError;
        }
        if (mounted) {
          setState(() => _changingPassword = false);
          _showSnack(msg, error: true);
        }
      }
    } catch (err) {
      if (mounted) {
        setState(() => _changingPassword = false);
        _showSnack(
          AppLocalizations.of(context)!.passwordUpdateFailed,
          error: true,
        );
      }
    }
  }

  Future<void> _removeAccount() async {
    final loc = AppLocalizations.of(context)!;
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

  Future<void> _logout() async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
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
                    loc.signOutConfirmMessage,
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
                          onPressed: () => Navigator.pop(context, false),
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
                          onPressed: () => Navigator.pop(context, true),
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
                            style: const TextStyle(fontWeight: FontWeight.w600),
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

    if (confirmed != true) return;

    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SignInScreen()),
        (route) => false,
      );
      _showSnack(loc.signedOut);
    } catch (err) {
      if (mounted) _showSnack(loc.signOutFailed, error: true);
    }
  }

  Widget _fieldShimmer({double height = 48, double width = double.infinity}) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: dark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: dark ? Colors.grey[700]! : Colors.grey[100]!,
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios,
                              size: 20,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                          Text(
                            loc.account,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _editMode ? Icons.close : Icons.edit,
                              size: 22,
                              color:
                                  _editMode
                                      ? Colors.red
                                      : Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.6),
                            ),
                            onPressed:
                                () => setState(() => _editMode = !_editMode),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _loading
                              ? Shimmer.fromColors(
                                baseColor:
                                    dark
                                        ? Colors.grey[800]!
                                        : Colors.grey[300]!,
                                highlightColor:
                                    dark
                                        ? Colors.grey[700]!
                                        : Colors.grey[100]!,
                                child: Container(
                                  width: 88,
                                  height: 88,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                              : Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 44,
                                    backgroundColor:
                                        dark
                                            ? Colors.grey[800]
                                            : Colors.grey[300],
                                    backgroundImage:
                                        (_pickedImg != null)
                                            ? FileImage(_pickedImg!)
                                            : (_pickedBytes != null)
                                            ? MemoryImage(_pickedBytes!)
                                            : (_avatarUrl != null
                                                    ? CachedNetworkImageProvider(
                                                      _avatarUrl!,
                                                    )
                                                    : null)
                                                as ImageProvider?,
                                    child:
                                        (_avatarUrl == null &&
                                                _pickedImg == null)
                                            ? Icon(
                                              Icons.person,
                                              size: 60,
                                              color:
                                                  dark
                                                      ? Colors.grey[400]
                                                      : Colors.grey[600],
                                            )
                                            : null,
                                  ),
                                  if (_saving)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black45,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            valueColor: AlwaysStoppedAnimation(
                                              Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                          const SizedBox(width: 12),
                          _loading
                              ? Shimmer.fromColors(
                                baseColor:
                                    dark
                                        ? Colors.grey[800]!
                                        : Colors.grey[300]!,
                                highlightColor:
                                    dark
                                        ? Colors.grey[700]!
                                        : Colors.grey[100]!,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                              : InkWell(
                                onTap: _editMode ? _selectImageSource : null,
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color:
                                        dark
                                            ? Colors.grey[800]
                                            : Colors.grey[200],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Center(
                                        child: Icon(
                                          Icons.camera_alt,
                                          size: 24,
                                          color:
                                              dark
                                                  ? Colors.grey[400]
                                                  : Colors.grey,
                                        ),
                                      ),
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: Icon(
                                          Icons.add,
                                          size: 14,
                                          color:
                                              dark
                                                  ? Colors.grey[400]
                                                  : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _loading
                          ? Center(
                            child: Shimmer.fromColors(
                              baseColor:
                                  dark ? Colors.grey[800]! : Colors.grey[300]!,
                              highlightColor:
                                  dark ? Colors.grey[700]! : Colors.grey[100]!,
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                height: 80,
                              ),
                            ),
                          )
                          : Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color:
                                    dark
                                        ? Theme.of(context).colorScheme.surface
                                        : Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      dark
                                          ? Colors.grey[800]!
                                          : Colors.grey[200]!,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 32,
                                            height: 32,
                                            child: Image.asset(
                                              'assets/logos/Tesia_nobg.png',
                                              width: 64,
                                              height: 32,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                loc.freePlan,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).colorScheme.onSurface,
                                                ),
                                              ),
                                              Text(
                                                _kitCode != null &&
                                                        _kitCode!.isNotEmpty
                                                    ? _kitCode!
                                                    : loc.unknown,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.6),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Text(
                                        loc.scansCompleted(
                                          _points,
                                          _pointsTotal,
                                        ),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  if (_waitingForEmailVerification)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.blue.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                    Colors.blue,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              loc.waitingForEmailVerification,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.blue[700],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          child: LinearProgressIndicator(
                                            value:
                                                (_pointsTotal > 0)
                                                    ? (_points / _pointsTotal)
                                                    : 0,
                                            backgroundColor:
                                                dark
                                                    ? Colors.grey[800]
                                                    : Colors.grey[200],
                                            valueColor:
                                                const AlwaysStoppedAnimation(
                                                  kTesiaColor,
                                                ),
                                            minHeight: 5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${((_pointsTotal > 0) ? ((_points * 100 / _pointsTotal).round()) : 0)}%',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                      const SizedBox(height: 32),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.fullname,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (_loading)
                                  _fieldShimmer(height: 48)
                                else
                                  TextFormField(
                                    controller: _displayNameCtrl,
                                    enabled: _editMode,
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: loc.fullname,
                                      hintStyle: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.4),
                                      ),
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              dark
                                                  ? Colors.grey[700]!
                                                  : Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              dark
                                                  ? Colors.grey[700]!
                                                  : Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.blue,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                    ),
                                  ),
                                const SizedBox(height: 24),

                                Text(
                                  loc.email,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (_loading)
                                  _fieldShimmer(height: 48)
                                else
                                  TextFormField(
                                    controller: _emailCtrl,
                                    enabled: _editMode,
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: loc.email,
                                      hintStyle: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.4),
                                      ),
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              dark
                                                  ? Colors.grey[700]!
                                                  : Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              dark
                                                  ? Colors.grey[700]!
                                                  : Colors.grey[300]!,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                    ),
                                  ),
                                const SizedBox(height: 24),
                                if (_loading)
                                  _fieldShimmer(height: 48)
                                else
                                  InkWell(
                                    onTap:
                                        () => setState(
                                          () => _pwdSection = !_pwdSection,
                                        ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  loc.modifyPassword,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withOpacity(0.7),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  loc.modifyPasswordDescription,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withOpacity(0.5),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            _pwdSection
                                                ? Icons.expand_less
                                                : Icons.expand_more,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.6),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (_pwdSection && _loading) ...[
                                  const SizedBox(height: 12),
                                  _fieldShimmer(height: 48),
                                  const SizedBox(height: 12),
                                  _fieldShimmer(height: 48),
                                ],
                                if (_pwdSection && !_loading) ...[
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _newPwdCtrl,
                                    obscureText: !_pwdVisible,
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: loc.newPassword,
                                      hintStyle: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.4),
                                      ),
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              dark
                                                  ? Colors.grey[700]!
                                                  : Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              dark
                                                  ? Colors.grey[700]!
                                                  : Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.blue,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _pwdVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                        ),
                                        onPressed:
                                            () => setState(
                                              () => _pwdVisible = !_pwdVisible,
                                            ),
                                      ),
                                    ),
                                    validator: (v) {
                                      final p = v ?? '';
                                      final c = _confirmPwdCtrl.text;
                                      if (p.isEmpty && c.isEmpty) return null;
                                      if (p.isEmpty)
                                        return loc.pleaseEnterNewPassword;
                                      if (p.length < 8) {
                                        return ((loc.passwordTooShort
                                                    as String?) ??
                                                'Password must be at least {min} characters')
                                            .replaceFirst('{min}', '8');
                                      }
                                      if (!RegExp(r'[A-Z]').hasMatch(p)) {
                                        return loc.passwordRequiresUpper ??
                                            'Password must contain an uppercase letter';
                                      }
                                      if (!RegExp(r'[a-z]').hasMatch(p)) {
                                        return loc.passwordRequiresLower ??
                                            'Password must contain a lowercase letter';
                                      }
                                      if (!RegExp(r'[0-9]').hasMatch(p)) {
                                        return loc.passwordRequiresDigit ??
                                            'Password must contain a digit';
                                      }
                                      if (!RegExp(
                                        r'[!@#$%^&*(),.?":{}|<>]',
                                      ).hasMatch(p)) {
                                        return loc.passwordRequiresSpecial ??
                                            'Password must contain a special character';
                                      }
                                      if (c.isNotEmpty && p != c) {
                                        return loc.passwordsDoNotMatch;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _confirmPwdCtrl,
                                    obscureText: !_confirmVisible,
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: loc.confirmNewPassword,
                                      hintStyle: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.4),
                                      ),
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              dark
                                                  ? Colors.grey[700]!
                                                  : Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              dark
                                                  ? Colors.grey[700]!
                                                  : Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.blue,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _confirmVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                        ),
                                        onPressed:
                                            () => setState(
                                              () =>
                                                  _confirmVisible =
                                                      !_confirmVisible,
                                            ),
                                      ),
                                    ),
                                    validator: (v) {
                                      final p = _newPwdCtrl.text;
                                      final c = v ?? '';
                                      if (p.isEmpty && c.isEmpty) return null;
                                      if (c.isEmpty) {
                                        return loc.pleaseConfirmYourPassword;
                                      }
                                      if (p.isEmpty)
                                        return loc.pleaseEnterNewPassword;
                                      if (c != p)
                                        return loc.passwordsDoNotMatch;
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed:
                                          _changingPassword
                                              ? null
                                              : _changePassword,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kTesiaColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child:
                                          _changingPassword
                                              ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                        Colors.white,
                                                      ),
                                                ),
                                              )
                                              : Text(
                                                loc.modifyPassword,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 24),

                                InkWell(
                                  onTap:
                                      () => setState(
                                        () => _dangerSection = !_dangerSection,
                                      ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                loc.dangerZone,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.red[700],
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _dangerSection
                                                    ? loc.dangerZoneExpanded
                                                    : loc.dangerZoneCollapsed,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.red[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          _dangerSection
                                              ? Icons.expand_less
                                              : Icons.expand_more,
                                          color: Colors.red[700],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (_dangerSection) ...[
                                  const SizedBox(height: 8),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: _removeAccount,
                                    child: Text(loc.deleteAccount),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: _logout,
                                    child: Text(loc.signOut),
                                  ),
                                ],
                                const SizedBox(height: 32),

                                if (_editMode)
                                  SizedBox(
                                    width: double.infinity,
                                    child:
                                        _loading
                                            ? _fieldShimmer(height: 52)
                                            : ElevatedButton(
                                              onPressed:
                                                  _saving
                                                      ? null
                                                      : _commitChanges,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: kTesiaColor,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                elevation: 0,
                                              ),
                                              child:
                                                  _saving
                                                      ? const SizedBox(
                                                        height: 20,
                                                        width: 20,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          valueColor:
                                                              AlwaysStoppedAnimation(
                                                                Colors.white,
                                                              ),
                                                        ),
                                                      )
                                                      : Text(
                                                        loc.saveChanges,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 16,
                                                          letterSpacing: 0.5,
                                                        ),
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
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailVerificationTimer?.cancel();
    _displayNameCtrl.dispose();
    _emailCtrl.dispose();
    _newPwdCtrl.dispose();
    _confirmPwdCtrl.dispose();
    super.dispose();
  }
}
