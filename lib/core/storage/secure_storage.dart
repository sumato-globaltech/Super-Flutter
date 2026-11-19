import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../error/exceptions/cache_exception.dart';
import 'storage_keys.dart';

// class SecureStorage {
//   SecureStorage({FlutterSecureStorage? storage})
//     : _storage = storage ?? _defaultStorage;

//   static const _defaultStorage = FlutterSecureStorage(
//     aOptions: AndroidOptions(
//       resetOnError: true,
//       storageNamespace: StorageKeys.secureNamespace,
//     ),
//     iOptions: IOSOptions(
//       accessibility: KeychainAccessibility.first_unlock_this_device,
//     ),
//   );

//   final FlutterSecureStorage _storage;

//   String? _accessToken;
//   String? _refreshToken;

//   String? get accessToken => _accessToken;

//   String? get refreshToken => _refreshToken;

//   bool get hasSession => _accessToken != null && _refreshToken != null;

//   Future<void> restore() async {
//     try {
//       _accessToken = await _storage.read(key: StorageKeys.accessToken);
//       _refreshToken = await _storage.read(key: StorageKeys.refreshToken);
//     } on Object catch (error) {
//       _accessToken = null;
//       _refreshToken = null;
//       throw CacheException('Could not read the stored session.', error);
//     }
//   }

//   Future<void> saveTokens({
//     required String accessToken,
//     required String refreshToken,
//   }) async {
//     _accessToken = accessToken;
//     _refreshToken = refreshToken;
//     await Future.wait([
//       _storage.write(key: StorageKeys.accessToken, value: accessToken),
//       _storage.write(key: StorageKeys.refreshToken, value: refreshToken),
//     ]);
//   }

//   Future<void> clearTokens() async {
//     _accessToken = null;
//     _refreshToken = null;
//     await Future.wait([
//       _storage.delete(key: StorageKeys.accessToken),
//       _storage.delete(key: StorageKeys.refreshToken),
//     ]);
//   }

//   Future<String?> read(String key) => _storage.read(key: key);

//   Future<void> write(String key, String value) =>
//       _storage.write(key: key, value: value);

//   Future<void> delete(String key) => _storage.delete(key: key);

//   Future<void> clearAll() async {
//     _accessToken = null;
//     _refreshToken = null;
//     await _storage.deleteAll();
//   }
// }


class TokenHandler {
  static const storage = FlutterSecureStorage();
  static Future setAccessKey(String value, {bool isRefresh = false}) async {
    await storage.write(key: isRefresh ? "keyRefresh" : "key", value: value);
  }

  static Future<String> getToken({bool isRefresh = false}) async {
    var token = await storage.read(key: isRefresh ? "keyRefresh" : "key");
    // if (await isTokenExpired(token ?? "")) {
    //   return "";
    // } else {
      return token ?? "";
    // }
  }

  static Future<void> resetJwt() async {
    navigatorKey.currentContext?.read<AppStateCubit>().clear();
    await storage.delete(key: "key");
  }

  // static Future<LoginModel> doctorLoginModel() async {
  //   String key = await TokenHandler.getToken();
  //   if (key.isNotEmpty) {
  //     final data = jsonDecode(key);
  //     return LoginModel.fromJson(data);
  //   }
  //   return LoginModel();
  // }

  // Validate Toke Start
  static Future<bool> isTokenExpired(String token) async {
    if (token.isEmpty) {
      return true; // Token is considered expired if it's empty or null
    }
    List<String> tokenParts = token.split('.');
    if (tokenParts.length != 3) {
      return true; // Invalid token format, consider it expired
    }
    String payload = tokenParts[1];
    String decodedPayload =
        String.fromCharCodes(base64Url.decode(base64Url.normalize(payload)));
    Map<String, dynamic> payloadMap = json.decode(decodedPayload);
    if (payloadMap.containsKey("exp")) {
      var expirationTimestamp = payloadMap["exp"];
      final ntp = await NTP.now();
      var currentTimestamp =
          ntp.millisecondsSinceEpoch ~/ 1000; // Convert to seconds
      if (currentTimestamp > expirationTimestamp) {
        return true; // Token is expired
      } else {
        return false; // Token is still valid
      }
    } else {
      return true; // Token doesn't contain expiration info, consider it expired
    }
  }
  // Validate Token End
}