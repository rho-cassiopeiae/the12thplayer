import 'error.dart';

class InvalidAuthenticationTokenError extends Error {
  InvalidAuthenticationTokenError(String message) : super(message);
}
