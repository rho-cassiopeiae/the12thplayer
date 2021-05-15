import 'error.dart';

class ApiError extends Error {
  ApiError()
      : super(
          'Something went wrong while trying to communicate with the server',
        );
}
