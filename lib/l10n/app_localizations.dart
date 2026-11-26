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

  /// No description provided for @subscriptionCatalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Available plans'**
  String get subscriptionCatalogTitle;

  /// No description provided for @subscriptionCatalogEmpty.
  ///
  /// In en, this message translates to:
  /// **'No plans available.'**
  String get subscriptionCatalogEmpty;

  /// No description provided for @subscriptionSelect.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscriptionSelect;

  /// No description provided for @subscriptionSelected.
  ///
  /// In en, this message translates to:
  /// **'Current plan'**
  String get subscriptionSelected;

  /// No description provided for @subscriptionResumePayment.
  ///
  /// In en, this message translates to:
  /// **'Resume payment'**
  String get subscriptionResumePayment;

  /// No description provided for @subscriptionRenew.
  ///
  /// In en, this message translates to:
  /// **'Renew subscription'**
  String get subscriptionRenew;

  /// No description provided for @subscriptionRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh status'**
  String get subscriptionRefresh;

  /// No description provided for @subscriptionFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get subscriptionFree;

  /// No description provided for @subscriptionMonthly.
  ///
  /// In en, this message translates to:
  /// **'per month'**
  String get subscriptionMonthly;

  /// No description provided for @subscriptionAnnual.
  ///
  /// In en, this message translates to:
  /// **'per year'**
  String get subscriptionAnnual;

  /// No description provided for @subscriptionConfirmSelection.
  ///
  /// In en, this message translates to:
  /// **'Confirm plan'**
  String get subscriptionConfirmSelection;

  /// No description provided for @subscriptionConfirmRenewal.
  ///
  /// In en, this message translates to:
  /// **'Confirm renewal'**
  String get subscriptionConfirmRenewal;

  /// No description provided for @subscriptionConfirmPaidBody.
  ///
  /// In en, this message translates to:
  /// **'Review the amount before continuing to Stripe.'**
  String get subscriptionConfirmPaidBody;

  /// No description provided for @subscriptionConfirmFreeBody.
  ///
  /// In en, this message translates to:
  /// **'Confirm that you want to select this free plan.'**
  String get subscriptionConfirmFreeBody;

  /// No description provided for @subscriptionRenewalBody.
  ///
  /// In en, this message translates to:
  /// **'You will make a manual payment to extend your subscription.'**
  String get subscriptionRenewalBody;

  /// No description provided for @subscriptionPaymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled. You can try again.'**
  String get subscriptionPaymentCancelled;

  /// No description provided for @subscriptionAwaitingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'We are confirming your payment. Please do not make another payment until confirmation is complete.'**
  String get subscriptionAwaitingConfirmation;

  /// No description provided for @subscriptionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your subscription has been updated successfully.'**
  String get subscriptionUpdated;

  /// No description provided for @subscriptionOperationFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to complete the operation. Refresh your subscription status and try again.'**
  String get subscriptionOperationFailed;

  /// No description provided for @subscriptionStripeNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Payments are currently unavailable.'**
  String get subscriptionStripeNotConfigured;

  /// No description provided for @subscriptionStateChanged.
  ///
  /// In en, this message translates to:
  /// **'Your subscription changed. Review its updated status.'**
  String get subscriptionStateChanged;

  /// No description provided for @subscriptionPaidChangeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Switching directly to this plan is unavailable.'**
  String get subscriptionPaidChangeUnavailable;

  /// No description provided for @subscriptionPendingNotice.
  ///
  /// In en, this message translates to:
  /// **'You have a pending subscription. Complete the payment for the same plan.'**
  String get subscriptionPendingNotice;

  /// No description provided for @subscriptionScheduled.
  ///
  /// In en, this message translates to:
  /// **'Cancellation scheduled'**
  String get subscriptionScheduled;

  /// No description provided for @subscriptionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get subscriptionContinue;

  /// No description provided for @subscriptionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get subscriptionBack;

  /// No description provided for @subscriptionBenefitReminders.
  ///
  /// In en, this message translates to:
  /// **'Basic reminders'**
  String get subscriptionBenefitReminders;

  /// No description provided for @subscriptionBenefitEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency alerts'**
  String get subscriptionBenefitEmergency;

  /// No description provided for @subscriptionBenefitFall.
  ///
  /// In en, this message translates to:
  /// **'Fall detection'**
  String get subscriptionBenefitFall;

  /// No description provided for @subscriptionBenefitGeofence.
  ///
  /// In en, this message translates to:
  /// **'Safe zones'**
  String get subscriptionBenefitGeofence;

  /// No description provided for @subscriptionBenefitHealth.
  ///
  /// In en, this message translates to:
  /// **'Health monitoring'**
  String get subscriptionBenefitHealth;

  /// No description provided for @subscriptionBenefitLocation.
  ///
  /// In en, this message translates to:
  /// **'Real-time location'**
  String get subscriptionBenefitLocation;

  /// No description provided for @subscriptionBenefitLocationHistory.
  ///
  /// In en, this message translates to:
  /// **'Location history'**
  String get subscriptionBenefitLocationHistory;

  /// No description provided for @subscriptionBenefitSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep monitoring'**
  String get subscriptionBenefitSleep;

  /// No description provided for @subscriptionBenefitTreatment.
  ///
  /// In en, this message translates to:
  /// **'Treatment adherence'**
  String get subscriptionBenefitTreatment;

  /// No description provided for @subscriptionBenefitVitals.
  ///
  /// In en, this message translates to:
  /// **'Vital signs history'**
  String get subscriptionBenefitVitals;
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
