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
}
