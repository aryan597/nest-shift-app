import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/storage/secure_storage.dart';
import '../../models/insight.dart';

class InsightsNotifier extends AsyncNotifier<List<Insight>> {
  @override
  Future<List<Insight>> build() async {
    final isDemoMode = await SecureStorageService.instance.isDemoMode();
    if (isDemoMode) return demoInsights();
    return _fetchInsights();
  }

  Future<List<Insight>> _fetchInsights() async {
    final dio = await DioClient.instance.dio;
    final response = await dio.get(ApiEndpoints.aiInsights);
    final list = response.data as List<dynamic>;
    return list.map((e) => Insight.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchInsights);
  }

  Future<void> approve(String id) async {
    try {
      final isDemoMode = await SecureStorageService.instance.isDemoMode();
      if (!isDemoMode) {
        final dio = await DioClient.instance.dio;
        await dio.post(ApiEndpoints.aiAutomationApprove(id));
      }
      final current = state.value ?? [];
      final updated = current.map((i) {
        if (i.id == id) i.isResolved = true;
        return i;
      }).toList();
      state = AsyncData(updated);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fixNow(String id) async {
    try {
      final current = state.value ?? [];
      final insight = current.firstWhere((i) => i.id == id);
      if (insight.actionDeviceId != null) {
        final isDemoMode = await SecureStorageService.instance.isDemoMode();
        if (!isDemoMode) {
          final dio = await DioClient.instance.dio;
          await dio.post(ApiEndpoints.deviceToggle(insight.actionDeviceId!));
        }
      }
      final updated = current.map((i) {
        if (i.id == id) i.isResolved = true;
        return i;
      }).toList();
      state = AsyncData(updated);
    } catch (e) {
      rethrow;
    }
  }
}

final insightsProvider = AsyncNotifierProvider<InsightsNotifier, List<Insight>>(InsightsNotifier.new);
