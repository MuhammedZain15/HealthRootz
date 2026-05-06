import 'package:dio/dio.dart';

import 'api_constants.dart';
import 'token_storage.dart';

/// Singleton Dio HTTP client with automatic token injection and error handling.
class ApiClient {
  ApiClient._();

  static final ApiClient _instance = ApiClient._();
  static ApiClient get instance => _instance;

  late final Dio _dio;
  bool _initialized = false;

  Dio get dio => _dio;

  /// Must be called once before any API call (e.g. in main.dart).
  Future<void> init() async {
    if (_initialized) return;

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // ── Request interceptor: attach JWT token ──
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // You can add global error handling here (e.g. 401 → logout)
          return handler.next(error);
        },
      ),
    );

    // ── Logging (debug only) ──
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('🌐 $obj'),
      ),
    );

    _initialized = true;
  }
}
