class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AppException(this.message, {this.code, this.originalException});

  @override
  String toString() => message;
}

class AuthException extends AppException {
  AuthException(String message, {String? code, dynamic originalException})
      : super(message, code: code, originalException: originalException);
}

class NetworkException extends AppException {
  NetworkException(String message, {String? code, dynamic originalException})
      : super(message, code: code, originalException: originalException);
}

class ValidationException extends AppException {
  ValidationException(String message, {String? code, dynamic originalException})
      : super(message, code: code, originalException: originalException);
}

class StorageException extends AppException {
  StorageException(String message, {String? code, dynamic originalException})
      : super(message, code: code, originalException: originalException);
}

class AudioException extends AppException {
  AudioException(String message, {String? code, dynamic originalException})
      : super(message, code: code, originalException: originalException);
}

class AppointmentException extends AppException {
  AppointmentException(String message, {String? code, dynamic originalException})
      : super(message, code: code, originalException: originalException);
}