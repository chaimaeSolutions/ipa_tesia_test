// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeTo => 'Welcome to';

  @override
  String get getStarted => 'Get Started';

  @override
  String get termsAndPrivacy => 'By continuing, you agree to our Terms of Service and Privacy Policy';

  @override
  String get language => 'Language';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get prev => 'Prev';

  @override
  String get takePicture => 'Take a Picture';

  @override
  String get readGuide => 'Read Guide';

  @override
  String stepXofY(Object current, Object total) {
    return 'Step $current of $total';
  }

  @override
  String percentComplete(Object percent) {
    return '$percent%';
  }

  @override
  String get onboardingCoverSubtitle => 'The AI-powered mold analysis app for quick and reliable identification.';

  @override
  String get scanMold => 'Scan the Mold';

  @override
  String get scanMoldDescription => 'Easily capture a photo of the mold in your environment. Our app guides you through a quick and simple scanning process to begin the analysis journey.';

  @override
  String get aiAnalysis => 'AI Analyses';

  @override
  String get aiAnalysisDescription => 'Harness the power of advanced AI. Your mold sample is analyzed with cutting-edge algorithms that deliver deep insights, ensuring accurate and reliable results.';

  @override
  String get fastResults => 'Fast Results with High Details';

  @override
  String get fastResultsDescription => 'Receive detailed, high-precision results in seconds. Our system provides clear, actionable reports designed to help you understand and manage mold issues effectively.';

  @override
  String get getStartedTitle => 'Get Started';

  @override
  String get getStartedDescription => 'Read our guide for best practices or jump right in to protect your environment with just one tap.';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get auto => 'Auto';

  @override
  String get system => 'System';

  @override
  String get changeTheme => 'Change theme';

  @override
  String get completeVerificationToContinue => 'Please complete kit verification or sign in';

  @override
  String get noSignedInUser => 'No signed-in user found. Please sign in first.';

  @override
  String get googleAccountLinkedSuccess => 'Google account linked successfully';

  @override
  String get providerAlreadyLinked => 'This account already has Google linked.';

  @override
  String get credentialAlreadyInUse => 'That Google account is already used by another account.';

  @override
  String get googleEmailAlreadyInUse => 'Google email is already associated with another account.';

  @override
  String get failedToLinkGoogleAccount => 'Failed to link Google account.';

  @override
  String get linking => 'Linking...';

  @override
  String get emailMismatch => 'Email mismatch';

  @override
  String get currentAccount => 'Current ';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get networkError => 'Network error. Check your connection.';

  @override
  String get requestTimedOut => 'Request timed out. Check your connection.';

  @override
  String get kitNotFound => 'Kit not found or invalid code.';

  @override
  String get invalidQr => 'Invalid QR code (forgery detected).';

  @override
  String get kitAlreadyReserved => 'Kit already reserved by another device.';

  @override
  String get kitAlreadyUsed => 'Kit already used or session expired.';

  @override
  String get signupFailed => 'Signup failed.';

  @override
  String get linkFailed => 'Link failed';

  @override
  String get serverError => 'Server error. Please try again.';

  @override
  String get serverErrorShort => 'Server error';

  @override
  String get unexpectedError => 'Unexpected error. Please try again.';

  @override
  String get theEmailAddress => 'The email address:';

  @override
  String get accountAlreadyRegistered => 'is already registered. Please sign in with this account or choose a different Google account.';

  @override
  String get chooseDifferentAccount => 'Choose Different Account';

  @override
  String get linkingCancelled => 'Linking cancelled';

  @override
  String get welcomeBack => 'Welcome ';

  @override
  String get signInToAccount => 'Sign in to your account';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get enterYourEmail => 'Enter Your Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get signIn => 'Sign In';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get signUp => 'Sign Up';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterPassword => 'Please enter a password';

  @override
  String get signInFailed => 'Sign in failed. Please try again.';

  @override
  String get or => 'OR';

  @override
  String get invalidCredentials => 'Invalid email or password. Please try again.';

  @override
  String get noUserFound => 'No user found with this email address.';

  @override
  String get incorrectPassword => 'Incorrect password.';

  @override
  String get invalidEmailAddress => 'Invalid email address.';

  @override
  String get accountDisabled => 'This account has been disabled.';

  @override
  String get tooManyFailedAttempts => 'Too many failed attempts. Try again later.';

  @override
  String get googleSignInNotPermitted => 'Google sign-in is not permitted for this account.';

  @override
  String get googleSignInServerError => 'Server error while verifying sign-in. Please try again later.';

  @override
  String passwordTooShort(Object min) {
    return 'Password must be at least $min characters';
  }

  @override
  String get passwordRequiresUpper => 'Password must contain an uppercase letter';

  @override
  String get passwordRequiresLower => 'Password must contain a lowercase letter';

  @override
  String get passwordRequiresDigit => 'Password must contain a digit';

  @override
  String get passwordRequiresSpecial => 'Password must contain a special character';

  @override
  String get googleSignInFailed => 'Failed to sign in with Google. Please try again.';

  @override
  String get verificationEmailResent => 'Verification email resent to';

  @override
  String get failedToResendEmail => 'Failed to resend email';

  @override
  String get failedToGetEmailFromGoogle => 'Failed to get email from Google';

  @override
  String get emailChangePendingVerification => 'Email change pending verification';

  @override
  String get yourEmailChangeTo => 'Your email change to:';

  @override
  String get isStillPendingVerification => 'is still pending verification. Please check your inbox and click the verification link.';

  @override
  String pendingEmailVerification(Object email) {
    return 'Pending email verification for $email';
  }

  @override
  String get accountmismatchError => 'Account mismatch detected. Please contact support.';

  @override
  String get createAnAccount => 'Create An Account';

  @override
  String get joinUsToStartYourJourney => 'Join us to start your journey';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get iAgreeToThe => 'I agree to the ';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get pleaseAcceptTerms => 'Please accept the Terms & Conditions';

  @override
  String get accountCreatedSuccessfully => 'Account created successfully!';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String emailAlreadyRegistered(Object email) {
    return 'The email $email is already registered. Please sign in with your existing account or use a different Google account.';
  }

  @override
  String get googleAuthNoIdToken => 'Google authentication failed. Please try again.';

  @override
  String get googleSignUpFailed => 'Failed to sign up with Google. Please try again.';

  @override
  String get signUpFailed => 'Sign up failed. Please try again.';

  @override
  String get googleSignInNotLinked => 'This email is registered with a password. Please sign in with email and password, or create a new account.';

  @override
  String get termsAndConditionsLong => 'Welcome to Tesia.\n\nThese Terms and Conditions govern your use of the Tesia mobile application and any related services. By creating an account and using the app, you agree to comply with these terms.\n\nEligibility\nYou must be at least 13 years old to register and use the service.\n\nYour responsibilities\nYou are responsible for maintaining the confidentiality of your account credentials and for all activity that occurs under your account. Do not use the app for unlawful purposes, attempt to reverse‑engineer the service, or upload content that infringes third‑party rights.\n\nService changes & access\nTesia may suspend, modify, or terminate access to features at any time.\n\nData & privacy\nWe collect and process certain personal data as described in our Privacy Policy. By using the app you consent to this collection and processing.\n\nDisclaimer & limitation of liability\nAll content is provided “as is” without warranties of any kind. To the maximum extent permitted by law, Tesia disclaims all warranties and will not be liable for indirect, incidental, special, or consequential damages.\n\nAccount termination & retention\nYou may terminate your account at any time. Some data may be retained after termination for legal or legitimate business purposes.\n\nChanges to these terms\nWe may update these terms from time to time. When required, we will post changes and obtain consent.\n\nQuestions\nIf you have questions or need help, contact support@tesia.com.\n\nBy tapping Accept you confirm that you have read, understood, and agree to these Terms and Conditions.';

  @override
  String get userDisabled => 'User account is disabled.';

  @override
  String get forgotPasswordSubtitle => 'Enter your email address and we\'ll send you a link to reset your password';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get resetLinkSent => 'Reset link sent successfully!';

  @override
  String get emailSent => 'Email Sent!';

  @override
  String get checkYourEmail => 'We\'ve sent a password reset link to:';

  @override
  String get resetInstructions => 'Click the link in your email to reset your password. The link will expire in 24 hours.';

  @override
  String get resendEmail => 'Resend';

  @override
  String get backToSignIn => 'Back to Sign In';

  @override
  String get resetFailed => 'Failed to send reset link. Please try again.';

  @override
  String tryAgainInSeconds(Object seconds) {
    return 'Please wait $seconds seconds before retrying.';
  }

  @override
  String get tooManyRequests => 'Too many attempts — try again later.';

  @override
  String get guideTitle => 'TESIA Mold Guide';

  @override
  String get guideDescription => 'Complete Guide to Mold Detection & Removal';

  @override
  String get export => 'Export';

  @override
  String get previous => 'Previous';

  @override
  String pageXofY(Object current, Object total) {
    return 'Page $current of $total';
  }

  @override
  String get account => 'Account';

  @override
  String get advancedAiAnalysis => 'Advanced AI analysis';

  @override
  String percentCompleted(Object percent) {
    return '$percent% completed';
  }

  @override
  String get unknown => 'Unknown';

  @override
  String scansCompleted(Object current, Object total) {
    return '$current/$total';
  }

  @override
  String get yourLatestScans => 'Your Latest Scans';

  @override
  String get seeMore => 'See more';

  @override
  String get aspergillus => 'Aspergillus';

  @override
  String get canCauseAllergies => 'Can cause allergies';

  @override
  String get cladosporium => 'Cladosporium';

  @override
  String get commonIndoorMold => 'Common indoor mold';

  @override
  String get alternaria => 'Alternaria';

  @override
  String get respiratoryIssues => 'Respiratory issues';

  @override
  String get stachybotrys => 'Stachybotrys';

  @override
  String get severeHealthEffects => 'Severe health effects';

  @override
  String get noRecentScans => 'No Recent Scans';

  @override
  String get getStartedByScanningMold => 'Get started by scanning mold around your home';

  @override
  String get fullname => 'Fullname';

  @override
  String get email => 'Email';

  @override
  String get freePlan => 'Free Plan';

  @override
  String get modifyPassword => 'Modify Password';

  @override
  String get modifyPasswordDescription => 'To change your password fill BOTH fields below.';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get pleaseEnterNewPassword => 'Please enter a new password';

  @override
  String get passwordMustBe6Chars => 'Password must be at least 6 characters';

  @override
  String get pleaseConfirmYourPassword => 'Please confirm your password';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get dangerZoneExpanded => 'Deleting your account is permanent and cannot be undone.';

  @override
  String get dangerZoneCollapsed => 'Tap to view delete option';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirmTitle => 'Delete account?';

  @override
  String get deleteAccountConfirmMessage => 'This will permanently delete your account and all data. Are you sure you want to continue?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get accountDeleted => 'Account deleted successfully.';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutConfirmMessage => 'Are you sure you want to sign out?';

  @override
  String get signedOut => 'Signed out';

  @override
  String get signOutFailed => 'Sign out failed';

  @override
  String get deleteAccountFailed => 'Account deletion failed';

  @override
  String get reauthenticateToDeleteAccount => 'Please re-authenticate to delete your account.';

  @override
  String get refreshfailed => 'Auth refresh failed. Sign out and sign in again.';

  @override
  String get imageStored => 'Profile image stored successfully.';

  @override
  String get uploadFailed => 'Image upload failed. Please try again.';

  @override
  String get removeFailed => 'Failed to remove profile picture. Please try again.';

  @override
  String get failedToPickImage => 'Failed to pick image. Please try again.';

  @override
  String get profilePictureUpdated => 'Profile picture updated successfully.';

  @override
  String get profilePictureRemoved => 'Profile picture removed successfully.';

  @override
  String get verifyIdentity => 'Verify Identity';

  @override
  String get verifyIdentityContent => 'How would you like to verify your identity?';

  @override
  String get google => 'Google';

  @override
  String reenterPasswordFor(Object email) {
    return 'Re-enter password for $email';
  }

  @override
  String get passwordRequired => 'Password required';

  @override
  String get continueLabel => 'Continue';

  @override
  String get emailChangeGoogleProvider => 'Email change not allowed for Google-only accounts.\nTo change your email: either update your Google account email, or link an email/password credential in Account ';

  @override
  String get emailchangecanceled => 'Email change cancelled';

  @override
  String emailChangePending(Object newEmail) {
    return 'A verification email has been sent to $newEmail.\nYour account email will update after you confirm the link.';
  }

  @override
  String get updatedfailed => 'Update failed';

  @override
  String verifemailsent(Object email) {
    return 'Verification email sent to $email. Please check your inbox.';
  }

  @override
  String get googlePasswordChangeNotAvailable => 'Password change is not available for Google-linked accounts.\nTo change your password, please use Google account settings.';

  @override
  String get passwordUpdatedSuccessfully => 'Password updated successfully';

  @override
  String get reauthCancelled => 'Re-authentication cancelled';

  @override
  String get reauthFailed => 'Re-authentication failed';

  @override
  String get passwordTooWeak => 'Password is too weak';

  @override
  String get authError => 'Authentication error';

  @override
  String get passwordUpdateFailed => 'Password update failed';

  @override
  String get accountDeletedFallback => 'Account deleted fallback';

  @override
  String get recentSignInRequiredDelete => 'Recent sign-in required to delete account';

  @override
  String get accountDeletionFailed => 'Account deletion failed';

  @override
  String get emailAlreadyInUse => 'Email already in use';

  @override
  String get failedToUpdateEmail => 'Failed to update email';

  @override
  String get emailVerifiedSuccessfully => 'Email verified successfully';

  @override
  String get recentSignInRequiredEmail => 'Recent sign-in required to update email';

  @override
  String get googleAccountNotLinked => 'Google account not linked';

  @override
  String get recentSignInRequiredLink => 'Recent sign-in required to link account';

  @override
  String get checkingPasswordRequirement => 'Checking password requirement...';

  @override
  String get unlinkingGoogleAccount => 'Unlinking Google account...';

  @override
  String get googleAccountAlreadyLinkedToYou => 'Google account already linked to you.';

  @override
  String get invalidGoogleCredential => 'Invalid Google credential.';

  @override
  String get googleAccountAlreadyLinked => 'Google account already linked.';

  @override
  String get unlinkingAccount => 'Unlinking account...';

  @override
  String get linkingAccount => 'Linking account...';

  @override
  String get accountNotFound => 'Account not found.';

  @override
  String get resend => 'Resend';

  @override
  String verificationEmailSent(Object email) {
    return 'Verification email sent to $email. Please check your inbox.';
  }

  @override
  String get emailChangeTimedOut => 'Email change timed out. Please try again.';

  @override
  String get waitingForEmailVerification => 'Waiting for email verification... Check your inbox.';

  @override
  String get verifyBeforeUpdateEmailTitle => 'Verify  Email';

  @override
  String get emailVerificationStepsTitle => 'Next Steps:';

  @override
  String get checkYourInbox => 'Check your inbox';

  @override
  String get clickTheVerificationLink => 'Click the verification link';

  @override
  String get signInAgainWithNewEmail => 'Sign in again with your new email';

  @override
  String get understood => 'Understood';

  @override
  String get latestScans => 'Latest Scans';

  @override
  String get highRisk => 'High Risk';

  @override
  String get mediumRisk => 'Medium Risk';

  @override
  String get lowRisk => 'Low Risk';

  @override
  String get scanHistory => 'Scan History';

  @override
  String get searchByMoldOrNotes => 'Search by Name';

  @override
  String get all => 'All';

  @override
  String get noScansYet => 'No scans yet';

  @override
  String get noScansDescription => 'Try scanning a sample or change filters. Your recent scans will appear here.';

  @override
  String get danger => 'Danger';

  @override
  String get low => 'Low';

  @override
  String get medium => 'Medium';

  @override
  String get high => 'High';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(Object days) {
    return '${days}d';
  }

  @override
  String get aspergillusDescription => 'Common indoor mold found in bathrooms';

  @override
  String get penicilliumDescription => 'Blue-green mold typically found in water-damaged areas';

  @override
  String get stachybotryDescription => 'Black mold - highly toxic and dangerous';

  @override
  String get cladosporiumDescription => 'Dark green mold commonly found outdoors';

  @override
  String get alternariaDescription => 'Brown mold that causes allergic reactions';

  @override
  String get filterBy => 'Filter By';

  @override
  String get moldType => 'Mold Type';

  @override
  String get dangerLevel => 'Danger Level';

  @override
  String get certainty => 'Certainty';

  @override
  String get any => 'Any';

  @override
  String get moldScanner => 'Mold Scanner';

  @override
  String get scansLeft => 'Scans left';

  @override
  String get readyToScan => 'Ready to Scan';

  @override
  String get getInstantMoldIdentification => 'Get instant mold identification results';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get photoGuidelines => 'Photo Guidelines';

  @override
  String get goodLighting => 'Good Lighting';

  @override
  String get goodLightingDescription => 'Use natural light or bright indoor lighting';

  @override
  String get optimalDistance => 'Optimal Distance';

  @override
  String get optimalDistanceDescription => 'Keep 20-30 cm away from the sample';

  @override
  String get staySteady => 'Stay Steady';

  @override
  String get staySteadyDescription => 'Hold still for a clear, focused image';

  @override
  String get aiPoweredAnalysis => 'AI-powered analysis provides instant identification with confidence scores';

  @override
  String get planLimitReached => 'Plan Limit Reached';

  @override
  String get planLimitReachedMessage => 'You have reached your scan limit for this plan. Upgrade to continue scanning.';

  @override
  String get ok => 'OK';

  @override
  String get analyzingImage => 'Analyzing Image';

  @override
  String get processingWithAI => 'Processing with AI detection...';

  @override
  String get scansRemaining => 'scans remaining';

  @override
  String failedToProcessImage(Object error) {
    return 'Failed to process image: $error';
  }

  @override
  String get scanQrCode => 'Scan QR Code';

  @override
  String get positionTheQrWithinFrame => 'Position the QR code within the frame to scan';

  @override
  String get pleaseSignIn => 'Please sign in to use the scanner';

  @override
  String get authenticationExpired => 'Authentication expired. Please sign in again.';

  @override
  String get apiKeyNotConfigured => 'AI service not configured on server. Please contact support.';

  @override
  String get failedToAnalyzeImage => 'Failed to analyze image. Try again later.';

  @override
  String get scanResults => 'Scan Results';

  @override
  String get viewOnWeb => 'View on Web';

  @override
  String get typeOfMold => 'Type of Mold';

  @override
  String get healthRisks => 'Health Risks';

  @override
  String get prevention => 'Prevention';

  @override
  String get detectionStatistics => 'Detection Statistics';

  @override
  String get users => 'users';

  @override
  String get detectionAccuracy => 'Detection Accuracy';

  @override
  String get commonInHomes => 'Common in Homes';

  @override
  String get severityLevel => 'Severity Level';

  @override
  String get quickFactsAboutMold => 'Quick facts about this mold type. Use the tabs to switch context.';

  @override
  String get overview => 'Overview';

  @override
  String get habitat => 'Habitat';

  @override
  String get images => 'Images';

  @override
  String get sampleImageCaptured => 'Sample image captured for this scan.';

  @override
  String get whatExposureCanCause => 'What exposure can cause';

  @override
  String get copyHealthRisks => 'Copy health risks';

  @override
  String get learnMore => 'Learn more';

  @override
  String get goToPrevention => 'Go to Prevention';

  @override
  String get close => 'Close';

  @override
  String get preventionMethods => 'Prevention Methods';

  @override
  String get copyPrevention => 'Copy prevention';

  @override
  String get practicalStepsToReduce => 'Practical steps to reduce exposure and prevent growth.';

  @override
  String get downloadFullReportPDF => 'Download full report (PDF)';

  @override
  String get home => 'Home';

  @override
  String get history => 'History';

  @override
  String get notifications => 'Notifications';

  @override
  String copiedToClipboard(Object label) {
    return '$label copied to clipboard';
  }

  @override
  String get pdfExported => 'PDF exported';

  @override
  String errorExportingPDF(Object error) {
    return 'Error exporting PDF: $error';
  }

  @override
  String get couldNotOpenWebLink => 'Could not open web link';

  @override
  String get pdfScanReportTitle => 'Mold Scan Report';

  @override
  String get pdfDescription => 'Description';

  @override
  String get pdfOverview => 'Overview';

  @override
  String get pdfHabitat => 'Habitat';

  @override
  String get pdfDetectionStatistics => 'Detection Statistics';

  @override
  String get pdfHealthRisks => 'Health Risks';

  @override
  String get pdfPreventionMethods => 'Prevention Methods';

  @override
  String get pdfNoneListed => 'None listed';

  @override
  String get pdfGenerated => 'Generated';

  @override
  String get couldNotCopy => 'Could not copy ';

  @override
  String get shareSummary => 'Share Summary';

  @override
  String get shareSummaryDescription => 'Share a quick summary of your mold scan results with others.';

  @override
  String unreadNotifications(Object count) {
    return '$count unread';
  }

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get notificationsDescription => 'We\'ll notify you when something new arrives';

  @override
  String get notificationDeleted => 'Notification deleted';

  @override
  String get scanComplete => 'Scan Complete';

  @override
  String scanCompleteMessage(Object moldType) {
    return 'Your $moldType scan has been analyzed successfully';
  }

  @override
  String get highRiskDetected => 'High Risk Detected';

  @override
  String highRiskDetectedMessage(Object moldType) {
    return '$moldType detected with high severity level. Take immediate action.';
  }

  @override
  String get scanLimitWarning => 'Scan Limit Warning';

  @override
  String scanLimitWarningMessage(Object remaining) {
    return 'You have $remaining scans remaining in your plan';
  }

  @override
  String get newFeatureAvailable => 'New Feature Available';

  @override
  String get newFeatureAvailableMessage => 'Check out our new AI-powered recommendations feature';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(Object minutes) {
    return '${minutes}m ago';
  }

  @override
  String hoursAgo(Object hours) {
    return '${hours}h ago';
  }

  @override
  String get deleteAll => 'Delete all';

  @override
  String get deleteAllNotifications => 'Delete All Notifications';

  @override
  String get deleteAllNotificationsConfirm => 'Are you sure you want to delete all notifications? This action cannot be undone.';

  @override
  String get allNotificationsDeleted => 'All notifications deleted';

  @override
  String get allMarkedAsRead => 'All notifications marked as read';

  @override
  String get pleaseSignInToViewNotifications => 'Please sign in to view notifications';

  @override
  String get errorLoadingNotifications => 'Error loading notifications';

  @override
  String scanResultTitle(Object moldType) {
    return 'Scan result: $moldType';
  }

  @override
  String scanResultMessageMedium(Object moldType, Object scansLeft) {
    return '$moldType detected (medium severity). Scans left: $scansLeft.';
  }

  @override
  String scanResultMessage(Object moldType, Object scansLeft) {
    return '$moldType detected. Scans left: $scansLeft.';
  }

  @override
  String scanResultMessageHigh(Object moldType, Object scansLeft) {
    return 'High severity detected for $moldType. Act fast. Scans left: $scansLeft.';
  }

  @override
  String get checkingSession => 'Checking your session...';

  @override
  String get kitCodePlaceholder => 'TS-XXXX-XXXX-XXXX';

  @override
  String get sessionRestored => 'Session restored';

  @override
  String get kitVerifiedSuccessfully => 'Kit verified successfully';

  @override
  String get noSessionToken => 'No session token. Please scan or enter the kit code.';

  @override
  String get verifyingQr => 'Verifying QR code...';

  @override
  String get verifyingCode => 'Verifying code...';

  @override
  String get codeVerified => 'Code verified';

  @override
  String get invalidCodeFormat => 'Code must match format: TS-XXXX-XXXX-XXXX';

  @override
  String get genericError => 'Something went wrong. Please try again.';

  @override
  String get scanOrEnterCode => 'Scan the QR code on your kit or enter the code manually to sign up.';

  @override
  String get kitVerification => 'Kit verification';

  @override
  String get enterCodeHint => 'Enter your kit code below';

  @override
  String get scanQr => 'Scan QR';

  @override
  String get enterCode => 'Enter code manually';

  @override
  String get verify => 'Verify';

  @override
  String get verifiedPrompt => 'Device verified. You can proceed to Sign Up.';

  @override
  String get proceedToSignup => 'Proceed to Sign Up';

  @override
  String get welcomeToTesia => 'Welcome to Tesia!';

  @override
  String get getStartedMessage => 'Complete your profile or link your Google account to get the most out of your mold detection experience.';

  @override
  String get completeProfile => 'Complete Profile';

  @override
  String get linkGoogleAccount => 'Link Google Account';

  @override
  String get ignoreForNow => 'Ignore for now';

  @override
  String get googleAccountLinked => 'Google account linked successfully!';

  @override
  String linkedWith(Object provider) {
    return 'Linked with $provider';
  }

  @override
  String get googleLinked => 'Linked with Google';

  @override
  String get welcomeNotificationTitle => 'Welcome to TESIA! 🎉';

  @override
  String get welcomeNotificationMessage => 'Complete your profile to get the most out of your experience';

  @override
  String get privacyAndSecurity => 'Privacy & Security';

  @override
  String get privacySummaryTitle => 'How we handle your data';

  @override
  String get privacySummaryBody => 'We collect only what is necessary to provide and improve TESIA. Your account info, test results, and device identifiers help us deliver personalized features and reliable sync across devices. We protect data with industry-standard security, do not sell personal data, and provide options to manage or delete your information.';

  @override
  String get viewPdf => 'View PDF';

  @override
  String get openFullPdf => 'Open full PDF';

  @override
  String get openPdf => 'Open PDF';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get theme => 'Theme';

  @override
  String get english => 'English';

  @override
  String get googleAccount => 'Google account';

  @override
  String get linked => 'Linked';

  @override
  String get syncActive => 'Sync active';

  @override
  String get syncYourDataWithGoogle => 'Sync your data with Google';

  @override
  String get security => 'Security';

  @override
  String get app => 'App';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get getHelpAndContactSupport => 'Get help and contact support';

  @override
  String get about => 'About';

  @override
  String get appVersionAndInformation => 'App version and information';

  @override
  String get rateApp => 'Rate App';

  @override
  String get rateUsOnTheAppStore => 'Rate us on the app store';

  @override
  String get signOutOfYourAccount => 'Sign out of your account';

  @override
  String get permanentlyDeleteYourAccount => 'Permanently delete your account';

  @override
  String get emailSupport => 'Email Support';

  @override
  String get emailSupportAddress => 'support@tesia.com';

  @override
  String get phoneSupport => 'Phone Support';

  @override
  String get phoneSupportNumber => '+1 (555) 123-4567';

  @override
  String get faq => 'FAQ';

  @override
  String get frequentlyAskedQuestions => 'Frequently asked questions';

  @override
  String get enjoyingTesia => 'Enjoying TESIA?';

  @override
  String get rateAppDescription => 'Please take a moment to rate us on the app store. Your feedback helps us improve and reach more people who need mold detection!';

  @override
  String get later => 'Later';

  @override
  String get rateNow => 'Rate Now';

  @override
  String get manageYourPrivacySettings => 'Manage your privacy settings';

  @override
  String get keyPoints => 'Key points';

  @override
  String get minimalDataCollection => 'Minimal data collection — only what we need to operate the service.';

  @override
  String get strongEncryption => 'Strong transport encryption (TLS) and Firebase security rules.';

  @override
  String get googleSignInOptional => 'Google Sign-In is optional and used only for sync/backups.';

  @override
  String get requestDataDeletion => 'You can request data deletion at any time.';

  @override
  String get moreDetails => 'More details';

  @override
  String get moreDetailsDescription => 'This summary highlights the most important privacy and security practices. For complete information, open the full PDF which includes detailed policies and contact information.';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get privacySecurityAndAppInfo => 'App info';

  @override
  String get aboutTesia => 'About TESIA';

  @override
  String get aboutTesiaDescription => 'TESIA is an AI-powered mold detection app designed to help homeowners and professionals quickly identify and analyze mold risks. We focus on accuracy, privacy, and a seamless user experience.';

  @override
  String get whatWeOffer => 'What we offer';

  @override
  String get aiMoldDetection => 'Real-time AI mold detection with confidence scores.';

  @override
  String get detailedReportsAndSync => 'Detailed downloadable reports and cloud sync.';

  @override
  String get privacyFirstApproach => 'Privacy-first: minimal data collection, no selling.';

  @override
  String get multiLanguageSupport => 'Multi-language and theme support.';

  @override
  String get version => 'Version';

  @override
  String get support => 'Support';

  @override
  String get copyright => '© 2025 TESIA. All rights reserved.';

  @override
  String get visitWebsite => 'Visit Website';

  @override
  String get signOutConfirmation => 'Are you sure you want to sign out? You will need to sign in again to access your account and sync your data.';

  @override
  String get deleteAccountConfirmation => 'Are you sure you want to permanently delete your account? This action cannot be undone and will result in:';

  @override
  String get lossOfDetectionHistory => '• Loss of all detection history';

  @override
  String get lossOfSettings => '• Loss of saved settings and preferences';

  @override
  String get lossOfCloudSync => '• Loss of cloud sync data';

  @override
  String get unableToRecover => '• Inability to recover the account';

  @override
  String get reset => 'Reset';

  @override
  String get apply => 'Apply';

  @override
  String printFailed(Object error) {
    return 'Print failed: $error';
  }

  @override
  String get couldNotOpenLink => 'Could not open link';

  @override
  String get accountLinked => 'Account linked';

  @override
  String get googleAccountLinkedDialogDescription => 'Your Google account is successfully linked. You can now sync your TESIA data across devices and enable backups.';

  @override
  String get connectGoogleAccountDescription => 'Connect your Google account to sync your TESIA data across all your devices and enable automatic backup of your mold detection history.';

  @override
  String get syncingData => 'Your data is being synced';

  @override
  String get linkAccount => 'Link account';

  @override
  String get unlinkAccount => 'Unlink account';

  @override
  String get googleSignInCancelled => 'Google sign-in cancelled';

  @override
  String get googleAccountUnlinked => 'Google account unlinked';

  @override
  String get notSignedIn => 'Not signed in';

  @override
  String errorPrefix(Object error) {
    return 'Error: $error';
  }

  @override
  String get setPassword => 'Set Password';

  @override
  String get setPasswordExplanation => 'To unlink Google you must set a password for this account so you can sign in after unlinking';

  @override
  String get unlinkRequiresPassword => 'You must set a password before unlinking Google.';

  @override
  String get failedToLinkPassword => 'Failed to set password. Please try again.';

  @override
  String get deletingAccount => 'Deleting account...';

  @override
  String get pleaseWait => 'Please wait, this may take a moment.';

  @override
  String get failedToDeleteAccount => 'Failed to delete account. Please try again.';

  @override
  String get failedToLoadPrivacyPolicy => 'Failed to load privacy policy. Please try again later.';
}
