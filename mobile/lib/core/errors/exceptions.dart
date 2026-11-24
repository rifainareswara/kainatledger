class AppException implements Exception {
  final String message;
  final int? statusCode;
  const AppException(this.message, {this.statusCode});

  @override
  String toString() => 'AppException($statusCode): $message';
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized']) : super(statusCode: 401);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Not found']) : super(statusCode: 404);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Server error']) : super(statusCode: 500);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error']);
}
