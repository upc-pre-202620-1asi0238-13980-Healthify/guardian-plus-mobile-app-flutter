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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Guardian+'**
  String get appTitle;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profilePersonalData.
  ///
  /// In en, this message translates to:
  /// **'My information'**
  String get profilePersonalData;

  /// No description provided for @profileCareRecipient.
  ///
  /// In en, this message translates to:
  /// **'Person under my care'**
  String get profileCareRecipient;

  /// No description provided for @profileCareCircle.
  ///
  /// In en, this message translates to:
  /// **'Care circle'**
  String get profileCareCircle;

  /// No description provided for @profileWearable.
  ///
  /// In en, this message translates to:
  /// **'Wearable'**
  String get profileWearable;

  /// No description provided for @profileMyPlan.
  ///
  /// In en, this message translates to:
  /// **'My plan'**
  String get profileMyPlan;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileLogout;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Application preferences'**
  String get settingsSubtitle;

  /// No description provided for @settingsPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferences;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get settingsAccessibility;

  /// No description provided for @settingsAccessibilitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Text, contrast and assistance'**
  String get settingsAccessibilitySubtitle;

  /// No description provided for @settingsApplication.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get settingsApplication;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms and conditions'**
  String get settingsTerms;

  /// No description provided for @settingsTermsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Guardian+ terms of use'**
  String get settingsTermsSubtitle;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About Guardian+'**
  String get settingsAbout;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Application information'**
  String get settingsAboutSubtitle;

  /// No description provided for @settingsInfo.
  ///
  /// In en, this message translates to:
  /// **'You can adjust these preferences at any time.'**
  String get settingsInfo;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0'**
  String get settingsVersion;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the application language'**
  String get languageSubtitle;

  /// No description provided for @languageSpanishLatam.
  ///
  /// In en, this message translates to:
  /// **'Spanish (Latin America)'**
  String get languageSpanishLatam;

  /// No description provided for @languageEnglishUs.
  ///
  /// In en, this message translates to:
  /// **'English (United States)'**
  String get languageEnglishUs;

  /// No description provided for @languageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Language updated successfully.'**
  String get languageUpdated;

  /// No description provided for @languageUpdateError.
  ///
  /// In en, this message translates to:
  /// **'The language could not be updated.'**
  String get languageUpdateError;

  /// No description provided for @languageLoadError.
  ///
  /// In en, this message translates to:
  /// **'The language preference could not be loaded.'**
  String get languageLoadError;

  /// No description provided for @accessibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibilityTitle;

  /// No description provided for @accessibilitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize your Guardian+ experience'**
  String get accessibilitySubtitle;

  /// No description provided for @accessibilityFontSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get accessibilityFontSize;

  /// No description provided for @accessibilitySmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get accessibilitySmall;

  /// No description provided for @accessibilityDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get accessibilityDefault;

  /// No description provided for @accessibilityLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get accessibilityLarge;

  /// No description provided for @accessibilityHighContrast.
  ///
  /// In en, this message translates to:
  /// **'High contrast'**
  String get accessibilityHighContrast;

  /// No description provided for @accessibilityHighContrastDescription.
  ///
  /// In en, this message translates to:
  /// **'Increase contrast between text and backgrounds'**
  String get accessibilityHighContrastDescription;

  /// No description provided for @accessibilityReduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get accessibilityReduceMotion;

  /// No description provided for @accessibilityReduceMotionDescription.
  ///
  /// In en, this message translates to:
  /// **'Reduce interface animations and transitions'**
  String get accessibilityReduceMotionDescription;

  /// No description provided for @accessibilityReset.
  ///
  /// In en, this message translates to:
  /// **'Restore defaults'**
  String get accessibilityReset;

  /// No description provided for @accessibilityUpdated.
  ///
  /// In en, this message translates to:
  /// **'Accessibility preferences updated successfully.'**
  String get accessibilityUpdated;

  /// No description provided for @accessibilityUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Accessibility preferences could not be saved.'**
  String get accessibilityUpdateError;

  /// No description provided for @accessibilityLoadError.
  ///
  /// In en, this message translates to:
  /// **'Accessibility preferences could not be loaded.'**
  String get accessibilityLoadError;

  /// No description provided for @authWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get authWelcome;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authLogin;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get authForgotPassword;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authNoAccount;

  /// No description provided for @authAlreadyAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authAlreadyAccount;

  /// No description provided for @authLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get authLogoutTitle;

  /// No description provided for @authLogoutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get authLogoutQuestion;

  /// No description provided for @authLogoutCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get authLogoutCancel;

  /// No description provided for @authLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get authLogoutConfirm;

  /// No description provided for @settingsNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Guardian+ notifications'**
  String get settingsNotificationsTitle;

  /// No description provided for @settingsNotificationsQuestion.
  ///
  /// In en, this message translates to:
  /// **'Would you like to receive Guardian+ notifications?'**
  String get settingsNotificationsQuestion;

  /// No description provided for @settingsNotificationsNo.
  ///
  /// In en, this message translates to:
  /// **'Do not receive'**
  String get settingsNotificationsNo;

  /// No description provided for @settingsNotificationsYes.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get settingsNotificationsYes;

  /// No description provided for @settingsInitialized.
  ///
  /// In en, this message translates to:
  /// **'Preferences configured successfully.'**
  String get settingsInitialized;

  /// No description provided for @settingsInitializationError.
  ///
  /// In en, this message translates to:
  /// **'Preferences could not be configured.'**
  String get settingsInitializationError;

  /// No description provided for @languageSection.
  ///
  /// In en, this message translates to:
  /// **'Application language'**
  String get languageSection;

  /// No description provided for @languageSave.
  ///
  /// In en, this message translates to:
  /// **'Save language'**
  String get languageSave;

  /// No description provided for @languageInfo.
  ///
  /// In en, this message translates to:
  /// **'The selected preference is saved to your Guardian+ profile.'**
  String get languageInfo;

  /// No description provided for @accessibilityVisual.
  ///
  /// In en, this message translates to:
  /// **'Visual'**
  String get accessibilityVisual;

  /// No description provided for @accessibilityMovement.
  ///
  /// In en, this message translates to:
  /// **'Motion'**
  String get accessibilityMovement;

  /// No description provided for @accessibilityTextSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get accessibilityTextSize;

  /// No description provided for @accessibilityPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get accessibilityPreview;

  /// No description provided for @accessibilitySave.
  ///
  /// In en, this message translates to:
  /// **'Save preferences'**
  String get accessibilitySave;

  /// No description provided for @accessibilityInfo.
  ///
  /// In en, this message translates to:
  /// **'These preferences are saved to your profile to maintain a consistent experience.'**
  String get accessibilityInfo;

  /// No description provided for @accessibilityPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Text example'**
  String get accessibilityPreviewTitle;

  /// No description provided for @accessibilityPreviewBody.
  ///
  /// In en, this message translates to:
  /// **'This is how some Guardian+ content will look with the selected text size.'**
  String get accessibilityPreviewBody;

  /// No description provided for @authHealthPlatform.
  ///
  /// In en, this message translates to:
  /// **'HEALTH PLATFORM'**
  String get authHealthPlatform;

  /// No description provided for @authConnectedCare.
  ///
  /// In en, this message translates to:
  /// **'Connected\ncare.'**
  String get authConnectedCare;

  /// No description provided for @authMonitoringSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time monitoring for the people who matter'**
  String get authMonitoringSubtitle;

  /// No description provided for @authMonitoringStat.
  ///
  /// In en, this message translates to:
  /// **'Monitoring'**
  String get authMonitoringStat;

  /// No description provided for @authUpdateStat.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get authUpdateStat;

  /// No description provided for @authAvailabilityStat.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get authAvailabilityStat;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Access your caregiver account'**
  String get authLoginSubtitle;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'name@email.com'**
  String get authEmailHint;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authPasswordHint;

  /// No description provided for @authSecureLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign in securely'**
  String get authSecureLogin;

  /// No description provided for @authContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get authContinueWith;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authTermsNotice.
  ///
  /// In en, this message translates to:
  /// **'By signing in, you accept the Terms of Use and Privacy Policy'**
  String get authTermsNotice;

  /// No description provided for @authAccountVerified.
  ///
  /// In en, this message translates to:
  /// **'Account verified. You can now sign in.'**
  String get authAccountVerified;

  /// No description provided for @authGoogleSoon.
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In will be connected in a future update.'**
  String get authGoogleSoon;

  /// No description provided for @registerJoin.
  ///
  /// In en, this message translates to:
  /// **'Join Guardian+'**
  String get registerJoin;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your caregiver account'**
  String get registerSubtitle;

  /// No description provided for @registerFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get registerFullName;

  /// No description provided for @registerFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'John Smith'**
  String get registerFullNameHint;

  /// No description provided for @registerPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Minimum 8 characters'**
  String get registerPasswordHint;

  /// No description provided for @registerConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get registerConfirmPassword;

  /// No description provided for @registerConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Repeat your password'**
  String get registerConfirmPasswordHint;

  /// No description provided for @registerVerificationNotice.
  ///
  /// In en, this message translates to:
  /// **'We will send a verification code to your email.'**
  String get registerVerificationNotice;

  /// No description provided for @otpVerifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get otpVerifyEmailTitle;

  /// No description provided for @otpVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get otpVerificationTitle;

  /// No description provided for @otpConfirmEmail.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email'**
  String get otpConfirmEmail;

  /// No description provided for @otpCheckEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get otpCheckEmail;

  /// No description provided for @otpCodeSentPrefix.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to'**
  String get otpCodeSentPrefix;

  /// No description provided for @otpVerifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify email'**
  String get otpVerifyEmail;

  /// No description provided for @otpVerifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get otpVerifyCode;

  /// No description provided for @otpResending.
  ///
  /// In en, this message translates to:
  /// **'Resending...'**
  String get otpResending;

  /// No description provided for @otpResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get otpResendCode;

  /// No description provided for @otpResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in'**
  String get otpResendIn;

  /// No description provided for @otpMustVerifyBeforeLogin.
  ///
  /// In en, this message translates to:
  /// **'You must verify your email before signing in.'**
  String get otpMustVerifyBeforeLogin;

  /// No description provided for @authLogoutQuestionPrefix.
  ///
  /// In en, this message translates to:
  /// **'Do you want to sign out of Guardian+? You will stop seeing information about'**
  String get authLogoutQuestionPrefix;

  /// No description provided for @authLogoutQuestionSuffix.
  ///
  /// In en, this message translates to:
  /// **'until you sign in again.'**
  String get authLogoutQuestionSuffix;

  /// No description provided for @profileRoleFamily.
  ///
  /// In en, this message translates to:
  /// **'Family member'**
  String get profileRoleFamily;

  /// No description provided for @profileCaresFor.
  ///
  /// In en, this message translates to:
  /// **'Cares for'**
  String get profileCaresFor;

  /// No description provided for @profileAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccountSection;

  /// No description provided for @profileCareSection.
  ///
  /// In en, this message translates to:
  /// **'Care'**
  String get profileCareSection;

  /// No description provided for @profileDevicePlanSection.
  ///
  /// In en, this message translates to:
  /// **'Device and plan'**
  String get profileDevicePlanSection;

  /// No description provided for @profilePreferencesSection.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profilePreferencesSection;

  /// No description provided for @profilePersonalDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personal and contact information'**
  String get profilePersonalDataSubtitle;

  /// No description provided for @profileCareRecipientSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Information about'**
  String get profileCareRecipientSubtitle;

  /// No description provided for @profileCareCircleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'People involved in their care'**
  String get profileCareCircleSubtitle;

  /// No description provided for @profileWearableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Device status and preferences'**
  String get profileWearableSubtitle;

  /// No description provided for @profileMyPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Current subscription and benefits'**
  String get profileMyPlanSubtitle;

  /// No description provided for @profileMyPlanSoon.
  ///
  /// In en, this message translates to:
  /// **'My plan will be available soon.'**
  String get profileMyPlanSoon;

  /// No description provided for @profilePersonalInfoSection.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get profilePersonalInfoSection;

  /// No description provided for @profileFirstNames.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get profileFirstNames;

  /// No description provided for @profileLastNames.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get profileLastNames;

  /// No description provided for @profileContactSection.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get profileContactSection;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profilePhone;

  /// No description provided for @profileSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get profileSaveChanges;

  /// No description provided for @profilePersonalInfoBanner.
  ///
  /// In en, this message translates to:
  /// **'Keep your information up to date to make communication easier within Guardian+.'**
  String get profilePersonalInfoBanner;

  /// No description provided for @profileDataError.
  ///
  /// In en, this message translates to:
  /// **'Your personal information could not be processed.'**
  String get profileDataError;

  /// No description provided for @profileDataSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your personal information was updated successfully.'**
  String get profileDataSuccess;

  /// No description provided for @careRecipientSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Information about the person you care for'**
  String get careRecipientSubtitle;

  /// No description provided for @careRecipientBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get careRecipientBirthDate;

  /// No description provided for @careRecipientSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get careRecipientSelectDate;

  /// No description provided for @careRecipientInfoBanner.
  ///
  /// In en, this message translates to:
  /// **'This information helps correctly identify the person under care within Guardian+.'**
  String get careRecipientInfoBanner;

  /// No description provided for @careRecipientError.
  ///
  /// In en, this message translates to:
  /// **'The care recipient information could not be processed.'**
  String get careRecipientError;

  /// No description provided for @careRecipientSuccess.
  ///
  /// In en, this message translates to:
  /// **'The care recipient information was updated successfully.'**
  String get careRecipientSuccess;

  /// No description provided for @careCircleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'People involved in care'**
  String get careCircleSubtitle;

  /// No description provided for @careCircleInfo.
  ///
  /// In en, this message translates to:
  /// **'Here you can view the people currently linked to the care circle.'**
  String get careCircleInfo;

  /// No description provided for @careCircleMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get careCircleMembers;

  /// No description provided for @careCircleLoadError.
  ///
  /// In en, this message translates to:
  /// **'The care circle could not be loaded.'**
  String get careCircleLoadError;

  /// No description provided for @careCircleEmpty.
  ///
  /// In en, this message translates to:
  /// **'There are no active members in the care circle.'**
  String get careCircleEmpty;

  /// No description provided for @careCirclePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Care circle members may access information needed to support care according to their relationship.'**
  String get careCirclePrivacy;

  /// No description provided for @careCircleActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get careCircleActive;

  /// No description provided for @relationshipFamily.
  ///
  /// In en, this message translates to:
  /// **'Family member'**
  String get relationshipFamily;

  /// No description provided for @relationshipCaregiver.
  ///
  /// In en, this message translates to:
  /// **'Caregiver'**
  String get relationshipCaregiver;

  /// No description provided for @termsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Using Guardian+'**
  String get termsSubtitle;

  /// No description provided for @termsLastUpdate.
  ///
  /// In en, this message translates to:
  /// **'LAST UPDATED: 2026'**
  String get termsLastUpdate;

  /// No description provided for @terms1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Use of the service'**
  String get terms1Title;

  /// No description provided for @terms1Body.
  ///
  /// In en, this message translates to:
  /// **'Guardian+ provides support tools for the care and remote monitoring of people under care.'**
  String get terms1Body;

  /// No description provided for @terms2Title.
  ///
  /// In en, this message translates to:
  /// **'2. User responsibilities'**
  String get terms2Title;

  /// No description provided for @terms2Body.
  ///
  /// In en, this message translates to:
  /// **'Users must keep their registered information up to date and use the application responsibly.'**
  String get terms2Body;

  /// No description provided for @terms3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Use of information'**
  String get terms3Title;

  /// No description provided for @terms3Body.
  ///
  /// In en, this message translates to:
  /// **'The information provided is used to offer and personalize the features available in Guardian+.'**
  String get terms3Body;

  /// No description provided for @terms4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Service availability'**
  String get terms4Title;

  /// No description provided for @terms4Body.
  ///
  /// In en, this message translates to:
  /// **'Some features depend on connectivity, the linked device and available services.'**
  String get terms4Body;

  /// No description provided for @terms5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Changes to these terms'**
  String get terms5Title;

  /// No description provided for @terms5Body.
  ///
  /// In en, this message translates to:
  /// **'Guardian+ may update these terms and communicate the corresponding changes.'**
  String get terms5Body;

  /// No description provided for @termsInfo.
  ///
  /// In en, this message translates to:
  /// **'Check this section periodically to review the current version of the terms of use.'**
  String get termsInfo;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Remote care and monitoring'**
  String get aboutTagline;

  /// No description provided for @aboutSection.
  ///
  /// In en, this message translates to:
  /// **'About Guardian+'**
  String get aboutSection;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Guardian+ helps family members and caregivers remotely support people under care through a centralized and accessible experience.'**
  String get aboutDescription;

  /// No description provided for @aboutInformation.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get aboutInformation;

  /// No description provided for @aboutAppVersion.
  ///
  /// In en, this message translates to:
  /// **'Application version'**
  String get aboutAppVersion;

  /// No description provided for @aboutDevelopedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by'**
  String get aboutDevelopedBy;

  /// No description provided for @aboutLegalInformation.
  ///
  /// In en, this message translates to:
  /// **'Legal information'**
  String get aboutLegalInformation;

  /// No description provided for @aboutTermsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review the Guardian+ terms of use'**
  String get aboutTermsSubtitle;

  /// No description provided for @aboutThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for using Guardian+ to support the care of the people who matter most.'**
  String get aboutThanks;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0'**
  String get aboutVersion;

  /// No description provided for @onboardingCompleteProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete your\nprofile.'**
  String get onboardingCompleteProfile;

  /// No description provided for @onboardingHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We only need a few details to prepare Guardian+.'**
  String get onboardingHeroSubtitle;

  /// No description provided for @onboardingConfigureAccount.
  ///
  /// In en, this message translates to:
  /// **'Set up your account'**
  String get onboardingConfigureAccount;

  /// No description provided for @onboardingExperienceInfo.
  ///
  /// In en, this message translates to:
  /// **'This information will be used to personalize your experience.'**
  String get onboardingExperienceInfo;

  /// No description provided for @onboardingYourData.
  ///
  /// In en, this message translates to:
  /// **'Your information'**
  String get onboardingYourData;

  /// No description provided for @onboardingRelationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get onboardingRelationship;

  /// No description provided for @onboardingFirstNameHint.
  ///
  /// In en, this message translates to:
  /// **'John'**
  String get onboardingFirstNameHint;

  /// No description provided for @onboardingLastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Smith'**
  String get onboardingLastNameHint;

  /// No description provided for @onboardingRecipientFirstNameHint.
  ///
  /// In en, this message translates to:
  /// **'Mary'**
  String get onboardingRecipientFirstNameHint;

  /// No description provided for @onboardingRecipientLastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Smith'**
  String get onboardingRecipientLastNameHint;

  /// No description provided for @myPlanCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current subscription'**
  String get myPlanCurrent;

  /// No description provided for @myPlanGuardianPlan.
  ///
  /// In en, this message translates to:
  /// **'Guardian+ plan'**
  String get myPlanGuardianPlan;

  /// No description provided for @myPlanStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get myPlanStatus;

  /// No description provided for @myPlanPeriod.
  ///
  /// In en, this message translates to:
  /// **'Current period'**
  String get myPlanPeriod;

  /// No description provided for @myPlanPlanId.
  ///
  /// In en, this message translates to:
  /// **'Plan ID'**
  String get myPlanPlanId;

  /// No description provided for @myPlanBenefits.
  ///
  /// In en, this message translates to:
  /// **'Included benefits'**
  String get myPlanBenefits;

  /// No description provided for @myPlanNoBenefits.
  ///
  /// In en, this message translates to:
  /// **'No benefits are currently available.'**
  String get myPlanNoBenefits;

  /// No description provided for @myPlanNoSubscription.
  ///
  /// In en, this message translates to:
  /// **'You do not currently have an active subscription.'**
  String get myPlanNoSubscription;

  /// No description provided for @myPlanLoadError.
  ///
  /// In en, this message translates to:
  /// **'Your subscription could not be loaded.'**
  String get myPlanLoadError;

  /// No description provided for @myPlanStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get myPlanStatusActive;

  /// No description provided for @myPlanStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get myPlanStatusPending;

  /// No description provided for @myPlanStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get myPlanStatusCancelled;

  /// No description provided for @myPlanStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get myPlanStatusExpired;

  /// No description provided for @myPlanCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel subscription'**
  String get myPlanCancelAction;

  /// No description provided for @myPlanCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel subscription?'**
  String get myPlanCancelTitle;

  /// No description provided for @myPlanCancelBody.
  ///
  /// In en, this message translates to:
  /// **'Your subscription will remain active until the end of the current billing period.'**
  String get myPlanCancelBody;

  /// No description provided for @myPlanKeepPlan.
  ///
  /// In en, this message translates to:
  /// **'Keep subscription'**
  String get myPlanKeepPlan;

  /// No description provided for @myPlanConfirmCancel.
  ///
  /// In en, this message translates to:
  /// **'Schedule cancellation'**
  String get myPlanConfirmCancel;

  /// No description provided for @myPlanCancellationScheduled.
  ///
  /// In en, this message translates to:
  /// **'Cancellation is scheduled for'**
  String get myPlanCancellationScheduled;

  /// No description provided for @myPlanCancellationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cancellation was scheduled successfully.'**
  String get myPlanCancellationSuccess;

  /// No description provided for @myPlanCancellationError.
  ///
  /// In en, this message translates to:
  /// **'The cancellation request could not be completed.'**
  String get myPlanCancellationError;

  /// No description provided for @sessionLoadingAccount.
  ///
  /// In en, this message translates to:
  /// **'Loading your account...'**
  String get sessionLoadingAccount;

  /// No description provided for @sessionLoadError.
  ///
  /// In en, this message translates to:
  /// **'Your account could not be loaded.'**
  String get sessionLoadError;

  /// No description provided for @sessionPrepareError.
  ///
  /// In en, this message translates to:
  /// **'Your account could not be prepared.'**
  String get sessionPrepareError;

  /// No description provided for @authCompleteFields.
  ///
  /// In en, this message translates to:
  /// **'Complete all fields to continue.'**
  String get authCompleteFields;

  /// No description provided for @otpNewCodeSent.
  ///
  /// In en, this message translates to:
  /// **'We sent you a new code.'**
  String get otpNewCodeSent;

  /// No description provided for @alertSeverityCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get alertSeverityCritical;

  /// No description provided for @alertSeverityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get alertSeverityHigh;

  /// No description provided for @alertSeverityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get alertSeverityMedium;

  /// No description provided for @alertStatusPendingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirming'**
  String get alertStatusPendingConfirmation;

  /// No description provided for @alertStatusTriggered.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get alertStatusTriggered;

  /// No description provided for @alertStatusEscalated.
  ///
  /// In en, this message translates to:
  /// **'Escalated'**
  String get alertStatusEscalated;

  /// No description provided for @alertStatusAcknowledged.
  ///
  /// In en, this message translates to:
  /// **'Acknowledged'**
  String get alertStatusAcknowledged;

  /// No description provided for @alertStatusDismissed.
  ///
  /// In en, this message translates to:
  /// **'Dismissed'**
  String get alertStatusDismissed;

  /// No description provided for @alertStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get alertStatusResolved;

  /// No description provided for @incidentStatusInAttention.
  ///
  /// In en, this message translates to:
  /// **'In attention'**
  String get incidentStatusInAttention;

  /// No description provided for @incidentStatusStabilized.
  ///
  /// In en, this message translates to:
  /// **'Stabilized'**
  String get incidentStatusStabilized;

  /// No description provided for @incidentStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get incidentStatusClosed;

  /// No description provided for @alertSourceFall.
  ///
  /// In en, this message translates to:
  /// **'Fall'**
  String get alertSourceFall;

  /// No description provided for @alertSourceSos.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get alertSourceSos;

  /// No description provided for @alertSourceVitalSigns.
  ///
  /// In en, this message translates to:
  /// **'Vital signs'**
  String get alertSourceVitalSigns;

  /// No description provided for @alertSourceSafeZone.
  ///
  /// In en, this message translates to:
  /// **'Safe zone'**
  String get alertSourceSafeZone;

  /// No description provided for @alertSourceInactivity.
  ///
  /// In en, this message translates to:
  /// **'Inactivity'**
  String get alertSourceInactivity;

  /// No description provided for @alertSourceReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get alertSourceReminder;

  /// No description provided for @alertSourceMedication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get alertSourceMedication;

  /// No description provided for @alertTitleFall.
  ///
  /// In en, this message translates to:
  /// **'Possible fall detected'**
  String get alertTitleFall;

  /// No description provided for @alertTitleVitalSign.
  ///
  /// In en, this message translates to:
  /// **'Vital sign out of range'**
  String get alertTitleVitalSign;

  /// No description provided for @alertTitleSafeZone.
  ///
  /// In en, this message translates to:
  /// **'Left the safe zone'**
  String get alertTitleSafeZone;

  /// No description provided for @alertTitleInactivity.
  ///
  /// In en, this message translates to:
  /// **'Prolonged inactivity'**
  String get alertTitleInactivity;

  /// No description provided for @alertTitleReminder.
  ///
  /// In en, this message translates to:
  /// **'Unconfirmed reminder'**
  String get alertTitleReminder;

  /// No description provided for @alertTitleMedication.
  ///
  /// In en, this message translates to:
  /// **'Medication running out'**
  String get alertTitleMedication;

  /// No description provided for @alertTimeNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get alertTimeNow;

  /// No description provided for @alertTitleSos.
  ///
  /// In en, this message translates to:
  /// **'{name} pressed the SOS button'**
  String alertTitleSos(String name);

  /// No description provided for @alertTimeSecondsAgo.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s ago'**
  String alertTimeSecondsAgo(int seconds);

  /// No description provided for @alertTimeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String alertTimeMinutesAgo(int minutes);

  /// No description provided for @alertTimeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} h ago'**
  String alertTimeHoursAgo(int hours);

  /// No description provided for @alertTimeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} d ago'**
  String alertTimeDaysAgo(int days);

  /// No description provided for @alertCallFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the phone to call {phoneNumber}'**
  String alertCallFailed(String phoneNumber);

  /// No description provided for @alertCallNeedsContact.
  ///
  /// In en, this message translates to:
  /// **'Add an emergency contact to be able to call'**
  String get alertCallNeedsContact;

  /// No description provided for @alertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alertsTitle;

  /// No description provided for @alertsActiveCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 active} other{{count} active}}'**
  String alertsActiveCount(int count);

  /// No description provided for @alertsSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Alert settings'**
  String get alertsSettingsTooltip;

  /// No description provided for @alertsTabActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get alertsTabActive;

  /// No description provided for @alertsTabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get alertsTabHistory;

  /// No description provided for @alertsOtherActive.
  ///
  /// In en, this message translates to:
  /// **'Other active alerts'**
  String get alertsOtherActive;

  /// No description provided for @alertsActive.
  ///
  /// In en, this message translates to:
  /// **'Active alerts'**
  String get alertsActive;

  /// No description provided for @alertsAllGoodTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} is fine'**
  String alertsAllGoodTitle(String name);

  /// No description provided for @alertsAllGoodMessage.
  ///
  /// In en, this message translates to:
  /// **'No active alerts. We\'ll let you know right away if anything changes.'**
  String get alertsAllGoodMessage;

  /// No description provided for @alertsMetaUnacknowledged.
  ///
  /// In en, this message translates to:
  /// **'{elapsed} · Unacknowledged'**
  String alertsMetaUnacknowledged(String elapsed);

  /// No description provided for @alertsMetaConfirming.
  ///
  /// In en, this message translates to:
  /// **'{elapsed} · Confirming'**
  String alertsMetaConfirming(String elapsed);

  /// No description provided for @alertsMetaAcknowledged.
  ///
  /// In en, this message translates to:
  /// **'{elapsed} · Acknowledged'**
  String alertsMetaAcknowledged(String elapsed);

  /// No description provided for @alertsViewDetail.
  ///
  /// In en, this message translates to:
  /// **'View alert details'**
  String get alertsViewDetail;

  /// No description provided for @alertsAcknowledge.
  ///
  /// In en, this message translates to:
  /// **'Acknowledge'**
  String get alertsAcknowledge;

  /// No description provided for @alertsCall.
  ///
  /// In en, this message translates to:
  /// **'Call {name}'**
  String alertsCall(String name);

  /// No description provided for @alertsWaitingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {name} to confirm they are okay'**
  String alertsWaitingConfirmation(String name);

  /// No description provided for @alertsFallNoResponse.
  ///
  /// In en, this message translates to:
  /// **'{name} did not respond within 20 s'**
  String alertsFallNoResponse(String name);

  /// No description provided for @alertsSosHeld.
  ///
  /// In en, this message translates to:
  /// **'Long press on the wristband'**
  String get alertsSosHeld;

  /// No description provided for @alertsSentToEveryone.
  ///
  /// In en, this message translates to:
  /// **'Sent to the whole care circle'**
  String get alertsSentToEveryone;

  /// No description provided for @alertsEscalatingNow.
  ///
  /// In en, this message translates to:
  /// **'Unacknowledged · sending to the next contacts…'**
  String get alertsEscalatingNow;

  /// No description provided for @alertsEscalatesToSecondary.
  ///
  /// In en, this message translates to:
  /// **'Unacknowledged · goes to your secondary contacts in'**
  String get alertsEscalatesToSecondary;

  /// No description provided for @alertsEscalatesToEveryone.
  ///
  /// In en, this message translates to:
  /// **'Unacknowledged · goes to the whole care circle in'**
  String get alertsEscalatesToEveryone;

  /// No description provided for @alertsEscalationNotice.
  ///
  /// In en, this message translates to:
  /// **'If nobody acknowledges a critical alert within {seconds} s, it will be sent automatically to your secondary contacts.'**
  String alertsEscalationNotice(int seconds);

  /// No description provided for @alertsManageContacts.
  ///
  /// In en, this message translates to:
  /// **'Manage emergency contacts'**
  String get alertsManageContacts;

  /// No description provided for @alertDetailTopPriority.
  ///
  /// In en, this message translates to:
  /// **'Top priority'**
  String get alertDetailTopPriority;

  /// No description provided for @alertDetailSosHeld.
  ///
  /// In en, this message translates to:
  /// **'3 s long press on the wristband · Their location was sent to your contacts'**
  String get alertDetailSosHeld;

  /// No description provided for @alertDetailDismissedBy.
  ///
  /// In en, this message translates to:
  /// **'False alarm dismissed by {name}'**
  String alertDetailDismissedBy(String name);

  /// No description provided for @alertDetailIncidentClosed.
  ///
  /// In en, this message translates to:
  /// **'Incident closed'**
  String get alertDetailIncidentClosed;

  /// No description provided for @alertDetailIncidentStabilized.
  ///
  /// In en, this message translates to:
  /// **'Incident stabilized'**
  String get alertDetailIncidentStabilized;

  /// No description provided for @alertDetailFallNoResponse.
  ///
  /// In en, this message translates to:
  /// **'{name} did not respond after a fall'**
  String alertDetailFallNoResponse(String name);

  /// No description provided for @alertDetailImpactDetected.
  ///
  /// In en, this message translates to:
  /// **'Impact detected by the wristband'**
  String get alertDetailImpactDetected;

  /// No description provided for @alertDetailDetected.
  ///
  /// In en, this message translates to:
  /// **'Detected'**
  String get alertDetailDetected;

  /// No description provided for @alertDetailStabilizedAt.
  ///
  /// In en, this message translates to:
  /// **'Stabilized'**
  String get alertDetailStabilizedAt;

  /// No description provided for @alertDetailClosedAt.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get alertDetailClosedAt;

  /// No description provided for @alertDetailDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get alertDetailDuration;

  /// No description provided for @alertDetailCancelWindow.
  ///
  /// In en, this message translates to:
  /// **'Cancellation window'**
  String get alertDetailCancelWindow;

  /// No description provided for @alertDetailSecondsLeft.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s left'**
  String alertDetailSecondsLeft(int seconds);

  /// No description provided for @alertDetailWindowExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired · {seconds} s'**
  String alertDetailWindowExpired(int seconds);

  /// No description provided for @alertDetailSinceDetection.
  ///
  /// In en, this message translates to:
  /// **'Since detection'**
  String get alertDetailSinceDetection;

  /// No description provided for @alertDetailEscalationWatching.
  ///
  /// In en, this message translates to:
  /// **'When someone acknowledges it or is on the way, everyone else will see it here.'**
  String get alertDetailEscalationWatching;

  /// No description provided for @alertDetailEscalationToSecondary.
  ///
  /// In en, this message translates to:
  /// **'If you don\'t acknowledge the alert, it will be sent to your secondary contacts.'**
  String get alertDetailEscalationToSecondary;

  /// No description provided for @alertDetailEscalationToEveryone.
  ///
  /// In en, this message translates to:
  /// **'If nobody acknowledges it, it will be sent to the whole care circle.'**
  String get alertDetailEscalationToEveryone;

  /// No description provided for @alertDetailAutoEscalation.
  ///
  /// In en, this message translates to:
  /// **'Automatic escalation'**
  String get alertDetailAutoEscalation;

  /// No description provided for @alertDetailSentToContacts.
  ///
  /// In en, this message translates to:
  /// **'Notice sent to your contacts'**
  String get alertDetailSentToContacts;

  /// No description provided for @contactStatusWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get contactStatusWaiting;

  /// No description provided for @contactStatusSending.
  ///
  /// In en, this message translates to:
  /// **'Sending'**
  String get contactStatusSending;

  /// No description provided for @contactStatusSent.
  ///
  /// In en, this message translates to:
  /// **'Notified'**
  String get contactStatusSent;

  /// No description provided for @contactStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get contactStatusDelivered;

  /// No description provided for @contactStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get contactStatusFailed;

  /// No description provided for @contactStatusAcknowledged.
  ///
  /// In en, this message translates to:
  /// **'Acknowledged'**
  String get contactStatusAcknowledged;

  /// No description provided for @contactStatusOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get contactStatusOnTheWay;

  /// No description provided for @contactStatusArrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get contactStatusArrived;

  /// No description provided for @contactStatusNotNeeded.
  ///
  /// In en, this message translates to:
  /// **'Not needed'**
  String get contactStatusNotNeeded;

  /// No description provided for @contactPrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get contactPrimary;

  /// No description provided for @contactSecondary.
  ///
  /// In en, this message translates to:
  /// **'Secondary'**
  String get contactSecondary;

  /// No description provided for @alertDetailTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Incident follow-up'**
  String get alertDetailTimelineTitle;

  /// No description provided for @alertDetailSomeMember.
  ///
  /// In en, this message translates to:
  /// **'A circle member'**
  String get alertDetailSomeMember;

  /// No description provided for @timelineFallDetected.
  ///
  /// In en, this message translates to:
  /// **'Fall detected by the wristband'**
  String get timelineFallDetected;

  /// No description provided for @timelineNotCancelled.
  ///
  /// In en, this message translates to:
  /// **'{name} didn\'t cancel the alert within {seconds} s'**
  String timelineNotCancelled(String name, int seconds);

  /// No description provided for @timelineDismissed.
  ///
  /// In en, this message translates to:
  /// **'{name} confirmed from the wristband that they are okay'**
  String timelineDismissed(String name);

  /// No description provided for @timelineSentTo.
  ///
  /// In en, this message translates to:
  /// **'Alert sent to {names}'**
  String timelineSentTo(String names);

  /// No description provided for @timelineAcknowledged.
  ///
  /// In en, this message translates to:
  /// **'{names} acknowledged the alert'**
  String timelineAcknowledged(String names);

  /// No description provided for @timelineOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'{names} is on the way'**
  String timelineOnTheWay(String names);

  /// No description provided for @timelineArrived.
  ///
  /// In en, this message translates to:
  /// **'{names} arrived with {name}'**
  String timelineArrived(String names, String name);

  /// No description provided for @timelineNextEscalation.
  ///
  /// In en, this message translates to:
  /// **'Sending to the next contacts (pending)'**
  String get timelineNextEscalation;

  /// No description provided for @alertDetailAcknowledge.
  ///
  /// In en, this message translates to:
  /// **'Acknowledge alert'**
  String get alertDetailAcknowledge;

  /// No description provided for @alertDetailArrived.
  ///
  /// In en, this message translates to:
  /// **'I\'ve arrived'**
  String get alertDetailArrived;

  /// No description provided for @alertDetailCloseIncident.
  ///
  /// In en, this message translates to:
  /// **'Close incident'**
  String get alertDetailCloseIncident;

  /// No description provided for @alertDetailOnMyWay.
  ///
  /// In en, this message translates to:
  /// **'I\'m on my way'**
  String get alertDetailOnMyWay;

  /// No description provided for @alertDetailMarkStabilized.
  ///
  /// In en, this message translates to:
  /// **'Mark stabilized'**
  String get alertDetailMarkStabilized;

  /// No description provided for @alertDetailCallEmergency.
  ///
  /// In en, this message translates to:
  /// **'Call emergency services (SAMU 106)'**
  String get alertDetailCallEmergency;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesLabel;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. Fall without injuries, she is lying down now.'**
  String get notesHint;

  /// No description provided for @summaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Incident summary'**
  String get summaryTitle;

  /// No description provided for @summaryType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get summaryType;

  /// No description provided for @summaryStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get summaryStart;

  /// No description provided for @summaryAcknowledgedBy.
  ///
  /// In en, this message translates to:
  /// **'Acknowledged by'**
  String get summaryAcknowledgedBy;

  /// No description provided for @summaryAcknowledgedIn.
  ///
  /// In en, this message translates to:
  /// **'{name} · in {duration}'**
  String summaryAcknowledgedIn(String name, String duration);

  /// No description provided for @summaryNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get summaryNotes;

  /// No description provided for @vitalsHeartRate.
  ///
  /// In en, this message translates to:
  /// **'Heart rate'**
  String get vitalsHeartRate;

  /// No description provided for @vitalsOxygen.
  ///
  /// In en, this message translates to:
  /// **'O₂ saturation'**
  String get vitalsOxygen;

  /// No description provided for @vitalsUnitBpm.
  ///
  /// In en, this message translates to:
  /// **'bpm'**
  String get vitalsUnitBpm;

  /// No description provided for @readingHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get readingHigh;

  /// No description provided for @readingLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get readingLow;

  /// No description provided for @readingNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get readingNormal;

  /// No description provided for @locationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Location updated {ago}'**
  String locationUpdated(String ago);

  /// No description provided for @locationViewMap.
  ///
  /// In en, this message translates to:
  /// **'View on map'**
  String get locationViewMap;

  /// No description provided for @alertDetailStabilizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark as stabilized'**
  String get alertDetailStabilizeTitle;

  /// No description provided for @alertDetailStabilizeMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} is no longer in danger. The incident stays open until you close it.'**
  String alertDetailStabilizeMessage(String name);

  /// No description provided for @alertDetailCloseMessage.
  ///
  /// In en, this message translates to:
  /// **'The alert will be resolved and moved to the history.'**
  String get alertDetailCloseMessage;

  /// No description provided for @alertDetailSosTitle.
  ///
  /// In en, this message translates to:
  /// **'SOS alert'**
  String get alertDetailSosTitle;

  /// No description provided for @alertDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Alert details'**
  String get alertDetailTitle;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No alerts in the history'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'When an alert happens, it will be recorded here with its whole follow-up.'**
  String get historyEmptyMessage;

  /// No description provided for @historyEmptyFiltered.
  ///
  /// In en, this message translates to:
  /// **'There are no {severity} severity alerts.'**
  String historyEmptyFiltered(String severity);

  /// No description provided for @historyWeekday.
  ///
  /// In en, this message translates to:
  /// **'{value, select, 1{Monday} 2{Tuesday} 3{Wednesday} 4{Thursday} 5{Friday} 6{Saturday} 7{Sunday} other{}}'**
  String historyWeekday(String value);

  /// No description provided for @historyMonth.
  ///
  /// In en, this message translates to:
  /// **'{value, select, 1{Jan} 2{Feb} 3{Mar} 4{Apr} 5{May} 6{Jun} 7{Jul} 8{Aug} 9{Sep} 10{Oct} 11{Nov} 12{Dec} other{}}'**
  String historyMonth(String value);

  /// No description provided for @historyToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get historyToday;

  /// No description provided for @historyYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get historyYesterday;

  /// No description provided for @historyDay.
  ///
  /// In en, this message translates to:
  /// **'{weekday} {day} {month}'**
  String historyDay(String weekday, int day, String month);

  /// No description provided for @historyAcknowledgedIn.
  ///
  /// In en, this message translates to:
  /// **'Acknowledged in {duration}'**
  String historyAcknowledgedIn(String duration);

  /// No description provided for @historyWaitingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {name} to confirm'**
  String historyWaitingConfirmation(String name);

  /// No description provided for @historyUnacknowledged.
  ///
  /// In en, this message translates to:
  /// **'Unacknowledged'**
  String get historyUnacknowledged;

  /// No description provided for @historySummaryAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts · 7 days'**
  String get historySummaryAlerts;

  /// No description provided for @historySummaryResponse.
  ///
  /// In en, this message translates to:
  /// **'Average response'**
  String get historySummaryResponse;

  /// No description provided for @historySummaryEscalated.
  ///
  /// In en, this message translates to:
  /// **'Escalated'**
  String get historySummaryEscalated;

  /// No description provided for @historyFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get historyFilterAll;

  /// No description provided for @historyFilterCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get historyFilterCritical;

  /// No description provided for @historyFilterHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get historyFilterHigh;

  /// No description provided for @historyFilterMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get historyFilterMedium;

  /// No description provided for @alertSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alert settings'**
  String get alertSettingsTitle;

  /// No description provided for @alertSettingsSoundSection.
  ///
  /// In en, this message translates to:
  /// **'Alert sound'**
  String get alertSettingsSoundSection;

  /// No description provided for @alertSettingsSilentTitle.
  ///
  /// In en, this message translates to:
  /// **'Silence non-critical alerts'**
  String get alertSettingsSilentTitle;

  /// No description provided for @alertSettingsSilentDetail.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s non-critical alerts reach the care circle\'s phones without sound. Falls and SOS always ring.'**
  String alertSettingsSilentDetail(String name);

  /// No description provided for @alertSettingsEscalationSection.
  ///
  /// In en, this message translates to:
  /// **'Escalation'**
  String get alertSettingsEscalationSection;

  /// No description provided for @alertSettingsEscalationTitle.
  ///
  /// In en, this message translates to:
  /// **'Notify the next contacts'**
  String get alertSettingsEscalationTitle;

  /// No description provided for @alertSettingsEscalationDetail.
  ///
  /// In en, this message translates to:
  /// **'If the primary contact doesn\'t acknowledge a critical or high alert, it is sent to the others.'**
  String get alertSettingsEscalationDetail;

  /// No description provided for @alertSettingsBroadcastTitle.
  ///
  /// In en, this message translates to:
  /// **'Notify everyone on falls and SOS'**
  String get alertSettingsBroadcastTitle;

  /// No description provided for @alertSettingsBroadcastDetail.
  ///
  /// In en, this message translates to:
  /// **'Critical alerts reach the whole care circle at the same time.'**
  String get alertSettingsBroadcastDetail;

  /// No description provided for @alertSettingsChannelPush.
  ///
  /// In en, this message translates to:
  /// **'Push notification'**
  String get alertSettingsChannelPush;

  /// No description provided for @alertSettingsChannelSms.
  ///
  /// In en, this message translates to:
  /// **'Text message (SMS)'**
  String get alertSettingsChannelSms;

  /// No description provided for @alertSettingsChannelInApp.
  ///
  /// In en, this message translates to:
  /// **'In the app'**
  String get alertSettingsChannelInApp;

  /// No description provided for @alertSettingsChannelsSection.
  ///
  /// In en, this message translates to:
  /// **'How we notify you'**
  String get alertSettingsChannelsSection;

  /// No description provided for @alertSettingsChannelsNote.
  ///
  /// In en, this message translates to:
  /// **'Critical alerts are always backed up by SMS. At least one channel must stay on.'**
  String get alertSettingsChannelsNote;

  /// No description provided for @alertSettingsAckTimeout.
  ///
  /// In en, this message translates to:
  /// **'Wait time before escalating'**
  String get alertSettingsAckTimeout;

  /// No description provided for @contactsSummaryNone.
  ///
  /// In en, this message translates to:
  /// **'No contacts yet'**
  String get contactsSummaryNone;

  /// No description provided for @contactsSummaryOne.
  ///
  /// In en, this message translates to:
  /// **'1 contact · {name}'**
  String contactsSummaryOne(String name);

  /// No description provided for @contactsSummaryMany.
  ///
  /// In en, this message translates to:
  /// **'{count} contacts · {name} is the primary one'**
  String contactsSummaryMany(int count, String name);

  /// No description provided for @emergencyContactsTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency contacts'**
  String get emergencyContactsTitle;

  /// No description provided for @contactsIntroEmpty.
  ///
  /// In en, this message translates to:
  /// **'{name} has no emergency contacts yet. Add at least one so the alerts reach someone.'**
  String contactsIntroEmpty(String name);

  /// No description provided for @contactsIntro.
  ///
  /// In en, this message translates to:
  /// **'They receive {name}\'s alerts in this order. If the first one doesn\'t answer within {seconds} s, the next ones are notified.'**
  String contactsIntro(String name, int seconds);

  /// No description provided for @contactsKeepOne.
  ///
  /// In en, this message translates to:
  /// **'At least one contact must remain: they receive the alerts first.'**
  String get contactsKeepOne;

  /// No description provided for @contactsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add contact'**
  String get contactsAdd;

  /// No description provided for @addContactTitle.
  ///
  /// In en, this message translates to:
  /// **'New emergency contact'**
  String get addContactTitle;

  /// No description provided for @addContactSubtitle.
  ///
  /// In en, this message translates to:
  /// **'They will be added at the end of {name}\'s list.'**
  String addContactSubtitle(String name);

  /// No description provided for @addContactName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get addContactName;

  /// No description provided for @addContactNameError.
  ///
  /// In en, this message translates to:
  /// **'Enter the name (up to {max} characters)'**
  String addContactNameError(int max);

  /// No description provided for @addContactRelationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get addContactRelationship;

  /// No description provided for @addContactRelationshipHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. Daughter, neighbor, caregiver'**
  String get addContactRelationshipHint;

  /// No description provided for @addContactRelationshipError.
  ///
  /// In en, this message translates to:
  /// **'Enter the relationship (up to {max} characters)'**
  String addContactRelationshipError(int max);

  /// No description provided for @addContactPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone with country code'**
  String get addContactPhone;

  /// No description provided for @addContactPhoneError.
  ///
  /// In en, this message translates to:
  /// **'Use the international format, for example +51987654321'**
  String get addContactPhoneError;

  /// No description provided for @addContactSave.
  ///
  /// In en, this message translates to:
  /// **'Save contact'**
  String get addContactSave;

  /// No description provided for @contactPrimaryChip.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get contactPrimaryChip;

  /// No description provided for @contactSecondaryChip.
  ///
  /// In en, this message translates to:
  /// **'Secondary {position}'**
  String contactSecondaryChip(int position);

  /// No description provided for @contactMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move {name} up'**
  String contactMoveUp(String name);

  /// No description provided for @contactMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move {name} down'**
  String contactMoveDown(String name);

  /// No description provided for @contactRemoveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String contactRemoveTooltip(String name);

  /// No description provided for @removeContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String removeContactTitle(String name);

  /// No description provided for @removeContactMessage.
  ///
  /// In en, this message translates to:
  /// **'They will stop receiving {name}\'s alerts. The rest of the list moves up one place.'**
  String removeContactMessage(String name);

  /// No description provided for @removeContactConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeContactConfirm;

  /// No description provided for @errorLoadAlerts.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the alerts'**
  String get errorLoadAlerts;

  /// No description provided for @errorLoadAlert.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the alert'**
  String get errorLoadAlert;

  /// No description provided for @errorLoadHistory.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the history'**
  String get errorLoadHistory;

  /// No description provided for @errorLoadSettings.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the settings'**
  String get errorLoadSettings;

  /// No description provided for @errorLoadContacts.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the contacts'**
  String get errorLoadContacts;

  /// No description provided for @errorAcknowledge.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t acknowledge the alert'**
  String get errorAcknowledge;

  /// No description provided for @errorRunAction.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t complete the action'**
  String get errorRunAction;

  /// No description provided for @errorChangeChannel.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t change the channel'**
  String get errorChangeChannel;

  /// No description provided for @errorKeepOneChannel.
  ///
  /// In en, this message translates to:
  /// **'At least one channel must stay on to receive the alerts'**
  String get errorKeepOneChannel;

  /// No description provided for @errorSaveSettings.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the settings'**
  String get errorSaveSettings;

  /// No description provided for @errorReorderContacts.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t change the order'**
  String get errorReorderContacts;

  /// No description provided for @errorRemoveContact.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t remove the contact'**
  String get errorRemoveContact;

  /// No description provided for @errorAddContact.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t add the contact'**
  String get errorAddContact;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
