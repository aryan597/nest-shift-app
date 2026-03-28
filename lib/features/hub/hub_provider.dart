import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/storage/secure_storage.dart';
import '../../shared/models/device.dart';

class GpioPin {
  final int pin;
  final String? name;
  final String mode;
  final bool isRegistered;
  final bool? state;
  final String? deviceType;
  final String? room;

  GpioPin({
    required this.pin,
    this.name,
    required this.mode,
    required this.isRegistered,
    this.state,
    this.deviceType,
    this.room,
  });

  factory GpioPin.fromJson(Map<String, dynamic> json) {
    return GpioPin(
      pin: json['pin'] as int,
      name: json['name'] as String?,
      mode: json['mode'] as String? ?? 'none',
      isRegistered: json['is_registered'] as bool? ?? false,
      state: json['state'] as bool?,
      deviceType: json['device_type'] as String?,
      room: json['room'] as String?,
    );
  }

  GpioPin copyWith({
    int? pin,
    String? name,
    String? mode,
    bool? isRegistered,
    bool? state,
    String? deviceType,
    String? room,
  }) {
    return GpioPin(
      pin: pin ?? this.pin,
      name: name ?? this.name,
      mode: mode ?? this.mode,
      isRegistered: isRegistered ?? this.isRegistered,
      state: state ?? this.state,
      deviceType: deviceType ?? this.deviceType,
      room: room ?? this.room,
    );
  }
}

class HubNotifier extends AsyncNotifier<List<Device>> {
  @override
  Future<List<Device>> build() async {
    final isDemoMode = await SecureStorageService.instance.isDemoMode();
    if (isDemoMode) return demoDevices();
    
    try {
      final dio = await DioClient.instance.dio;
      final response = await dio.get(ApiEndpoints.devices).timeout(const Duration(seconds: 8));
      final list = response.data as List<dynamic>;
      return list.map((e) => Device.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw 'Hub unreachable. Check your connection in Settings.';
    }
  }

  Future<void> toggleRelay(int pin, {required bool newState}) async {
    final current = state.value;
    if (current == null) return;
    final idx = current.indexWhere((d) => d.gpioPin == pin);
    if (idx < 0) return;
    final device = current[idx];
    final newDeviceState = device.state.copyWith(on: newState);
    final optimistic = List<Device>.from(current);
    optimistic[idx] = device.copyWith(state: newDeviceState);
    state = AsyncData(optimistic);
    try {
      final isDemoMode = await SecureStorageService.instance.isDemoMode();
      if (!isDemoMode) {
        final dio = await DioClient.instance.dio;
        await dio.post(ApiEndpoints.gpioRelaySet(pin), data: {'state': newState});
      }
    } catch (_) {
      final reverted = List<Device>.from(state.value ?? []);
      if (idx < reverted.length) reverted[idx] = device;
      state = AsyncData(reverted);
      rethrow;
    }
  }

  Future<List<Device>> _fetch() async {
    final dio = await DioClient.instance.dio;
    final response = await dio.get(ApiEndpoints.devices).timeout(const Duration(seconds: 8));
    final list = response.data as List<dynamic>;
    return list.map((e) => Device.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final hubProvider = AsyncNotifierProvider<HubNotifier, List<Device>>(() => HubNotifier());

// GPIO Pins Provider
class GpioPinsNotifier extends AsyncNotifier<List<GpioPin>> {
  @override
  Future<List<GpioPin>> build() async {
    final isDemoMode = await SecureStorageService.instance.isDemoMode();
    if (isDemoMode) return demoGpioPins();
    
    try {
      final dio = await DioClient.instance.dio;
      final response = await dio.get(ApiEndpoints.gpioPins).timeout(const Duration(seconds: 8));
      final list = response.data as List<dynamic>;
      return list.map((e) => GpioPin.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw 'Failed to get GPIO pins';
    }
  }

  Future<void> togglePin(int pin, bool newState) async {
    final current = state.value;
    if (current == null) return;
    
    // Optimistic update
    final updatedPins = current.map((p) {
      if (p.pin == pin) {
        return p.copyWith(state: newState);
      }
      return p;
    }).toList();
    state = AsyncData(updatedPins);
    
    try {
      final isDemoMode = await SecureStorageService.instance.isDemoMode();
      if (!isDemoMode) {
        final dio = await DioClient.instance.dio;
        await dio.post(ApiEndpoints.gpioRelaySet(pin), data: {'state': newState});
      }
    } catch (_) {
      state = AsyncData(current);
      rethrow;
    }
  }

  Future<void> registerPin(int pin, String name, String deviceType, {String? room}) async {
    final isDemoMode = await SecureStorageService.instance.isDemoMode();
    
    if (isDemoMode) {
      // Update demo data locally
      final current = state.value ?? [];
      final updatedPins = current.map((p) {
        if (p.pin == pin) {
          return p.copyWith(
            isRegistered: true,
            name: name,
            deviceType: deviceType,
            room: room,
            state: deviceType == 'relay' ? false : null,
          );
        }
        return p;
      }).toList();
      state = AsyncData(updatedPins);
    } else {
      // Live mode - API call
      final dio = await DioClient.instance.dio;
      await dio.post(ApiEndpoints.devices, data: {
        'name': name,
        'device_type': deviceType,
        'protocol': 'gpio',
        'config': {'pin': pin},
        'room_id': room,
      });
      ref.invalidateSelf();
    }
  }

  Future<void> updatePinConfig(int pin, String name, String deviceType, {String? room}) async {
    final isDemoMode = await SecureStorageService.instance.isDemoMode();
    
    if (isDemoMode) {
      final current = state.value ?? [];
      final updatedPins = current.map((p) {
        if (p.pin == pin) {
          return p.copyWith(
            name: name,
            deviceType: deviceType,
            room: room,
          );
        }
        return p;
      }).toList();
      state = AsyncData(updatedPins);
    } else {
      // Live mode - need device ID to update
      final dio = await DioClient.instance.dio;
      // Find device by pin config
      final devices = await dio.get(ApiEndpoints.devices).timeout(const Duration(seconds: 8));
      final deviceList = devices.data as List<dynamic>;
      
      for (var d in deviceList) {
        final config = d['config'] as Map<String, dynamic>?;
        if (config?['pin'] == pin) {
          await dio.put('/devices/${d['id']}', data: {
            'name': name,
            'device_type': deviceType,
            'room_id': room,
          });
          break;
        }
      }
      ref.invalidateSelf();
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final isDemoMode = await SecureStorageService.instance.isDemoMode();
    if (isDemoMode) {
      state = AsyncData(demoGpioPins());
    } else {
      final dio = await DioClient.instance.dio;
      final response = await dio.get(ApiEndpoints.gpioPins).timeout(const Duration(seconds: 8));
      final list = response.data as List<dynamic>;
      state = AsyncData(list.map((e) => GpioPin.fromJson(e as Map<String, dynamic>)).toList());
    }
  }
}

final gpioPinsProvider = AsyncNotifierProvider<GpioPinsNotifier, List<GpioPin>>(() => GpioPinsNotifier());

// Demo data
List<GpioPin> demoGpioPins() {
  return [
    GpioPin(pin: 17, name: 'Living Room Light', mode: 'output', isRegistered: true, state: true, deviceType: 'relay', room: 'Living Room'),
    GpioPin(pin: 27, name: 'Bedroom Fan', mode: 'output', isRegistered: true, state: false, deviceType: 'relay', room: 'Bedroom'),
    GpioPin(pin: 22, name: 'Kitchen Light', mode: 'output', isRegistered: true, state: true, deviceType: 'relay', room: 'Kitchen'),
    GpioPin(pin: 4, name: 'Temperature Sensor', mode: 'input', isRegistered: true, state: null, deviceType: 'sensor', room: 'Living Room'),
    GpioPin(pin: 14, name: 'Motion Detector', mode: 'input', isRegistered: true, state: null, deviceType: 'sensor', room: 'Hallway'),
    GpioPin(pin: 5, name: null, mode: 'none', isRegistered: false, state: null, deviceType: null, room: null),
    GpioPin(pin: 6, name: null, mode: 'none', isRegistered: false, state: null, deviceType: null, room: null),
    GpioPin(pin: 13, name: null, mode: 'none', isRegistered: false, state: null, deviceType: null, room: null),
    GpioPin(pin: 19, name: null, mode: 'none', isRegistered: false, state: null, deviceType: null, room: null),
    GpioPin(pin: 26, name: null, mode: 'none', isRegistered: false, state: null, deviceType: null, room: null),
  ];
}

List<Device> demoDevices() {
  return [
    Device(
      id: '1',
      name: 'Living Room Light',
      type: 'relay',
      state: const DeviceState(on: true),
      room: 'Living Room',
      gpioPin: 17,
      protocol: 'gpio',
      online: true,
    ),
    Device(
      id: '2',
      name: 'Bedroom Fan',
      type: 'relay',
      state: const DeviceState(on: false),
      room: 'Bedroom',
      gpioPin: 27,
      protocol: 'gpio',
      online: true,
    ),
    Device(
      id: '3',
      name: 'Kitchen Light',
      type: 'relay',
      state: const DeviceState(on: true),
      room: 'Kitchen',
      gpioPin: 22,
      protocol: 'gpio',
      online: true,
    ),
    Device(
      id: '4',
      name: 'Temperature Sensor',
      type: 'sensor',
      state: const DeviceState(on: false),
      room: 'Living Room',
      gpioPin: 4,
      protocol: 'gpio',
      online: true,
    ),
    Device(
      id: '5',
      name: 'Motion Detector',
      type: 'sensor',
      state: const DeviceState(on: false),
      room: 'Hallway',
      gpioPin: 14,
      protocol: 'gpio',
      online: true,
    ),
  ];
}
