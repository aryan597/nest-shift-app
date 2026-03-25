import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService instance = SecureStorageService._();

  static const _tokenKey = 'nestshift_token';
  static const _hubIdKey = 'nestshift_hub_id';
  static const _ipKey = 'nestshift_ip';
  static const _portKey = 'nestshift_port';
  static const _demoModeKey = 'nestshift_demo_mode';

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  // Token
  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);
  Future<String?> getToken() => _storage.read(key: _tokenKey);
  Future<void> deleteToken() => _storage.delete(key: _tokenKey);

  // Hub ID
  Future<void> saveHubId(String hubId) => _storage.write(key: _hubIdKey, value: hubId);
  Future<String?> getHubId() => _storage.read(key: _hubIdKey);

  // Connection info
  Future<void> saveConnectionInfo({required String ip, required int port}) async {
    await _storage.write(key: _ipKey, value: ip);
    await _storage.write(key: _portKey, value: port.toString());
  }

  Future<String?> getIp() => _storage.read(key: _ipKey);
  Future<int> getPort() async {
    final val = await _storage.read(key: _portKey);
    return int.tryParse(val ?? '8000') ?? 8000;
  }

  Future<(String, int)?> getConnectionInfo() async {
    final ip = await getIp();
    if (ip == null) return null;
    final port = await getPort();
    return (ip, port);
  }

  // Demo mode
  Future<void> setDemoMode(bool value) => _storage.write(key: _demoModeKey, value: value.toString());
  Future<bool> isDemoMode() async {
    final val = await _storage.read(key: _demoModeKey);
    return val == 'true';
  }

  // Clear all
  Future<void> clearAll() => _storage.deleteAll();
}
