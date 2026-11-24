import 'package:dio/dio.dart';
import '../../models/user_model.dart';

class AuthRemoteDataSource {
  final Dio _dio;
  const AuthRemoteDataSource(this._dio);

  Future<TokenModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return TokenModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> register({
    required String email,
    required String fullName,
    required String password,
  }) async {
    final response = await _dio.post('/auth/register', data: {
      'email': email,
      'full_name': fullName,
      'password': password,
    });
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<String> refreshToken(String refreshToken) async {
    final response = await _dio.post('/auth/refresh', data: {
      'refresh_token': refreshToken,
    });
    return response.data['access_token'] as String;
  }

  Future<void> logout(String refreshToken) async {
    await _dio.post('/auth/logout', data: {'refresh_token': refreshToken});
  }
}
