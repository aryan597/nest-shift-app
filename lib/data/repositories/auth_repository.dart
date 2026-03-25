import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/secure_storage_service.dart';
import '../api/dio_client.dart';
import '../../core/constants/app_constants.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.read(dioProvider),
    ref.read(secureStorageProvider),
  );
});

class AuthRepository {
  final Dio _dio;
  final SecureStorageService _storage;

  AuthRepository(this._dio, this._storage);

  Future<bool> pairWithPin(String pin) async {
    // Dummy / Demo Mode Shortcut
    if (pin == AppConstants.dummyPinCode) {
      await _storage.enableDemoMode(true);
      await _storage.saveToken(AppConstants.dummyUserId);
      return true;
    }

    try {
      // Connect to default nestshift.local:8000
      _dio.options.baseUrl = AppConstants.defaultBaseUrl;
      final response = await _dio.post('/pair', data: {'pin': pin});
      
      if (response.statusCode == 200 && response.data['token'] != null) {
        await _storage.saveToken(response.data['token']);
        await _storage.enableDemoMode(false);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> pairWithQr(String ip, int port, String pin) async {
    try {
      final url = 'http://$ip:$port';
      _dio.options.baseUrl = url;

      final response = await _dio.post('/pair', data: {'pin': pin});
      if (response.statusCode == 200 && response.data['token'] != null) {
        await _storage.saveToken(response.data['token']);
        await _storage.saveDeviceConnection(ip, port);
        await _storage.enableDemoMode(false);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> enableDemoMode() async {
    await _storage.enableDemoMode(true);
    await _storage.saveToken(AppConstants.dummyUserId);
  }

  Future<bool> isAuthenticated() async {
    final token = await _storage.getToken();
    return token != null;
  }

  Future<void> logout() async {
    await _storage.clearAll();
  }
}
