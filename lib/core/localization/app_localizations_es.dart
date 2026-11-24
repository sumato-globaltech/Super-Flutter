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
  String get farmAddFarmName => 'Farm Name';

  @override
  String get farmAddFarmAreaHa => 'Area (ha)';

  @override
  String get farmAddFarmBlockId => 'Block';

  @override
  String get farmAddFarmVillage => 'Village';

  @override
  String get farmAddFarmAddress => 'Address';

  @override
  String get farmAddFarmSoilType => 'Soil Type';

  @override
  String get farmAddFarmIrrigationType => 'Irrigation Method';

  @override
  String get farmAddFarmOwnership => 'Land Ownership';

  @override
  String get farmAddFarmLatitude => 'Latitude';

  @override
  String get farmAddFarmLongitude => 'Longitude';

  @override
  String get farmAddFarmDone => 'Farm created.';

  @override
  String get farmEditFarmName => 'Farm Name';

  @override
  String get farmEditFarmAreaHa => 'Area (ha)';

  @override
  String get farmEditFarmBlockId => 'Block';

  @override
  String get farmEditFarmVillage => 'Village';

  @override
  String get farmEditFarmAddress => 'Address';

  @override
  String get farmEditFarmSoilType => 'Soil Type';

  @override
  String get farmEditFarmIrrigationType => 'Irrigation Method';

  @override
  String get farmEditFarmOwnership => 'Land Ownership';

  @override
  String get farmEditFarmLatitude => 'Latitude';

  @override
  String get farmEditFarmLongitude => 'Longitude';

  @override
  String get farmEditFarmDone => 'Farm Detail updated.';

  @override
  String get shipmentsTitle => 'Shipments';

  @override
  String get shipmentsList => 'Shipments';

  @override
  String get shipmentsEmpty => 'No shipments yet';

  @override
  String get shipmentsNumber => 'Number';

  @override
  String get shipmentsRequestedAt => 'Requested At';

  @override
  String get shipmentsAcceptedAt => 'Accepted At';

  @override
  String get shipmentsRejectedAt => 'Rejected At';

  @override
  String get shipmentsShipmentDetailTitle => 'Shipment';

  @override
  String get valueYes => 'Yes';

  @override
  String get valueNo => 'No';

  @override
  String get shipmentsShipmentDetailDetails => 'Shipment Details';

  @override
  String get shipmentsShipmentDetailId => 'Id';

  @override
  String get shipmentsShipmentDetailNumber => 'Shipment';

  @override
  String get shipmentsShipmentDetailRejectReason => 'Reject reason';

  @override
  String get shipmentsShipmentDetailRequestedAt => 'Requested on';

  @override
  String get shipmentsShipmentDetailAcceptedAt => 'Accepted on';

  @override
  String get shipmentsShipmentDetailRejectedAt => 'Rejected on';

  @override
  String get shipmentsShipmentDetailPickedUpAt => 'Picked up on';

  @override
  String get shipmentsShipmentDetailReachedAt => 'Reached on';

  @override
  String get shipmentsShipmentDetailReceivedAt => 'Received on';

  @override
  String get shipmentsShipmentDetailStatus => 'Status';

  @override
  String get shipmentsShipmentDetailStatusValue => 'Code';

  @override
  String get shipmentsShipmentDetailStatusLabel => 'Status';

  @override
  String get shipmentsShipmentDetailFarmer => 'Farmer';

  @override
  String get shipmentsShipmentDetailFarmerId => 'Id';

  @override
  String get shipmentsShipmentDetailFarmerCode => 'Code';

  @override
  String get shipmentsShipmentDetailFarmerName => 'Name';

  @override
  String get shipmentsShipmentDetailVendor => 'Vendor';

  @override
  String get shipmentsShipmentDetailVendorId => 'Id';

  @override
  String get shipmentsShipmentDetailVendorCode => 'Vendor code';

  @override
  String get shipmentsShipmentDetailVendorName => 'Vendor';

  @override
  String get shipmentsShipmentDetailPickup => 'Pickup';

  @override
  String get shipmentsShipmentDetailPickupAddress => 'Pickup address';

  @override
  String get shipmentsShipmentDetailPickupPreferredOn => 'Preferred pickup';

  @override
  String get shipmentsShipmentDetailPickupLate => 'Picked up late';

  @override
  String get shipmentsShipmentDetailVehicle => 'Vehicle';

  @override
  String get shipmentsShipmentDetailVehicleId => 'Id';

  @override
  String get shipmentsShipmentDetailVehicleRegistrationNumber =>
      'Registration number';

  @override
  String get shipmentsShipmentDetailDriver => 'Driver';

  @override
  String get shipmentsShipmentDetailDriverId => 'Id';

  @override
  String get shipmentsShipmentDetailDriverCode => 'Driver code';

  @override
  String get shipmentsShipmentDetailDriverName => 'Driver';

  @override
  String get shipmentsShipmentDetailDriverPhone => 'Phone';

  @override
  String get shipmentsRequestShipmentTitle => 'Request Shipment';

  @override
  String get shipmentsActive => 'Activos';

  @override
  String get shipmentsHistory => 'Historial';

  @override
  String get shipmentsRequest => 'Solicitar';

  @override
  String get shipmentsStatus => 'Estado';

  @override
  String get shipmentsVendor => 'Comprador';

  @override
  String get shipmentsPickupOn => 'Recogida el';

  @override
  String get shipmentsItems => 'Productos';

  @override
  String get shipmentsActiveEmpty => 'No hay envíos activos';

  @override
  String get shipmentsHistoryEmpty => 'No hay envíos anteriores';

  @override
  String get shipmentsShipmentDetailCancelledAt => 'Cancelled on';

  @override
  String get shipmentsShipmentDetailCancelReason => 'Cancel reason';

  @override
  String get shipmentsShipmentDetailNotes => 'Notes';

  @override
  String get shipmentsPicked => 'Recogido';

  @override
  String get shipmentsReceived => 'Recibido';

  @override
  String get shipmentsVehicleType => 'Tipo de vehículo';

  @override
  String get shipmentsCancel => 'Cancelar envío';

  @override
  String get shipmentsCancelTitle => '¿Cancelar este envío?';

  @override
  String get shipmentsCancelMessage =>
      'Se avisará al comprador de la cancelación.';

  @override
  String get shipmentsCancelReason => 'Motivo';

  @override
  String get shipmentsCancelled => 'Envío cancelado';

  @override
  String get shipmentsPickupDistrict => 'Distrito de recogida';

  @override
  String get shipmentsPickupAddress => 'Dirección de recogida';

  @override
  String get shipmentsNotes => 'Notas';

  @override
  String get shipmentsItem => 'Producto';

  @override
  String get shipmentsCrop => 'Cultivo';

  @override
  String get shipmentsQuantity => 'Cantidad';

  @override
  String get shipmentsUnit => 'Unidad';

  @override
  String get shipmentsAddItem => 'Añadir producto';

  @override
  String get shipmentsRemoveItem => 'Quitar producto';

  @override
  String get shipmentsInvalidQuantity => 'Introduce una cantidad mayor que 0';

  @override
  String get shipmentsSend => 'Enviar solicitud';

  @override
  String get shipmentsRequested => 'Envío enviado al comprador';

  @override
  String get shipmentsFarmer => 'Agricultor';

  @override
  String get shipmentsReason => 'Motivo';

  @override
  String get shipmentsAccept => 'Aceptar';

  @override
  String get shipmentsAcceptTitle => '¿Aceptar este envío?';

  @override
  String get shipmentsAccepted => 'Envío aceptado';

  @override
  String get shipmentsAssignMessage =>
      'Elige el vehículo y el conductor que lo recogerán.';

  @override
  String get shipmentsOnTrip => 'En viaje';

  @override
  String get shipmentsReject => 'Rechazar';

  @override
  String get shipmentsRejectTitle => '¿Rechazar este envío?';

  @override
  String get shipmentsRejectMessage => 'El agricultor verá tu motivo.';

  @override
  String get shipmentsRejected => 'Envío rechazado';

  @override
  String get shipmentsReassign => 'Reasignar';

  @override
  String get shipmentsReassignTitle => 'Cambiar vehículo o conductor';

  @override
  String get shipmentsReassigned => 'Vehículo y conductor actualizados';

  @override
  String get shipmentsReceive => 'Recibir';

  @override
  String get shipmentsReceiveTitle => 'Registrar lo recibido';

  @override
  String get shipmentsReceiveMessage =>
      'Introduce la cantidad recibida de cada producto.';

  @override
  String get shipmentsReweigh => 'Volver a pesar';

  @override
  String get shipmentsReweighTitle => 'Volver a pesar un producto';

  @override
  String get shipmentsReweighMessage =>
      'Corrige la cantidad recibida de un producto.';

  @override
  String get shipmentsReweighed => 'Cantidad corregida guardada';

  @override
  String get shipmentsInvalidWeighed => 'Introduce 0 o más';

  @override
  String get shipmentsSold => 'Vendido';

  @override
  String get shipmentsSave => 'Guardar';

  @override
  String get shipmentsRecordPicked => 'Registrar carga';

  @override
  String get shipmentsRecordPickedTitle => 'Registrar cantidades cargadas';

  @override
  String get shipmentsRecordPickedMessage =>
      'Introduce lo que cargaste de cada producto.';

  @override
  String get shipmentsPickedSaved => 'Cantidades cargadas guardadas';

  @override
  String get shipmentsConfirmPickup => 'Confirmar recogida';

  @override
  String get shipmentsPickupTitle => 'Confirmar la recogida';

  @override
  String get shipmentsPickupMessage =>
      'Revisa la cantidad cargada de cada producto. El envío saldrá en camino.';

  @override
  String get shipmentsPickedUp => 'Recogida confirmada';

  @override
  String get shipmentsMarkReached => 'Llegado';

  @override
  String get shipmentsReachTitle => '¿Marcar como llegado?';

  @override
  String get shipmentsReachMessage => 'El comprador registrará lo recibido.';

  @override
  String get shipmentsReachedDone => 'Marcado como llegado';

  @override
  String get schemesTitle => 'Schemes';

  @override
  String get schemesList => 'Schemes';

  @override
  String get schemesEmpty => 'No schemes yet';

  @override
  String get schemesName => 'Scheme';

  @override
  String get schemesCode => 'Code';

  @override
  String get schemesIsOpen => 'Open for applications';

  @override
  String get schemesEndsOn => 'Closes on';

  @override
  String get schemesSchemeDetailTitle => 'Scheme';

  @override
  String get schemesSchemeDetailDetails => 'Scheme Details';

  @override
  String get schemesSchemeDetailCode => 'Code';

  @override
  String get schemesSchemeDetailIsOpen => 'Open for applications';

  @override
  String get schemesSchemeDetailStartsOn => 'Opens on';

  @override
  String get schemesSchemeDetailEndsOn => 'Closes on';

  @override
  String get schemesSchemeDetailSubsidyAmount => 'Subsidy';

  @override
  String get schemesSchemeDetailFundingSource => 'Funded by';

  @override
  String get schemesSchemeDetailFinancialYear => 'Financial year';

  @override
  String get schemesSchemeDetailDescription => 'Description';

  @override
  String get schemesSchemeDetailEligibility => 'Eligibility';

  @override
  String get schemesSchemeDetailApplicationProcess => 'How to apply';

  @override
  String get schemesMyApplicationsTitle => 'My Applications';

  @override
  String get schemesMyApplications => 'Mis solicitudes';

  @override
  String get schemesApplicationsCount => 'Solicitudes';

  @override
  String get schemesRequiredDocuments => 'Documentos que necesitarás';

  @override
  String get schemesFiles => 'Archivos del programa';

  @override
  String get schemesFile => 'Archivo';

  @override
  String get schemesDistricts => 'Dónde se aplica';

  @override
  String get schemesApply => 'Solicitar';

  @override
  String get schemesApplyTitle => '¿Solicitar este programa?';

  @override
  String get schemesApplyMessage =>
      'Tu solicitud llegará a los funcionarios para su revisión.';

  @override
  String get schemesApplied => 'Solicitud enviada';

  @override
  String get schemesYourApplication => 'Tu solicitud';

  @override
  String schemesApplyMessageDocuments(String documents) {
    return 'Tu solicitud llegará a los funcionarios. Después sube estos documentos desde Mis solicitudes: $documents';
  }

  @override
  String get schemesStatus => 'Estado';

  @override
  String get schemesAppliedOn => 'Solicitado el';

  @override
  String get schemesDecisionNote => 'Nota del funcionario';

  @override
  String get schemesAmountApproved => 'Aprobado';

  @override
  String get schemesAmountDisbursed => 'Desembolsado';

  @override
  String get schemesNotUploaded => 'Sin subir';

  @override
  String get schemesUpload => 'Subir';

  @override
  String get schemesReplace => 'Reemplazar';

  @override
  String get schemesUploaded => 'Documento subido';

  @override
  String get schemesFileTooLarge => 'Elige un archivo de 5 MB o menos';

  @override
  String get schemesWithdraw => 'Retirar';

  @override
  String get schemesWithdrawTitle => '¿Retirar esta solicitud?';

  @override
  String get schemesWithdrawMessage =>
      'Los funcionarios dejarán de revisarla. No se puede deshacer.';

  @override
  String get schemesWithdrawn => 'Solicitud retirada';

  @override
  String get schemesNoApplications => 'Aún no hay solicitudes';

  @override
  String get schemesNoApplicationsMessage =>
      'Abre un programa y pulsa Solicitar.';

  @override
  String schemesUploadTitle(String document) {
    return '¿Subir $document?';
  }

  @override
  String get supportTitle => 'Mesa de ayuda';

  @override
  String get supportTicketDetailTitle => 'Consulta';

  @override
  String get supportCreateTicketTitle => 'Nueva consulta';

  @override
  String get helpDeskQueueSummaryTitle => 'Mesa de ayuda';

  @override
  String get supportList => 'Tickets';

  @override
  String get supportEmpty => 'Aún no hay consultas';

  @override
  String get supportNumber => 'Número';

  @override
  String get supportSubject => 'Asunto';

  @override
  String get supportCreatedAt => 'Preguntado el';

  @override
  String get supportTicketDetailDetails => 'Detalles de la consulta';

  @override
  String get supportTicketDetailNumber => 'Número';

  @override
  String get supportTicketDetailSubject => 'Asunto';

  @override
  String get supportTicketDetailQuestion => 'Pregunta';

  @override
  String get supportTicketDetailOutcome => 'Resultado';

  @override
  String get supportTicketDetailCreatedAt => 'Preguntado el';

  @override
  String get supportTicketDetailResolvedAt => 'Resuelto el';

  @override
  String get supportCreateTicketCategoryId => 'Categoría';

  @override
  String get supportCreateTicketSubject => 'Asunto';

  @override
  String get supportCreateTicketQuestion => 'Pregunta';

  @override
  String get supportCreateTicketCropId => 'Cultivo';

  @override
  String get supportCreateTicketPhoto => 'Foto';

  @override
  String get supportCreateTicketDone => 'Pregunta enviada';

  @override
  String get helpDeskQueueSummaryDetails => 'Mi cola';

  @override
  String get helpDeskQueueSummaryOpen => 'Mis consultas abiertas';

  @override
  String get helpDeskQueueSummaryOverdueFollowUps =>
      'Mis seguimientos atrasados';

  @override
  String get helpDeskQueueSummaryResolvedToday => 'Resueltas hoy';

  @override
  String get helpDeskQueueSummaryUnassigned => 'Esperando un agente';

  @override
  String get supportAsk => 'Hacer una pregunta';

  @override
  String get supportCallCenter => 'Centro de llamadas';

  @override
  String get supportNoNumber => 'Aún no hay número para este distrito';

  @override
  String get supportCallBack => 'Solicitar una llamada';

  @override
  String get supportCallBackMessage => 'Un agente te llamará.';

  @override
  String get supportCallBackSend => 'Solicitar llamada';

  @override
  String get supportCallBackQuestion => '¿De qué se trata? (opcional)';

  @override
  String get supportCallBackDone => 'Llamada solicitada';

  @override
  String get supportStatus => 'Estado';

  @override
  String get supportReplies => 'Respuestas';

  @override
  String get supportNoReplies => 'Aún no hay respuestas';

  @override
  String get productionTitle => 'Producción';

  @override
  String get productionDetails => 'Resumen';

  @override
  String get productionFinancialYear => 'Año fiscal';

  @override
  String get productionTotalTonnes => 'Total (toneladas)';

  @override
  String get productionMonth => 'Mes';

  @override
  String get productionAllMonths => 'Todos los meses';

  @override
  String get productionCrop => 'Cultivo';

  @override
  String get productionAllCrops => 'Todos los cultivos';

  @override
  String get productionByMonth => 'Toneladas por mes';

  @override
  String get productionByCrop => 'Por cultivo';

  @override
  String get productionEmpty => 'No hay producción registrada';

  @override
  String productionTonnes(String amount) {
    return '$amount toneladas';
  }

  @override
  String productionRecords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros',
      one: '1 registro',
    );
    return '$_temp0';
  }

  @override
  String productionDistricts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count distritos',
      one: '1 distrito',
    );
    return '$_temp0';
  }

  @override
  String get adminCommunicationAdminNoticesTitle => 'Manage Notices';

  @override
  String get adminCommunicationAdminAlertsTitle => 'Manage Alerts';

  @override
  String get adminCommunicationAddNoticeTitle => 'New Notice';

  @override
  String get adminCommunicationEditNoticeTitle => 'Edit Notice';

  @override
  String get adminCommunicationAddAlertTitle => 'New Alert';

  @override
  String get adminCommunicationEditAlertTitle => 'Edit Alert';

  @override
  String get adminCommunicationAdminNoticesList => 'Admin Notices';

  @override
  String get adminCommunicationAdminNoticesEmpty => 'No notices yet';

  @override
  String get adminCommunicationAdminNoticesPublishedAt => 'Published on';

  @override
  String get adminCommunicationAdminNoticesExpiresAt => 'Expires on';

  @override
  String get adminCommunicationAdminAlertsList => 'Admin Alerts';

  @override
  String get adminCommunicationAdminAlertsEmpty => 'No alerts yet';

  @override
  String get adminCommunicationAdminAlertsStartsOn => 'From';

  @override
  String get adminCommunicationAdminAlertsEndsOn => 'Until';

  @override
  String get adminCommunicationAddNoticeCategoryId => 'Category';

  @override
  String get adminCommunicationAddNoticeBody => 'Text';

  @override
  String get adminCommunicationAddNoticePriority => 'Priority';

  @override
  String get adminCommunicationAddNoticeExpiresOn => 'Expires on';

  @override
  String get adminCommunicationAddNoticeDone => 'Notice saved as a draft';

  @override
  String get adminCommunicationEditNoticeCategoryId => 'Category';

  @override
  String get adminCommunicationEditNoticeBody => 'Text';

  @override
  String get adminCommunicationEditNoticePriority => 'Priority';

  @override
  String get adminCommunicationEditNoticeExpiresOn => 'Expires on';

  @override
  String get adminCommunicationEditNoticeDone => 'Notice updated';

  @override
  String get adminCommunicationAddAlertCategoryId => 'Category';

  @override
  String get adminCommunicationAddAlertDistrictId => 'District';

  @override
  String get adminCommunicationAddAlertDescription => 'Description';

  @override
  String get adminCommunicationAddAlertSeverity => 'Severity';

  @override
  String get adminCommunicationAddAlertStartsOn => 'Starts on';

  @override
  String get adminCommunicationAddAlertEndsOn => 'Ends on';

  @override
  String get adminCommunicationAddAlertDone => 'Alert saved as a draft';

  @override
  String get adminCommunicationEditAlertCategoryId => 'Category';

  @override
  String get adminCommunicationEditAlertDistrictId => 'District';

  @override
  String get adminCommunicationEditAlertDescription => 'Description';

  @override
  String get adminCommunicationEditAlertSeverity => 'Severity';

  @override
  String get adminCommunicationEditAlertStartsOn => 'Starts on';

  @override
  String get adminCommunicationEditAlertEndsOn => 'Ends on';

  @override
  String get adminCommunicationEditAlertDone => 'Alert updated';

  @override
  String get adminTitle => 'Título';

  @override
  String get adminStatus => 'Estado';

  @override
  String get adminEdit => 'Editar';

  @override
  String get adminPublish => 'Publicar';

  @override
  String get adminArchive => 'Archivar';

  @override
  String get adminRestore => 'Restaurar';

  @override
  String get adminActivate => 'Activar';

  @override
  String get adminAlertCancel => 'Cancelar alerta';

  @override
  String get adminAlertStatewide => 'Todo el estado';

  @override
  String get adminDeleteWarning => 'No se puede deshacer.';

  @override
  String get adminAlertCancelWarning =>
      'Una alerta cancelada no se puede editar ni volver a activar.';

  @override
  String get adminDone => 'Guardado';

  @override
  String get adminNoticeFormattingLost =>
      'Este aviso tiene formato. Si cambias el texto aquí se guardará sin formato.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileEditProfileTitle => 'Edit Profile';

  @override
  String get profileEditProfileName => 'Name';

  @override
  String get profileEditProfileEmail => 'Email';

  @override
  String get profileEditProfileGender => 'Gender';

  @override
  String get profileEditProfileDateOfBirth => 'Date of birth';

  @override
  String get profileEditProfileVillage => 'Village';

  @override
  String get profileEditProfileAddress => 'Address';

  @override
  String get profileEditProfileLandAreaHa => 'Land (ha)';

  @override
  String get profileEditProfileLandOwnership => 'Land ownership';

  @override
  String get profileEditProfileDone => 'Profile updated';

  @override
  String get profileAccount => 'Cuenta';

  @override
  String get profileRole => 'Rol';

  @override
  String get profilePhone => 'Teléfono';

  @override
  String get profileFarmer => 'Datos del agricultor';

  @override
  String get profileCode => 'Código de agricultor';

  @override
  String get profileVerified => 'Verificado';

  @override
  String get profileDistricts => 'Distritos';

  @override
  String get profileBlocks => 'Bloques';

  @override
  String get profileNotSet => 'Sin definir';

  @override
  String get profileVerifyAgain =>
      'Estás verificado. Si cambias tus datos, puede que haya que verificarte de nuevo.';

  @override
  String get profileChangePassword => 'Cambiar contraseña';

  @override
  String get meetingsTitle => 'Reuniones';

  @override
  String get facilitiesTitle => 'Instalaciones';

  @override
  String get facilitiesFacilityStatsTitle => 'Estadísticas';

  @override
  String get meetingsList => 'Meetings';

  @override
  String get meetingsEmpty => 'No hay próximas reuniones';

  @override
  String get meetingsAgenda => 'Agenda';

  @override
  String get meetingsStartsAt => 'Empieza';

  @override
  String get facilitiesList => 'Facilities';

  @override
  String get facilitiesEmpty => 'Aún no hay instalaciones';

  @override
  String get facilitiesName => 'Name';

  @override
  String get facilitiesAddress => 'Dirección';

  @override
  String get facilitiesFacilityStatsDetails => 'Resumen';

  @override
  String get facilitiesFacilityStatsTotal => 'Total';

  @override
  String get facilitiesFacilityStatsOperational => 'En funcionamiento';

  @override
  String get meetingsChoose => 'Elige un distrito para ver sus reuniones';

  @override
  String get meetingsStatus => 'Estado';

  @override
  String meetingsRescheduled(String date) {
    return 'cambiada desde $date';
  }

  @override
  String get meetingsJoin => 'Unirse';

  @override
  String get facilitiesType => 'Tipo';

  @override
  String get facilitiesAllTypes => 'Todos los tipos';

  @override
  String get facilitiesAllDistricts => 'Todos los distritos';

  @override
  String get facilitiesStatus => 'Estado';

  @override
  String get facilitiesOperational => 'En funcionamiento';

  @override
  String get facilitiesNotOperational => 'Fuera de servicio';

  @override
  String get facilitiesCapacity => 'Capacidad';

  @override
  String facilitiesTonnesPerDay(String amount) {
    return '$amount toneladas/día';
  }

  @override
  String facilitiesSqm(String amount) {
    return '$amount m² de almacén';
  }

  @override
  String get facilitiesProducts => 'Productos';

  @override
  String get facilitiesByType => 'Por tipo';

  @override
  String get facilitiesByDistrict => 'Por distrito';

  @override
  String facilitiesWorking(int working, int total) {
    return '$working de $total en funcionamiento';
  }

  @override
  String get cropDetectorTitle => 'Detector de cultivos IA';

  @override
  String get cropDetectorGallery => 'Galería';

  @override
  String get cropDetectorCamera => 'Cámara';

  @override
  String get cropDetectorAgain => 'Escanear otra vez';

  @override
  String get cropDetectorNoAccess =>
      'Permite el acceso a la cámara o las fotos en Ajustes';

  @override
  String get cropDetectorGuide => 'Escanea un cultivo';

  @override
  String get cropDetectorGuideLight => 'Luz';

  @override
  String get cropDetectorGuideLightText =>
      'Usa buena luz natural y mantén la planta enfocada';

  @override
  String get cropDetectorGuideFocus => 'Sujeto';

  @override
  String get cropDetectorGuideFocusText =>
      'Muestra una planta y evita fondos recargados';

  @override
  String get cropDetectorGuidePrivacy => 'Tu foto';

  @override
  String get cropDetectorGuidePrivacyText =>
      'Se envía a Plantix para analizarla';

  @override
  String get cropDetectorAnalysing =>
      'Analizando el cultivo. Puede tardar un momento.';

  @override
  String get cropDetectorResult => 'Resultado';

  @override
  String get cropDetectorHealth => 'Salud del cultivo';

  @override
  String get cropDetectorCrop => 'Cultivo';

  @override
  String get cropDetectorPhoto => 'Calidad de la foto';

  @override
  String get cropDetectorFocus => 'Enfoque';

  @override
  String get cropDetectorDistance => 'Distancia';

  @override
  String get cropDetectorNotice => 'Nota';

  @override
  String get cropDetectorNoDiagnosis =>
      'No se encontró ningún diagnóstico para esta foto';

  @override
  String get cropDetectorUnknown => 'Diagnóstico desconocido';

  @override
  String get cropDetectorLikelihood => 'Probabilidad';

  @override
  String get cropDetectorSimilar => 'Casos similares';

  @override
  String get cropDetectorSigns => 'Signos';

  @override
  String get cropDetectorDescription => 'Descripción';

  @override
  String get cropDetectorPrevention => 'Medidas preventivas';

  @override
  String get cropDetectorOrganic => 'Tratamiento orgánico';

  @override
  String get cropDetectorChemical => 'Tratamiento químico';

  @override
  String get cropDetectorDisclaimer =>
      'Un resultado de IA puede fallar. Consulta a un técnico antes de tratar tu cultivo.';
}
