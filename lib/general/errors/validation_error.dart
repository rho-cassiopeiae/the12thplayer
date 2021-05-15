import 'error.dart';

class ValidationError extends Error {
  ValidationError() : super('Invalid input data');
}
