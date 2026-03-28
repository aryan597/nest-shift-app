import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService instance = SecureStorageService._();

  static const _tokenKey = 'nestshift_token';
  static const _hubIdKey = 'nestshift_hub_id';
  static const _ipKey = 'nestshift_ip';
  static const _portKey = 'nestshift_port';
  static const _demoModeKey = 'nestshift_demo_mode';
  static const _onboardingCompleteKey = 'nestshift_onboarding_complete';

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) await init();
  }

  // Token
  Future<void> saveToken(String token) async {
    await _ensureInitialized();
    await _prefs.setString(_tokenKey, token);
  }
  
  Future<String?> getToken() async {
    await _ensureInitialized();
    return _prefs.getString(_tokenKey);
  }
  
  Future<void> deleteToken() async {
    await _ensureInitialized();
    await _prefs.remove(_tokenKey);
  }

  // Hub ID
  Future<void> saveHubId(String hubId) async {
    await _ensureInitialized();
    await _prefs.setString(_hubIdKey, hubId);
  }
  
  Future<String?> getHubId() async {
    await _ensureInitialized();
    return _prefs.getString(_hubIdKey);
  }

  // Connection info
  Future<void> saveConnectionInfo({required String ip, required int port}) async {
    await _ensureInitialized();
    await _prefs.setString(_ipKey, ip);
    await _prefs.setString(_portKey, port.toString());
  }

  Future<String?> getIp() async {
    await _ensureInitialized();
    return _prefs.getString(_ipKey);
  }
  
  Future<int> getPort() async {
    await _ensureInitialized();
    final val = _prefs.getString(_portKey);
    return int.tryParse(val ?? '8000') ?? 8000;
  }

  Future<(String, int)?> getConnectionInfo() async {
    final ip = await getIp();
    if (ip == null) return null;
    final port = await getPort();
    return (ip, port);
  }

  // Demo mode
  Future<void> setDemoMode(bool value) async {
    await _ensureInitialized();
    await _prefs.setString(_demoModeKey, value.toString());
  }
  
  Future<bool> isDemoMode() async {
    await _ensureInitialized();
    final val = _prefs.getString(_demoModeKey);
    return val == 'true';
  }

  // Onboarding
  Future<void> setOnboardingComplete(bool value) async {
    await _ensureInitialized();
    await _prefs.setString(_onboardingCompleteKey, value.toString());
  }
  
  Future<bool> isOnboardingComplete() async {
    await _ensureInitialized();
    final val = _prefs.getString(_onboardingCompleteKey);
    return val == 'true';
  }

  // Clear all
  Future<void> clearAll() async {
    await _ensureInitialized();
    await _prefs.clear();
  }
}
