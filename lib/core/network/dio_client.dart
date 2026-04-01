import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage.dart';
import '../constants/app_constants.dart';
import 'api_endpoints.dart';

class DioClient {
  DioClient._();
  static final DioClient instance = DioClient._();

  Dio? _dio;
  String _currentBaseUrl = '';

  Future<Dio> get dio async {
    if (_dio == null) await _init();
    return _dio!;
  }

  Future<void> _init() async {
    final info = await SecureStorageService.instance.getConnectionInfo();
    final String baseUrl;
    if (info != null) {
      final (ip, port) = info;
      baseUrl = ApiEndpoints.baseUrl(ip, port);
      debugPrint('[DioClient] Using saved connection: $baseUrl');
    } else {
      baseUrl = AppConstants.defaultBaseUrl;
      debugPrint('[DioClient] Using default URL: $baseUrl');
    }
    _currentBaseUrl = baseUrl;

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 5),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio!.interceptors.addAll([
      _DebugInterceptor(),
      if (kDebugMode) LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint('[Dio] $obj'),
      ),
    ]);

    debugPrint('[DioClient] Init complete');
  }

  Future<void> reinitialize({required String ip, required int port}) async {
    final baseUrl = ApiEndpoints.baseUrl(ip, port);
    debugPrint('[DioClient] Reinitializing with: $baseUrl');
    
    if (_currentBaseUrl == baseUrl && _dio != null) {
      debugPrint('[DioClient] Same URL, no need to reinitialize');
      return;
    }

    _currentBaseUrl = baseUrl;
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 5),
      headers: {'Content-Type': 'application/json'},
    ));
    _dio!.interceptors.addAll([
      _DebugInterceptor(),
      if (kDebugMode) LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint('[Dio] $obj'),
      ),
    ]);
    debugPrint('[DioClient] Reinitialize complete');
  }
}

class BrainDioClient {
  BrainDioClient._();
  static final BrainDioClient instance = BrainDioClient._();

  Dio? _dio;
  String _currentBaseUrl = '';

  Future<Dio> get dio async {
    if (_dio == null) await _init();
    return _dio!;
  }

  Future<void> _init() async {
    final info = await SecureStorageService.instance.getConnectionInfo();
    final String baseUrl;
    if (info != null) {
      final (ip, _) = info;
      baseUrl = 'http://$ip:${AppConstants.brainPort}';
      debugPrint('[BrainDioClient] Using brain connection: $baseUrl');
    } else {
      baseUrl = 'http://${AppConstants.defaultLocalHost}:${AppConstants.brainPort}';
      debugPrint('[BrainDioClient] Using default brain URL: $baseUrl');
    }
    _currentBaseUrl = baseUrl;
    _createDio();
    debugPrint('[BrainDioClient] Init complete');
  }

  void _createDio() {
    final token = SecureStorageService.instance.getTokenSync();
    final headers = <String, dynamic>{
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      debugPrint('[BrainDioClient] Using auth token');
    } else {
      debugPrint('[BrainDioClient] No auth token (Brain API may not require auth)');
    }

    _dio = Dio(BaseOptions(
      baseUrl: _currentBaseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 5),
      headers: headers,
      validateStatus: (status) => status != null && status < 500,
    ));

    _dio!.interceptors.addAll([
      if (kDebugMode) LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint('[BrainDio] $obj'),
      ),
    ]);
  }

  Future<void> reinitialize({required String ip}) async {
    final baseUrl = 'http://$ip:${AppConstants.brainPort}';
    debugPrint('[BrainDioClient] Reinitializing with: $baseUrl');
    
    if (_currentBaseUrl == baseUrl && _dio != null) {
      debugPrint('[BrainDioClient] Same URL, no need to reinitialize');
      return;
    }

    _currentBaseUrl = baseUrl;
    _createDio();
    debugPrint('[BrainDioClient] Reinitialize complete');
  }

  Future<void> updateToken() async {
    if (_dio != null) {
      final token = SecureStorageService.instance.getTokenSync();
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      _dio!.options.headers.clear();
      _dio!.options.headers.addAll(headers);
      debugPrint('[BrainDioClient] Token updated');
    }
  }
}

class _DebugInterceptor extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    debugPrint('[DioClient] REQUEST: ${options.method} ${options.uri}');
    debugPrint('[DioClient] HEADERS: ${options.headers}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('[DioClient] RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
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