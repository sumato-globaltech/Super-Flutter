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

  @override
  String get homeQuickActions => 'Quick actions';

  @override
  String get noticesTitle => 'Avisos';

  @override
  String get noticesEmpty => 'No hay avisos aún';

  @override
  String get noticesEmptyMessage =>
      'Desliza hacia abajo para volver a comprobar.';

  @override
  String get alertsTitle => 'Alertas';

  @override
  String get alertsEmpty => 'Sin alertas';

  @override
  String get alertsEmptyMessage =>
      'Desliza hacia abajo para volver a comprobar.';

  @override
  String get noticeDetailTitle => 'Aviso';

  @override
  String get noticeDetailFieldTitle => 'Título';

  @override
  String get noticeDetailFieldCategory => 'Categoría';

  @override
  String get noticeDetailFieldPriority => 'Prioridad';

  @override
  String get noticeDetailFieldPublishedAt => 'Publicado';

  @override
  String get noticeDetailFieldExpiresAt => 'Vence';

  @override
  String get noticeDetailFieldBody => 'Contenido';

  @override
  String get homeViewAllNotices => 'Ver todos';

  @override
  String get homeViewAllAlerts => 'Ver todos';

  @override
  String get marketSummaryTitle => 'Resumen de precios';

  @override
  String marketReportingToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mercados reportando hoy',
      one: '1 mercado reportando hoy',
    );
    return '$_temp0';
  }

  @override
  String marketCropsTracked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cultivos registrados',
      one: '1 cultivo registrado',
    );
    return '$_temp0';
  }

  @override
  String get marketFilterAll => 'Todos';

  @override
  String get marketFilterFavourites => 'Favoritos';

  @override
  String get marketEmpty => 'No se encontraron mercados';

  @override
  String get marketEmptyMessage =>
      'Desliza hacia abajo para comprobar de nuevo.';

  @override
  String get marketFavouritesEmpty => 'Aún no tienes mercados favoritos';

  @override
  String get marketFavouritesEmptyMessage =>
      'Toca el ícono de estrella en cualquier mercado para añadirlo a favoritos.';

  @override
  String get marketSignInForFavourites =>
      'Inicia sesión para guardar mercados favoritos';

  @override
  String get marketPriceHistoryTitle => 'Historial de precios';

  @override
  String get marketPriceHistoryEmpty => 'Sin registros de precios';

  @override
  String get marketPriceHistoryEmptyMessage =>
      'Aún no hay historial de precios para este mercado.';

  @override
  String get marketFieldAddress => 'Dirección';

  @override
  String get marketFieldType => 'Tipo';

  @override
  String get marketFieldDistrict => 'Distrito';

  @override
  String get marketFieldFacilities => 'Instalaciones';

  @override
  String get marketFieldLocation => 'Ubicación';

  @override
  String marketPriceRange(String min, String max) {
    return 'Mín ₹$min · Máx ₹$max';
  }

  @override
  String marketPricePerUnit(String price, String unit) {
    return '₹$price / $unit';
  }

  @override
  String get searchCrops => 'Buscar cultivos...';

  @override
  String get all => 'Todos';

  @override
  String get cropRecommendations => 'Recomendaciones de cultivos';

  @override
  String get cropRecommendationsSubtitle =>
      'Encuentra los mejores cultivos para tu distrito y temporada';

  @override
  String get noCropsFound => 'No se encontraron cultivos';

  @override
  String get tryAdjustingFilters =>
      'Intenta ajustar tus opciones de búsqueda o filtro';

  @override
  String cropDurationDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get cropDetails => 'Detalles del cultivo';

  @override
  String get cropAdvisory => 'Asesoramiento';

  @override
  String get cropFertilizers => 'Fertilizantes';

  @override
  String get cropCalendar => 'Calendario';

  @override
  String get cropVarieties => 'Variedades';

  @override
  String get cropPrices => 'Precios';

  @override
  String get localName => 'Nombre local';

  @override
  String get noAdvisoryAvailable => 'Sin asesoramiento disponible';

  @override
  String get noAdvisorySubtitle =>
      'La información de asesoramiento aún no está disponible';

  @override
  String get advisorySeason => 'Temporada';

  @override
  String get sowingWindow => 'Ventana de siembra';

  @override
  String get harvestWindow => 'Ventana de cosecha';

  @override
  String get temperatureRange => 'Temperatura';

  @override
  String get rainfallRequirement => 'Precipitación';

  @override
  String get soilTypes => 'Tipos de suelo';

  @override
  String get soilPh => 'pH del suelo';

  @override
  String get soilDrainage => 'Drenaje';

  @override
  String get sowingMethod => 'Método de siembra';

  @override
  String get seedRate => 'Tasa de semilla';

  @override
  String get plantSpacing => 'Espaciado';

  @override
  String get landPreparation => 'Preparación del terreno';

  @override
  String get weedManagement => 'Control de malezas';

  @override
  String get advisoryPractice => 'Práctica';

  @override
  String get noFertilizersAvailable => 'Sin recomendaciones de fertilizantes';

  @override
  String get noFertilizersSubtitle =>
      'Los calendarios de fertilización aún no están disponibles';

  @override
  String get fertilizerGroup => 'Programa de fertilización';

  @override
  String get cropCalendarSchedule => 'Programa del calendario';

  @override
  String get cropCalendarActiveMessage =>
      'Siga el asesoramiento mensual para un rendimiento óptimo.';

  @override
  String get noVarietiesFound => 'No hay variedades registradas';

  @override
  String get noVarietiesSubtitle =>
      'Aún no se han documentado variedades para este cultivo';

  @override
  String get varietyName => 'Nombre de la variedad';

  @override
  String get duration => 'Duración';

  @override
  String get expectedYield => 'Rendimiento esperado';

  @override
  String get noPricesReported => 'Sin precios de mercado reportados';

  @override
  String get noPricesReportedSubtitle =>
      'No se han registrado precios recientes para este cultivo';

  @override
  String get reportingDate => 'Fecha de reporte';

  @override
  String get priceRange => 'Rango de precio';

  @override
  String get recommendationParameters => 'Parámetros de recomendación';

  @override
  String get district => 'Distrito';

  @override
  String get sowingMonth => 'Mes de siembra';

  @override
  String get areaHectares => 'Área (ha)';

  @override
  String get getRecommendations => 'Obtener recomendaciones';

  @override
  String get noRecommendationsFound => 'No se encontraron recomendaciones';

  @override
  String get tryDifferentMonthOrDistrict =>
      'Intente seleccionar otro distrito o mes de siembra';

  @override
  String get recommendedCropsList => 'Cultivos recomendados';

  @override
  String get suitability => 'Idoneidad';

  @override
  String get activeFarms => 'Activas';

  @override
  String get archivedFarms => 'Archivadas';

  @override
  String get noFarmsFound => 'No se encontraron fincas';

  @override
  String get noArchivedFarmsFound => 'No se encontraron fincas archivadas';

  @override
  String get addFarmPrompt => 'Toca el botón para añadir tu primera finca.';

  @override
  String get archived => 'Archivada';

  @override
  String get active => 'Activa';

  @override
  String get addFarm => 'Añadir finca';

  @override
  String get editFarm => 'Editar finca';

  @override
  String get farmName => 'Nombre de la finca';

  @override
  String get village => 'Aldea';

  @override
  String get soilType => 'Tipo de suelo';

  @override
  String get irrigationMethod => 'Método de riego';

  @override
  String get landOwnership => 'Propiedad de la tierra';

  @override
  String get latitude => 'Latitud';

  @override
  String get longitude => 'Longitud';

  @override
  String get invalidArea => 'Introduce un área válida en hectáreas (mayor a 0)';

  @override
  String get createFarm => 'Crear finca';

  @override
  String get updateFarm => 'Actualizar finca';

  @override
  String get farmCreated => 'Finca creada exitosamente';

  @override
  String get farmUpdated => 'Finca actualizada exitosamente';

  @override
  String get farmDeleted => 'Finca eliminada exitosamente';

  @override
  String get farmDetails => 'Detalles de la finca';

  @override
  String get deleteFarmConfirmTitle => '¿Eliminar finca?';

  @override
  String get deleteFarmConfirmMessage =>
      '¿Estás seguro de que deseas eliminar esta finca? Esta acción no se puede deshacer.';

  @override
  String get noCropsOnFarm => 'Sin cultivos registrados';

  @override
  String get addCropPrompt =>
      'Añade cultivos para rastrear el crecimiento y la cosecha.';

  @override
  String get addCrop => 'Añadir cultivo';

  @override
  String get cropName => 'Nombre del cultivo';

  @override
  String get season => 'Temporada';

  @override
  String get sownOn => 'Sembrado el';

  @override
  String get expectedHarvest => 'Cosecha esperada';

  @override
  String get income => 'Ingresos';

  @override
  String get expense => 'Gastos';

  @override
  String get netProfit => 'Beneficio neto';

  @override
  String get financeSummary => 'Resumen financiero';

  @override
  String get noTransactionsFound => 'Sin transacciones';

  @override
  String get addTransactionPrompt =>
      'Añade transacciones de ingresos o gastos para rastrear las finanzas.';

  @override
  String get addTransaction => 'Añadir transacción';

  @override
  String get transactionAmount => 'Importe (₹)';

  @override
  String get transactionCategory => 'Categoría';

  @override
  String get transactionDate => 'Fecha';

  @override
  String get transactionDescription => 'Descripción';

  @override
  String get transactionInvalidAmount => 'Introduce un importe mayor que 0';

  @override
  String get transactionAdded => 'Transacción añadida';

  @override
  String get farmCropCrop => 'Cultivo';

  @override
  String get farmCropStatus => 'Estado';

  @override
  String get farmCropSownOn => 'Fecha de siembra';

  @override
  String get farmCropAdded => 'Cultivo añadido';

  @override
  String get noPhotosFound => 'Sin fotos subidas';

  @override
  String get noPhotosSubtitle =>
      'Sube fotos para monitorear el progreso de tu finca.';

  @override
  String get uploadPhoto => 'Subir foto';

  @override
  String get archive => 'Archivar';

  @override
  String get unarchive => 'Desarchivar';

  @override
  String get delete => 'Eliminar';

  @override
  String get transactions => 'Transacciones';

  @override
  String get photos => 'Fotos';

  @override
  String get add => 'Añadir';

  @override
  String get location => 'Ubicación';

  @override
  String get address => 'Dirección';

  @override
  String get devices => 'Dispositivos';

  @override
  String get deviceDetail => 'Detalle del dispositivo';

  @override
  String get soilSensorAccount => 'Cuenta de sensor de suelo';

  @override
  String get soilSensorAccountLinked => 'Vinculado';

  @override
  String get soilSensorAccountNotLinked => 'No vinculado';

  @override
  String get linkAccount => 'Vincular cuenta';

  @override
  String get unlinkAccount => 'Desvincular cuenta';

  @override
  String get syncDevices => 'Sincronizar dispositivos';

  @override
  String get syncing => 'Sincronizando...';

  @override
  String get syncQueued => 'Sincronización en cola con éxito';

  @override
  String get noDevicesFound => 'No se encontraron dispositivos IoT';

  @override
  String get noDevicesFoundDesc =>
      'Conecte una cuenta de sensor de suelo o registre dispositivos para ver las lecturas.';

  @override
  String get deviceOnline => 'En línea';

  @override
  String get deviceOffline => 'Desconectado';

  @override
  String get sensors => 'Sensores';

  @override
  String get readings => 'Lecturas';

  @override
  String get noReadingsFound => 'No se registraron lecturas para este período.';

  @override
  String get serialNumber => 'Número de serie';

  @override
  String get hardwareModel => 'Modelo de hardware';

  @override
  String get batteryLevel => 'Nivel de batería';

  @override
  String get lastSync => 'Última sincronización';

  @override
  String get lastReading => 'Última lectura';

  @override
  String get days7 => '7 Días';

  @override
  String get days14 => '14 Días';

  @override
  String get days30 => '30 Días';

  @override
  String get unlinkConfirmTitle => '¿Desvincular cuenta de sensor de suelo?';

  @override
  String get unlinkConfirmMessage =>
      '¿Está seguro de que desea desvincular su cuenta? Las lecturas de IoT ya no se sincronizarán automáticamente.';

  @override
  String get soilSensUsername => 'Usuario SoilSens';

  @override
  String get soilSensPassword => 'Contraseña';

  @override
  String get status => 'Estado';

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
