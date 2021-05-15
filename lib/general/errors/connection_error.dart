import 'error.dart';

class ConnectionError extends Error {
  ConnectionError()
      : super(
          'Error connecting to the server. Check your internet connection',
        );
}
