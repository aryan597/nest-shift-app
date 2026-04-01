import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/websocket_service.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/storage/secure_storage.dart';
import '../../shared/models/device.dart';

// ─── Connection State ─────────────────────────────────────────────────────────

class ConnectionState {
  final WsConnectionState wsState;
  final DateTime? lastPing;
  final int? latencyMs;
  const ConnectionState({required this.wsState, this.lastPing, this.latencyMs});
  bool get isConnected => wsState == WsConnectionState.connected;
  ConnectionState copyWith({WsConnectionState? wsState, DateTime? lastPing, int? latencyMs}) =>
      ConnectionState(wsState: wsState ?? this.wsState, lastPing: lastPing ?? this.lastPing, latencyMs: latencyMs ?? this.latencyMs);
}

class ConnectionNotifier extends AsyncNotifier<ConnectionState> {
  StreamSubscription? _sub;

  @override
  Future<ConnectionState> build() async {
    final isDemoMode = await SecureStorageService.instance.isDemoMode();
    if (isDemoMode) {
      return const ConnectionState(wsState: WsConnectionState.connected);
    }
    _sub?.cancel();
    _sub = WebSocketService.instance.connectionStream.listen((wsState) {
      state = AsyncData(ConnectionState(wsState: wsState, lastPing: DateTime.now()));
    });
    ref.onDispose(() => _sub?.cancel());
    await WebSocketService.instance.connect();
    return ConnectionState(wsState: WebSocketService.instance.state);
  }
}

final connectionProvider = AsyncNotifierProvider<ConnectionNotifier, ConnectionState>(ConnectionNotifier.new);

// ─── Hub System Status Provider ───────────────────────────────────────────────

class HubSystemInfo {
  final String hubName;
  final String hubId;
  final String version;
  final int uptimeSeconds;
  final bool mqttConnected;
  final int deviceCount;
  final int onlineDeviceCount;
  final int activeAutomations;
  final int activeSchedules;
  final double memoryMb;
  final double cpuPercent;
  final double diskPercent;
  final DateTime? timestamp;

  const HubSystemInfo({
    required this.hubName,
    required this.hubId,
    required this.version,
    required this.uptimeSeconds,
    required this.mqttConnected,
    required this.deviceCount,
    required this.onlineDeviceCount,
    required this.activeAutomations,
    required this.activeSchedules,
    required this.memoryMb,
    required this.cpuPercent,
    required this.diskPercent,
    this.timestamp,
  });

  factory HubSystemInfo.fromJson(Map<String, dynamic> json) {
    return HubSystemInfo(
      hubName: json['hub_name'] as String? ?? 'NestShift Hub',
      hubId: json['hub_id'] as String? ?? '',
      version: json['version'] as String? ?? '1.0.0',
      uptimeSeconds: json['uptime_seconds'] as int? ?? 0,
      mqttConnected: json['mqtt_connected'] as bool? ?? false,
      deviceCount: json['device_count'] as int? ?? 0,
      onlineDeviceCount: json['online_device_count'] as int? ?? 0,
      activeAutomations: json['active_automations'] as int? ?? 0,
      activeSchedules: json['active_schedules'] as int? ?? 0,
      memoryMb: (json['memory_mb'] as num?)?.toDouble() ?? 0,
      cpuPercent: (json['cpu_percent'] as num?)?.toDouble() ?? 0,
      diskPercent: (json['disk_percent'] as num?)?.toDouble() ?? 0,
      timestamp: json['timestamp'] != null 
          ? DateTime.tryParse(json['timestamp'] as String)
          : null,
    );
  }

  factory HubSystemInfo.demo() => const HubSystemInfo(
        hubName: 'NestShift Hub',
        hubId: 'demo-hub-001',
        version: '1.0.0',
        uptimeSeconds: 16320,
        mqttConnected: true,
        deviceCount: 10,
        onlineDeviceCount: 8,
        activeAutomations: 5,
        activeSchedules: 3,
        memoryMb: 45.2,
        cpuPercent: 12.5,
        diskPercent: 32.1,
      );

  String get uptimeFormatted {
    if (uptimeSeconds < 60) return '${uptimeSeconds}s';
    if (uptimeSeconds < 3600) return '${(uptimeSeconds / 60).floor()}m ${uptimeSeconds % 60}s';
    final hours = uptimeSeconds ~/ 3600;
    final minutes = (uptimeSeconds % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }
}

class HubSystemStatusNotifier extends AsyncNotifier<HubSystemInfo> {
  Timer? _refreshTimer;

  @override
  Future<HubSystemInfo> build() async {
    final isDemoMode = await SecureStorageService.instance.isDemoMode();
    if (isDemoMode) return HubSystemInfo.demo();
    
    _startRefreshTimer();
    ref.onDispose(() => _refreshTimer?.cancel());
    
    return _fetchStatus();
  }

  Future<HubSystemInfo> _fetchStatus() async {
    try {
      final dio = await DioClient.instance.dio;
      final response = await dio.get(ApiEndpoints.systemStatus);
      return HubSystemInfo.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return HubSystemInfo.demo();
    }
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      final info = await _fetchStatus();
      state = AsyncData(info);
    });
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchStatus);
  }
}

final hubSystemStatusProvider = AsyncNotifierProvider<HubSystemStatusNotifier, HubSystemInfo>(HubSystemStatusNotifier.new);

// ─── Devices Provider ─────────────────────────────────────────────────────────

class DevicesNotifier extends AsyncNotifier<List<Device>> {
  StreamSubscription? _wsSub;

  @override
  Future<List<Device>> build() async {
    final isDemoMode = await SecureStorageService.instance.isDemoMode();
    if (isDemoMode) return demoDevices();

    _listenToWebSocket();
    ref.onDispose(() => _wsSub?.cancel());
    return _fetchDevices();
  }

  Future<List<Device>> _fetchDevices() async {
    final dio = await DioClient.instance.dio;
    final response = await dio.get(ApiEndpoints.devices);
    final list = response.data as List<dynamic>;
    return list.map((e) => Device.fromJson(e as Map<String, dynamic>)).toList();
  }

  void _listenToWebSocket() {
    _wsSub?.cancel();
    _wsSub = WebSocketService.instance.eventStream.listen((event) {
      final type = event['type'] as String?;
      if (type == 'device_update' || type == 'gpio_event') {
        final data = event['data'] as Map<String, dynamic>?;
        if (data != null) {
          if (type == 'gpio_event') HapticFeedback.lightImpact();
          _updateDevice(Device.fromJson(data));
        }
      }
    });
  }

  void _updateDevice(Device updated) {
    final current = state.value;
    if (current == null) return;
    final idx = current.indexWhere((d) => d.id == updated.id);
    if (idx >= 0) {
      final newList = List<Device>.from(current);
      newList[idx] = updated;
      state = AsyncData(newList);
    }
  }

  Future<void> optimisticToggle(String deviceId) async {
    final current = state.value;
    if (current == null) return;
    final idx = current.indexWhere((d) => d.id == deviceId);
    if (idx < 0) return;

    final device = current[idx];
    final newState = device.state.copyWith(on: !device.state.on);
    final optimistic = List<Device>.from(current);
    optimistic[idx] = device.copyWith(state: newState);
    state = AsyncData(optimistic);

    try {
      final dio = await DioClient.instance.dio;
      await dio.post(ApiEndpoints.deviceToggle(deviceId));
    } catch (_) {
      final reverted = List<Device>.from(state.value ?? []);
      if (idx < reverted.length) reverted[idx] = device;
      state = AsyncData(reverted);
      rethrow;
    }
  }

  Future<void> toggleRelay(int pin, {required bool newState}) async {
    final current = state.value;
    if (current == null) return;
    final idx = current.indexWhere((d) => d.gpioPin == pin);
    if (idx < 0) return;

    final device = current[idx];
    final optimistic = List<Device>.from(current);
    optimistic[idx] = device.copyWith(state: device.state.copyWith(on: newState));
    state = AsyncData(optimistic);

    try {
      final dio = await DioClient.instance.dio;
      await dio.post(ApiEndpoints.gpioRelaySet(pin), data: {'state': newState});
    } catch (_) {
      final reverted = List<Device>.from(state.value ?? []);
      if (idx < reverted.length) reverted[idx] = device;
      state = AsyncData(reverted);
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchDevices);
  }
}

final devicesProvider = AsyncNotifierProvider<DevicesNotifier, List<Device>>(DevicesNotifier.new);
