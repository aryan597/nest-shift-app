import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/websocket_service.dart';
import '../../core/storage/secure_storage.dart';
import '../../models/brain_status.dart';

class BrainStatusNotifier extends AsyncNotifier<BrainStatus> {
  Timer? _pollTimer;
  StreamSubscription? _wsSub;

  @override
  Future<BrainStatus> build() async {
    final isDemoMode = await SecureStorageService.instance.isDemoMode();
    if (isDemoMode) return BrainStatus.demo();

    _startPolling();
    _listenToWebSocket();
    ref.onDispose(() {
      _pollTimer?.cancel();
      _wsSub?.cancel();
    });
    return _fetchStatus();
  }

  Future<BrainStatus> _fetchStatus() async {
    try {
      final dio = await DioClient.instance.dio;
      final response = await dio.get(ApiEndpoints.brainStatus);
      return BrainStatus.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return BrainStatus.offline();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      final status = await _fetchStatus();
      state = AsyncData(status);
    });
  }

  void _listenToWebSocket() {
    _wsSub?.cancel();
    _wsSub = WebSocketService.instance.eventStream.listen((event) {
      if (event['type'] == 'brain_status') {
        final data = event['data'] as Map<String, dynamic>?;
        if (data != null) state = AsyncData(BrainStatus.fromJson(data));
      }
    });
  }

  Future<void> refresh() async {
    final status = await _fetchStatus();
    state = AsyncData(status);
  }
}

final brainStatusProvider = AsyncNotifierProvider<BrainStatusNotifier, BrainStatus>(BrainStatusNotifier.new);
