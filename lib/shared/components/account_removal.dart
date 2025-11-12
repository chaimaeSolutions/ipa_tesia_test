import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tesia_app/l10n/app_localizations.dart';
import 'package:tesia_app/authentication/signin_screen.dart';
import 'package:tesia_app/shared/components/showsnackbar.dart';

Future<void> performAccountRemoval(BuildContext context) async {
  final loc = AppLocalizations.of(context)!;
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    if (context.mounted) {
      showSnack(context, loc.notSignedIn ?? 'Not signed in', error: true);
    }
    return;
  }

  final uid = currentUser.uid;
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final navigator = Navigator.of(context);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  loc.deletingAccount ?? 'Deleting your account...',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.pleaseWait ?? 'Please wait...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  try {
    try {
      final scansRef = storage.ref().child('users/$uid/scans');
      final listResult = await scansRef.listAll();
      for (var fileRef in listResult.items) {
        await fileRef.delete();
      }
      for (var prefixRef in listResult.prefixes) {
        await _deleteStorageFolder(prefixRef);
      }
    } catch (_) {}

    try {
      final avatarsRef = storage.ref().child('avatars/$uid');
      final avatarsList = await avatarsRef.listAll();
      for (var fileRef in avatarsList.items) {
        await fileRef.delete();
      }
      for (var prefixRef in avatarsList.prefixes) {
        await _deleteStorageFolder(prefixRef);
      }
    } catch (_) {}

    final scansSnapshot =
        await firestore.collection('users').doc(uid).collection('scans').get();
    for (var doc in scansSnapshot.docs) {
      await doc.reference.delete();
    }

    final notificationsSnapshot =
        await firestore
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .get();
    for (var doc in notificationsSnapshot.docs) {
      await doc.reference.delete();
    }

    await firestore.collection('users').doc(uid).delete();

    await currentUser.delete();

    await FirebaseAuth.instance.signOut();

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false,
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      final newContext = navigator.context;
      if (newContext.mounted) {
        showSnack(
          newContext,
          loc.accountDeleted ?? 'Account deleted successfully',
          error: false,
        );
      }
    });
  } on FirebaseAuthException catch (e) {
    navigator.pop();

    if (e.code == 'requires-recent-login') {
      await FirebaseAuth.instance.signOut();
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (route) => false,
      );
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      final newContext = navigator.context;
      if (newContext.mounted) {
        showSnack(
          newContext,
          e.code == 'requires-recent-login'
              ? (loc.reauthenticateToDeleteAccount ??
                  'Please sign in again to delete your account')
              : (e.message ??
                  loc.failedToDeleteAccount ??
                  'Failed to delete account'),
          error: true,
        );
      }
    });
  } catch (e) {
    navigator.pop();

    Future.delayed(const Duration(milliseconds: 300), () {
      final newContext = navigator.context;
      if (newContext.mounted) {
        showSnack(
          newContext,
          loc.unexpectedError ?? 'An unexpected error occurred',
          error: true,
        );
      }
    });
  }
}

Future<void> _deleteStorageFolder(Reference folderRef) async {
  final listResult = await folderRef.listAll();
  for (var fileRef in listResult.items) {
    await fileRef.delete();
  }
  for (var prefixRef in listResult.prefixes) {
    await _deleteStorageFolder(prefixRef);
  }
}
