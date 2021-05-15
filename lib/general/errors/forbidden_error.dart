import 'error.dart';

class ForbiddenError extends Error {
  ForbiddenError()
      : super(
          'You do not have sufficient permissions to perform the requested action',
        );
}
