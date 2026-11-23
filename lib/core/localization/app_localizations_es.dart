// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Flutter Kit';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get createAccount => 'Crear una cuenta';

  @override
  String get username => 'Usuario';

  @override
  String get password => 'Contraseña';

  @override
  String get email => 'Correo electrónico';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get signInToContinue => 'Inicia sesión para continuar';

  @override
  String get alreadyHaveAccount => 'Ya tengo una cuenta';

  @override
  String get home => 'Inicio';

  @override
  String get products => 'Productos';

  @override
  String get profile => 'Perfil';

  @override
  String get search => 'Buscar productos';

  @override
  String get categories => 'Categorías';

  @override
  String get featured => 'Destacados';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get browse => 'Explorar';

  @override
  String get greetingMorning => 'Buenos días';

  @override
  String get greetingAfternoon => 'Buenas tardes';

  @override
  String get greetingEvening => 'Buenas noches';

  @override
  String inStockCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count en stock',
      one: '1 en stock',
      zero: 'Agotado',
    );
    return '$_temp0';
  }

  @override
  String percentOff(String percent) {
    return '$percent% de descuento';
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
  String get tryAgain => 'Reintentar';

  @override
  String get goHome => 'Ir al inicio';

  @override
  String get clearFilters => 'Quitar filtros';

  @override
  String get noMatches => 'Sin resultados';

  @override
  String get noProducts => 'Todavía no hay productos';

  @override
  String showingSavedData(String message) {
    return '$message Mostrando datos guardados.';
  }

  @override
  String get errorNoConnection => 'Sin conexión a internet.';

  @override
  String get errorTimeout =>
      'La solicitud tardó demasiado. Inténtalo de nuevo.';

  @override
  String get errorServer => 'Algo salió mal de nuestro lado.';

  @override
  String get errorSessionExpired =>
      'Tu sesión ha expirado. Inicia sesión de nuevo.';

  @override
  String get errorUnknown => 'Algo salió mal. Inténtalo de nuevo.';

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
}
