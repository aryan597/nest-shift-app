import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/storage/secure_storage.dart';
import '../../models/device.dart';

class HubNotifier extends AsyncNotifier<List<Device>> {
  @override
  Future<List<Device>> build() async {
    final isDemoMode = await SecureStorageService.instance.isDemoMode();
    if (isDemoMode) return demoDevices();
    final dio = await DioClient.instance.dio;
    final response = await dio.get(ApiEndpoints.devices);
    final list = response.data as List<dynamic>;
    return list.map((e) => Device.fromJson(e as Map<String, dynamic>)).toList();
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

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final dio = await DioClient.instance.dio;
      final response = await dio.get(ApiEndpoints.devices);
      final list = response.data as List<dynamic>;
      return list.map((e) => Device.fromJson(e as Map<String, dynamic>)).toList();
    });
  }
}

final hubProvider = AsyncNotifierProvider<HubNotifier, List<Device>>(HubNotifier.new);
