import 'error.dart';

class ServerError extends Error {
  ServerError() : super('Something went wrong on the server. Try again later');
}
