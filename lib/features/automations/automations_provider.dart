import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/storage/secure_storage.dart';
import '../../shared/models/automation.dart';

class AutomationsNotifier extends AsyncNotifier<List<Automation>> {
  final _uuid = const Uuid();

  @override
  Future<List<Automation>> build() async {
    final isDemoMode = await SecureStorageService.instance.isDemoMode();
    if (isDemoMode) return demoAutomations();

    try {
      final dio = await DioClient.instance.dio;
      final response = await dio.get(ApiEndpoints.automations).timeout(const Duration(seconds: 8));
      final list = response.data as List<dynamic>;
      return list.map((e) => Automation.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw 'Automations unavailable. Check hub connection.';
    }
  }

  // The _fetch method is removed as its logic is now directly in build().
  // The refresh method needs to be updated to reflect this change.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build); // Call build() directly to re-fetch
  }

  Future<void> toggle(String id) async {
    final current = state.value;
    if (current == null) return;
    final idx = current.indexWhere((a) => a.id == id);
    if (idx < 0) return;

    final automation = current[idx];
    final optimistic = List<Automation>.from(current);
    optimistic[idx] = automation.copyWith(enabled: !automation.enabled);
    state = AsyncData(optimistic);

    try {
      final isDemoMode = await SecureStorageService.instance.isDemoMode();
      if (!isDemoMode) {
        final dio = await DioClient.instance.dio;
        await dio.post(ApiEndpoints.automationToggle(id));
      }
    } catch (_) {
      final reverted = List<Automation>.from(state.value ?? []);
      if (idx < reverted.length) reverted[idx] = automation;
      state = AsyncData(reverted);
      rethrow;
    }
  }

  Future<void> create({
    required String name,
    required AutomationTrigger trigger,
    required AutomationAction action,
  }) async {
    final isDemoMode = await SecureStorageService.instance.isDemoMode();
    late Automation newAutomation;

    if (isDemoMode) {
      newAutomation = Automation(
        id: _uuid.v4(),
        name: name,
        trigger: trigger,
        action: action,
        enabled: false,
      );
    } else {
      final dio = await DioClient.instance.dio;
      final response = await dio.post(ApiEndpoints.automations, data: {
        'name': name,
        'trigger': trigger.toJson(),
        'action': action.toJson(),
      });
      newAutomation = Automation.fromJson(response.data as Map<String, dynamic>);
    }

    final current = state.value ?? [];
    state = AsyncData([...current, newAutomation]);
  }

  Future<void> delete(String id) async {
    final current = state.value ?? [];
    try {
      final isDemoMode = await SecureStorageService.instance.isDemoMode();
      if (!isDemoMode) {
        final dio = await DioClient.instance.dio;
        await dio.delete(ApiEndpoints.automationById(id));
      }
      state = AsyncData(current.where((a) => a.id != id).toList());
    } catch (_) {
      rethrow;
    }
  }
}

final automationsProvider = AsyncNotifierProvider<AutomationsNotifier, List<Automation>>(AutomationsNotifier.new);
