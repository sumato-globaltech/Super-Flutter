import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'dart:math';

// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
// import 'package:ntp/ntp.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;
import 'package:super_flutter/app/router/navigator_keys.dart';
import 'package:super_flutter/core/constants/constants.dart';

// import 'package:permission_handler/permission_handler.dart';

class Utils {
  Utils._internal();
  static final Utils _instance = Utils._internal();
  factory Utils() {
    return _instance;
  }

  static Future<void> _permissionQueue = Future<void>.value();

  static Future<T> runExclusivePermission<T>(Future<T> Function() request) {
    final completer = Completer<T>();
    _permissionQueue = _permissionQueue.then((_) async {
      try {
        completer.complete(await request());
      } catch (e, s) {
        completer.completeError(e, s);
      }
    });
    return completer.future;
  }

  // static const Uuid _uuid = Uuid();
  // static flutterToast(String msg) {
  //   ShadToaster.of(navigatorKey.currentContext!).show(
  //     ShadToast(
  //       title: Text(msg),
  //       // description: const Text('Friday, February 10, 2023 at 5:57 PM'),
  //       action: ShadButton.outline(
  //         child: const Text('Close'),
  //         onPressed: () => ShadToaster.of(navigatorKey.currentContext!).hide(),
  //       ),
  //     ),
  //   );
  // }
  static void flutterToast(String msg) {
    final context = rootNavigatorKey.currentContext!;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          duration: const Duration(seconds: 3),
          persist: false,
          action: SnackBarAction(
            label: 'Close',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
  }

  // static Future<void> launchUrl2({
  //   required String url,
  //   Uri? uri,
  //   LaunchMode? launchMode,
  // }) async {
  //   if (!await launchUrl(
  //     uri ?? Uri.parse(url),
  //     mode: launchMode ?? LaunchMode.externalApplication,
  //   )) {
  //     throw Exception('Could not launch $url');
  //   }
  // }

  static String getSignalFlag(String signalFlag) {
    if (signalFlag == "Y") {
      return "Normal";
    } else if (signalFlag == "H") {
      return "High";
    } else if (signalFlag == "M") {
      return "Medium";
    } else {
      return '';
    }
  }

  static getHeight(BuildContext context) {
    var orientationOf = MediaQuery.orientationOf(context);
    Size size = MediaQuery.sizeOf(context);
    if (orientationOf == Orientation.portrait) {
      return size.height;
    } else {
      return size.width;
    }
  }

  static String getFormattedDateString(String date) {
    if (date.isEmpty) {
      return "";
    }
    DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    DateTime dateTimeFormatted = dateFormat.parse(date);
    DateFormat dateFormatReadable = DateFormat('dd MMM yyyy');
    return dateFormatReadable.format(dateTimeFormatted);
  }

  static double calculateBMI(
    double weightInKg,
    double height, {
    bool isCms = true,
  }) {
    double bmi;
    if (isCms) {
      height = height / 100;
    } else {
      height = height * 0.0254;
    }
    bmi = weightInKg / (height * height);
    return bmi;
  }

  static Future<TimeOfDay> selectTime(BuildContext context) async {
    TimeOfDay selectedTime = TimeOfDay.now();
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      selectedTime = pickedTime;
    }
    return selectedTime;
  } // TimeOfDay To Format AM/PM

  static String timeOfDayAMPM(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    final format = DateFormat('h:mm a');
    return format.format(dateTime);
  }

  // static Future<List<File>> pickFiles({
  //   FileType type = FileType.custom,
  //   bool allowMultiple = false,
  // }) async {
  //   final result = await FilePicker.pickFiles(
  //     allowMultiple: allowMultiple,
  //     type: type,
  //     // compressionQuality: 50,
  //     allowedExtensions: type == FileType.custom
  //         ? ['pdf', 'doc', 'docx']
  //         : null,
  //   );
  //   if (result.isNotEmpty) {
  //     List<File> files = result.map((path) => File(path.path!)).toList();
  //     return files;
  //   }
  //   return [];
  // }

  // static Future<File?> pickImageFromCamera([
  //   int? imageQuality,
  //   ImageSource? source,
  // ]) async {
  //   // if (!isIOS) {
  //   //   if (!await requestAllPermissions()) {
  //   //     return null;
  //   //   }
  //   // }
  //   if (!await requestCameraPermission()) {
  //     return null;
  //   }
  //   final XFile? result = await ImagePicker().pickImage(
  //     source: source ?? ImageSource.camera,
  //     imageQuality: imageQuality ?? 70,
  //   );
  //   if (result != null) {
  //     String? appStoragePath = await saveFileToAppStorage(
  //       result.path,
  //       customPath: true,
  //     );
  //     if (isAndroid) {
  //       unawaited(saveFileToGallery(result.path));
  //     }
  //     if (appStoragePath == null) {
  //       return null;
  //     }
  //     return File(appStoragePath);
  //   }
  //   return null;
  // }

  // static Future<File?> pickImageFromCameraOverlay({
  //   required List<String> text,
  // }) async {
  //   if (!await requestAllPermissions()) {
  //     return null;
  //   }
  //   final position = await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.high,
  //   );
  //   final XFile? result = await ImagePicker().pickImage(
  //     source: ImageSource.camera,
  //     imageQuality: 50,
  //   );
  //   // if (result != null) {
  //   //   // final overlayFile = await ImageOverlay.addOverlay(
  //   //   //   imagePath: File(result.path),
  //   //   //   latitude: position.latitude,
  //   //   //   longitude: position.longitude,
  //   //   //   timestamp: Utils.formatDate2(DateTime.now().toString()),
  //   //   //   text: text,
  //   //   // );
  //   //   return overlayFile;
  //   // }
  //   return null;
  // }

  // static Future<bool> requestCameraPermission() async {
  //   var status = await Permission.camera.status;
  //   if (status.isGranted) {
  //     return true;
  //   }
  //   status = await Permission.camera.request();
  //   if (status.isGranted) {
  //     return true;
  //   }
  //   if (status.isPermanentlyDenied) {
  //     flutterToast(
  //       'Camera permission is permanently denied. Please enable it from Settings.',
  //     );
  //     openAppSettings();
  //   }
  //   return false;
  // }

  static Future<bool> requestAllPermissions() async {
    // final cameraStatus = await Permission.camera.request();
    // if (!cameraStatus.isGranted) {
    //   flutterToast('Camera permission denied');
    //   return false;
    // }
    // final locationStatus = await Permission.locationWhenInUse.request();
    // if (!locationStatus.isGranted) {
    //   flutterToast('Location permission denied');
    //   return false;
    // }
    // if (!await Geolocator.isLocationServiceEnabled()) {
    //   flutterToast('Location services are disabled.');
    //   return false;
    // }
    return false;
  }

  // static Future<Map<String, String>?> getCurrentLocationLatLng() async {
  //   try {
  //     final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     if (!serviceEnabled) {
  //       flutterToast('Location services are disabled. Please enable location.');
  //       await Geolocator.openLocationSettings();
  //       return null;
  //     }

  //     var permission = await Geolocator.checkPermission();
  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //     }

  //     if (permission == LocationPermission.denied) {
  //       flutterToast('Location permission is required.');
  //       return null;
  //     }

  //     if (permission == LocationPermission.deniedForever) {
  //       flutterToast(
  //         'Location permission is permanently denied. Please enable it from settings.',
  //       );
  //       // await openAppSettings();
  //       return null;
  //     }

  //     Position? position;
  //     try {
  //       const locationSettings = LocationSettings(
  //         accuracy: LocationAccuracy.bestForNavigation,
  //         timeLimit: Duration(seconds: 20),
  //       );
  //       position = await Geolocator.getCurrentPosition(
  //         locationSettings: locationSettings,
  //       );
  //     } catch (_) {
  //       position = await Geolocator.getLastKnownPosition();
  //     }

  //     if (position == null) {
  //       flutterToast('Unable to get location. Please try again.');
  //       return null;
  //     }

  //     return {
  //       'latitude': position.latitude.toStringAsFixed(7),
  //       'longitude': position.longitude.toStringAsFixed(7),
  //     };
  //   } catch (e, st) {
  //     developer.log('Failed to fetch location', error: e, stackTrace: st);
  //     flutterToast(
  //       'Unable to request location permission. Please enable it from settings.',
  //     );
  //     return null;
  //   }
  // }

  //Get Current Year First Day OR Last Date
  static Future<DateTime> getYearDate(bool isLastDate) async {
    DateTime now = await NTP.now();
    DateTime firstDateOfYear = DateTime(now.year, 1, 1);
    DateTime lastDateOfYear = DateTime(now.year, 12, 31);
    if (isLastDate) {
      return lastDateOfYear;
    } else {
      return firstDateOfYear;
    }
  }

  static Future<List<DateTime>> getDateTimeRange(String range) async {
    DateTime now = await NTP.now();
    DateTime firstDateOfYear = DateTime(now.year, 1, 1);
    DateTime lastDateOfYear = DateTime(now.year, 12, 31);
    DateTime firstDateOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDateOfMonth = DateTime(now.year, now.month + 1, 0);
    DateTime firstDateOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime lastDateOfWeek = now.add(
      Duration(days: DateTime.daysPerWeek - now.weekday),
    );
    DateTime firstDateOfToday = DateTime(now.year, now.month, now.day);
    DateTime lastDateOfToday = DateTime(
      now.year,
      now.month,
      now.day,
      23,
      59,
      59,
    );
    DateTime firstDateOfYesterday = DateTime(now.year, now.month, now.day - 1);
    DateTime lastDateOfYesterday = DateTime(
      now.year,
      now.month,
      now.day - 1,
      23,
      59,
      59,
    );
    DateTime firstDateOfLastYear = DateTime(now.year - 1, 1, 1);
    DateTime lastDateOfLastYear = DateTime(now.year - 1, 12, 31);
    if (range == "Today") {
      return [firstDateOfToday, lastDateOfToday];
    } else if (range == "Yesterday") {
      return [firstDateOfYesterday, lastDateOfYesterday];
    } else if (range == "This Week") {
      return [firstDateOfWeek, lastDateOfWeek];
    } else if (range == "This Month") {
      return [firstDateOfMonth, lastDateOfMonth];
    } else if (range == "This Year") {
      return [firstDateOfYear, lastDateOfYear];
    } else if (range == "Last Year") {
      return [firstDateOfLastYear, lastDateOfLastYear];
    } else {
      return [firstDateOfToday, lastDateOfToday];
    }
  }

  static Future<DateTime?> filterDatePicker(
    DateTime? dateTime,
    String helpText,
    BuildContext context,
  ) async {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: dateTime ?? DateTime(1990),
      lastDate: DateTime.now(),
      helpText: helpText,
    );
  }

  static Future<String> getTodayString() async {
    try {
      final ntp = await NTP.now();
      return DateFormat().add_yMMMEd().format(ntp);
    } catch (e) {
      return DateFormat().add_yMMMEd().format(DateTime.now());
    }
  }

  static logPrint(String message) {
    developer.log(message);
  }

  static bool get isIOS {
    return Platform.isIOS;
  }

  static bool get isAndroid {
    return Platform.isAndroid;
  }

  //

  static logPrintColor(String message, {String color = 'reset'}) {
    // Define ANSI escape codes for different colors
    Map<String, String> colors = {
      'black': '\x1B[30m',
      'red': '\x1B[31m',
      'green': '\x1B[32m',
      'yellow': '\x1B[33m',
      'blue': '\x1B[34m',
      'magenta': '\x1B[35m',
      'cyan': '\x1B[36m',
      'white': '\x1B[37m',
      'reset': '\x1B[0m',
    };
    String? colorCode = colors.containsKey(color)
        ? colors[color]
        : colors['white'];
    developer.log('$colorCode$message${colors['reset']}');
  }

  // app auth
  // static Future<bool> get authStart async {
  //   try {
  //     final LocalAuthentication auth = LocalAuthentication();
  //     final isAuth = await auth.authenticate(
  //       localizedReason: 'Please authenticate to continue',
  //       options: const AuthenticationOptions(
  //         stickyAuth: true,
  //         biometricOnly: false,
  //         useErrorDialogs: false,
  //       ),
  //       // authMessages: const [
  //       //   AndroidAuthMessages(
  //       //     signInTitle: 'Oops! Biometric authentication required!',
  //       //     cancelButton: 'No thanks',
  //       //   ),
  //       //   IOSAuthMessages(
  //       //     cancelButton: 'No thanks',
  //       //   ),
  //       // ],
  //     );
  //     return isAuth;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  static num generateRandomNumber(int maxLength) {
    Random random = Random();
    num min = pow(10, maxLength - 1);
    num max = pow(10, maxLength) - 1;
    return min + random.nextInt(max.toInt() - min.toInt());
  }

  static String? validateEmail(String? email) {
    String emailPattern = r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$';
    RegExp regExp = RegExp(emailPattern);
    if (email == null || email.isEmpty) {
      return 'Please enter an email address.';
    }
    if (!regExp.hasMatch(email)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password.';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least 1 uppercase letter.';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least 1 lowercase letter.';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least 1 special character.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a Phone number.';
    }
    String phonePattern = r'^[0-9]{10}$';
    RegExp regExp = RegExp(phonePattern);
    if (!regExp.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  static Future<String?> getDeviceIpAddress() async {
    String? ipAddress;
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            ipAddress = addr.address;
            break;
          }
        }
        if (ipAddress != null) {
          break;
        }
      }
    } catch (e) {
      logPrint("Error getting IP address: $e");
    }
    return ipAddress;
  }

  static String get getPlatformName {
    if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'IOS';
    } else if (Platform.isMacOS) {
      return 'macOS';
    } else if (Platform.isWindows) {
      return 'Windows';
    } else if (Platform.isLinux) {
      return 'Linux';
    } else {
      return 'Unknown';
    }
  }

  static String formatDateTime(String? dateTime) {
    if (dateTime == null) {
      return "";
    }
    dateTime = DateFormat("dd MMM yyyy, h:m a")
        .format(DateTime.parse(dateTime).toLocal());
    return dateTime;
  }

  static String formatDate(String? dateTime) {
    if (dateTime == null) {
      return "";
    }
    dateTime = DateFormat("dd MMM yyyy").format(DateTime.parse(dateTime));
    return dateTime;
  }

  static String formatDateSafe(String? dateTime, {String fallback = 'N/A'}) {
    if (dateTime == null || dateTime.isEmpty) return fallback;
    try {
      return formatDate(dateTime);
    } catch (_) {
      return dateTime;
    }
  }

  static String timeAgo(
    Object? value, {
    String fallback = 'N/A',
    bool shortForm = true,
  }) {
    DateTime? dt;
    if (value is DateTime) {
      dt = value;
    } else if (value is String && value.trim().isNotEmpty) {
      dt = DateTime.tryParse(value.trim());
    }
    if (dt == null) return fallback;

    final now = DateTime.now();
    final local = dt.toLocal();
    final diff = now.difference(local);
    final isFuture = diff.isNegative;
    final seconds = diff.abs().inSeconds;

    String unit(int amount, String short, String long) {
      if (shortForm) return '$amount$short';
      return '$amount $long${amount == 1 ? '' : 's'}';
    }

    String label;
    if (seconds < 45) {
      return isFuture ? 'in a moment' : 'just now';
    } else if (seconds < 3600) {
      label = unit(seconds ~/ 60, 'm', 'minute');
    } else if (seconds < 86400) {
      label = unit(seconds ~/ 3600, 'h', 'hour');
    } else if (seconds < 604800) {
      label = unit(seconds ~/ 86400, 'd', 'day');
    } else if (seconds < 2592000) {
      label = unit(seconds ~/ 604800, 'w', 'week');
    } else if (seconds < 31536000) {
      label = unit(seconds ~/ 2592000, 'mo', 'month');
    } else {
      label = unit(seconds ~/ 31536000, 'y', 'year');
    }

    return isFuture ? 'in $label' : '$label ago';
  }

  static String formatDate2(String? dateTime) {
    if (dateTime == null) {
      return "";
    }
    final dt = DateTime.parse(dateTime);
    final timePart = DateFormat('hh:mm a').format(dt);
    final datePart = DateFormat('dd MMM yyyy').format(dt);
    return '$timePart | $datePart';
  }

  // static DateTime

  // static Future openLocationSettings() async {
  //   Geolocator.openLocationSettings();
  // }

  // static Future<bool> isAllowGPS() async {
  //   final location = await Geolocator.checkPermission();
  //   if (location == LocationPermission.always ||
  //       location == LocationPermission.whileInUse) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  // static Future<bool> requestLocationPermission() async {
  //   LocationPermission permission = await Geolocator.requestPermission();
  //   if (permission == LocationPermission.always ||
  //       permission == LocationPermission.whileInUse) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  // static Future<String> getLatLngToAddress(LatLng? latLng) async {
  //   if (latLng != null) {
  //     List<Placemark> placemarks =
  //         await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
  //     Placemark placemark =
  //         placemarks.isNotEmpty ? placemarks[0] : const Placemark();
  //     List<String> addressComponents = [];
  //     if (placemark.street != null && placemark.street!.isNotEmpty) {
  //       addressComponents.add(placemark.street!);
  //     }
  //     if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
  //       addressComponents.add(placemark.subLocality!);
  //     }
  //     if (placemark.locality != null && placemark.locality!.isNotEmpty) {
  //       addressComponents.add(placemark.locality!);
  //     }
  //     if (placemark.administrativeArea != null &&
  //         placemark.administrativeArea!.isNotEmpty) {
  //       addressComponents.add(placemark.administrativeArea!);
  //     }
  //     if (placemark.country != null && placemark.country!.isNotEmpty) {
  //       addressComponents.add(placemark.country!);
  //     }
  //     return addressComponents.join(', ');
  //   }
  //   return "";
  // }

  // static Color? statusColor(num? id) {
  //   // Define ANSI escape codes for different colors
  //   Map<int, dynamic> colors = {
  //     1: DesignColor.rejected,
  //     3: DesignColor.error400,
  //     4: DesignColor.success600,
  //   };
  //   return colors[id];
  // }

  // static double _calculateDistance(LatLng location1, LatLng location2) {
  //   const double earthRadius = 6371;

  //   double dLat = _degreesToRadians(location2.latitude - location1.latitude);
  //   double dLng = _degreesToRadians(location2.longitude - location1.longitude);

  //   double a = pow(sin(dLat / 2), 2) +
  //       cos(_degreesToRadians(location1.latitude)) *
  //           cos(_degreesToRadians(location2.latitude)) *
  //           pow(sin(dLng / 2), 2);

  //   double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  //   return earthRadius * c;
  // }

  // static double _degreesToRadians(double degrees) {
  //   return degrees * pi / 180;
  // }

  // static LatLng? findNearestLocation(
  //     List<LatLng> locations, LatLng currentLocation) {
  //   double minDistance = double.infinity;
  //   LatLng? nearestLocation;

  //   for (LatLng location in locations) {
  //     double distance = _calculateDistance(currentLocation, location);

  //     if (distance < minDistance) {
  //       minDistance = distance;
  //       nearestLocation = location;
  //     }
  //   }

  //   return nearestLocation;
  // }

  // static Future<String> getJsonFile(String path) async {
  //   ByteData byte = await rootBundle.load(path);
  //   var list = byte.buffer.asUint8List(byte.offsetInBytes, byte.lengthInBytes);
  //   return utf8.decode(list);
  // }

  // static Future<BitmapDescriptor> customMarker(String path) async {
  //   return BitmapDescriptor.fromAssetImage(
  //       const ImageConfiguration(size: Size(40, 40)), path);
  // }

  // static Future<Uint8List> getImages(String path, int width) async {
  //   ByteData data = await rootBundle.load(path);
  //   ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
  //       targetHeight: width);
  //   ui.FrameInfo fi = await codec.getNextFrame();
  //   return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
  //       .buffer
  //       .asUint8List();
  // }

  // static Future<String> markerStatus(String? actualEndDate) async {
  //   String assetName = AssetsName.imgLocationGreen;
  //   if (actualEndDate != null) {
  //     return assetName;
  //   }
  //   DateTime actualEndDateToDate = DateTime.parse(actualEndDate!);
  //   DateTime currentDate = await NTP.now();
  //   if (actualEndDateToDate.isAfter(currentDate)) {
  //     if (actualEndDateToDate.difference(currentDate).inDays > 7) {
  //       assetName = AssetsName.imgLocationGreen;
  //     } else {
  //       assetName = AssetsName.imgLocationYellow;
  //     }
  //   } else {
  //     assetName = AssetsName.imgLocationRed;
  //   }
  //   return assetName;
  // }

  // static Color? workStatusColorByDate({
  //   required DateTime datetime,
  //   required DateTime today,
  //   required num statusID,
  // }) {
  //   Color? filterColor;
  //   DateTime actualEndDateToDate = datetime;
  //   int days = actualEndDateToDate.difference(today).inDays;
  //   final isCompleted = statusID == ApplicationStatusCode.applicationCompleted;
  //   final isCrossed =
  //       statusID == ApplicationStatusCode.applicationAccepted && days < 0;
  //   final isNear = statusID == ApplicationStatusCode.applicationAccepted &&
  //       days >= 0 &&
  //       days <= Constants.endDays;
  //   final isOntime = statusID == ApplicationStatusCode.applicationAccepted &&
  //       ((days >= 0 && days <= Constants.endDays) || days > Constants.endDays);
  //   if (isOntime && !isCompleted && !isCrossed && !isNear) {
  //     filterColor = DesignColor.success600;
  //   }
  //   if (isNear) {
  //     filterColor = DesignColor.colorPrimary;
  //   }
  //   if (isCrossed) {
  //     filterColor = DesignColor.red;
  //   }
  //   if (isCompleted) {
  //     filterColor = DesignColor.blue;
  //   }
  //   return filterColor;
  // }

  // static bool workDateTimeStatus({
  //   required DateTime datetime,
  //   required DateTime today,
  //   required num statusID,
  //   required DateTimeStatus dateTimeStatus,
  // }) {
  //   DateTime day = DateTime.now();
  //   int days = datetime.difference(day).inDays;
  //   if (dateTimeStatus == DateTimeStatus.ontime) {
  //     return statusID == ApplicationStatusCode.applicationAccepted &&
  //         ((days >= 0 && days <= Constants.endDays) ||
  //             days > Constants.endDays);
  //   }
  //   if (dateTimeStatus == DateTimeStatus.nearingdate) {
  //     return statusID == ApplicationStatusCode.applicationAccepted &&
  //         days >= 0 &&
  //         days <= Constants.endDays;
  //   }
  //   if (dateTimeStatus == DateTimeStatus.crosseddate) {
  //     return statusID == ApplicationStatusCode.applicationAccepted && days < 0;
  //   }
  //   if (dateTimeStatus == DateTimeStatus.completed) {
  //     return statusID == ApplicationStatusCode.applicationCompleted;
  //   }
  //   return false;
  // }

  // static bool searchAddress(String query, String address) {
  //   query = query.toLowerCase();
  //   address = address.toLowerCase();
  //   List<String> queryWords = query.split(" ");
  //   List<String> addressWords = address.split(" ");
  //   for (var word in queryWords) {
  //     if (!addressWords.contains(word)) {
  //       return false;
  //     }
  //   }
  //   return true;
  // }

  // static bool searchTextFilter(String query, String actualText) {
  //   query = query.toLowerCase();
  //   actualText = actualText.toLowerCase();
  //   List<String> queryWords = query.split(" ");
  //   List<String> addressWords = actualText.split(" ");
  //   if (!actualText.contains(query)) {
  //     for (var word in queryWords) {
  //       if (!addressWords.contains(word)) {
  //         return false;
  //       }
  //     }
  //   }
  //   return true;
  // }

  // static String applicationApiStatusNameCustomize(num apiStatus) {
  //   final statusText = apiStatus == ApplicationStatusCode.applicationCompleted
  //       ? 'Completed'
  //       : apiStatus == WorkStatusCode.workPending
  //           ? 'Pending'
  //           : 'Work in Progress';
  //   return statusText;
  // }

  static List<int> get getMonths {
    return List.generate(12, (index) => index + 1);
  }

  static String numberToMonth(int number) {
    List<String> months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    if (number < 1 || number > 12) {
      return "Invalid month number";
    }

    return months[number - 1];
  }

  static List<int> getLastYears([int number = 6]) {
    int currentYear = DateTime.now().year;
    return List.generate(number, (index) => currentYear - index);
  }

  static isValidUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) {
      return false;
    }
    return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  // static Future<String?> saveFileToAppStorage(
  //   String? tempPath, {
  //   String subDir = 'uploads',
  //   bool customPath = false,
  // }) async {
  //   if (tempPath == null) return null;
  //   final directory = await getApplicationDocumentsDirectory();
  //   final folder = Directory('${directory.path}/$subDir');
  //   if (!await folder.exists()) {
  //     await folder.create(recursive: true);
  //   }
  //   // final fileName = tempPath.split('/').last;
  //   final fileName = p.basename(tempPath);
  //   final extensionType = p.extension(fileName);
  //   final newPath = customPath
  //       ? '${folder.path}/${generateUniqueId()}$extensionType'
  //       : '${folder.path}/$fileName';
  //   final tempFile = File(tempPath);
  //   final newFile = await tempFile.copy(newPath);
  //   return newFile.path;
  // }

  static Future<Directory> getExternalPublicDirectory({
    String subDir = Constants.appName,
  }) async {
    if (Platform.isAndroid) {
      final dir = await getExternalStorageDirectory();
      final pathSegments = dir!.path.split('/Android');
      final publicPath = Directory('${pathSegments[0]}/Pictures/$subDir');
      if (!await publicPath.exists()) {
        await publicPath.create(recursive: true);
      }
      return publicPath;
    }
    return await getApplicationDocumentsDirectory();
  }

  static Future<String?> saveFileToGallery(String? tempPath) async {
    try {
      if (tempPath == null) return null;
      Directory? directory = await getExternalPublicDirectory();
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final fileName = p.basename(tempPath);
      final extensionType = p.extension(fileName);
      final newPath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}$extensionType';
      final tempFile = File(tempPath);
      final newFile = await tempFile.copy(newPath);
      // if (Platform.isAndroid) {
      //   final result = await _refreshGallery(newFile.path);
      //   print('Gallery refreshed: $result');
      // }
      return newFile.path;
    } catch (e) {}
    return null;
  }

  static Future<bool> removeLocalFile(String? filePath) async {
    try {
      if (filePath == null) return false;
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      } else {
        return false;
      }
    } catch (e) {}
    return false;
  }

  // static String generateUniqueId([String? originalId]) {
  //   if (originalId == null || originalId.isEmpty) {
  //     return _uuid.v4();
  //   }
  //   return '${originalId}_${_uuid.v4()}';
  // }

  // static dynamic updateIds(dynamic node) {
  //   if (node is Map<String, dynamic>) {
  //     final updated = <String, dynamic>{};
  //     node.forEach((key, value) {
  //       if (key == 'id' && value is String) {
  //         updated[key] = generateUniqueId(value);
  //       } else {
  //         updated[key] = updateIds(value);
  //       }
  //     });
  //     return updated;
  //   } else if (node is List) {
  //     return node.map((item) => updateIds(item)).toList();
  //   } else {
  //     return node;
  //   }
  // }

  // static String updateStringJson({
  //   required String jsonString,
  //   required Map<String, dynamic> newField,
  //   required List<int> path,
  //   int? insertIndex,
  //   bool removeAnswers = true,
  // }) {
  //   try {
  //     List<dynamic> data = jsonDecode(jsonString);
  //     dynamic current = data;
  //     for (int i = 0; i < path.length; i++) {
  //       int index = path[i];
  //       if (current is List) {
  //         current = current[index];
  //       } else if (current is Map<String, dynamic> &&
  //           current.containsKey('fields')) {
  //         current = (current['fields'] as List)[index];
  //       } else {
  //         print("Invalid path at $index");
  //         return jsonString;
  //       }
  //     }
  //     if (current is Map<String, dynamic> && current.containsKey('fields')) {
  //       final updateIds = removeAnswers
  //           ? Utils.updateIds(removeAnswersFromJson(newField))
  //           : Utils.updateIds(newField);
  //       List fieldsList = current['fields'] as List;
  //       if (insertIndex != null &&
  //           insertIndex >= 0 &&
  //           insertIndex <= fieldsList.length) {
  //         fieldsList.insert(insertIndex, updateIds);
  //       } else {
  //         fieldsList.add(updateIds);
  //       }
  //     } else {
  //       print("Target has no 'fields'");
  //       return jsonString;
  //     }

  //     return jsonEncode(data);
  //   } catch (e) {
  //     print("Error in updateStringJson: $e");
  //     return jsonString;
  //   }
  // }

  static String? deleteFieldFromJson({
    required String jsonString,
    required List<int> path,
    int? deleteIndex,
  }) {
    try {
      if (deleteIndex == null) {
        return null;
      }
      List<dynamic> data = jsonDecode(jsonString);
      dynamic current = data;
      for (int i = 0; i < path.length; i++) {
        int index = path[i];
        if (current is List) {
          current = current[index];
        } else if (current is Map<String, dynamic> &&
            current.containsKey('fields')) {
          current = (current['fields'] as List)[index];
        } else {
          print("Invalid path at $index");
          return jsonString;
        }
      }

      if (current is Map<String, dynamic> && current.containsKey('fields')) {
        List fieldsList = current['fields'] as List;
        if (deleteIndex >= 0 && deleteIndex < fieldsList.length) {
          fieldsList.removeAt(deleteIndex);
        } else {
          print("Invalid deleteIndex: $deleteIndex");
        }
      } else {
        print("Target has no 'fields'");
        return jsonString;
      }

      return jsonEncode(data);
    } catch (e) {
      print("Error in deleteFieldFromJson: $e");
      return jsonString;
    }
  }

  static Map removeAnswersFromJson(Map data) {
    try {
      void clean(dynamic node) {
        if (node is Map<String, dynamic>) {
          node.remove('answer');
          if (node.containsKey('fields') && node['fields'] is List) {
            for (var child in node['fields']) {
              clean(child);
            }
          }
        } else if (node is List) {
          for (var child in node) {
            clean(child);
          }
        }
      }

      clean(data);
      return data;
    } catch (e) {
      return data;
    }
  }

  static dynamic answerNormalizer(dynamic field) {
    try {
      if (field == null) return null;
      if (field is String && field.trim().isEmpty) return null;
      if (field is List && field.isEmpty) return null;
      if (field is Map && field.isEmpty) return null;
      return field;
    } catch (e) {
      return null;
    }
  }

  // static Future<String?> get getDeviceId async {
  //   final deviceInfo = DeviceInfoPlugin();
  //   if (Platform.isAndroid) {
  //     AndroidDeviceInfo android = await deviceInfo.androidInfo;
  //     return android.id;
  //   }
  //   if (Platform.isIOS) {
  //     IosDeviceInfo ios = await deviceInfo.iosInfo;
  //     return ios.identifierForVendor;
  //   }
  //   return null;
  // }

  // static Future<String?> get getDeviceModel async {
  //   final deviceInfo = DeviceInfoPlugin();
  //   if (Platform.isAndroid) {
  //     AndroidDeviceInfo android = await deviceInfo.androidInfo;
  //     return android.model;
  //   }
  //   if (Platform.isIOS) {
  //     IosDeviceInfo ios = await deviceInfo.iosInfo;
  //     return ios.utsname.machine;
  //   }
  //   return null;
  // }

  // static Future<Position?> safeGetLocation({int timeoutSec = 15}) async {
  //   try {
  //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     if (!serviceEnabled) {
  //       flutterToast("Location service disabled");
  //       return null;
  //     }
  //     LocationPermission permission = await Geolocator.checkPermission();
  //     if (permission == LocationPermission.denied) {
  //       permission = await runExclusivePermission(Geolocator.requestPermission)
  //           .timeout(
  //             Duration(seconds: timeoutSec),
  //             onTimeout: () => Geolocator.checkPermission(),
  //           );
  //     }
  //     if (permission == LocationPermission.denied ||
  //         permission == LocationPermission.deniedForever) {
  //       flutterToast("Location permission denied");
  //       return null;
  //     }
  //     final LocationSettings locationSettings = LocationSettings(
  //       accuracy: LocationAccuracy.high,
  //       timeLimit: Duration(seconds: timeoutSec),
  //     );
  //     final Position position = await Geolocator.getCurrentPosition(
  //       locationSettings: locationSettings,
  //     ).timeout(Duration(seconds: timeoutSec));
  //     if (position.isMocked && !kDebugMode) {
  //       return null;
  //     }
  //     return position;
  //   } on TimeoutException {
  //     final lastPosition = await Geolocator.getLastKnownPosition();
  //     if (lastPosition == null) {
  //       return null;
  //     }
  //     if (lastPosition.isMocked) {
  //       return null;
  //     }
  //     return lastPosition;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // static Future<void> navigateToMapLocation(
  //   String latitude,
  //   String longitude,
  // ) async {
  //   try {
  //     final url =
  //         'https://www.google.com/maps/search/?api=1&query=${latitude},${longitude}';
  //     final uri = Uri.parse(url);
  //     launchUrl2(uri: uri, url: url);
  //   } catch (e) {}
  // }
}
