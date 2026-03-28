import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/secure_storage.dart';

class SettingsState {
  final String? ip;
  final int port;
  final String? hubId;
  final String? token;
  final bool isDemoMode;
  const SettingsState({this.ip, required this.port, this.hubId, this.token, required this.isDemoMode});
}

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  @override
  Future<SettingsState> build() async {
    final ip = await SecureStorageService.instance.getIp();
    final port = await SecureStorageService.instance.getPort();
    final hubId = await SecureStorageService.instance.getHubId();
    final token = await SecureStorageService.instance.getToken();
    final isDemoMode = await SecureStorageService.instance.isDemoMode();
    return SettingsState(ip: ip, port: port, hubId: hubId, token: token, isDemoMode: isDemoMode);
  }

  Future<void> unpair() async {
    await SecureStorageService.instance.clearAll();
  }

  Future<bool> testConnection() async {
    try {
      final isDemoMode = await SecureStorageService.instance.isDemoMode();
      if (isDemoMode) return true;
      // Import here to avoid circular deps
      final ip = await SecureStorageService.instance.getIp();
      if (ip == null) return false;
      return true;
    } catch (_) {
      return false;
    }
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
