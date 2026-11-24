import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';

class AuthLocalDataSource {
  final FlutterSecureStorage _storage;

  const AuthLocalDataSource(this._storage);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    DioClient.setTokens(accessToken, refreshToken);
    try {
      await Future.wait([
        _storage.write(key: kAccessToken, value: accessToken),
        _storage.write(key: kRefreshToken, value: refreshToken),
      ]);
    } catch (_) {}
  }

  Future<String?> getAccessToken() async {
    if (DioClient.currentAccessToken != null) {
      return DioClient.currentAccessToken;
    }
    try {
      final token = await _storage.read(key: kAccessToken);
      if (token != null) DioClient.currentAccessToken = token;
      return token;
    } catch (_) {
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    if (DioClient.currentRefreshToken != null) {
      return DioClient.currentRefreshToken;
    }
    try {
      final token = await _storage.read(key: kRefreshToken);
      if (token != null) DioClient.currentRefreshToken = token;
      return token;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearTokens() async {
    DioClient.instance.clearTokens();
    try {
      await Future.wait([
        _storage.delete(key: kAccessToken),
        _storage.delete(key: kRefreshToken),
      ]);
    } catch (_) {}
  }

  Future<bool> get hasAccessToken async {
    if (DioClient.currentAccessToken != null) return true;
    try {
      final token = await _storage.read(key: kAccessToken);
      return token != null;
    } catch (_) {
      return false;
    }
  }
}
