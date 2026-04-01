import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/websocket_service.dart';
import '../../core/storage/secure_storage.dart';
import '../../shared/models/brain_status.dart';

class BrainStatusNotifier extends AsyncNotifier<BrainStatus> {
  Timer? _pollTimer;
  StreamSubscription? _wsSub;

  @override
  Future<BrainStatus> build() async {
    final isDemoMode = await SecureStorageService.instance.isDemoMode();
    if (isDemoMode) return BrainStatus.demo();

    _connectWebSocket();
    _startPolling();
    ref.onDispose(() {
      _pollTimer?.cancel();
      _wsSub?.cancel();
    });
    return _fetchStatus();
  }

  Future<void> _connectWebSocket() async {
    await BrainWebSocketService.instance.connect();
    _wsSub?.cancel();
    _wsSub = BrainWebSocketService.instance.eventStream.listen((event) {
      if (event['type'] == 'brain_status') {
        final data = event['data'] as Map<String, dynamic>?;
        if (data != null) state = AsyncData(BrainStatus.fromJson(data));
      }
    });
  }

  Future<BrainStatus> _fetchStatus() async {
    try {
      final dio = await BrainDioClient.instance.dio;
      final response = await dio.get(ApiEndpoints.brainStatus);
      return BrainStatus.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return BrainStatus.offline();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final status = await _fetchStatus();
      state = AsyncData(status);
    });
  }

  Future<void> refresh() async {
    final status = await _fetchStatus();
    state = AsyncData(status);
  }
}

final brainStatusProvider = AsyncNotifierProvider<BrainStatusNotifier, BrainStatus>(BrainStatusNotifier.new);