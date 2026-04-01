import 'package:flutter/foundation.dart';
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
    debugPrint('[Automations] build() called');
    final isDemoMode = await SecureStorageService.instance.isDemoMode();
    if (isDemoMode) {
      debugPrint('[Automations] Demo mode - returning demo data');
      return demoAutomations();
    }

    try {
      final dio = await DioClient.instance.dio;
      debugPrint('[Automations] Fetching from API...');
      final response = await dio.get(ApiEndpoints.automations).timeout(const Duration(seconds: 8));
      debugPrint('[Automations] Got response: ${response.statusCode}');
      final list = response.data as List<dynamic>;
      debugPrint('[Automations] Parsed ${list.length} automations');
      return list.map((e) => Automation.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e, stack) {
      debugPrint('[Automations] Error: $e');
      debugPrint('[Automations] Stack: $stack');
      throw 'Automations unavailable. Check hub connection.';
    }
  }

  Future<List<Automation>> _fetch() async {
    debugPrint('[Automations] _fetch() called');
    final isDemoMode = await SecureStorageService.instance.isDemoMode();
    if (isDemoMode) {
      debugPrint('[Automations] Demo mode - returning demo data');
      return demoAutomations();
    }

    final dio = await DioClient.instance.dio;
    debugPrint('[Automations] Fetching from API...');
    final response = await dio.get(ApiEndpoints.automations).timeout(const Duration(seconds: 8));
    debugPrint('[Automations] Got response: ${response.statusCode}');
    final list = response.data as List<dynamic>;
    return list.map((e) => Automation.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> refresh() async {
    debugPrint('[Automations] refresh() called');
    state = const AsyncLoading();
    debugPrint('[Automations] State set to loading');
    final result = await AsyncValue.guard(_fetch);
    debugPrint('[Automations] Fetch result: ${result}');
    state = result;
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
    required List<AutomationAction> actions,
    String? description,
  }) async {
    final isDemoMode = await SecureStorageService.instance.isDemoMode();
    late Automation newAutomation;

    if (isDemoMode) {
      newAutomation = Automation(
        id: _uuid.v4(),
        name: name,
        description: description,
        trigger: trigger,
        actions: actions,
        enabled: false,
      );
    } else {
      final dio = await DioClient.instance.dio;
      final response = await dio.post(ApiEndpoints.automations, data: {
        'name': name,
        'description': description ?? '',
        'trigger_type': trigger.type,
        'trigger_config': trigger.config,
        'actions': actions.map((a) => a.toJson()).toList(),
        'enabled': false,
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
        await dio.delete(ApiEndpoints.automation(id));
      }
      state = AsyncData(current.where((a) => a.id != id).toList());
    } catch (_) {
      rethrow;
    }
  }
}

final automationsProvider = AsyncNotifierProvider<AutomationsNotifier, List<Automation>>(AutomationsNotifier.new);