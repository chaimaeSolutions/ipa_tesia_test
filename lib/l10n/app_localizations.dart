import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @welcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get welcomeTo;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @termsAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our Terms of Service and Privacy Policy'**
  String get termsAndPrivacy;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @prev.
  ///
  /// In en, this message translates to:
  /// **'Prev'**
  String get prev;

  /// No description provided for @takePicture.
  ///
  /// In en, this message translates to:
  /// **'Take a Picture'**
  String get takePicture;

  /// No description provided for @readGuide.
  ///
  /// In en, this message translates to:
  /// **'Read Guide'**
  String get readGuide;

  /// No description provided for @stepXofY.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepXofY(Object current, Object total);

  /// No description provided for @percentComplete.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String percentComplete(Object percent);

  /// No description provided for @onboardingCoverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The AI-powered mold analysis app for quick and reliable identification.'**
  String get onboardingCoverSubtitle;

  /// No description provided for @scanMold.
  ///
  /// In en, this message translates to:
  /// **'Scan the Mold'**
  String get scanMold;

  /// No description provided for @scanMoldDescription.
  ///
  /// In en, this message translates to:
  /// **'Easily capture a photo of the mold in your environment. Our app guides you through a quick and simple scanning process to begin the analysis journey.'**
  String get scanMoldDescription;

  /// No description provided for @aiAnalysis.
  ///
  /// In en, this message translates to:
  /// **'AI Analyses'**
  String get aiAnalysis;

  /// No description provided for @aiAnalysisDescription.
  ///
  /// In en, this message translates to:
  /// **'Harness the power of advanced AI. Your mold sample is analyzed with cutting-edge algorithms that deliver deep insights, ensuring accurate and reliable results.'**
  String get aiAnalysisDescription;

  /// No description provided for @fastResults.
  ///
  /// In en, this message translates to:
  /// **'Fast Results with High Details'**
  String get fastResults;

  /// No description provided for @fastResultsDescription.
  ///
  /// In en, this message translates to:
  /// **'Receive detailed, high-precision results in seconds. Our system provides clear, actionable reports designed to help you understand and manage mold issues effectively.'**
  String get fastResultsDescription;

  /// No description provided for @getStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStartedTitle;

  /// No description provided for @getStartedDescription.
  ///
  /// In en, this message translates to:
  /// **'Read our guide for best practices or jump right in to protect your environment with just one tap.'**
  String get getStartedDescription;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @changeTheme.
  ///
  /// In en, this message translates to:
  /// **'Change theme'**
  String get changeTheme;

  /// No description provided for @completeVerificationToContinue.
  ///
  /// In en, this message translates to:
  /// **'Please complete kit verification or sign in'**
  String get completeVerificationToContinue;

  /// No description provided for @noSignedInUser.
  ///
  /// In en, this message translates to:
  /// **'No signed-in user found. Please sign in first.'**
  String get noSignedInUser;

  /// No description provided for @googleAccountLinkedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Google account linked successfully'**
  String get googleAccountLinkedSuccess;

  /// No description provided for @providerAlreadyLinked.
  ///
  /// In en, this message translates to:
  /// **'This account already has Google linked.'**
  String get providerAlreadyLinked;

  /// No description provided for @credentialAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'That Google account is already used by another account.'**
  String get credentialAlreadyInUse;

  /// No description provided for @googleEmailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'Google email is already associated with another account.'**
  String get googleEmailAlreadyInUse;

  /// No description provided for @failedToLinkGoogleAccount.
  ///
  /// In en, this message translates to:
  /// **'Failed to link Google account.'**
  String get failedToLinkGoogleAccount;

  /// No description provided for @linking.
  ///
  /// In en, this message translates to:
  /// **'Linking...'**
  String get linking;

  /// No description provided for @emailMismatch.
  ///
  /// In en, this message translates to:
  /// **'Email mismatch'**
  String get emailMismatch;

  /// No description provided for @currentAccount.
  ///
  /// In en, this message translates to:
  /// **'Current '**
  String get currentAccount;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection.'**
  String get networkError;

  /// No description provided for @requestTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Check your connection.'**
  String get requestTimedOut;

  /// No description provided for @kitNotFound.
  ///
  /// In en, this message translates to:
  /// **'Kit not found or invalid code.'**
  String get kitNotFound;

  /// No description provided for @invalidQr.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code (forgery detected).'**
  String get invalidQr;

  /// No description provided for @kitAlreadyReserved.
  ///
  /// In en, this message translates to:
  /// **'Kit already reserved by another device.'**
  String get kitAlreadyReserved;

  /// No description provided for @kitAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'Kit already used or session expired.'**
  String get kitAlreadyUsed;

  /// No description provided for @signupFailed.
  ///
  /// In en, this message translates to:
  /// **'Signup failed.'**
  String get signupFailed;

  /// No description provided for @linkFailed.
  ///
  /// In en, this message translates to:
  /// **'Link failed'**
  String get linkFailed;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again.'**
  String get serverError;

  /// No description provided for @serverErrorShort.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get serverErrorShort;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error. Please try again.'**
  String get unexpectedError;

  /// No description provided for @theEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'The email address:'**
  String get theEmailAddress;

  /// No description provided for @accountAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'is already registered. Please sign in with this account or choose a different Google account.'**
  String get accountAlreadyRegistered;

  /// No description provided for @chooseDifferentAccount.
  ///
  /// In en, this message translates to:
  /// **'Choose Different Account'**
  String get chooseDifferentAccount;

  /// No description provided for @linkingCancelled.
  ///
  /// In en, this message translates to:
  /// **'Linking cancelled'**
  String get linkingCancelled;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome '**
  String get welcomeBack;

  /// No description provided for @signInToAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get signInToAccount;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Email'**
  String get enterYourEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get pleaseEnterPassword;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed. Please try again.'**
  String get signInFailed;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password. Please try again.'**
  String get invalidCredentials;

  /// No description provided for @noUserFound.
  ///
  /// In en, this message translates to:
  /// **'No user found with this email address.'**
  String get noUserFound;

  /// No description provided for @incorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password.'**
  String get incorrectPassword;

  /// No description provided for @invalidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address.'**
  String get invalidEmailAddress;

  /// No description provided for @accountDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get accountDisabled;

  /// No description provided for @tooManyFailedAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many failed attempts. Try again later.'**
  String get tooManyFailedAttempts;

  /// No description provided for @googleSignInNotPermitted.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in is not permitted for this account.'**
  String get googleSignInNotPermitted;

  /// No description provided for @googleSignInServerError.
  ///
  /// In en, this message translates to:
  /// **'Server error while verifying sign-in. Please try again later.'**
  String get googleSignInServerError;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {min} characters'**
  String passwordTooShort(Object min);

  /// No description provided for @passwordRequiresUpper.
  ///
  /// In en, this message translates to:
  /// **'Password must contain an uppercase letter'**
  String get passwordRequiresUpper;

  /// No description provided for @passwordRequiresLower.
  ///
  /// In en, this message translates to:
  /// **'Password must contain a lowercase letter'**
  String get passwordRequiresLower;

  /// No description provided for @passwordRequiresDigit.
  ///
  /// In en, this message translates to:
  /// **'Password must contain a digit'**
  String get passwordRequiresDigit;

  /// No description provided for @passwordRequiresSpecial.
  ///
  /// In en, this message translates to:
  /// **'Password must contain a special character'**
  String get passwordRequiresSpecial;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign in with Google. Please try again.'**
  String get googleSignInFailed;

  /// No description provided for @verificationEmailResent.
  ///
  /// In en, this message translates to:
  /// **'Verification email resent to'**
  String get verificationEmailResent;

  /// No description provided for @failedToResendEmail.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend email'**
  String get failedToResendEmail;

  /// No description provided for @failedToGetEmailFromGoogle.
  ///
  /// In en, this message translates to:
  /// **'Failed to get email from Google'**
  String get failedToGetEmailFromGoogle;

  /// No description provided for @emailChangePendingVerification.
  ///
  /// In en, this message translates to:
  /// **'Email change pending verification'**
  String get emailChangePendingVerification;

  /// No description provided for @yourEmailChangeTo.
  ///
  /// In en, this message translates to:
  /// **'Your email change to:'**
  String get yourEmailChangeTo;

  /// No description provided for @isStillPendingVerification.
  ///
  /// In en, this message translates to:
  /// **'is still pending verification. Please check your inbox and click the verification link.'**
  String get isStillPendingVerification;

  /// No description provided for @pendingEmailVerification.
  ///
  /// In en, this message translates to:
  /// **'Pending email verification for {email}'**
  String pendingEmailVerification(Object email);

  /// No description provided for @accountmismatchError.
  ///
  /// In en, this message translates to:
  /// **'Account mismatch detected. Please contact support.'**
  String get accountmismatchError;

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create An Account'**
  String get createAnAccount;

  /// No description provided for @joinUsToStartYourJourney.
  ///
  /// In en, this message translates to:
  /// **'Join us to start your journey'**
  String get joinUsToStartYourJourney;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @iAgreeToThe.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get iAgreeToThe;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @pleaseAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'Please accept the Terms & Conditions'**
  String get pleaseAcceptTerms;

  /// No description provided for @accountCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get accountCreatedSuccessfully;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @emailAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'The email {email} is already registered. Please sign in with your existing account or use a different Google account.'**
  String emailAlreadyRegistered(Object email);

  /// No description provided for @googleAuthNoIdToken.
  ///
  /// In en, this message translates to:
  /// **'Google authentication failed. Please try again.'**
  String get googleAuthNoIdToken;

  /// No description provided for @googleSignUpFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign up with Google. Please try again.'**
  String get googleSignUpFailed;

  /// No description provided for @signUpFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign up failed. Please try again.'**
  String get signUpFailed;

  /// No description provided for @googleSignInNotLinked.
  ///
  /// In en, this message translates to:
  /// **'This email is registered with a password. Please sign in with email and password, or create a new account.'**
  String get googleSignInNotLinked;

  /// No description provided for @termsAndConditionsLong.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Tesia.\n\nThese Terms and Conditions govern your use of the Tesia mobile application and any related services. By creating an account and using the app, you agree to comply with these terms.\n\nEligibility\nYou must be at least 13 years old to register and use the service.\n\nYour responsibilities\nYou are responsible for maintaining the confidentiality of your account credentials and for all activity that occurs under your account. Do not use the app for unlawful purposes, attempt to reverse‑engineer the service, or upload content that infringes third‑party rights.\n\nService changes & access\nTesia may suspend, modify, or terminate access to features at any time.\n\nData & privacy\nWe collect and process certain personal data as described in our Privacy Policy. By using the app you consent to this collection and processing.\n\nDisclaimer & limitation of liability\nAll content is provided “as is” without warranties of any kind. To the maximum extent permitted by law, Tesia disclaims all warranties and will not be liable for indirect, incidental, special, or consequential damages.\n\nAccount termination & retention\nYou may terminate your account at any time. Some data may be retained after termination for legal or legitimate business purposes.\n\nChanges to these terms\nWe may update these terms from time to time. When required, we will post changes and obtain consent.\n\nQuestions\nIf you have questions or need help, contact support@tesia.com.\n\nBy tapping Accept you confirm that you have read, understood, and agree to these Terms and Conditions.'**
  String get termsAndConditionsLong;

  /// No description provided for @userDisabled.
  ///
  /// In en, this message translates to:
  /// **'User account is disabled.'**
  String get userDisabled;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent successfully!'**
  String get resetLinkSent;

  /// No description provided for @emailSent.
  ///
  /// In en, this message translates to:
  /// **'Email Sent!'**
  String get emailSent;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a password reset link to:'**
  String get checkYourEmail;

  /// No description provided for @resetInstructions.
  ///
  /// In en, this message translates to:
  /// **'Click the link in your email to reset your password. The link will expire in 24 hours.'**
  String get resetInstructions;

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resendEmail;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get backToSignIn;

  /// No description provided for @resetFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset link. Please try again.'**
  String get resetFailed;

  /// No description provided for @tryAgainInSeconds.
  ///
  /// In en, this message translates to:
  /// **'Please wait {seconds} seconds before retrying.'**
  String tryAgainInSeconds(Object seconds);

  /// No description provided for @tooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts — try again later.'**
  String get tooManyRequests;

  /// No description provided for @guideTitle.
  ///
  /// In en, this message translates to:
  /// **'TESIA Mold Guide'**
  String get guideTitle;

  /// No description provided for @guideDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete Guide to Mold Detection & Removal'**
  String get guideDescription;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @pageXofY.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String pageXofY(Object current, Object total);

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @advancedAiAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Advanced AI analysis'**
  String get advancedAiAnalysis;

  /// No description provided for @percentCompleted.
  ///
  /// In en, this message translates to:
  /// **'{percent}% completed'**
  String percentCompleted(Object percent);

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @scansCompleted.
  ///
  /// In en, this message translates to:
  /// **'{current}/{total}'**
  String scansCompleted(Object current, Object total);

  /// No description provided for @yourLatestScans.
  ///
  /// In en, this message translates to:
  /// **'Your Latest Scans'**
  String get yourLatestScans;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See more'**
  String get seeMore;

  /// No description provided for @aspergillus.
  ///
  /// In en, this message translates to:
  /// **'Aspergillus'**
  String get aspergillus;

  /// No description provided for @canCauseAllergies.
  ///
  /// In en, this message translates to:
  /// **'Can cause allergies'**
  String get canCauseAllergies;

  /// No description provided for @cladosporium.
  ///
  /// In en, this message translates to:
  /// **'Cladosporium'**
  String get cladosporium;

  /// No description provided for @commonIndoorMold.
  ///
  /// In en, this message translates to:
  /// **'Common indoor mold'**
  String get commonIndoorMold;

  /// No description provided for @alternaria.
  ///
  /// In en, this message translates to:
  /// **'Alternaria'**
  String get alternaria;

  /// No description provided for @respiratoryIssues.
  ///
  /// In en, this message translates to:
  /// **'Respiratory issues'**
  String get respiratoryIssues;

  /// No description provided for @stachybotrys.
  ///
  /// In en, this message translates to:
  /// **'Stachybotrys'**
  String get stachybotrys;

  /// No description provided for @severeHealthEffects.
  ///
  /// In en, this message translates to:
  /// **'Severe health effects'**
  String get severeHealthEffects;

  /// No description provided for @noRecentScans.
  ///
  /// In en, this message translates to:
  /// **'No Recent Scans'**
  String get noRecentScans;

  /// No description provided for @getStartedByScanningMold.
  ///
  /// In en, this message translates to:
  /// **'Get started by scanning mold around your home'**
  String get getStartedByScanningMold;

  /// No description provided for @fullname.
  ///
  /// In en, this message translates to:
  /// **'Fullname'**
  String get fullname;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @freePlan.
  ///
  /// In en, this message translates to:
  /// **'Free Plan'**
  String get freePlan;

  /// No description provided for @modifyPassword.
  ///
  /// In en, this message translates to:
  /// **'Modify Password'**
  String get modifyPassword;

  /// No description provided for @modifyPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'To change your password fill BOTH fields below.'**
  String get modifyPasswordDescription;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @pleaseEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get pleaseEnterNewPassword;

  /// No description provided for @passwordMustBe6Chars.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMustBe6Chars;

  /// No description provided for @pleaseConfirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmYourPassword;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @dangerZoneExpanded.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account is permanent and cannot be undone.'**
  String get dangerZoneExpanded;

  /// No description provided for @dangerZoneCollapsed.
  ///
  /// In en, this message translates to:
  /// **'Tap to view delete option'**
  String get dangerZoneCollapsed;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account and all data. Are you sure you want to continue?'**
  String get deleteAccountConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully.'**
  String get accountDeleted;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmMessage;

  /// No description provided for @signedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get signedOut;

  /// No description provided for @signOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign out failed'**
  String get signOutFailed;

  /// No description provided for @deleteAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'Account deletion failed'**
  String get deleteAccountFailed;

  /// No description provided for @reauthenticateToDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Please re-authenticate to delete your account.'**
  String get reauthenticateToDeleteAccount;

  /// No description provided for @refreshfailed.
  ///
  /// In en, this message translates to:
  /// **'Auth refresh failed. Sign out and sign in again.'**
  String get refreshfailed;

  /// No description provided for @imageStored.
  ///
  /// In en, this message translates to:
  /// **'Profile image stored successfully.'**
  String get imageStored;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Image upload failed. Please try again.'**
  String get uploadFailed;

  /// No description provided for @removeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove profile picture. Please try again.'**
  String get removeFailed;

  /// No description provided for @failedToPickImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image. Please try again.'**
  String get failedToPickImage;

  /// No description provided for @profilePictureUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated successfully.'**
  String get profilePictureUpdated;

  /// No description provided for @profilePictureRemoved.
  ///
  /// In en, this message translates to:
  /// **'Profile picture removed successfully.'**
  String get profilePictureRemoved;

  /// No description provided for @verifyIdentity.
  ///
  /// In en, this message translates to:
  /// **'Verify Identity'**
  String get verifyIdentity;

  /// No description provided for @verifyIdentityContent.
  ///
  /// In en, this message translates to:
  /// **'How would you like to verify your identity?'**
  String get verifyIdentityContent;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @reenterPasswordFor.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password for {email}'**
  String reenterPasswordFor(Object email);

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password required'**
  String get passwordRequired;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @emailChangeGoogleProvider.
  ///
  /// In en, this message translates to:
  /// **'Email change not allowed for Google-only accounts.\nTo change your email: either update your Google account email, or link an email/password credential in Account '**
  String get emailChangeGoogleProvider;

  /// No description provided for @emailchangecanceled.
  ///
  /// In en, this message translates to:
  /// **'Email change cancelled'**
  String get emailchangecanceled;

  /// No description provided for @emailChangePending.
  ///
  /// In en, this message translates to:
  /// **'A verification email has been sent to {newEmail}.\nYour account email will update after you confirm the link.'**
  String emailChangePending(Object newEmail);

  /// No description provided for @updatedfailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get updatedfailed;

  /// No description provided for @verifemailsent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent to {email}. Please check your inbox.'**
  String verifemailsent(Object email);

  /// No description provided for @googlePasswordChangeNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Password change is not available for Google-linked accounts.\nTo change your password, please use Google account settings.'**
  String get googlePasswordChangeNotAvailable;

  /// No description provided for @passwordUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdatedSuccessfully;

  /// No description provided for @reauthCancelled.
  ///
  /// In en, this message translates to:
  /// **'Re-authentication cancelled'**
  String get reauthCancelled;

  /// No description provided for @reauthFailed.
  ///
  /// In en, this message translates to:
  /// **'Re-authentication failed'**
  String get reauthFailed;

  /// No description provided for @passwordTooWeak.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get passwordTooWeak;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'Authentication error'**
  String get authError;

  /// No description provided for @passwordUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Password update failed'**
  String get passwordUpdateFailed;

  /// No description provided for @accountDeletedFallback.
  ///
  /// In en, this message translates to:
  /// **'Account deleted fallback'**
  String get accountDeletedFallback;

  /// No description provided for @recentSignInRequiredDelete.
  ///
  /// In en, this message translates to:
  /// **'Recent sign-in required to delete account'**
  String get recentSignInRequiredDelete;

  /// No description provided for @accountDeletionFailed.
  ///
  /// In en, this message translates to:
  /// **'Account deletion failed'**
  String get accountDeletionFailed;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'Email already in use'**
  String get emailAlreadyInUse;

  /// No description provided for @failedToUpdateEmail.
  ///
  /// In en, this message translates to:
  /// **'Failed to update email'**
  String get failedToUpdateEmail;

  /// No description provided for @emailVerifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Email verified successfully'**
  String get emailVerifiedSuccessfully;

  /// No description provided for @recentSignInRequiredEmail.
  ///
  /// In en, this message translates to:
  /// **'Recent sign-in required to update email'**
  String get recentSignInRequiredEmail;

  /// No description provided for @googleAccountNotLinked.
  ///
  /// In en, this message translates to:
  /// **'Google account not linked'**
  String get googleAccountNotLinked;

  /// No description provided for @recentSignInRequiredLink.
  ///
  /// In en, this message translates to:
  /// **'Recent sign-in required to link account'**
  String get recentSignInRequiredLink;

  /// No description provided for @checkingPasswordRequirement.
  ///
  /// In en, this message translates to:
  /// **'Checking password requirement...'**
  String get checkingPasswordRequirement;

  /// No description provided for @unlinkingGoogleAccount.
  ///
  /// In en, this message translates to:
  /// **'Unlinking Google account...'**
  String get unlinkingGoogleAccount;

  /// No description provided for @googleAccountAlreadyLinkedToYou.
  ///
  /// In en, this message translates to:
  /// **'Google account already linked to you.'**
  String get googleAccountAlreadyLinkedToYou;

  /// No description provided for @invalidGoogleCredential.
  ///
  /// In en, this message translates to:
  /// **'Invalid Google credential.'**
  String get invalidGoogleCredential;

  /// No description provided for @googleAccountAlreadyLinked.
  ///
  /// In en, this message translates to:
  /// **'Google account already linked.'**
  String get googleAccountAlreadyLinked;

  /// No description provided for @unlinkingAccount.
  ///
  /// In en, this message translates to:
  /// **'Unlinking account...'**
  String get unlinkingAccount;

  /// No description provided for @linkingAccount.
  ///
  /// In en, this message translates to:
  /// **'Linking account...'**
  String get linkingAccount;

  /// No description provided for @accountNotFound.
  ///
  /// In en, this message translates to:
  /// **'Account not found.'**
  String get accountNotFound;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent to {email}. Please check your inbox.'**
  String verificationEmailSent(Object email);

  /// No description provided for @emailChangeTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Email change timed out. Please try again.'**
  String get emailChangeTimedOut;

  /// No description provided for @waitingForEmailVerification.
  ///
  /// In en, this message translates to:
  /// **'Waiting for email verification... Check your inbox.'**
  String get waitingForEmailVerification;

  /// No description provided for @verifyBeforeUpdateEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify  Email'**
  String get verifyBeforeUpdateEmailTitle;

  /// No description provided for @emailVerificationStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Next Steps:'**
  String get emailVerificationStepsTitle;

  /// No description provided for @checkYourInbox.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get checkYourInbox;

  /// No description provided for @clickTheVerificationLink.
  ///
  /// In en, this message translates to:
  /// **'Click the verification link'**
  String get clickTheVerificationLink;

  /// No description provided for @signInAgainWithNewEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign in again with your new email'**
  String get signInAgainWithNewEmail;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// No description provided for @latestScans.
  ///
  /// In en, this message translates to:
  /// **'Latest Scans'**
  String get latestScans;

  /// No description provided for @highRisk.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get highRisk;

  /// No description provided for @mediumRisk.
  ///
  /// In en, this message translates to:
  /// **'Medium Risk'**
  String get mediumRisk;

  /// No description provided for @lowRisk.
  ///
  /// In en, this message translates to:
  /// **'Low Risk'**
  String get lowRisk;

  /// No description provided for @scanHistory.
  ///
  /// In en, this message translates to:
  /// **'Scan History'**
  String get scanHistory;

  /// No description provided for @searchByMoldOrNotes.
  ///
  /// In en, this message translates to:
  /// **'Search by Name'**
  String get searchByMoldOrNotes;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noScansYet.
  ///
  /// In en, this message translates to:
  /// **'No scans yet'**
  String get noScansYet;

  /// No description provided for @noScansDescription.
  ///
  /// In en, this message translates to:
  /// **'Try scanning a sample or change filters. Your recent scans will appear here.'**
  String get noScansDescription;

  /// No description provided for @danger.
  ///
  /// In en, this message translates to:
  /// **'Danger'**
  String get danger;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d'**
  String daysAgo(Object days);

  /// No description provided for @aspergillusDescription.
  ///
  /// In en, this message translates to:
  /// **'Common indoor mold found in bathrooms'**
  String get aspergillusDescription;

  /// No description provided for @penicilliumDescription.
  ///
  /// In en, this message translates to:
  /// **'Blue-green mold typically found in water-damaged areas'**
  String get penicilliumDescription;

  /// No description provided for @stachybotryDescription.
  ///
  /// In en, this message translates to:
  /// **'Black mold - highly toxic and dangerous'**
  String get stachybotryDescription;

  /// No description provided for @cladosporiumDescription.
  ///
  /// In en, this message translates to:
  /// **'Dark green mold commonly found outdoors'**
  String get cladosporiumDescription;

  /// No description provided for @alternariaDescription.
  ///
  /// In en, this message translates to:
  /// **'Brown mold that causes allergic reactions'**
  String get alternariaDescription;

  /// No description provided for @filterBy.
  ///
  /// In en, this message translates to:
  /// **'Filter By'**
  String get filterBy;

  /// No description provided for @moldType.
  ///
  /// In en, this message translates to:
  /// **'Mold Type'**
  String get moldType;

  /// No description provided for @dangerLevel.
  ///
  /// In en, this message translates to:
  /// **'Danger Level'**
  String get dangerLevel;

  /// No description provided for @certainty.
  ///
  /// In en, this message translates to:
  /// **'Certainty'**
  String get certainty;

  /// No description provided for @any.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get any;

  /// No description provided for @moldScanner.
  ///
  /// In en, this message translates to:
  /// **'Mold Scanner'**
  String get moldScanner;

  /// No description provided for @scansLeft.
  ///
  /// In en, this message translates to:
  /// **'Scans left'**
  String get scansLeft;

  /// No description provided for @readyToScan.
  ///
  /// In en, this message translates to:
  /// **'Ready to Scan'**
  String get readyToScan;

  /// No description provided for @getInstantMoldIdentification.
  ///
  /// In en, this message translates to:
  /// **'Get instant mold identification results'**
  String get getInstantMoldIdentification;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @photoGuidelines.
  ///
  /// In en, this message translates to:
  /// **'Photo Guidelines'**
  String get photoGuidelines;

  /// No description provided for @goodLighting.
  ///
  /// In en, this message translates to:
  /// **'Good Lighting'**
  String get goodLighting;

  /// No description provided for @goodLightingDescription.
  ///
  /// In en, this message translates to:
  /// **'Use natural light or bright indoor lighting'**
  String get goodLightingDescription;

  /// No description provided for @optimalDistance.
  ///
  /// In en, this message translates to:
  /// **'Optimal Distance'**
  String get optimalDistance;

  /// No description provided for @optimalDistanceDescription.
  ///
  /// In en, this message translates to:
  /// **'Keep 20-30 cm away from the sample'**
  String get optimalDistanceDescription;

  /// No description provided for @staySteady.
  ///
  /// In en, this message translates to:
  /// **'Stay Steady'**
  String get staySteady;

  /// No description provided for @staySteadyDescription.
  ///
  /// In en, this message translates to:
  /// **'Hold still for a clear, focused image'**
  String get staySteadyDescription;

  /// No description provided for @aiPoweredAnalysis.
  ///
  /// In en, this message translates to:
  /// **'AI-powered analysis provides instant identification with confidence scores'**
  String get aiPoweredAnalysis;

  /// No description provided for @planLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Plan Limit Reached'**
  String get planLimitReached;

  /// No description provided for @planLimitReachedMessage.
  ///
  /// In en, this message translates to:
  /// **'You have reached your scan limit for this plan. Upgrade to continue scanning.'**
  String get planLimitReachedMessage;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @analyzingImage.
  ///
  /// In en, this message translates to:
  /// **'Analyzing Image'**
  String get analyzingImage;

  /// No description provided for @processingWithAI.
  ///
  /// In en, this message translates to:
  /// **'Processing with AI detection...'**
  String get processingWithAI;

  /// No description provided for @scansRemaining.
  ///
  /// In en, this message translates to:
  /// **'scans remaining'**
  String get scansRemaining;

  /// No description provided for @failedToProcessImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to process image: {error}'**
  String failedToProcessImage(Object error);

  /// No description provided for @scanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQrCode;

  /// No description provided for @positionTheQrWithinFrame.
  ///
  /// In en, this message translates to:
  /// **'Position the QR code within the frame to scan'**
  String get positionTheQrWithinFrame;

  /// No description provided for @pleaseSignIn.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to use the scanner'**
  String get pleaseSignIn;

  /// No description provided for @authenticationExpired.
  ///
  /// In en, this message translates to:
  /// **'Authentication expired. Please sign in again.'**
  String get authenticationExpired;

  /// No description provided for @apiKeyNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'AI service not configured on server. Please contact support.'**
  String get apiKeyNotConfigured;

  /// No description provided for @failedToAnalyzeImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to analyze image. Try again later.'**
  String get failedToAnalyzeImage;

  /// No description provided for @scanResults.
  ///
  /// In en, this message translates to:
  /// **'Scan Results'**
  String get scanResults;

  /// No description provided for @viewOnWeb.
  ///
  /// In en, this message translates to:
  /// **'View on Web'**
  String get viewOnWeb;

  /// No description provided for @typeOfMold.
  ///
  /// In en, this message translates to:
  /// **'Type of Mold'**
  String get typeOfMold;

  /// No description provided for @healthRisks.
  ///
  /// In en, this message translates to:
  /// **'Health Risks'**
  String get healthRisks;

  /// No description provided for @prevention.
  ///
  /// In en, this message translates to:
  /// **'Prevention'**
  String get prevention;

  /// No description provided for @detectionStatistics.
  ///
  /// In en, this message translates to:
  /// **'Detection Statistics'**
  String get detectionStatistics;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'users'**
  String get users;

  /// No description provided for @detectionAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Detection Accuracy'**
  String get detectionAccuracy;

  /// No description provided for @commonInHomes.
  ///
  /// In en, this message translates to:
  /// **'Common in Homes'**
  String get commonInHomes;

  /// No description provided for @severityLevel.
  ///
  /// In en, this message translates to:
  /// **'Severity Level'**
  String get severityLevel;

  /// No description provided for @quickFactsAboutMold.
  ///
  /// In en, this message translates to:
  /// **'Quick facts about this mold type. Use the tabs to switch context.'**
  String get quickFactsAboutMold;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @habitat.
  ///
  /// In en, this message translates to:
  /// **'Habitat'**
  String get habitat;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @sampleImageCaptured.
  ///
  /// In en, this message translates to:
  /// **'Sample image captured for this scan.'**
  String get sampleImageCaptured;

  /// No description provided for @whatExposureCanCause.
  ///
  /// In en, this message translates to:
  /// **'What exposure can cause'**
  String get whatExposureCanCause;

  /// No description provided for @copyHealthRisks.
  ///
  /// In en, this message translates to:
  /// **'Copy health risks'**
  String get copyHealthRisks;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get learnMore;

  /// No description provided for @goToPrevention.
  ///
  /// In en, this message translates to:
  /// **'Go to Prevention'**
  String get goToPrevention;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @preventionMethods.
  ///
  /// In en, this message translates to:
  /// **'Prevention Methods'**
  String get preventionMethods;

  /// No description provided for @copyPrevention.
  ///
  /// In en, this message translates to:
  /// **'Copy prevention'**
  String get copyPrevention;

  /// No description provided for @practicalStepsToReduce.
  ///
  /// In en, this message translates to:
  /// **'Practical steps to reduce exposure and prevent growth.'**
  String get practicalStepsToReduce;

  /// No description provided for @downloadFullReportPDF.
  ///
  /// In en, this message translates to:
  /// **'Download full report (PDF)'**
  String get downloadFullReportPDF;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'{label} copied to clipboard'**
  String copiedToClipboard(Object label);

  /// No description provided for @pdfExported.
  ///
  /// In en, this message translates to:
  /// **'PDF exported'**
  String get pdfExported;

  /// No description provided for @errorExportingPDF.
  ///
  /// In en, this message translates to:
  /// **'Error exporting PDF: {error}'**
  String errorExportingPDF(Object error);

  /// No description provided for @couldNotOpenWebLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open web link'**
  String get couldNotOpenWebLink;

  /// No description provided for @pdfScanReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Mold Scan Report'**
  String get pdfScanReportTitle;

  /// No description provided for @pdfDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get pdfDescription;

  /// No description provided for @pdfOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get pdfOverview;

  /// No description provided for @pdfHabitat.
  ///
  /// In en, this message translates to:
  /// **'Habitat'**
  String get pdfHabitat;

  /// No description provided for @pdfDetectionStatistics.
  ///
  /// In en, this message translates to:
  /// **'Detection Statistics'**
  String get pdfDetectionStatistics;

  /// No description provided for @pdfHealthRisks.
  ///
  /// In en, this message translates to:
  /// **'Health Risks'**
  String get pdfHealthRisks;

  /// No description provided for @pdfPreventionMethods.
  ///
  /// In en, this message translates to:
  /// **'Prevention Methods'**
  String get pdfPreventionMethods;

  /// No description provided for @pdfNoneListed.
  ///
  /// In en, this message translates to:
  /// **'None listed'**
  String get pdfNoneListed;

  /// No description provided for @pdfGenerated.
  ///
  /// In en, this message translates to:
  /// **'Generated'**
  String get pdfGenerated;

  /// No description provided for @couldNotCopy.
  ///
  /// In en, this message translates to:
  /// **'Could not copy '**
  String get couldNotCopy;

  /// No description provided for @shareSummary.
  ///
  /// In en, this message translates to:
  /// **'Share Summary'**
  String get shareSummary;

  /// No description provided for @shareSummaryDescription.
  ///
  /// In en, this message translates to:
  /// **'Share a quick summary of your mold scan results with others.'**
  String get shareSummaryDescription;

  /// No description provided for @unreadNotifications.
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String unreadNotifications(Object count);

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @notificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'ll notify you when something new arrives'**
  String get notificationsDescription;

  /// No description provided for @notificationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Notification deleted'**
  String get notificationDeleted;

  /// No description provided for @scanComplete.
  ///
  /// In en, this message translates to:
  /// **'Scan Complete'**
  String get scanComplete;

  /// No description provided for @scanCompleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Your {moldType} scan has been analyzed successfully'**
  String scanCompleteMessage(Object moldType);

  /// No description provided for @highRiskDetected.
  ///
  /// In en, this message translates to:
  /// **'High Risk Detected'**
  String get highRiskDetected;

  /// No description provided for @highRiskDetectedMessage.
  ///
  /// In en, this message translates to:
  /// **'{moldType} detected with high severity level. Take immediate action.'**
  String highRiskDetectedMessage(Object moldType);

  /// No description provided for @scanLimitWarning.
  ///
  /// In en, this message translates to:
  /// **'Scan Limit Warning'**
  String get scanLimitWarning;

  /// No description provided for @scanLimitWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'You have {remaining} scans remaining in your plan'**
  String scanLimitWarningMessage(Object remaining);

  /// No description provided for @newFeatureAvailable.
  ///
  /// In en, this message translates to:
  /// **'New Feature Available'**
  String get newFeatureAvailable;

  /// No description provided for @newFeatureAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Check out our new AI-powered recommendations feature'**
  String get newFeatureAvailableMessage;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String minutesAgo(Object minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(Object hours);

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get deleteAll;

  /// No description provided for @deleteAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Delete All Notifications'**
  String get deleteAllNotifications;

  /// No description provided for @deleteAllNotificationsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all notifications? This action cannot be undone.'**
  String get deleteAllNotificationsConfirm;

  /// No description provided for @allNotificationsDeleted.
  ///
  /// In en, this message translates to:
  /// **'All notifications deleted'**
  String get allNotificationsDeleted;

  /// No description provided for @allMarkedAsRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get allMarkedAsRead;

  /// No description provided for @pleaseSignInToViewNotifications.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to view notifications'**
  String get pleaseSignInToViewNotifications;

  /// No description provided for @errorLoadingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Error loading notifications'**
  String get errorLoadingNotifications;

  /// No description provided for @scanResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan result: {moldType}'**
  String scanResultTitle(Object moldType);

  /// No description provided for @scanResultMessageMedium.
  ///
  /// In en, this message translates to:
  /// **'{moldType} detected (medium severity). Scans left: {scansLeft}.'**
  String scanResultMessageMedium(Object moldType, Object scansLeft);

  /// No description provided for @scanResultMessage.
  ///
  /// In en, this message translates to:
  /// **'{moldType} detected. Scans left: {scansLeft}.'**
  String scanResultMessage(Object moldType, Object scansLeft);

  /// No description provided for @scanResultMessageHigh.
  ///
  /// In en, this message translates to:
  /// **'High severity detected for {moldType}. Act fast. Scans left: {scansLeft}.'**
  String scanResultMessageHigh(Object moldType, Object scansLeft);

  /// No description provided for @checkingSession.
  ///
  /// In en, this message translates to:
  /// **'Checking your session...'**
  String get checkingSession;

  /// No description provided for @kitCodePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'TS-XXXX-XXXX-XXXX'**
  String get kitCodePlaceholder;

  /// No description provided for @sessionRestored.
  ///
  /// In en, this message translates to:
  /// **'Session restored'**
  String get sessionRestored;

  /// No description provided for @kitVerifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Kit verified successfully'**
  String get kitVerifiedSuccessfully;

  /// No description provided for @noSessionToken.
  ///
  /// In en, this message translates to:
  /// **'No session token. Please scan or enter the kit code.'**
  String get noSessionToken;

  /// No description provided for @verifyingQr.
  ///
  /// In en, this message translates to:
  /// **'Verifying QR code...'**
  String get verifyingQr;

  /// No description provided for @verifyingCode.
  ///
  /// In en, this message translates to:
  /// **'Verifying code...'**
  String get verifyingCode;

  /// No description provided for @codeVerified.
  ///
  /// In en, this message translates to:
  /// **'Code verified'**
  String get codeVerified;

  /// No description provided for @invalidCodeFormat.
  ///
  /// In en, this message translates to:
  /// **'Code must match format: TS-XXXX-XXXX-XXXX'**
  String get invalidCodeFormat;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericError;

  /// No description provided for @scanOrEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code on your kit or enter the code manually to sign up.'**
  String get scanOrEnterCode;

  /// No description provided for @kitVerification.
  ///
  /// In en, this message translates to:
  /// **'Kit verification'**
  String get kitVerification;

  /// No description provided for @enterCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your kit code below'**
  String get enterCodeHint;

  /// No description provided for @scanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get scanQr;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter code manually'**
  String get enterCode;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @verifiedPrompt.
  ///
  /// In en, this message translates to:
  /// **'Device verified. You can proceed to Sign Up.'**
  String get verifiedPrompt;

  /// No description provided for @proceedToSignup.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Sign Up'**
  String get proceedToSignup;

  /// No description provided for @welcomeToTesia.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Tesia!'**
  String get welcomeToTesia;

  /// No description provided for @getStartedMessage.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile or link your Google account to get the most out of your mold detection experience.'**
  String get getStartedMessage;

  /// No description provided for @completeProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get completeProfile;

  /// No description provided for @linkGoogleAccount.
  ///
  /// In en, this message translates to:
  /// **'Link Google Account'**
  String get linkGoogleAccount;

  /// No description provided for @ignoreForNow.
  ///
  /// In en, this message translates to:
  /// **'Ignore for now'**
  String get ignoreForNow;

  /// No description provided for @googleAccountLinked.
  ///
  /// In en, this message translates to:
  /// **'Google account linked successfully!'**
  String get googleAccountLinked;

  /// No description provided for @linkedWith.
  ///
  /// In en, this message translates to:
  /// **'Linked with {provider}'**
  String linkedWith(Object provider);

  /// No description provided for @googleLinked.
  ///
  /// In en, this message translates to:
  /// **'Linked with Google'**
  String get googleLinked;

  /// No description provided for @welcomeNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to TESIA! 🎉'**
  String get welcomeNotificationTitle;

  /// No description provided for @welcomeNotificationMessage.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to get the most out of your experience'**
  String get welcomeNotificationMessage;

  /// No description provided for @privacyAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacyAndSecurity;

  /// No description provided for @privacySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'How we handle your data'**
  String get privacySummaryTitle;

  /// No description provided for @privacySummaryBody.
  ///
  /// In en, this message translates to:
  /// **'We collect only what is necessary to provide and improve TESIA. Your account info, test results, and device identifiers help us deliver personalized features and reliable sync across devices. We protect data with industry-standard security, do not sell personal data, and provide options to manage or delete your information.'**
  String get privacySummaryBody;

  /// No description provided for @viewPdf.
  ///
  /// In en, this message translates to:
  /// **'View PDF'**
  String get viewPdf;

  /// No description provided for @openFullPdf.
  ///
  /// In en, this message translates to:
  /// **'Open full PDF'**
  String get openFullPdf;

  /// No description provided for @openPdf.
  ///
  /// In en, this message translates to:
  /// **'Open PDF'**
  String get openPdf;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @googleAccount.
  ///
  /// In en, this message translates to:
  /// **'Google account'**
  String get googleAccount;

  /// No description provided for @linked.
  ///
  /// In en, this message translates to:
  /// **'Linked'**
  String get linked;

  /// No description provided for @syncActive.
  ///
  /// In en, this message translates to:
  /// **'Sync active'**
  String get syncActive;

  /// No description provided for @syncYourDataWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sync your data with Google'**
  String get syncYourDataWithGoogle;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @app.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get app;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @getHelpAndContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Get help and contact support'**
  String get getHelpAndContactSupport;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appVersionAndInformation.
  ///
  /// In en, this message translates to:
  /// **'App version and information'**
  String get appVersionAndInformation;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @rateUsOnTheAppStore.
  ///
  /// In en, this message translates to:
  /// **'Rate us on the app store'**
  String get rateUsOnTheAppStore;

  /// No description provided for @signOutOfYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get signOutOfYourAccount;

  /// No description provided for @permanentlyDeleteYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account'**
  String get permanentlyDeleteYourAccount;

  /// No description provided for @emailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupport;

  /// No description provided for @emailSupportAddress.
  ///
  /// In en, this message translates to:
  /// **'support@tesia.com'**
  String get emailSupportAddress;

  /// No description provided for @phoneSupport.
  ///
  /// In en, this message translates to:
  /// **'Phone Support'**
  String get phoneSupport;

  /// No description provided for @phoneSupportNumber.
  ///
  /// In en, this message translates to:
  /// **'+1 (555) 123-4567'**
  String get phoneSupportNumber;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @frequentlyAskedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get frequentlyAskedQuestions;

  /// No description provided for @enjoyingTesia.
  ///
  /// In en, this message translates to:
  /// **'Enjoying TESIA?'**
  String get enjoyingTesia;

  /// No description provided for @rateAppDescription.
  ///
  /// In en, this message translates to:
  /// **'Please take a moment to rate us on the app store. Your feedback helps us improve and reach more people who need mold detection!'**
  String get rateAppDescription;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @rateNow.
  ///
  /// In en, this message translates to:
  /// **'Rate Now'**
  String get rateNow;

  /// No description provided for @manageYourPrivacySettings.
  ///
  /// In en, this message translates to:
  /// **'Manage your privacy settings'**
  String get manageYourPrivacySettings;

  /// No description provided for @keyPoints.
  ///
  /// In en, this message translates to:
  /// **'Key points'**
  String get keyPoints;

  /// No description provided for @minimalDataCollection.
  ///
  /// In en, this message translates to:
  /// **'Minimal data collection — only what we need to operate the service.'**
  String get minimalDataCollection;

  /// No description provided for @strongEncryption.
  ///
  /// In en, this message translates to:
  /// **'Strong transport encryption (TLS) and Firebase security rules.'**
  String get strongEncryption;

  /// No description provided for @googleSignInOptional.
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In is optional and used only for sync/backups.'**
  String get googleSignInOptional;

  /// No description provided for @requestDataDeletion.
  ///
  /// In en, this message translates to:
  /// **'You can request data deletion at any time.'**
  String get requestDataDeletion;

  /// No description provided for @moreDetails.
  ///
  /// In en, this message translates to:
  /// **'More details'**
  String get moreDetails;

  /// No description provided for @moreDetailsDescription.
  ///
  /// In en, this message translates to:
  /// **'This summary highlights the most important privacy and security practices. For complete information, open the full PDF which includes detailed policies and contact information.'**
  String get moreDetailsDescription;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// No description provided for @privacySecurityAndAppInfo.
  ///
  /// In en, this message translates to:
  /// **'App info'**
  String get privacySecurityAndAppInfo;

  /// No description provided for @aboutTesia.
  ///
  /// In en, this message translates to:
  /// **'About TESIA'**
  String get aboutTesia;

  /// No description provided for @aboutTesiaDescription.
  ///
  /// In en, this message translates to:
  /// **'TESIA is an AI-powered mold detection app designed to help homeowners and professionals quickly identify and analyze mold risks. We focus on accuracy, privacy, and a seamless user experience.'**
  String get aboutTesiaDescription;

  /// No description provided for @whatWeOffer.
  ///
  /// In en, this message translates to:
  /// **'What we offer'**
  String get whatWeOffer;

  /// No description provided for @aiMoldDetection.
  ///
  /// In en, this message translates to:
  /// **'Real-time AI mold detection with confidence scores.'**
  String get aiMoldDetection;

  /// No description provided for @detailedReportsAndSync.
  ///
  /// In en, this message translates to:
  /// **'Detailed downloadable reports and cloud sync.'**
  String get detailedReportsAndSync;

  /// No description provided for @privacyFirstApproach.
  ///
  /// In en, this message translates to:
  /// **'Privacy-first: minimal data collection, no selling.'**
  String get privacyFirstApproach;

  /// No description provided for @multiLanguageSupport.
  ///
  /// In en, this message translates to:
  /// **'Multi-language and theme support.'**
  String get multiLanguageSupport;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2025 TESIA. All rights reserved.'**
  String get copyright;

  /// No description provided for @visitWebsite.
  ///
  /// In en, this message translates to:
  /// **'Visit Website'**
  String get visitWebsite;

  /// No description provided for @signOutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out? You will need to sign in again to access your account and sync your data.'**
  String get signOutConfirmation;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete your account? This action cannot be undone and will result in:'**
  String get deleteAccountConfirmation;

  /// No description provided for @lossOfDetectionHistory.
  ///
  /// In en, this message translates to:
  /// **'• Loss of all detection history'**
  String get lossOfDetectionHistory;

  /// No description provided for @lossOfSettings.
  ///
  /// In en, this message translates to:
  /// **'• Loss of saved settings and preferences'**
  String get lossOfSettings;

  /// No description provided for @lossOfCloudSync.
  ///
  /// In en, this message translates to:
  /// **'• Loss of cloud sync data'**
  String get lossOfCloudSync;

  /// No description provided for @unableToRecover.
  ///
  /// In en, this message translates to:
  /// **'• Inability to recover the account'**
  String get unableToRecover;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @printFailed.
  ///
  /// In en, this message translates to:
  /// **'Print failed: {error}'**
  String printFailed(Object error);

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get couldNotOpenLink;

  /// No description provided for @accountLinked.
  ///
  /// In en, this message translates to:
  /// **'Account linked'**
  String get accountLinked;

  /// No description provided for @googleAccountLinkedDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'Your Google account is successfully linked. You can now sync your TESIA data across devices and enable backups.'**
  String get googleAccountLinkedDialogDescription;

  /// No description provided for @connectGoogleAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Connect your Google account to sync your TESIA data across all your devices and enable automatic backup of your mold detection history.'**
  String get connectGoogleAccountDescription;

  /// No description provided for @syncingData.
  ///
  /// In en, this message translates to:
  /// **'Your data is being synced'**
  String get syncingData;

  /// No description provided for @linkAccount.
  ///
  /// In en, this message translates to:
  /// **'Link account'**
  String get linkAccount;

  /// No description provided for @unlinkAccount.
  ///
  /// In en, this message translates to:
  /// **'Unlink account'**
  String get unlinkAccount;

  /// No description provided for @googleSignInCancelled.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in cancelled'**
  String get googleSignInCancelled;

  /// No description provided for @googleAccountUnlinked.
  ///
  /// In en, this message translates to:
  /// **'Google account unlinked'**
  String get googleAccountUnlinked;

  /// No description provided for @notSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get notSignedIn;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorPrefix(Object error);

  /// No description provided for @setPassword.
  ///
  /// In en, this message translates to:
  /// **'Set Password'**
  String get setPassword;

  /// No description provided for @setPasswordExplanation.
  ///
  /// In en, this message translates to:
  /// **'To unlink Google you must set a password for this account so you can sign in after unlinking'**
  String get setPasswordExplanation;

  /// No description provided for @unlinkRequiresPassword.
  ///
  /// In en, this message translates to:
  /// **'You must set a password before unlinking Google.'**
  String get unlinkRequiresPassword;

  /// No description provided for @failedToLinkPassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to set password. Please try again.'**
  String get failedToLinkPassword;

  /// No description provided for @deletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Deleting account...'**
  String get deletingAccount;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait, this may take a moment.'**
  String get pleaseWait;

  /// No description provided for @failedToDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account. Please try again.'**
  String get failedToDeleteAccount;

  /// No description provided for @failedToLoadPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Failed to load privacy policy. Please try again later.'**
  String get failedToLoadPrivacyPolicy;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
