class IotEndpoints {
  static String farmDevices(String farm) =>
      '/api/v1/farmer/farms/$farm/devices';
  static String syncFarmDevices(String farm) =>
      '/api/v1/farmer/farms/$farm/devices/sync';
  static String soilSensorAccount(String farm) =>
      '/api/v1/farmer/farms/$farm/soil-sensor-account';
  static String device(String device) => '/api/v1/devices/$device';
  static String deviceReadings(String device) =>
      '/api/v1/devices/$device/readings';
}
