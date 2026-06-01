import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];

  /// Returns a user-friendly message safe to display in the UI.
  String get userMessage {
    if (this is AuthFailure) return _mapAuthCode(message);
    if (this is NetworkFailure) return 'No internet connection. Please check your network and try again.';
    if (this is NotFoundFailure) return 'The requested item could not be found.';
    if (this is ServerFailure) return 'Something went wrong on our end. Please try again.';
    return 'An unexpected error occurred. Please try again.';
  }
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found.']);
}

// Maps Firebase Auth error codes / message fragments to clean UI copy.
String _mapAuthCode(String raw) {
  final r = raw.toLowerCase();
  if (r.contains('email-already-in-use')) {
    return 'An account with this email already exists. Try signing in instead.';
  }
  if (r.contains('wrong-password') ||
      r.contains('invalid-credential') ||
      r.contains('invalid-login-credentials')) {
    return 'Incorrect email or password. Please try again.';
  }
  if (r.contains('user-not-found')) {
    return 'No account found with this email address.';
  }
  if (r.contains('weak-password')) {
    return 'Password is too weak. Use at least 6 characters with a mix of letters and numbers.';
  }
  if (r.contains('too-many-requests')) {
    return 'Too many failed attempts. Please wait a few minutes and try again.';
  }
  if (r.contains('network-request-failed')) {
    return 'Network error. Please check your connection.';
  }
  if (r.contains('user-disabled')) {
    return 'This account has been disabled. Please contact support.';
  }
  if (r.contains('email') && r.contains('invalid')) {
    return 'The email address is not valid.';
  }
  if (r.contains('requires-recent-login')) {
    return 'Please sign out and sign in again before making this change.';
  }
  // Fallback: strip the Firebase error-code prefix bracket if present
  final bracketEnd = raw.indexOf(']');
  if (bracketEnd != -1 && bracketEnd < raw.length - 1) {
    return raw.substring(bracketEnd + 1).trim();
  }
  return raw;
}
