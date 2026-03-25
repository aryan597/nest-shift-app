import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.keyToken, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.keyToken);
  }

  Future<void> saveDeviceConnection(String ip, int port) async {
    await _storage.write(key: AppConstants.keyDeviceIp, value: ip);
    await _storage.write(key: AppConstants.keyDevicePort, value: port.toString());
  }

  Future<String?> getDeviceIp() async {
    return await _storage.read(key: AppConstants.keyDeviceIp);
  }

  Future<String?> getDevicePort() async {
    return await _storage.read(key: AppConstants.keyDevicePort);
  }

  Future<void> enableDemoMode(bool enable) async {
    await _storage.write(key: AppConstants.keyDemoMode, value: enable.toString());
  }

  Future<bool> isDemoModeEnabled() async {
    final res = await _storage.read(key: AppConstants.keyDemoMode);
    return res == 'true';
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
