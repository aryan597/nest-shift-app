import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage.dart';
import 'api_endpoints.dart';

class DioClient {
  DioClient._();
  static final DioClient instance = DioClient._();

  late final Dio _dio;
  bool _initialized = false;

  Future<Dio> get dio async {
    if (!_initialized) await _init();
    return _dio;
  }

  Future<void> _init() async {
    final info = await SecureStorageService.instance.getConnectionInfo();
    final String baseUrl;
    if (info != null) {
      final (ip, port) = info;
      baseUrl = ApiEndpoints.baseUrl(ip, port);
    } else {
      baseUrl = 'http://nestshift.local:8000';
    }

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.addAll([
      _AuthInterceptor(),
      if (kDebugMode) LogInterceptor(requestBody: true, responseBody: true),
    ]);

    _initialized = true;
  }

  /// Re-initialise with new base URL (called after pairing)
  Future<void> reinitialize({required String ip, required int port}) async {
    _initialized = false;
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl(ip, port),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));
    _dio.interceptors.addAll([
      _AuthInterceptor(),
      if (kDebugMode) LogInterceptor(requestBody: true, responseBody: true),
    ]);
    _initialized = true;
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorageService.instance.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Signal unauthorized — consumer should navigate to /pairing
      debugPrint('[DioClient] 401 Unauthorized — token may be invalid');
    }
    handler.next(err);
  }
}

extension DioExceptionExtension on DioException {
  String get friendlyMessage {
    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Hub unreachable — check connection';
      case DioExceptionType.connectionError:
        return 'Cannot connect to hub';
      case DioExceptionType.badResponse:
        if (response?.statusCode == 401) return 'Session expired — please re-pair';
        if (response?.statusCode == 404) return 'Resource not found';
        return 'Server error (${response?.statusCode})';
      default:
        return 'Something went wrong';
    }
  }
}
