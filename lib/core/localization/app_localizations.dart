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

  /// No description provided for @homeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get homeQuickActions;

  /// App bar title of the all-notices list screen
  ///
  /// In en, this message translates to:
  /// **'Notices'**
  String get noticesTitle;

  /// Empty state title when there are no notices
  ///
  /// In en, this message translates to:
  /// **'No notices yet'**
  String get noticesEmpty;

  /// Empty state message below the notices empty title
  ///
  /// In en, this message translates to:
  /// **'Pull down to check again.'**
  String get noticesEmptyMessage;

  /// App bar title of the all-alerts list screen
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alertsTitle;

  /// Empty state title when there are no alerts
  ///
  /// In en, this message translates to:
  /// **'No alerts'**
  String get alertsEmpty;

  /// Empty state message below the alerts empty title
  ///
  /// In en, this message translates to:
  /// **'Pull down to check again.'**
  String get alertsEmptyMessage;

  /// App bar title of the notice detail screen
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get noticeDetailTitle;

  /// Label for the notice title field
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get noticeDetailFieldTitle;

  /// Label for the notice category field
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get noticeDetailFieldCategory;

  /// Label for the notice priority field
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get noticeDetailFieldPriority;

  /// Label for the notice published date field
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get noticeDetailFieldPublishedAt;

  /// Label for the notice expiry date field
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get noticeDetailFieldExpiresAt;

  /// Label for the notice body content section
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get noticeDetailFieldBody;

  /// Link text to open the all notices screen from the home
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get homeViewAllNotices;

  /// Link text to open the all alerts screen from the home
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get homeViewAllAlerts;

  /// Title of the market prices overview card
  ///
  /// In en, this message translates to:
  /// **'Price Overview'**
  String get marketSummaryTitle;

  /// Number of markets that reported prices today
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 market reporting today} other{{count} markets reporting today}}'**
  String marketReportingToday(int count);

  /// Number of crops tracked in the market summary
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 crop tracked} other{{count} crops tracked}}'**
  String marketCropsTracked(int count);

  /// Tab or filter chip for all markets
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get marketFilterAll;

  /// Tab or filter chip for favourite markets
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get marketFilterFavourites;

  /// Empty state title when no markets exist
  ///
  /// In en, this message translates to:
  /// **'No markets found'**
  String get marketEmpty;

  /// Empty state message when no markets exist
  ///
  /// In en, this message translates to:
  /// **'Pull down to check again.'**
  String get marketEmptyMessage;

  /// Empty state title for favourites list
  ///
  /// In en, this message translates to:
  /// **'No favourite markets yet'**
  String get marketFavouritesEmpty;

  /// Empty state message for favourites list
  ///
  /// In en, this message translates to:
  /// **'Tap the star icon on any market to add it to your favourites.'**
  String get marketFavouritesEmptyMessage;

  /// Prompt when guest tries to view favourites
  ///
  /// In en, this message translates to:
  /// **'Sign in to save favourite markets'**
  String get marketSignInForFavourites;

  /// Title of the price history screen
  ///
  /// In en, this message translates to:
  /// **'Price History'**
  String get marketPriceHistoryTitle;

  /// Empty state title when a market has no price records
  ///
  /// In en, this message translates to:
  /// **'No price records'**
  String get marketPriceHistoryEmpty;

  /// Empty state message when a market has no price records
  ///
  /// In en, this message translates to:
  /// **'No price history has been recorded for this market yet.'**
  String get marketPriceHistoryEmptyMessage;

  /// Label for market address
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get marketFieldAddress;

  /// Label for market type
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get marketFieldType;

  /// Label for market district
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get marketFieldDistrict;

  /// Label for market facilities
  ///
  /// In en, this message translates to:
  /// **'Facilities'**
  String get marketFieldFacilities;

  /// Label for market GPS location
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get marketFieldLocation;

  /// Price range min to max
  ///
  /// In en, this message translates to:
  /// **'Min ₹{min} · Max ₹{max}'**
  String marketPriceRange(String min, String max);

  /// Modal price per unit
  ///
  /// In en, this message translates to:
  /// **'₹{price} / {unit}'**
  String marketPricePerUnit(String price, String unit);

  /// No description provided for @searchCrops.
  ///
  /// In en, this message translates to:
  /// **'Search crops...'**
  String get searchCrops;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @cropRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Crop Recommendations'**
  String get cropRecommendations;

  /// No description provided for @cropRecommendationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find the best crops for your district and season'**
  String get cropRecommendationsSubtitle;

  /// No description provided for @noCropsFound.
  ///
  /// In en, this message translates to:
  /// **'No crops found'**
  String get noCropsFound;

  /// No description provided for @tryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filter options'**
  String get tryAdjustingFilters;

  /// Duration of crop growth cycle in days
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String cropDurationDays(int count);

  /// No description provided for @cropDetails.
  ///
  /// In en, this message translates to:
  /// **'Crop Details'**
  String get cropDetails;

  /// No description provided for @cropAdvisory.
  ///
  /// In en, this message translates to:
  /// **'Advisory'**
  String get cropAdvisory;

  /// No description provided for @cropFertilizers.
  ///
  /// In en, this message translates to:
  /// **'Fertilizers'**
  String get cropFertilizers;

  /// No description provided for @cropCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get cropCalendar;

  /// No description provided for @cropVarieties.
  ///
  /// In en, this message translates to:
  /// **'Varieties'**
  String get cropVarieties;

  /// No description provided for @cropPrices.
  ///
  /// In en, this message translates to:
  /// **'Prices'**
  String get cropPrices;

  /// No description provided for @localName.
  ///
  /// In en, this message translates to:
  /// **'Local name'**
  String get localName;

  /// No description provided for @noAdvisoryAvailable.
  ///
  /// In en, this message translates to:
  /// **'No advisory available'**
  String get noAdvisoryAvailable;

  /// No description provided for @noAdvisorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Advisory information for this crop is not available yet'**
  String get noAdvisorySubtitle;

  /// No description provided for @advisorySeason.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get advisorySeason;

  /// No description provided for @sowingWindow.
  ///
  /// In en, this message translates to:
  /// **'Sowing window'**
  String get sowingWindow;

  /// No description provided for @harvestWindow.
  ///
  /// In en, this message translates to:
  /// **'Harvest window'**
  String get harvestWindow;

  /// No description provided for @temperatureRange.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperatureRange;

  /// No description provided for @rainfallRequirement.
  ///
  /// In en, this message translates to:
  /// **'Rainfall'**
  String get rainfallRequirement;

  /// No description provided for @soilTypes.
  ///
  /// In en, this message translates to:
  /// **'Soil types'**
  String get soilTypes;

  /// No description provided for @soilPh.
  ///
  /// In en, this message translates to:
  /// **'Soil pH'**
  String get soilPh;

  /// No description provided for @soilDrainage.
  ///
  /// In en, this message translates to:
  /// **'Drainage'**
  String get soilDrainage;

  /// No description provided for @sowingMethod.
  ///
  /// In en, this message translates to:
  /// **'Sowing method'**
  String get sowingMethod;

  /// No description provided for @seedRate.
  ///
  /// In en, this message translates to:
  /// **'Seed rate'**
  String get seedRate;

  /// No description provided for @plantSpacing.
  ///
  /// In en, this message translates to:
  /// **'Spacing'**
  String get plantSpacing;

  /// No description provided for @landPreparation.
  ///
  /// In en, this message translates to:
  /// **'Land preparation'**
  String get landPreparation;

  /// No description provided for @weedManagement.
  ///
  /// In en, this message translates to:
  /// **'Weed management'**
  String get weedManagement;

  /// No description provided for @advisoryPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get advisoryPractice;

  /// No description provided for @noFertilizersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No fertilizer recommendations'**
  String get noFertilizersAvailable;

  /// No description provided for @noFertilizersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer schedules for this crop are not available yet'**
  String get noFertilizersSubtitle;

  /// No description provided for @fertilizerGroup.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer Schedule'**
  String get fertilizerGroup;

  /// No description provided for @cropCalendarSchedule.
  ///
  /// In en, this message translates to:
  /// **'Calendar Schedule'**
  String get cropCalendarSchedule;

  /// No description provided for @cropCalendarActiveMessage.
  ///
  /// In en, this message translates to:
  /// **'Follow the monthly crop advisory and practices for optimal yield.'**
  String get cropCalendarActiveMessage;

  /// No description provided for @noVarietiesFound.
  ///
  /// In en, this message translates to:
  /// **'No varieties recorded'**
  String get noVarietiesFound;

  /// No description provided for @noVarietiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Varieties for this crop have not been documented yet'**
  String get noVarietiesSubtitle;

  /// No description provided for @varietyName.
  ///
  /// In en, this message translates to:
  /// **'Variety name'**
  String get varietyName;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @expectedYield.
  ///
  /// In en, this message translates to:
  /// **'Expected yield'**
  String get expectedYield;

  /// No description provided for @noPricesReported.
  ///
  /// In en, this message translates to:
  /// **'No market prices reported'**
  String get noPricesReported;

  /// No description provided for @noPricesReportedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No recent market prices have been recorded for this crop'**
  String get noPricesReportedSubtitle;

  /// No description provided for @reportingDate.
  ///
  /// In en, this message translates to:
  /// **'Reporting date'**
  String get reportingDate;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price range'**
  String get priceRange;

  /// No description provided for @recommendationParameters.
  ///
  /// In en, this message translates to:
  /// **'Recommendation Parameters'**
  String get recommendationParameters;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @sowingMonth.
  ///
  /// In en, this message translates to:
  /// **'Sowing month'**
  String get sowingMonth;

  /// No description provided for @areaHectares.
  ///
  /// In en, this message translates to:
  /// **'Area (ha)'**
  String get areaHectares;

  /// No description provided for @getRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Get Recommendations'**
  String get getRecommendations;

  /// No description provided for @noRecommendationsFound.
  ///
  /// In en, this message translates to:
  /// **'No recommendations found'**
  String get noRecommendationsFound;

  /// No description provided for @tryDifferentMonthOrDistrict.
  ///
  /// In en, this message translates to:
  /// **'Try selecting a different district or sowing month'**
  String get tryDifferentMonthOrDistrict;

  /// No description provided for @recommendedCropsList.
  ///
  /// In en, this message translates to:
  /// **'Recommended Crops'**
  String get recommendedCropsList;

  /// No description provided for @suitability.
  ///
  /// In en, this message translates to:
  /// **'Suitability'**
  String get suitability;

  /// No description provided for @activeFarms.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeFarms;

  /// No description provided for @archivedFarms.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archivedFarms;

  /// No description provided for @noFarmsFound.
  ///
  /// In en, this message translates to:
  /// **'No farms found'**
  String get noFarmsFound;

  /// No description provided for @noArchivedFarmsFound.
  ///
  /// In en, this message translates to:
  /// **'No archived farms found'**
  String get noArchivedFarmsFound;

  /// No description provided for @addFarmPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to add your first farm.'**
  String get addFarmPrompt;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @addFarm.
  ///
  /// In en, this message translates to:
  /// **'Add Farm'**
  String get addFarm;

  /// No description provided for @editFarm.
  ///
  /// In en, this message translates to:
  /// **'Edit Farm'**
  String get editFarm;

  /// No description provided for @farmName.
  ///
  /// In en, this message translates to:
  /// **'Farm Name'**
  String get farmName;

  /// No description provided for @village.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get village;

  /// No description provided for @soilType.
  ///
  /// In en, this message translates to:
  /// **'Soil Type'**
  String get soilType;

  /// No description provided for @irrigationMethod.
  ///
  /// In en, this message translates to:
  /// **'Irrigation Method'**
  String get irrigationMethod;

  /// No description provided for @landOwnership.
  ///
  /// In en, this message translates to:
  /// **'Land Ownership'**
  String get landOwnership;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @invalidArea.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid area in hectares (greater than 0)'**
  String get invalidArea;

  /// No description provided for @createFarm.
  ///
  /// In en, this message translates to:
  /// **'Create Farm'**
  String get createFarm;

  /// No description provided for @updateFarm.
  ///
  /// In en, this message translates to:
  /// **'Update Farm'**
  String get updateFarm;

  /// No description provided for @farmCreated.
  ///
  /// In en, this message translates to:
  /// **'Farm added successfully'**
  String get farmCreated;

  /// No description provided for @farmUpdated.
  ///
  /// In en, this message translates to:
  /// **'Farm updated successfully'**
  String get farmUpdated;

  /// No description provided for @farmDeleted.
  ///
  /// In en, this message translates to:
  /// **'Farm deleted successfully'**
  String get farmDeleted;

  /// No description provided for @farmDetails.
  ///
  /// In en, this message translates to:
  /// **'Farm Details'**
  String get farmDetails;

  /// No description provided for @deleteFarmConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Farm?'**
  String get deleteFarmConfirmTitle;

  /// No description provided for @deleteFarmConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this farm? This action cannot be undone.'**
  String get deleteFarmConfirmMessage;

  /// No description provided for @noCropsOnFarm.
  ///
  /// In en, this message translates to:
  /// **'No crops recorded'**
  String get noCropsOnFarm;

  /// No description provided for @addCropPrompt.
  ///
  /// In en, this message translates to:
  /// **'Add crops to track growth, season, and yields.'**
  String get addCropPrompt;

  /// No description provided for @addCrop.
  ///
  /// In en, this message translates to:
  /// **'Add Crop'**
  String get addCrop;

  /// No description provided for @cropName.
  ///
  /// In en, this message translates to:
  /// **'Crop Name'**
  String get cropName;

  /// No description provided for @season.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get season;

  /// No description provided for @sownOn.
  ///
  /// In en, this message translates to:
  /// **'Sown on'**
  String get sownOn;

  /// No description provided for @expectedHarvest.
  ///
  /// In en, this message translates to:
  /// **'Expected harvest'**
  String get expectedHarvest;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @netProfit.
  ///
  /// In en, this message translates to:
  /// **'Net Profit'**
  String get netProfit;

  /// No description provided for @financeSummary.
  ///
  /// In en, this message translates to:
  /// **'Finance Summary'**
  String get financeSummary;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactionsFound;

  /// No description provided for @addTransactionPrompt.
  ///
  /// In en, this message translates to:
  /// **'Add income or expense transactions to track farm finances.'**
  String get addTransactionPrompt;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @transactionAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount (₹)'**
  String get transactionAmount;

  /// No description provided for @transactionCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get transactionCategory;

  /// No description provided for @transactionDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get transactionDate;

  /// No description provided for @transactionDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get transactionDescription;

  /// No description provided for @transactionInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than 0'**
  String get transactionInvalidAmount;

  /// No description provided for @transactionAdded.
  ///
  /// In en, this message translates to:
  /// **'Transaction added'**
  String get transactionAdded;

  /// No description provided for @farmCropCrop.
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get farmCropCrop;

  /// No description provided for @farmCropStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get farmCropStatus;

  /// No description provided for @farmCropSownOn.
  ///
  /// In en, this message translates to:
  /// **'Sown on'**
  String get farmCropSownOn;

  /// No description provided for @farmCropAdded.
  ///
  /// In en, this message translates to:
  /// **'Crop added'**
  String get farmCropAdded;

  /// No description provided for @noPhotosFound.
  ///
  /// In en, this message translates to:
  /// **'No photos uploaded'**
  String get noPhotosFound;

  /// No description provided for @noPhotosSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload photos to monitor your farm progress.'**
  String get noPhotosSubtitle;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get uploadPhoto;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @unarchive.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get unarchive;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @devices.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devices;

  /// No description provided for @deviceDetail.
  ///
  /// In en, this message translates to:
  /// **'Device Detail'**
  String get deviceDetail;

  /// No description provided for @soilSensorAccount.
  ///
  /// In en, this message translates to:
  /// **'Soil Sensor Account'**
  String get soilSensorAccount;

  /// No description provided for @soilSensorAccountLinked.
  ///
  /// In en, this message translates to:
  /// **'Linked'**
  String get soilSensorAccountLinked;

  /// No description provided for @soilSensorAccountNotLinked.
  ///
  /// In en, this message translates to:
  /// **'Not Linked'**
  String get soilSensorAccountNotLinked;

  /// No description provided for @linkAccount.
  ///
  /// In en, this message translates to:
  /// **'Link Account'**
  String get linkAccount;

  /// No description provided for @unlinkAccount.
  ///
  /// In en, this message translates to:
  /// **'Unlink Account'**
  String get unlinkAccount;

  /// No description provided for @syncDevices.
  ///
  /// In en, this message translates to:
  /// **'Sync Devices'**
  String get syncDevices;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// No description provided for @syncQueued.
  ///
  /// In en, this message translates to:
  /// **'Sync queued successfully'**
  String get syncQueued;

  /// No description provided for @noDevicesFound.
  ///
  /// In en, this message translates to:
  /// **'No IoT devices found'**
  String get noDevicesFound;

  /// No description provided for @noDevicesFoundDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect a soil sensor account or register devices to see sensor readings.'**
  String get noDevicesFoundDesc;

  /// No description provided for @deviceOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get deviceOnline;

  /// No description provided for @deviceOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get deviceOffline;

  /// No description provided for @sensors.
  ///
  /// In en, this message translates to:
  /// **'Sensors'**
  String get sensors;

  /// No description provided for @readings.
  ///
  /// In en, this message translates to:
  /// **'Readings'**
  String get readings;

  /// No description provided for @noReadingsFound.
  ///
  /// In en, this message translates to:
  /// **'No readings recorded for this period.'**
  String get noReadingsFound;

  /// No description provided for @serialNumber.
  ///
  /// In en, this message translates to:
  /// **'Serial Number'**
  String get serialNumber;

  /// No description provided for @hardwareModel.
  ///
  /// In en, this message translates to:
  /// **'Hardware Model'**
  String get hardwareModel;

  /// No description provided for @batteryLevel.
  ///
  /// In en, this message translates to:
  /// **'Battery Level'**
  String get batteryLevel;

  /// No description provided for @lastSync.
  ///
  /// In en, this message translates to:
  /// **'Last Sync'**
  String get lastSync;

  /// No description provided for @lastReading.
  ///
  /// In en, this message translates to:
  /// **'Last Reading'**
  String get lastReading;

  /// No description provided for @days7.
  ///
  /// In en, this message translates to:
  /// **'7 Days'**
  String get days7;

  /// No description provided for @days14.
  ///
  /// In en, this message translates to:
  /// **'14 Days'**
  String get days14;

  /// No description provided for @days30.
  ///
  /// In en, this message translates to:
  /// **'30 Days'**
  String get days30;

  /// No description provided for @unlinkConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlink Soil Sensor Account?'**
  String get unlinkConfirmTitle;

  /// No description provided for @unlinkConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unlink your soil sensor account? IoT readings will no longer sync automatically.'**
  String get unlinkConfirmMessage;

  /// No description provided for @soilSensUsername.
  ///
  /// In en, this message translates to:
  /// **'SoilSens Username'**
  String get soilSensUsername;

  /// No description provided for @soilSensPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get soilSensPassword;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// App bar title of the add_farm screen
  ///
  /// In en, this message translates to:
  /// **'Add Farm'**
  String get farmAddFarmTitle;

  /// App bar title of the edit_farm screen
  ///
  /// In en, this message translates to:
  /// **'Edit Farm'**
  String get farmEditFarmTitle;

  /// Label of the name input
  ///
  /// In en, this message translates to:
  /// **'Farm Name'**
  String get farmAddFarmName;

  /// Label of the area_ha input
  ///
  /// In en, this message translates to:
  /// **'Area (ha)'**
  String get farmAddFarmAreaHa;

  /// Label of the block_id input
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get farmAddFarmBlockId;

  /// Label of the village input
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get farmAddFarmVillage;

  /// Label of the address input
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get farmAddFarmAddress;

  /// Label of the soil_type input
  ///
  /// In en, this message translates to:
  /// **'Soil Type'**
  String get farmAddFarmSoilType;

  /// Label of the irrigation_type input
  ///
  /// In en, this message translates to:
  /// **'Irrigation Method'**
  String get farmAddFarmIrrigationType;

  /// Label of the ownership input
  ///
  /// In en, this message translates to:
  /// **'Land Ownership'**
  String get farmAddFarmOwnership;

  /// Label of the latitude input
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get farmAddFarmLatitude;

  /// Label of the longitude input
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get farmAddFarmLongitude;

  /// Shown when the farm form was sent
  ///
  /// In en, this message translates to:
  /// **'Farm created.'**
  String get farmAddFarmDone;

  /// Label of the name input
  ///
  /// In en, this message translates to:
  /// **'Farm Name'**
  String get farmEditFarmName;

  /// Label of the area_ha input
  ///
  /// In en, this message translates to:
  /// **'Area (ha)'**
  String get farmEditFarmAreaHa;

  /// Label of the block_id input
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get farmEditFarmBlockId;

  /// Label of the village input
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get farmEditFarmVillage;

  /// Label of the address input
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get farmEditFarmAddress;

  /// Label of the soil_type input
  ///
  /// In en, this message translates to:
  /// **'Soil Type'**
  String get farmEditFarmSoilType;

  /// Label of the irrigation_type input
  ///
  /// In en, this message translates to:
  /// **'Irrigation Method'**
  String get farmEditFarmIrrigationType;

  /// Label of the ownership input
  ///
  /// In en, this message translates to:
  /// **'Land Ownership'**
  String get farmEditFarmOwnership;

  /// Label of the latitude input
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get farmEditFarmLatitude;

  /// Label of the longitude input
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get farmEditFarmLongitude;

  /// Shown when the farm detail form was sent
  ///
  /// In en, this message translates to:
  /// **'Farm Detail updated.'**
  String get farmEditFarmDone;

  /// App bar title of the shipments screen
  ///
  /// In en, this message translates to:
  /// **'Shipments'**
  String get shipmentsTitle;

  /// Title of the ShipmentModel list
  ///
  /// In en, this message translates to:
  /// **'Shipments'**
  String get shipmentsList;

  /// Shown when there is no ShipmentModel
  ///
  /// In en, this message translates to:
  /// **'No shipments yet'**
  String get shipmentsEmpty;

  /// Label of the number row
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get shipmentsNumber;

  /// Label of the requestedAt row
  ///
  /// In en, this message translates to:
  /// **'Requested At'**
  String get shipmentsRequestedAt;

  /// Label of the acceptedAt row
  ///
  /// In en, this message translates to:
  /// **'Accepted At'**
  String get shipmentsAcceptedAt;

  /// Label of the rejectedAt row
  ///
  /// In en, this message translates to:
  /// **'Rejected At'**
  String get shipmentsRejectedAt;

  /// App bar title of the shipment_detail screen
  ///
  /// In en, this message translates to:
  /// **'Shipment'**
  String get shipmentsShipmentDetailTitle;

  /// A true value
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get valueYes;

  /// A false value
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get valueNo;

  /// Title of the ShipmentModel card
  ///
  /// In en, this message translates to:
  /// **'Shipment Details'**
  String get shipmentsShipmentDetailDetails;

  /// Label of the id row
  ///
  /// In en, this message translates to:
  /// **'Id'**
  String get shipmentsShipmentDetailId;

  /// Label of the number row
  ///
  /// In en, this message translates to:
  /// **'Shipment'**
  String get shipmentsShipmentDetailNumber;

  /// Label of the rejectReason row
  ///
  /// In en, this message translates to:
  /// **'Reject reason'**
  String get shipmentsShipmentDetailRejectReason;

  /// Label of the requestedAt row
  ///
  /// In en, this message translates to:
  /// **'Requested on'**
  String get shipmentsShipmentDetailRequestedAt;

  /// Label of the acceptedAt row
  ///
  /// In en, this message translates to:
  /// **'Accepted on'**
  String get shipmentsShipmentDetailAcceptedAt;

  /// Label of the rejectedAt row
  ///
  /// In en, this message translates to:
  /// **'Rejected on'**
  String get shipmentsShipmentDetailRejectedAt;

  /// Label of the pickedUpAt row
  ///
  /// In en, this message translates to:
  /// **'Picked up on'**
  String get shipmentsShipmentDetailPickedUpAt;

  /// Label of the reachedAt row
  ///
  /// In en, this message translates to:
  /// **'Reached on'**
  String get shipmentsShipmentDetailReachedAt;

  /// Label of the receivedAt row
  ///
  /// In en, this message translates to:
  /// **'Received on'**
  String get shipmentsShipmentDetailReceivedAt;

  /// Title of the status card
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get shipmentsShipmentDetailStatus;

  /// Label of the status.value row
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get shipmentsShipmentDetailStatusValue;

  /// Label of the status.label row
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get shipmentsShipmentDetailStatusLabel;

  /// Title of the farmer card
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get shipmentsShipmentDetailFarmer;

  /// Label of the farmer.id row
  ///
  /// In en, this message translates to:
  /// **'Id'**
  String get shipmentsShipmentDetailFarmerId;

  /// Label of the farmer.code row
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get shipmentsShipmentDetailFarmerCode;

  /// Label of the farmer.name row
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get shipmentsShipmentDetailFarmerName;

  /// Title of the vendor card
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get shipmentsShipmentDetailVendor;

  /// Label of the vendor.id row
  ///
  /// In en, this message translates to:
  /// **'Id'**
  String get shipmentsShipmentDetailVendorId;

  /// Label of the vendor.code row
  ///
  /// In en, this message translates to:
  /// **'Vendor code'**
  String get shipmentsShipmentDetailVendorCode;

  /// Label of the vendor.name row
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get shipmentsShipmentDetailVendorName;

  /// Title of the pickup card
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get shipmentsShipmentDetailPickup;

  /// Label of the pickup.address row
  ///
  /// In en, this message translates to:
  /// **'Pickup address'**
  String get shipmentsShipmentDetailPickupAddress;

  /// Label of the pickup.preferredOn row
  ///
  /// In en, this message translates to:
  /// **'Preferred pickup'**
  String get shipmentsShipmentDetailPickupPreferredOn;

  /// Label of the pickup.late row
  ///
  /// In en, this message translates to:
  /// **'Picked up late'**
  String get shipmentsShipmentDetailPickupLate;

  /// Title of the vehicle card
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get shipmentsShipmentDetailVehicle;

  /// Label of the vehicle.id row
  ///
  /// In en, this message translates to:
  /// **'Id'**
  String get shipmentsShipmentDetailVehicleId;

  /// Label of the vehicle.registrationNumber row
  ///
  /// In en, this message translates to:
  /// **'Registration number'**
  String get shipmentsShipmentDetailVehicleRegistrationNumber;

  /// Title of the driver card
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get shipmentsShipmentDetailDriver;

  /// Label of the driver.id row
  ///
  /// In en, this message translates to:
  /// **'Id'**
  String get shipmentsShipmentDetailDriverId;

  /// Label of the driver.code row
  ///
  /// In en, this message translates to:
  /// **'Driver code'**
  String get shipmentsShipmentDetailDriverCode;

  /// Label of the driver.name row
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get shipmentsShipmentDetailDriverName;

  /// Label of the driver.phone row
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get shipmentsShipmentDetailDriverPhone;

  /// App bar title of the request_shipment screen
  ///
  /// In en, this message translates to:
  /// **'Request Shipment'**
  String get shipmentsRequestShipmentTitle;

  /// No description provided for @shipmentsActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get shipmentsActive;

  /// No description provided for @shipmentsHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get shipmentsHistory;

  /// No description provided for @shipmentsRequest.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get shipmentsRequest;

  /// No description provided for @shipmentsStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get shipmentsStatus;

  /// No description provided for @shipmentsVendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get shipmentsVendor;

  /// No description provided for @shipmentsPickupOn.
  ///
  /// In en, this message translates to:
  /// **'Pickup on'**
  String get shipmentsPickupOn;

  /// No description provided for @shipmentsItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get shipmentsItems;

  /// No description provided for @shipmentsActiveEmpty.
  ///
  /// In en, this message translates to:
  /// **'No active shipments'**
  String get shipmentsActiveEmpty;

  /// No description provided for @shipmentsHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No past shipments'**
  String get shipmentsHistoryEmpty;

  /// Label of the cancelledAt row
  ///
  /// In en, this message translates to:
  /// **'Cancelled on'**
  String get shipmentsShipmentDetailCancelledAt;

  /// Label of the cancelReason row
  ///
  /// In en, this message translates to:
  /// **'Cancel reason'**
  String get shipmentsShipmentDetailCancelReason;

  /// Label of the notes row
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get shipmentsShipmentDetailNotes;

  /// No description provided for @shipmentsPicked.
  ///
  /// In en, this message translates to:
  /// **'Picked'**
  String get shipmentsPicked;

  /// No description provided for @shipmentsReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get shipmentsReceived;

  /// No description provided for @shipmentsVehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle type'**
  String get shipmentsVehicleType;

  /// No description provided for @shipmentsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel shipment'**
  String get shipmentsCancel;

  /// No description provided for @shipmentsCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this shipment?'**
  String get shipmentsCancelTitle;

  /// No description provided for @shipmentsCancelMessage.
  ///
  /// In en, this message translates to:
  /// **'The vendor will be told it is cancelled.'**
  String get shipmentsCancelMessage;

  /// No description provided for @shipmentsCancelReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get shipmentsCancelReason;

  /// No description provided for @shipmentsCancelled.
  ///
  /// In en, this message translates to:
  /// **'Shipment cancelled'**
  String get shipmentsCancelled;

  /// No description provided for @shipmentsPickupDistrict.
  ///
  /// In en, this message translates to:
  /// **'Pickup district'**
  String get shipmentsPickupDistrict;

  /// No description provided for @shipmentsPickupAddress.
  ///
  /// In en, this message translates to:
  /// **'Pickup address'**
  String get shipmentsPickupAddress;

  /// No description provided for @shipmentsNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get shipmentsNotes;

  /// No description provided for @shipmentsItem.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get shipmentsItem;

  /// No description provided for @shipmentsCrop.
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get shipmentsCrop;

  /// No description provided for @shipmentsQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get shipmentsQuantity;

  /// No description provided for @shipmentsUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get shipmentsUnit;

  /// No description provided for @shipmentsAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get shipmentsAddItem;

  /// No description provided for @shipmentsRemoveItem.
  ///
  /// In en, this message translates to:
  /// **'Remove item'**
  String get shipmentsRemoveItem;

  /// No description provided for @shipmentsInvalidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter a quantity greater than 0'**
  String get shipmentsInvalidQuantity;

  /// No description provided for @shipmentsSend.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get shipmentsSend;

  /// No description provided for @shipmentsRequested.
  ///
  /// In en, this message translates to:
  /// **'Shipment sent to the vendor'**
  String get shipmentsRequested;

  /// No description provided for @shipmentsFarmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get shipmentsFarmer;

  /// No description provided for @shipmentsReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get shipmentsReason;

  /// No description provided for @shipmentsAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get shipmentsAccept;

  /// No description provided for @shipmentsAcceptTitle.
  ///
  /// In en, this message translates to:
  /// **'Accept this shipment?'**
  String get shipmentsAcceptTitle;

  /// No description provided for @shipmentsAccepted.
  ///
  /// In en, this message translates to:
  /// **'Shipment accepted'**
  String get shipmentsAccepted;

  /// No description provided for @shipmentsAssignMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose the vehicle and driver who will pick it up.'**
  String get shipmentsAssignMessage;

  /// No description provided for @shipmentsOnTrip.
  ///
  /// In en, this message translates to:
  /// **'On a trip'**
  String get shipmentsOnTrip;

  /// No description provided for @shipmentsReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get shipmentsReject;

  /// No description provided for @shipmentsRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject this shipment?'**
  String get shipmentsRejectTitle;

  /// No description provided for @shipmentsRejectMessage.
  ///
  /// In en, this message translates to:
  /// **'The farmer will see your reason.'**
  String get shipmentsRejectMessage;

  /// No description provided for @shipmentsRejected.
  ///
  /// In en, this message translates to:
  /// **'Shipment rejected'**
  String get shipmentsRejected;

  /// No description provided for @shipmentsReassign.
  ///
  /// In en, this message translates to:
  /// **'Reassign'**
  String get shipmentsReassign;

  /// No description provided for @shipmentsReassignTitle.
  ///
  /// In en, this message translates to:
  /// **'Change vehicle or driver'**
  String get shipmentsReassignTitle;

  /// No description provided for @shipmentsReassigned.
  ///
  /// In en, this message translates to:
  /// **'Vehicle and driver updated'**
  String get shipmentsReassigned;

  /// No description provided for @shipmentsReceive.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get shipmentsReceive;

  /// No description provided for @shipmentsReceiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Record what you received'**
  String get shipmentsReceiveTitle;

  /// No description provided for @shipmentsReceiveMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter the quantity received for each item.'**
  String get shipmentsReceiveMessage;

  /// No description provided for @shipmentsReweigh.
  ///
  /// In en, this message translates to:
  /// **'Re-weigh'**
  String get shipmentsReweigh;

  /// No description provided for @shipmentsReweighTitle.
  ///
  /// In en, this message translates to:
  /// **'Re-weigh an item'**
  String get shipmentsReweighTitle;

  /// No description provided for @shipmentsReweighMessage.
  ///
  /// In en, this message translates to:
  /// **'Correct the received quantity of one item.'**
  String get shipmentsReweighMessage;

  /// No description provided for @shipmentsReweighed.
  ///
  /// In en, this message translates to:
  /// **'Re-weighed quantity saved'**
  String get shipmentsReweighed;

  /// No description provided for @shipmentsInvalidWeighed.
  ///
  /// In en, this message translates to:
  /// **'Enter 0 or more'**
  String get shipmentsInvalidWeighed;

  /// No description provided for @shipmentsSold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get shipmentsSold;

  /// No description provided for @shipmentsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get shipmentsSave;

  /// No description provided for @shipmentsRecordPicked.
  ///
  /// In en, this message translates to:
  /// **'Record picked'**
  String get shipmentsRecordPicked;

  /// No description provided for @shipmentsRecordPickedTitle.
  ///
  /// In en, this message translates to:
  /// **'Record picked quantities'**
  String get shipmentsRecordPickedTitle;

  /// No description provided for @shipmentsRecordPickedMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter what you loaded for each item.'**
  String get shipmentsRecordPickedMessage;

  /// No description provided for @shipmentsPickedSaved.
  ///
  /// In en, this message translates to:
  /// **'Picked quantities saved'**
  String get shipmentsPickedSaved;

  /// No description provided for @shipmentsConfirmPickup.
  ///
  /// In en, this message translates to:
  /// **'Confirm pickup'**
  String get shipmentsConfirmPickup;

  /// No description provided for @shipmentsPickupTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm the pickup'**
  String get shipmentsPickupTitle;

  /// No description provided for @shipmentsPickupMessage.
  ///
  /// In en, this message translates to:
  /// **'Check the picked quantity of each item. The shipment will be on its way.'**
  String get shipmentsPickupMessage;

  /// No description provided for @shipmentsPickedUp.
  ///
  /// In en, this message translates to:
  /// **'Pickup confirmed'**
  String get shipmentsPickedUp;

  /// No description provided for @shipmentsMarkReached.
  ///
  /// In en, this message translates to:
  /// **'Reached'**
  String get shipmentsMarkReached;

  /// No description provided for @shipmentsReachTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark as reached?'**
  String get shipmentsReachTitle;

  /// No description provided for @shipmentsReachMessage.
  ///
  /// In en, this message translates to:
  /// **'The vendor will record what was received.'**
  String get shipmentsReachMessage;

  /// No description provided for @shipmentsReachedDone.
  ///
  /// In en, this message translates to:
  /// **'Marked as reached'**
  String get shipmentsReachedDone;
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
