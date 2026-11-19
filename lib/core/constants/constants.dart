
import 'package:package_info_plus/package_info_plus.dart';

class Constants {
  static final Constants _instance = Constants._internal();
  Constants._internal();
  // factory Constants() {
  //   return _instance;
  // }
  static Constants get instance => _instance;
  // For api Start
  // static String apiUrl = "http://ino-irrigation.test";
  static String apiUrl = "https://irrigationassam.in";
  static const String apiVersion = "/api/";
  // For api End

  // Supabase Start
  static const String supabaseUrl = '';
  static const String supabaseAnonKey = '';

  static const String googleWebClientId = '';
  static const String googleIosClientId = '';

  static PackageInfo? packageInfo;
  static int buildNumber = 0;
  // static String? deviceIpAddress;

  static Future<void> setAppInfo() async {
    PackageInfo pi = await PackageInfo.fromPlatform();
    packageInfo = pi;
    buildNumber = int.parse(pi.buildNumber);
    // deviceIpAddress = await Utils.getDeviceIpAddress();
  }

  static const String appName = 'UDAE';
  // key
  static const String keyLoginButton = "keyLoginButton";
  static const int otpResendSeconds = 120;
  // key
  static const String appFullName =
      'Unified Digital Agriculture Ecosystem';
  static const double elevation = 0;

  static const String companyName = 'Sumato Globaltech Pvt. Ltd.';
  static const String companySite = '';
  static const String supportEmail = 'sumatoglobal@gmail.com';
  static const String privacyPolicyUrl = '';
  static const String currencySymbol = '₹';
  static const String remoteAppConfig = 'config';

  // App Config Start

  static const double borderRadius = 12;
  // App Config End
}
