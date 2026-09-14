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
}
