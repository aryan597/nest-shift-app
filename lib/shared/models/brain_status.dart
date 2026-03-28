class BrainStatus {
  final bool parserLoaded;
  final bool mqttConnected;
  final String uptime;
  final String? lastCommand;

  const BrainStatus({
    required this.parserLoaded,
    required this.mqttConnected,
    required this.uptime,
    this.lastCommand,
  });

  factory BrainStatus.fromJson(Map<String, dynamic> json) => BrainStatus(
        parserLoaded: json['parser_loaded'] as bool? ?? false,
        mqttConnected: json['mqtt_connected'] as bool? ?? false,
        uptime: json['uptime'] as String? ?? '0s',
        lastCommand: json['last_command'] as String?,
      );

  factory BrainStatus.offline() => const BrainStatus(
        parserLoaded: false,
        mqttConnected: false,
        uptime: '0s',
      );

  factory BrainStatus.demo() => const BrainStatus(
        parserLoaded: true,
        mqttConnected: true,
        uptime: '4h 32m',
        lastCommand: 'Turn on living room light',
      );

  bool get isOnline => parserLoaded;

  BrainStatus copyWith({
    bool? parserLoaded,
    bool? mqttConnected,
    String? uptime,
    String? lastCommand,
  }) =>
      BrainStatus(
        parserLoaded: parserLoaded ?? this.parserLoaded,
        mqttConnected: mqttConnected ?? this.mqttConnected,
        uptime: uptime ?? this.uptime,
        lastCommand: lastCommand ?? this.lastCommand,
      );
}
