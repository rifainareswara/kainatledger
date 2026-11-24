abstract class AppFailure {
  final String message;
  const AppFailure(this.message);
}

class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class ServerFailure extends AppFailure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

class AuthFailure extends AppFailure {
  const AuthFailure([super.message = 'Authentication failed']);
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}

class CacheFailure extends AppFailure {
  const CacheFailure([super.message = 'Local storage error']);
}
