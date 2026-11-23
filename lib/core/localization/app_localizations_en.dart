// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flutter Kit';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get createAccount => 'Create an account';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get email => 'Email';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get alreadyHaveAccount => 'I already have an account';

  @override
  String get home => 'Home';

  @override
  String get products => 'Products';

  @override
  String get profile => 'Profile';

  @override
  String get search => 'Search products';

  @override
  String get categories => 'Categories';

  @override
  String get featured => 'Featured';

  @override
  String get seeAll => 'See all';

  @override
  String get browse => 'Browse';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String inStockCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count in stock',
      one: '1 in stock',
      zero: 'Sold out',
    );
    return '$_temp0';
  }

  @override
  String percentOff(String percent) {
    return '$percent% off';
  }

  @override
  String get market => 'Market';

  @override
  String get farms => 'Farms';

  @override
  String get schemes => 'Schemes';

  @override
  String get shipments => 'Shipments';

  @override
  String get production => 'Production';

  @override
  String get helpDesk => 'Help desk';

  @override
  String get crops => 'Crops';

  @override
  String get notices => 'Notices';

  @override
  String get manageNotices => 'Manage notices';

  @override
  String get manageAlerts => 'Manage alerts';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get comingSoonMessage =>
      'This section is being built and will be available soon.';

  @override
  String get more => 'More';

  @override
  String get done => 'Done';

  @override
  String get imageUnavailable => 'Image unavailable';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied';

  @override
  String get readMore => 'more';

  @override
  String get uiGallery => 'UI gallery';

  @override
  String get tryAgain => 'Try again';

  @override
  String get goHome => 'Go home';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get noMatches => 'No matches';

  @override
  String get noProducts => 'No products yet';

  @override
  String showingSavedData(String message) {
    return '$message Showing saved data.';
  }

  @override
  String get errorNoConnection => 'No internet connection.';

  @override
  String get errorTimeout => 'The request took too long. Please try again.';

  @override
  String get errorServer => 'Something went wrong on our side.';

  @override
  String get errorSessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';

  @override
  String get loginWithEmail => 'Email';

  @override
  String get loginWithPhone => 'Phone';

  @override
  String get loginPhone => 'Mobile number *';

  @override
  String get loginPhoneHint => '10-digit mobile number';

  @override
  String get loginPhoneInvalid => 'Enter a 10-digit mobile number';

  @override
  String get loginOtpSend => 'Send OTP';

  @override
  String get loginOtp => 'OTP *';

  @override
  String get loginOtpHint => '6-digit code';

  @override
  String get loginOtpInvalid => 'Enter the 6-digit code';

  @override
  String get loginOtpVerify => 'Verify';

  @override
  String loginOtpSentTo(String phone) {
    return 'We sent a code to $phone';
  }

  @override
  String loginOtpExpiresIn(String time) {
    return 'Code expires in $time';
  }

  @override
  String get loginOtpExpired => 'The code has expired';

  @override
  String get loginOtpResend => 'Resend OTP';

  @override
  String get loginOtpChangeNumber => 'Change number';

  @override
  String get authChangePasswordTitle => 'Change password';

  @override
  String fieldEnter(String field) {
    return 'Enter $field';
  }

  @override
  String fieldSelect(String field) {
    return 'Select $field';
  }

  @override
  String fieldChoose(String field) {
    return 'Choose $field';
  }

  @override
  String fieldRequired(String field) {
    return '$field is required';
  }

  @override
  String get fieldInvalidNumber => 'Enter a valid number';

  @override
  String get loading => 'Loading...';

  @override
  String get formSubmit => 'Submit';

  @override
  String get authChangePasswordCurrentPassword => 'Current password';

  @override
  String get authChangePasswordPassword => 'New password';

  @override
  String get authChangePasswordPasswordConfirmation => 'Confirm new password';

  @override
  String get authChangePasswordDone =>
      'Password changed. Other devices have been signed out.';

  @override
  String get authChangePasswordRequired => 'Set a new password to continue.';

  @override
  String get signOutAllDevices => 'Sign out of all devices';

  @override
  String get signOutConfirmTitle => 'Sign out?';

  @override
  String get signOutConfirmMessage =>
      'You will need to sign in again on this device.';

  @override
  String get signOutAllConfirmTitle => 'Sign out of all devices?';

  @override
  String get signOutAllConfirmMessage =>
      'Every device signed in to your account, this one included, will need to sign in again.';

  @override
  String get homeAlerts => 'Alerts today';

  @override
  String get homeNotices => 'Latest notices';

  @override
  String get homeStatewide => 'Statewide';

  @override
  String get homeNothingNew => 'Nothing new today';

  @override
  String get homeNothingNewMessage => 'Pull down to check again.';

  @override
  String get homeQuickActions => 'Quick actions';

  @override
  String get noticesTitle => 'Notices';

  @override
  String get noticesEmpty => 'No notices yet';

  @override
  String get noticesEmptyMessage => 'Pull down to check again.';

  @override
  String get alertsTitle => 'Alerts';

  @override
  String get alertsEmpty => 'No alerts';

  @override
  String get alertsEmptyMessage => 'Pull down to check again.';

  @override
  String get noticeDetailTitle => 'Notice';

  @override
  String get noticeDetailFieldTitle => 'Title';

  @override
  String get noticeDetailFieldCategory => 'Category';

  @override
  String get noticeDetailFieldPriority => 'Priority';

  @override
  String get noticeDetailFieldPublishedAt => 'Published';

  @override
  String get noticeDetailFieldExpiresAt => 'Expires';

  @override
  String get noticeDetailFieldBody => 'Content';

  @override
  String get homeViewAllNotices => 'View all';

  @override
  String get homeViewAllAlerts => 'View all';

  @override
  String get marketSummaryTitle => 'Price Overview';

  @override
  String marketReportingToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count markets reporting today',
      one: '1 market reporting today',
    );
    return '$_temp0';
  }

  @override
  String marketCropsTracked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count crops tracked',
      one: '1 crop tracked',
    );
    return '$_temp0';
  }

  @override
  String get marketFilterAll => 'All';

  @override
  String get marketFilterFavourites => 'Favourites';

  @override
  String get marketEmpty => 'No markets found';

  @override
  String get marketEmptyMessage => 'Pull down to check again.';

  @override
  String get marketFavouritesEmpty => 'No favourite markets yet';

  @override
  String get marketFavouritesEmptyMessage =>
      'Tap the star icon on any market to add it to your favourites.';

  @override
  String get marketSignInForFavourites => 'Sign in to save favourite markets';

  @override
  String get marketPriceHistoryTitle => 'Price History';

  @override
  String get marketPriceHistoryEmpty => 'No price records';

  @override
  String get marketPriceHistoryEmptyMessage =>
      'No price history has been recorded for this market yet.';

  @override
  String get marketFieldAddress => 'Address';

  @override
  String get marketFieldType => 'Type';

  @override
  String get marketFieldDistrict => 'District';

  @override
  String get marketFieldFacilities => 'Facilities';

  @override
  String get marketFieldLocation => 'Location';

  @override
  String marketPriceRange(String min, String max) {
    return 'Min ₹$min · Max ₹$max';
  }

  @override
  String marketPricePerUnit(String price, String unit) {
    return '₹$price / $unit';
  }

  @override
  String get searchCrops => 'Search crops...';

  @override
  String get all => 'All';

  @override
  String get cropRecommendations => 'Crop Recommendations';

  @override
  String get cropRecommendationsSubtitle =>
      'Find the best crops for your district and season';

  @override
  String get noCropsFound => 'No crops found';

  @override
  String get tryAdjustingFilters =>
      'Try adjusting your search or filter options';

  @override
  String cropDurationDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get cropDetails => 'Crop Details';

  @override
  String get cropAdvisory => 'Advisory';

  @override
  String get cropFertilizers => 'Fertilizers';

  @override
  String get cropCalendar => 'Calendar';

  @override
  String get cropVarieties => 'Varieties';

  @override
  String get cropPrices => 'Prices';

  @override
  String get localName => 'Local name';

  @override
  String get noAdvisoryAvailable => 'No advisory available';

  @override
  String get noAdvisorySubtitle =>
      'Advisory information for this crop is not available yet';

  @override
  String get advisorySeason => 'Season';

  @override
  String get sowingWindow => 'Sowing window';

  @override
  String get harvestWindow => 'Harvest window';

  @override
  String get temperatureRange => 'Temperature';

  @override
  String get rainfallRequirement => 'Rainfall';

  @override
  String get soilTypes => 'Soil types';

  @override
  String get soilPh => 'Soil pH';

  @override
  String get soilDrainage => 'Drainage';

  @override
  String get sowingMethod => 'Sowing method';

  @override
  String get seedRate => 'Seed rate';

  @override
  String get plantSpacing => 'Spacing';

  @override
  String get landPreparation => 'Land preparation';

  @override
  String get weedManagement => 'Weed management';

  @override
  String get advisoryPractice => 'Practice';

  @override
  String get noFertilizersAvailable => 'No fertilizer recommendations';

  @override
  String get noFertilizersSubtitle =>
      'Fertilizer schedules for this crop are not available yet';

  @override
  String get fertilizerGroup => 'Fertilizer Schedule';

  @override
  String get cropCalendarSchedule => 'Calendar Schedule';

  @override
  String get cropCalendarActiveMessage =>
      'Follow the monthly crop advisory and practices for optimal yield.';

  @override
  String get noVarietiesFound => 'No varieties recorded';

  @override
  String get noVarietiesSubtitle =>
      'Varieties for this crop have not been documented yet';

  @override
  String get varietyName => 'Variety name';

  @override
  String get duration => 'Duration';

  @override
  String get expectedYield => 'Expected yield';

  @override
  String get noPricesReported => 'No market prices reported';

  @override
  String get noPricesReportedSubtitle =>
      'No recent market prices have been recorded for this crop';

  @override
  String get reportingDate => 'Reporting date';

  @override
  String get priceRange => 'Price range';

  @override
  String get recommendationParameters => 'Recommendation Parameters';

  @override
  String get district => 'District';

  @override
  String get sowingMonth => 'Sowing month';

  @override
  String get areaHectares => 'Area (ha)';

  @override
  String get getRecommendations => 'Get Recommendations';

  @override
  String get noRecommendationsFound => 'No recommendations found';

  @override
  String get tryDifferentMonthOrDistrict =>
      'Try selecting a different district or sowing month';

  @override
  String get recommendedCropsList => 'Recommended Crops';

  @override
  String get suitability => 'Suitability';

  @override
  String get activeFarms => 'Active';

  @override
  String get archivedFarms => 'Archived';

  @override
  String get noFarmsFound => 'No farms found';

  @override
  String get noArchivedFarmsFound => 'No archived farms found';

  @override
  String get addFarmPrompt => 'Tap the button below to add your first farm.';

  @override
  String get archived => 'Archived';

  @override
  String get active => 'Active';

  @override
  String get addFarm => 'Add Farm';

  @override
  String get editFarm => 'Edit Farm';

  @override
  String get farmName => 'Farm Name';

  @override
  String get village => 'Village';

  @override
  String get soilType => 'Soil Type';

  @override
  String get irrigationMethod => 'Irrigation Method';

  @override
  String get landOwnership => 'Land Ownership';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get invalidArea =>
      'Please enter a valid area in hectares (greater than 0)';

  @override
  String get createFarm => 'Create Farm';

  @override
  String get updateFarm => 'Update Farm';

  @override
  String get farmCreated => 'Farm added successfully';

  @override
  String get farmUpdated => 'Farm updated successfully';

  @override
  String get farmDeleted => 'Farm deleted successfully';

  @override
  String get farmDetails => 'Farm Details';

  @override
  String get deleteFarmConfirmTitle => 'Delete Farm?';

  @override
  String get deleteFarmConfirmMessage =>
      'Are you sure you want to delete this farm? This action cannot be undone.';

  @override
  String get noCropsOnFarm => 'No crops recorded';

  @override
  String get addCropPrompt => 'Add crops to track growth, season, and yields.';

  @override
  String get addCrop => 'Add Crop';

  @override
  String get cropName => 'Crop Name';

  @override
  String get season => 'Season';

  @override
  String get sownOn => 'Sown on';

  @override
  String get expectedHarvest => 'Expected harvest';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get netProfit => 'Net Profit';

  @override
  String get financeSummary => 'Finance Summary';

  @override
  String get noTransactionsFound => 'No transactions found';

  @override
  String get addTransactionPrompt =>
      'Add income or expense transactions to track farm finances.';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get transactionAmount => 'Amount (₹)';

  @override
  String get transactionCategory => 'Category';

  @override
  String get transactionDate => 'Date';

  @override
  String get transactionDescription => 'Description';

  @override
  String get transactionInvalidAmount => 'Enter an amount greater than 0';

  @override
  String get transactionAdded => 'Transaction added';

  @override
  String get farmCropCrop => 'Crop';

  @override
  String get farmCropStatus => 'Status';

  @override
  String get farmCropSownOn => 'Sown on';

  @override
  String get farmCropAdded => 'Crop added';

  @override
  String get noPhotosFound => 'No photos uploaded';

  @override
  String get noPhotosSubtitle => 'Upload photos to monitor your farm progress.';

  @override
  String get uploadPhoto => 'Upload Photo';

  @override
  String get archive => 'Archive';

  @override
  String get unarchive => 'Unarchive';

  @override
  String get delete => 'Delete';

  @override
  String get transactions => 'Transactions';

  @override
  String get photos => 'Photos';

  @override
  String get add => 'Add';

  @override
  String get location => 'Location';

  @override
  String get address => 'Address';

  @override
  String get devices => 'Devices';

  @override
  String get deviceDetail => 'Device Detail';

  @override
  String get soilSensorAccount => 'Soil Sensor Account';

  @override
  String get soilSensorAccountLinked => 'Linked';

  @override
  String get soilSensorAccountNotLinked => 'Not Linked';

  @override
  String get linkAccount => 'Link Account';

  @override
  String get unlinkAccount => 'Unlink Account';

  @override
  String get syncDevices => 'Sync Devices';

  @override
  String get syncing => 'Syncing...';

  @override
  String get syncQueued => 'Sync queued successfully';

  @override
  String get noDevicesFound => 'No IoT devices found';

  @override
  String get noDevicesFoundDesc =>
      'Connect a soil sensor account or register devices to see sensor readings.';

  @override
  String get deviceOnline => 'Online';

  @override
  String get deviceOffline => 'Offline';

  @override
  String get sensors => 'Sensors';

  @override
  String get readings => 'Readings';

  @override
  String get noReadingsFound => 'No readings recorded for this period.';

  @override
  String get serialNumber => 'Serial Number';

  @override
  String get hardwareModel => 'Hardware Model';

  @override
  String get batteryLevel => 'Battery Level';

  @override
  String get lastSync => 'Last Sync';

  @override
  String get lastReading => 'Last Reading';

  @override
  String get days7 => '7 Days';

  @override
  String get days14 => '14 Days';

  @override
  String get days30 => '30 Days';

  @override
  String get unlinkConfirmTitle => 'Unlink Soil Sensor Account?';

  @override
  String get unlinkConfirmMessage =>
      'Are you sure you want to unlink your soil sensor account? IoT readings will no longer sync automatically.';

  @override
  String get soilSensUsername => 'SoilSens Username';

  @override
  String get soilSensPassword => 'Password';

  @override
  String get status => 'Status';

  @override
  String get farmAddFarmTitle => 'Add Farm';

  @override
  String get farmEditFarmTitle => 'Edit Farm';

  @override
  String get farmAddFarmName => 'Name';

  @override
  String get farmAddFarmAreaHa => 'Area Ha';

  @override
  String get farmAddFarmBlockId => 'Block';

  @override
  String get farmAddFarmVillage => 'Village';

  @override
  String get farmAddFarmAddress => 'Address';

  @override
  String get farmAddFarmSoilType => 'Soil Type';

  @override
  String get farmAddFarmIrrigationType => 'Irrigation Type';

  @override
  String get farmAddFarmOwnership => 'Ownership';

  @override
  String get farmAddFarmLatitude => 'Latitude';

  @override
  String get farmAddFarmLongitude => 'Longitude';

  @override
  String get farmAddFarmDone => 'Farm created.';

  @override
  String get farmEditFarmName => 'Name';

  @override
  String get farmEditFarmAreaHa => 'Area Ha';

  @override
  String get farmEditFarmBlockId => 'Block';

  @override
  String get farmEditFarmVillage => 'Village';

  @override
  String get farmEditFarmAddress => 'Address';

  @override
  String get farmEditFarmSoilType => 'Soil Type';

  @override
  String get farmEditFarmIrrigationType => 'Irrigation Type';

  @override
  String get farmEditFarmOwnership => 'Ownership';

  @override
  String get farmEditFarmLatitude => 'Latitude';

  @override
  String get farmEditFarmLongitude => 'Longitude';

  @override
  String get farmEditFarmDone => 'Farm Detail updated.';
}
