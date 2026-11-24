import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  const AuthRepositoryImpl(this._remote, this._local);

  @override
  Future<({String accessToken, String refreshToken})> login({
    required String email,
    required String password,
  }) async {
    final model = await _remote.login(email: email, password: password);
    await _local.saveTokens(
      accessToken: model.accessToken,
      refreshToken: model.refreshToken,
    );
    return (accessToken: model.accessToken, refreshToken: model.refreshToken);
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String fullName,
    required String password,
  }) async {
    final model = await _remote.register(
      email: email,
      fullName: fullName,
      password: password,
    );
    return model.toEntity();
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    final newToken = await _remote.refreshToken(refreshToken);
    await _local.saveTokens(accessToken: newToken, refreshToken: refreshToken);
    return newToken;
  }

  @override
  Future<void> logout(String refreshToken) async {
    await _remote.logout(refreshToken);
    await _local.clearTokens();
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) =>
      _local.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

  @override
  Future<({String? accessToken, String? refreshToken})> getStoredTokens() async {
    final access = await _local.getAccessToken();
    final refresh = await _local.getRefreshToken();
    return (accessToken: access, refreshToken: refresh);
  }

  @override
  Future<void> clearTokens() => _local.clearTokens();

  @override
  bool get isLoggedIn => false; // checked async via getStoredTokens
}
