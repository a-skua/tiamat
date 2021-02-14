/// ErrorType.
enum ErrorType {
  label,
  opecode,
  operand,
}

/// Error.
class Error {
  final ErrorType type;
  final String detail;
  Error(this.detail, this.type);
}
