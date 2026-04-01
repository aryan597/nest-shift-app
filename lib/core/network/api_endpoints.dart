class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String pair = '/pair';

  // WebSocket
  static String wsUrl(String ip, int port, String token) =>
      'ws://$ip:$port/ws?token=$token';

  // Base URL builder
  static String baseUrl(String ip, int port) => 'http://$ip:$port';

  // System
  static const String systemStatus = '/status';
  static const String brainStatus = '/brain/status';
  static const String config = '/config';

  // Hub Management
  static const String hubReboot = '/hub/reboot';
  static String hubRestart(String service) => '/hub/restart/$service';

  // Devices
  static const String devices = '/devices';
  static String device(String id) => '/devices/$id';
  static String deviceToggle(String id) => '/devices/$id/toggle';
  static String deviceSet(String id) => '/devices/$id/set';
  static String deviceControl(String id) => '/devices/$id/control';
  static String deviceReadings(String id) => '/devices/$id/readings';
  static String deviceEvents(String id) => '/devices/$id/events';

  // Rooms
  static const String rooms = '/rooms';
  static String room(String id) => '/rooms/$id';
  static String roomControl(String id) => '/rooms/$id/control';

  // Sensors
  static const String sensors = '/sensors';
  static String sensorReading(String deviceId) => '/sensors/$deviceId/reading';

  // Automations
  static const String automations = '/automations';
  static String automation(String id) => '/automations/$id';
  static String automationTrigger(String id) => '/automations/$id/trigger';
  static String automationToggle(String id) => '/automations/$id/toggle';

  // Schedules
  static const String schedules = '/schedules';

  // Scenes
  static const String scenes = '/scenes';
  static String scene(String id) => '/scenes/$id';
  static String sceneActivate(String id) => '/scenes/$id/activate';

  // GPIO
  static const String gpioPins = '/gpio/pins';
  static String gpioRelaySet(int pin) => '/gpio/relay/$pin/set';
  static String gpioRelayToggle(int pin) => '/gpio/relay/$pin/toggle';

  // AI
  static const String aiCommand = '/ai/command';
  static const String aiHistory = '/ai/history';
  static const String aiInsights = '/ai/insights';
  static String aiAutomationApprove(String id) => '/ai/automations/$id/approve';

  // Events
  static const String events = '/events';

  // Notifications
  static const String notifications = '/notifications';
  static String notificationRead(String id) => '/notifications/$id/read';
}