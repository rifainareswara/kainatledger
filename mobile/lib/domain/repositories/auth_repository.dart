import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<({String accessToken, String refreshToken})> login({
    required String email,
    required String password,
  });

  Future<UserEntity> register({
    required String email,
    required String fullName,
    required String password,
  });

  Future<String> refreshToken(String refreshToken);

  Future<void> logout(String refreshToken);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<({String? accessToken, String? refreshToken})> getStoredTokens();

  Future<void> clearTokens();

  bool get isLoggedIn;
}
