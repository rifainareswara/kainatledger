import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

/// Central Dio instance with JWT interceptor.
///
/// - Attaches `Authorization: Bearer <token>` to every request.
/// - On 401, tries once to refresh the access token.
/// - On second 401 (refresh invalid), clears tokens → caller should navigate to login.
class DioClient {
  DioClient._();
  static final DioClient instance = DioClient._();

  static String? currentAccessToken;
  static String? currentRefreshToken;

  static void setTokens(String? access, String? refresh) {
    currentAccessToken = access;
    currentRefreshToken = refresh;
  }

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  late final Dio _dio = _buildDio();

  Dio get dio => _dio;

  Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(milliseconds: connectTimeoutMs),
        receiveTimeout: const Duration(milliseconds: receiveTimeoutMs),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(_AuthInterceptor(_storage, dio));
    return dio;
  }

  Future<void> clearTokens() async {
    currentAccessToken = null;
    currentRefreshToken = null;
    try {
      await _storage.delete(key: kAccessToken);
      await _storage.delete(key: kRefreshToken);
    } catch (_) {}
  }
}

class _AuthInterceptor extends QueuedInterceptor {
  final FlutterSecureStorage _storage;
  final Dio _dio;

  _AuthInterceptor(this._storage, this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    String? token = DioClient.currentAccessToken;
    if (token == null) {
      try {
        token = await _storage.read(key: kAccessToken);
        DioClient.currentAccessToken = token;
      } catch (_) {}
    }
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        // Retry original request with new token
        final newToken = await _storage.read(key: kAccessToken);
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newToken';
        try {
          final response = await _dio.fetch(opts);
          handler.resolve(response);
          return;
        } on DioException catch (e) {
          handler.next(e);
          return;
        }
      } else {
        // Refresh also failed — clear tokens
        await DioClient.instance.clearTokens();
      }
    }
    handler.next(err);
  }

  Future<bool> _tryRefresh() async {
    String? refreshToken = DioClient.currentRefreshToken;
    if (refreshToken == null) {
      try {
        refreshToken = await _storage.read(key: kRefreshToken);
      } catch (_) {}
    }
    if (refreshToken == null) return false;

    try {
      // Use a plain Dio without interceptors to avoid infinite loop
      final plainDio = Dio(BaseOptions(baseUrl: baseUrl));
      final response = await plainDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final newAccess = response.data['access_token'] as String?;
      if (newAccess == null) return false;
      DioClient.setTokens(newAccess, refreshToken);
      try {
        await _storage.write(key: kAccessToken, value: newAccess);
      } catch (_) {}
      return true;
    } catch (_) {
      return false;
    }
  }
}
