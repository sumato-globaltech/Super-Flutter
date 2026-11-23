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
/// import 'localization/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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

  /// Application name shown in the task switcher
  ///
  /// In en, this message translates to:
  /// **'Flutter Kit'**
  String get appTitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get alreadyHaveAccount;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get search;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @browse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browse;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// Stock level for a product
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Sold out} =1{1 in stock} other{{count} in stock}}'**
  String inStockCount(int count);

  /// No description provided for @percentOff.
  ///
  /// In en, this message translates to:
  /// **'{percent}% off'**
  String percentOff(String percent);

  /// No description provided for @market.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get market;

  /// No description provided for @farms.
  ///
  /// In en, this message translates to:
  /// **'Farms'**
  String get farms;

  /// No description provided for @schemes.
  ///
  /// In en, this message translates to:
  /// **'Schemes'**
  String get schemes;

  /// No description provided for @shipments.
  ///
  /// In en, this message translates to:
  /// **'Shipments'**
  String get shipments;

  /// No description provided for @production.
  ///
  /// In en, this message translates to:
  /// **'Production'**
  String get production;

  /// No description provided for @helpDesk.
  ///
  /// In en, this message translates to:
  /// **'Help desk'**
  String get helpDesk;

  /// No description provided for @crops.
  ///
  /// In en, this message translates to:
  /// **'Crops'**
  String get crops;

  /// No description provided for @notices.
  ///
  /// In en, this message translates to:
  /// **'Notices'**
  String get notices;

  /// No description provided for @manageNotices.
  ///
  /// In en, this message translates to:
  /// **'Manage notices'**
  String get manageNotices;

  /// No description provided for @manageAlerts.
  ///
  /// In en, this message translates to:
  /// **'Manage alerts'**
  String get manageAlerts;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @comingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'This section is being built and will be available soon.'**
  String get comingSoonMessage;

  /// Bottom bar tab that lists the destinations that do not fit
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @imageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Image unavailable'**
  String get imageUnavailable;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// Link after a shortened text that opens the full text
  ///
  /// In en, this message translates to:
  /// **'more'**
  String get readMore;

  /// Developer screen that shows the shared widgets
  ///
  /// In en, this message translates to:
  /// **'UI gallery'**
  String get uiGallery;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go home'**
  String get goHome;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @noMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get noMatches;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get noProducts;

  /// No description provided for @showingSavedData.
  ///
  /// In en, this message translates to:
  /// **'{message} Showing saved data.'**
  String showingSavedData(String message);

  /// No description provided for @errorNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get errorNoConnection;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request took too long. Please try again.'**
  String get errorTimeout;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side.'**
  String get errorServer;

  /// No description provided for @errorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get errorSessionExpired;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnknown;

  /// No description provided for @loginWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginWithEmail;

  /// No description provided for @loginWithPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get loginWithPhone;

  /// No description provided for @loginPhone.
  ///
  /// In en, this message translates to:
  /// **'Mobile number *'**
  String get loginPhone;

  /// No description provided for @loginPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'10-digit mobile number'**
  String get loginPhoneHint;

  /// No description provided for @loginPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a 10-digit mobile number'**
  String get loginPhoneInvalid;

  /// No description provided for @loginOtpSend.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get loginOtpSend;

  /// No description provided for @loginOtp.
  ///
  /// In en, this message translates to:
  /// **'OTP *'**
  String get loginOtp;

  /// No description provided for @loginOtpHint.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get loginOtpHint;

  /// No description provided for @loginOtpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get loginOtpInvalid;

  /// No description provided for @loginOtpVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get loginOtpVerify;

  /// Shown above the code input
  ///
  /// In en, this message translates to:
  /// **'We sent a code to {phone}'**
  String loginOtpSentTo(String phone);

  /// Countdown of the sent code, as m:ss
  ///
  /// In en, this message translates to:
  /// **'Code expires in {time}'**
  String loginOtpExpiresIn(String time);

  /// No description provided for @loginOtpExpired.
  ///
  /// In en, this message translates to:
  /// **'The code has expired'**
  String get loginOtpExpired;

  /// No description provided for @loginOtpResend.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get loginOtpResend;

  /// No description provided for @loginOtpChangeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get loginOtpChangeNumber;

  /// App bar title of the change_password screen
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get authChangePasswordTitle;

  /// Hint of a text input
  ///
  /// In en, this message translates to:
  /// **'Enter {field}'**
  String fieldEnter(String field);

  /// Hint of a date or dropdown input, and a date picker's title
  ///
  /// In en, this message translates to:
  /// **'Select {field}'**
  String fieldSelect(String field);

  /// Hint of a file input
  ///
  /// In en, this message translates to:
  /// **'Choose {field}'**
  String fieldChoose(String field);

  /// Shown under an empty required input
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String fieldRequired(String field);

  /// Shown under a number input that is not a number
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get fieldInvalidNumber;

  /// Shown while a list loads
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Submit button of a form
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get formSubmit;

  /// Label of the current_password input
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get authChangePasswordCurrentPassword;

  /// Label of the password input
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authChangePasswordPassword;

  /// Label of the password_confirmation input
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get authChangePasswordPasswordConfirmation;

  /// Shown when the change password form was sent
  ///
  /// In en, this message translates to:
  /// **'Password changed. Other devices have been signed out.'**
  String get authChangePasswordDone;

  /// Shown on the change password screen when the account must change it
  ///
  /// In en, this message translates to:
  /// **'Set a new password to continue.'**
  String get authChangePasswordRequired;

  /// No description provided for @signOutAllDevices.
  ///
  /// In en, this message translates to:
  /// **'Sign out of all devices'**
  String get signOutAllDevices;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again on this device.'**
  String get signOutConfirmMessage;

  /// No description provided for @signOutAllConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of all devices?'**
  String get signOutAllConfirmTitle;

  /// No description provided for @signOutAllConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Every device signed in to your account, this one included, will need to sign in again.'**
  String get signOutAllConfirmMessage;

  /// No description provided for @homeAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts today'**
  String get homeAlerts;

  /// No description provided for @homeNotices.
  ///
  /// In en, this message translates to:
  /// **'Latest notices'**
  String get homeNotices;

  /// No description provided for @homeStatewide.
  ///
  /// In en, this message translates to:
  /// **'Statewide'**
  String get homeStatewide;

  /// No description provided for @homeNothingNew.
  ///
  /// In en, this message translates to:
  /// **'Nothing new today'**
  String get homeNothingNew;

  /// No description provided for @homeNothingNewMessage.
  ///
  /// In en, this message translates to:
  /// **'Pull down to check again.'**
  String get homeNothingNewMessage;
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
