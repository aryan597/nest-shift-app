import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/secure_storage_service.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final storage = ref.read(secureStorageProvider);
      final token = await storage.getToken();
      
      // Override baseUrl if specified in storage
      final ip = await storage.getDeviceIp();
      final port = await storage.getDevicePort();
      if (ip != null && port != null) {
        options.baseUrl = 'http://$ip:$port';
      } else {
        options.baseUrl = AppConstants.defaultBaseUrl;
      }

      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
  ));

  return dio;
});
