abstract final class NetworkConstants {
  static const authorizationHeader = 'Authorization';

  static const contentTypeHeader = 'Content-Type';

  static const acceptHeader = 'Accept';

  static const bearerPrefix = 'Bearer';

  static const applicationJson = 'application/json';

  static const connectTimeoutSeconds = 30;

  static const receiveTimeoutSeconds = 30;

  static const sendTimeoutSeconds = 30;

  static const maxLoggedBodyLength = 2000;

  static const accessTokenLifetimeMinutes = 30;

  static String bearerToken(String token) {
    return '$bearerPrefix $token';
  }
}
