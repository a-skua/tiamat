/// ErrorType.
enum ErrorType {
  syntax,
}

/// Error.
class Error {
  final ErrorType type;
  final String message;
  Error(this.message, this.type);
}
