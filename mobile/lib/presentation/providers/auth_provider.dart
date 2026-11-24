import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import 'category_provider.dart';
import 'report_provider.dart';
import 'repository_providers.dart';
import 'transaction_provider.dart';
import 'wallet_provider.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthNotifier(this._repository, this._ref) : super(const AuthState()) {
    checkAuthStatus();
  }

  void _invalidateUserData() {
    _ref.invalidate(walletsProvider);
    _ref.invalidate(walletSummaryProvider);
    _ref.invalidate(recentTransactionsProvider);
    _ref.invalidate(transactionsProvider);
    _ref.invalidate(reportSummaryProvider);
    _ref.invalidate(monthlyReportProvider);
    _ref.invalidate(categoryReportProvider);
    _ref.invalidate(categoriesProvider);
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final tokens = await _repository.getStoredTokens();
      if (tokens.accessToken != null && tokens.refreshToken != null) {
        _invalidateUserData();
        state = state.copyWith(status: AuthStatus.authenticated, errorMessage: null);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: null);
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: e.toString());
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _repository.login(email: email, password: password);
      _invalidateUserData();
      state = state.copyWith(status: AuthStatus.authenticated, errorMessage: null);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _extractErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String fullName,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _repository.register(
        email: email,
        fullName: fullName,
        password: password,
      );
      // Auto login after register
      return await login(email: email, password: password);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _extractErrorMessage(e),
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final tokens = await _repository.getStoredTokens();
      if (tokens.refreshToken != null) {
        await _repository.logout(tokens.refreshToken!);
      }
    } catch (_) {
      await _repository.clearTokens();
    } finally {
      _invalidateUserData();
      state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: null);
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error is Exception) {
      final msg = error.toString();
      if (msg.contains('401')) return 'Email atau password salah';
      if (msg.contains('409') || msg.contains('already exists')) {
        return 'Email sudah terdaftar';
      }
      return msg.replaceFirst('Exception: ', '');
    }
    return 'Terjadi kesalahan sistem, silakan coba lagi';
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider), ref);
});
