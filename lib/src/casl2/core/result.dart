import 'error.dart';

/// Result.
class Result<T> {
  final T value;
  final List<Error> errors;

  Result(this.value, this.errors);
}
