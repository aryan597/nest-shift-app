class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String pair = '/pair';

  // Devices
  static const String devices = '/devices';
  static String deviceToggle(String id) => '/devices/$id/toggle';
  static String deviceSet(String id) => '/devices/$id/set';

  // Brain / AI
  static const String aiCommand = '/ai/command';
  static const String aiHistory = '/ai/history';
  static const String aiInsights = '/ai/insights';
  static String aiScene(String name) => '/ai/scene/$name';
  static const String brainStatus = '/brain/status';
  static String brainExportTraining = '/brain/export-training-data';

  // Automations
  static const String automations = '/automations';
  static String automationById(String id) => '/automations/$id';
  static String automationToggle(String id) => '/automations/$id/toggle';
  static String aiAutomationApprove(String id) => '/ai/automations/$id/approve';

  // GPIO
  static const String gpioPins = '/gpio/pins';
  static String gpioRelayToggle(int pin) => '/gpio/relay/$pin/toggle';
  static String gpioRelaySet(int pin) => '/gpio/relay/$pin/set';

  // WebSocket
  static String wsUrl(String ip, int port, String token) =>
      'ws://$ip:$port/ws?token=$token';

  // Base URL builder
  static String baseUrl(String ip, int port) => 'http://$ip:$port';
}
