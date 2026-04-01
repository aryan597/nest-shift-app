class BrainStatus {
  final bool parserLoaded;
  final bool mqttConnected;
  final bool apiReachable;
  final bool whisperLoaded;
  final int uptimeSeconds;
  final int commandsProcessedToday;
  final int schedulerJobs;
  final String? lastCommand;
  final HubSystemStatus? hubSystemStatus;

  const BrainStatus({
    required this.parserLoaded,
    required this.mqttConnected,
    required this.apiReachable,
    required this.whisperLoaded,
    required this.uptimeSeconds,
    required this.commandsProcessedToday,
    required this.schedulerJobs,
    this.lastCommand,
    this.hubSystemStatus,
  });

  factory BrainStatus.fromJson(Map<String, dynamic> json) {
    HubSystemStatus? hubStatus;
    if (json['hub_system_status'] != null) {
      hubStatus = HubSystemStatus.fromJson(json['hub_system_status'] as Map<String, dynamic>);
    } else if (json['cpu_temp'] != null) {
      hubStatus = HubSystemStatus(
        cpuTemp: (json['cpu_temp'] as num?)?.toDouble() ?? 0,
        cpuPercent: (json['cpu_percent'] as num?)?.toDouble() ?? 0,
        memoryUsed: (json['memory_used'] as num?)?.toDouble() ?? 0,
        memoryTotal: (json['memory_total'] as num?)?.toDouble() ?? 0,
        diskUsed: (json['disk_used'] as num?)?.toDouble() ?? 0,
        diskTotal: (json['disk_total'] as num?)?.toDouble() ?? 0,
      );
    }
    
    final status = json['status'] as String?;
    
    return BrainStatus(
      parserLoaded: json['parser_loaded'] as bool? ?? (status == 'healthy'),
      mqttConnected: json['mqtt_connected'] as bool? ?? false,
      apiReachable: json['api_reachable'] as bool? ?? true,
      whisperLoaded: json['whisper_loaded'] as bool? ?? true,
      uptimeSeconds: json['uptime_seconds'] as int? ?? 0,
      commandsProcessedToday: json['commands_processed_today'] as int? ?? 0,
      schedulerJobs: json['scheduler_jobs'] as int? ?? 0,
      lastCommand: json['last_command'] as String?,
      hubSystemStatus: hubStatus,
    );
  }

  factory BrainStatus.offline() => const BrainStatus(
        parserLoaded: false,
        mqttConnected: false,
        apiReachable: false,
        whisperLoaded: false,
        uptimeSeconds: 0,
        commandsProcessedToday: 0,
        schedulerJobs: 0,
      );

  factory BrainStatus.demo() => const BrainStatus(
        parserLoaded: true,
        mqttConnected: true,
        apiReachable: true,
        whisperLoaded: true,
        uptimeSeconds: 16320,
        commandsProcessedToday: 12,
        schedulerJobs: 2,
        lastCommand: 'Turn on living room light',
        hubSystemStatus: HubSystemStatus(
          cpuTemp: 48.5,
          cpuPercent: 12.3,
          memoryUsed: 512,
          memoryTotal: 2048,
          diskUsed: 3.2,
          diskTotal: 32,
        ),
      );

  bool get isOnline => parserLoaded && whisperLoaded;

  String get uptimeFormatted {
    if (uptimeSeconds < 60) return '${uptimeSeconds}s';
    if (uptimeSeconds < 3600) return '${(uptimeSeconds / 60).floor()}m ${(uptimeSeconds % 60)}s';
    final hours = uptimeSeconds ~/ 3600;
    final minutes = (uptimeSeconds % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }

  int get lightsOn => 0;

  int get totalDevices => 0;

  double get todayEnergy => 0;

  BrainStatus copyWith({
    bool? parserLoaded,
    bool? mqttConnected,
    bool? apiReachable,
    bool? whisperLoaded,
    int? uptimeSeconds,
    int? commandsProcessedToday,
    int? schedulerJobs,
    String? lastCommand,
    HubSystemStatus? hubSystemStatus,
  }) =>
      BrainStatus(
        parserLoaded: parserLoaded ?? this.parserLoaded,
        mqttConnected: mqttConnected ?? this.mqttConnected,
        apiReachable: apiReachable ?? this.apiReachable,
        whisperLoaded: whisperLoaded ?? this.whisperLoaded,
        uptimeSeconds: uptimeSeconds ?? this.uptimeSeconds,
        commandsProcessedToday: commandsProcessedToday ?? this.commandsProcessedToday,
        schedulerJobs: schedulerJobs ?? this.schedulerJobs,
        lastCommand: lastCommand ?? this.lastCommand,
        hubSystemStatus: hubSystemStatus ?? this.hubSystemStatus,
      );
}

class HubSystemStatus {
  final double cpuTemp;
  final double cpuPercent;
  final double memoryUsed;
  final double memoryTotal;
  final double diskUsed;
  final double diskTotal;

  const HubSystemStatus({
    required this.cpuTemp,
    required this.cpuPercent,
    required this.memoryUsed,
    required this.memoryTotal,
    required this.diskUsed,
    required this.diskTotal,
  });

  factory HubSystemStatus.fromJson(Map<String, dynamic> json) => HubSystemStatus(
        cpuTemp: (json['cpu_temp'] as num?)?.toDouble() ?? 0,
        cpuPercent: (json['cpu_percent'] as num?)?.toDouble() ?? 0,
        memoryUsed: (json['memory_used'] as num?)?.toDouble() ?? 0,
        memoryTotal: (json['memory_total'] as num?)?.toDouble() ?? 0,
        diskUsed: (json['disk_used'] as num?)?.toDouble() ?? 0,
        diskTotal: (json['disk_total'] as num?)?.toDouble() ?? 0,
      );

  factory HubSystemStatus.demo() => const HubSystemStatus(
        cpuTemp: 48.5,
        cpuPercent: 12.3,
        memoryUsed: 512,
        memoryTotal: 2048,
        diskUsed: 3.2,
        diskTotal: 32,
      );

  double get memoryPercent => memoryTotal > 0 ? (memoryUsed / memoryTotal) * 100 : 0;
  double get diskPercent => diskTotal > 0 ? (diskUsed / diskTotal) * 100 : 0;
  String get memoryFormatted => '${memoryUsed.toStringAsFixed(0)}MB / ${memoryTotal.toStringAsFixed(0)}MB';
  String get diskFormatted => '${diskUsed.toStringAsFixed(1)}GB / ${diskTotal.toStringAsFixed(0)}GB';
}