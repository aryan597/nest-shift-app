// lib/core/constants/app_constants.dart
class AppConstants {
  static const String dummyUserId = "0000";
  static const String dummyPinCode = "0000";
  static const String defaultLocalHost = "100.86.202.10";
  static const int defaultLocalPort = 8000;
  static const int brainPort = 8001;
  
  static const String keyToken = "AUTH_TOKEN";
  static const String keyDeviceIp = "DEVICE_IP";
  static const String keyDevicePort = "DEVICE_PORT";
  static const String keyDemoMode = "DEMO_MODE_ACTIVE";
  
  static String get defaultBaseUrl => "http://$defaultLocalHost:$defaultLocalPort";
  static String get defaultWebSocketUrl => "ws://$defaultLocalHost:$defaultLocalPort/ws";
  static String get defaultBrainUrl => "http://$defaultLocalHost:$brainPort";
}
