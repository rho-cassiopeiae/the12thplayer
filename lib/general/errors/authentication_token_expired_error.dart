import 'error.dart';

class AuthenticationTokenExpiredError extends Error {
  AuthenticationTokenExpiredError() : super('Authentication token expired');
}
